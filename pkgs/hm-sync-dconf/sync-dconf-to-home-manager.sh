#!/usr/bin/env bash
set -euo pipefail

hm_dir="${HM_DIR:-/home/berry/.config/home-manager}"
target="${hm_dir}/gnome-dconf.nix"
backup_dir="${hm_dir}/backups"
assume_yes=false
list_only=false
cli_paths=()

labels=()
paths=()

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "缺少命令：$1" >&2
    exit 1
  fi
}

usage() {
  cat <<EOF
用法：
  $0
  $0 --list
  $0 -y org/gnome/desktop/interface org/gnome/mutter

不传路径时进入选单；传入路径时只同步指定路径。
EOF
}

normalize_path() {
  local raw="$1"
  raw="${raw#/}"
  raw="${raw%/}"
  printf '%s\n' "$raw"
}

dump_path() {
  local nix_path="$1"
  dconf dump "/${nix_path}/"
}

extension_uuid_to_path() {
  local uuid="$1"

  case "${uuid}" in
    blur-my-shell@aunetx)
      printf '%s\n' "org/gnome/shell/extensions/blur-my-shell"
      ;;
    dash-to-dock@micxgx.gmail.com)
      printf '%s\n' "org/gnome/shell/extensions/dash-to-dock"
      ;;
    just-perfection-desktop@just-perfection)
      printf '%s\n' "org/gnome/shell/extensions/just-perfection"
      ;;
    kimpanel@kde.org)
      printf '%s\n' "org/gnome/shell/extensions/kimpanel"
      ;;
    *)
      printf '%s\n' "org/gnome/shell/extensions/${uuid%%@*}"
      ;;
  esac
}

add_menu_item() {
  local label="$1"
  local path="$2"
  local existing

  for existing in "${paths[@]}"; do
    if [[ "${existing}" == "${path}" ]]; then
      return
    fi
  done

  labels+=("${label}")
  paths+=("${path}")
}

add_static_menu_items() {
  add_menu_item "GNOME 外观：interface" "org/gnome/desktop/interface"
  add_menu_item "GNOME Mutter：mutter" "org/gnome/mutter"
  add_menu_item "窗口偏好：wm/preferences" "org/gnome/desktop/wm/preferences"
  add_menu_item "触摸板：peripherals/touchpad" "org/gnome/desktop/peripherals/touchpad"
  add_menu_item "输入源：input-sources" "org/gnome/desktop/input-sources"
}

discover_extensions_from_gnome_extensions() {
  local uuid path

  if ! command -v gnome-extensions >/dev/null 2>&1; then
    return
  fi

  while IFS= read -r uuid; do
    [[ -z "${uuid}" ]] && continue
    path="$(extension_uuid_to_path "${uuid}")"
    add_menu_item "扩展：${uuid}" "${path}"
  done < <(gnome-extensions list 2>/dev/null || true)
}

discover_extensions_from_dconf() {
  local entry name

  while IFS= read -r entry; do
    [[ "${entry}" != */ ]] && continue
    name="${entry%/}"
    [[ -z "${name}" ]] && continue
    add_menu_item "扩展配置：${name}" "org/gnome/shell/extensions/${name}"
  done < <(dconf list /org/gnome/shell/extensions/ 2>/dev/null || true)
}

build_menu() {
  labels=()
  paths=()

  add_static_menu_items
  discover_extensions_from_gnome_extensions
  discover_extensions_from_dconf
  add_menu_item "自定义 dconf 路径" "__custom__"
}

print_menu() {
  echo "选择要从当前 dconf 同步到 Home Manager 的项目："
  local i
  for i in "${!labels[@]}"; do
    printf '  %d) %s\n' "$((i + 1))" "${labels[$i]}"
  done
  echo
  echo "可输入单个编号，或用逗号/空格选择多个，例如：1,2,6"
}

select_paths() {
  local answer item index selected=()

  print_menu >&2
  read -r -p "同步哪些项目？ " answer </dev/tty
  answer="${answer//,/ }"

  for item in ${answer}; do
    if [[ ! "${item}" =~ ^[0-9]+$ ]]; then
      echo "无效编号：${item}" >&2
      exit 1
    fi

    index=$((item - 1))
    if (( index < 0 || index >= ${#paths[@]} )); then
      echo "编号超出范围：${item}" >&2
      exit 1
    fi

    if [[ "${paths[$index]}" == "__custom__" ]]; then
      local custom
      read -r -p "输入 dconf 路径，例如 org/gnome/shell/extensions/dash-to-dock： " custom </dev/tty
      custom="$(normalize_path "${custom}")"
      if [[ -z "${custom}" ]]; then
        echo "自定义路径不能为空" >&2
        exit 1
      fi
      selected+=("${custom}")
    else
      selected+=("${paths[$index]}")
    fi
  done

  if (( ${#selected[@]} == 0 )); then
    echo "未选择任何项目" >&2
    exit 1
  fi

  printf '%s\n' "${selected[@]}"
}

confirm_paths() {
  if [[ "${assume_yes}" == true ]]; then
    return
  fi

  echo "将同步以下 dconf 路径："
  printf '  - %s\n' "$@"
  echo
  read -r -p "确认覆盖 gnome-dconf.nix 中的同名项目？[y/N] " answer </dev/tty
  case "${answer}" in
    y|Y|yes|YES) ;;
    *) echo "已取消"; exit 0 ;;
  esac
}

need_cmd dconf
need_cmd perl
need_cmd nix

build_menu

while (( $# > 0 )); do
  case "$1" in
    -y|--yes)
      assume_yes=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --list)
      list_only=true
      shift
      ;;
    *)
      cli_paths+=("$(normalize_path "$1")")
      shift
      ;;
  esac
done

if [[ "${list_only}" == true ]]; then
  print_menu
  exit 0
fi

if [[ ! -f "${target}" ]]; then
  echo "找不到目标文件：${target}" >&2
  exit 1
fi

mkdir -p "${backup_dir}"

if (( ${#cli_paths[@]} > 0 )); then
  selected_paths=("${cli_paths[@]}")
else
  mapfile -t selected_paths < <(select_paths)
fi
confirm_paths "${selected_paths[@]}"

timestamp="$(date +%Y%m%d-%H%M%S-%N)"
backup="${backup_dir}/gnome-dconf.nix.${timestamp}"
blocks="$(mktemp /tmp/hm-dconf-blocks.XXXXXX)"
dump_file="$(mktemp /tmp/hm-dconf-dump.XXXXXX)"
failed="${backup_dir}/gnome-dconf.nix.failed-${timestamp}"
trap 'rm -f "${blocks}" "${dump_file}"' EXIT

cp -a "${target}" "${backup}"
echo "已备份：${backup}"

for path in "${selected_paths[@]}"; do
  dump_path "${path}" > "${dump_file}"
  if [[ ! -s "${dump_file}" ]]; then
    echo "跳过 ${path}：当前 dconf 没有可导出的值"
    continue
  fi

  perl - "${path}" "${dump_file}" <<'PERL' >> "${blocks}"
use strict;
use warnings;

my $base = shift @ARGV;
my $dump_file = shift @ARGV;
open my $dfh, "<", $dump_file or die "无法读取 dconf dump $dump_file: $!";
my $dump = do { local $/; <$dfh> };
close $dfh;
my %sections;
my $section = "";

sub nix_string {
  my ($s) = @_;
  $s =~ s/\\'/'/g;
  $s =~ s/\\\\/\\/g;
  $s =~ s/\\/\\\\/g;
  $s =~ s/"/\\"/g;
  return qq{"$s"};
}

sub remove_commas_outside_strings {
  my ($value) = @_;
  my $out = "";
  my $in = 0;
  my $escape = 0;
  for my $char (split //, $value) {
    if ($in) {
      $out .= $char;
      if ($escape) {
        $escape = 0;
      } elsif ($char eq "\\") {
        $escape = 1;
      } elsif ($char eq '"') {
        $in = 0;
      }
      next;
    }
    if ($char eq '"') {
      $in = 1;
      $out .= $char;
    } elsif ($char ne ",") {
      $out .= $char;
    }
  }
  return $out;
}

sub convert_value {
  my ($value) = @_;
  $value =~ s/^\s+|\s+$//g;
  $value =~ s/^\@[A-Za-z0-9]+ //;
  $value =~ s/'((?:\\.|[^'\\])*)'/nix_string($1)/ge;
  $value = remove_commas_outside_strings($value);
  return $value;
}

for my $line (split /\n/, $dump) {
  next if $line =~ /^\s*$/;
  if ($line =~ /^\[(.*)\]$/) {
    $section = $1 eq "/" ? "" : $1;
    next;
  }
  next unless $line =~ /^([^=]+)=(.*)$/;
  my ($key, $value) = ($1, $2);
  $key =~ s/^\s+|\s+$//g;
  push @{ $sections{$section} }, [$key, convert_value($value)];
}

for my $section (sort keys %sections) {
  my $path = $base;
  $path .= "/$section" if $section ne "";

  print "###PATH:$path\n";
  print qq|    "$path" = {\n|;
  for my $entry (@{ $sections{$section} }) {
    my ($key, $value) = @$entry;
    print qq|      $key = $value;\n|;
  }
  print qq|    };\n\n|;
}
PERL
done

if [[ ! -s "${blocks}" ]]; then
  echo "没有生成任何可写入的 dconf 项，目标文件未修改"
  exit 0
fi

perl - "${target}" "${blocks}" <<'PERL'
use strict;
use warnings;

my ($target, $blocks_file) = @ARGV;

open my $bfh, "<", $blocks_file or die "无法读取块文件 $blocks_file: $!";
my @records;
my ($path, @lines);
while (my $line = <$bfh>) {
  if ($line =~ /^###PATH:(.*)$/) {
    push @records, [$path, join("", @lines)] if defined $path;
    $path = $1;
    @lines = ();
  } else {
    push @lines, $line;
  }
}
push @records, [$path, join("", @lines)] if defined $path;
close $bfh;

open my $tfh, "<", $target or die "无法读取 $target: $!";
my @file = <$tfh>;
close $tfh;

sub brace_delta {
  my ($line) = @_;
  my $delta = 0;
  my $in = 0;
  my $escape = 0;
  for my $char (split //, $line) {
    if ($in) {
      if ($escape) {
        $escape = 0;
      } elsif ($char eq "\\") {
        $escape = 1;
      } elsif ($char eq '"') {
        $in = 0;
      }
      next;
    }
    if ($char eq '"') {
      $in = 1;
    } elsif ($char eq "{") {
      $delta++;
    } elsif ($char eq "}") {
      $delta--;
    }
  }
  return $delta;
}

sub replace_or_insert {
  my ($path, $block) = @_;
  return if $block =~ /^\s*$/;

  my $start;
  for my $i (0 .. $#file) {
    if ($file[$i] =~ /^    "\Q$path\E" = \{\s*$/) {
      $start = $i;
      last;
    }
  }

  if (!defined $start) {
    for my $line (@file) {
      die "路径 $path 已存在，但不是脚本支持的标准 attrset 写法，已停止覆盖。\n"
        if $line =~ /"\Q$path\E"\s*=/;
    }

    for (my $i = $#file; $i >= 0; $i--) {
      if ($file[$i] =~ /^  \};\s*$/) {
        splice @file, $i, 0, split /(?=^)/m, $block;
        return;
      }
    }
    die "找不到 dconf.settings 的结束位置，已停止写入。\n";
  }

  my $depth = 0;
  my $end;
  for my $i ($start .. $#file) {
    $depth += brace_delta($file[$i]);
    if ($i > $start && $depth == 0 && $file[$i] =~ /^\s*\};\s*$/) {
      $end = $i;
      last;
    }
  }

  die "无法识别路径 $path 的结束位置，已停止覆盖。\n" unless defined $end;
  splice @file, $start, $end - $start + 1, split /(?=^)/m, $block;
}

for my $record (@records) {
  my ($path, $block) = @$record;
  replace_or_insert($path, $block);
}

open my $out, ">", $target or die "无法写入 $target: $!";
print {$out} @file;
close $out;
PERL

if command -v nixfmt >/dev/null 2>&1; then
  nixfmt "${target}"
elif command -v alejandra >/dev/null 2>&1; then
  alejandra -q "${target}"
fi

echo "验证 Home Manager flake"
if nix flake check "path:${hm_dir}" --no-build; then
  echo "同步完成：${target}"
else
  cp -a "${target}" "${failed}"
  cp -a "${backup}" "${target}"
  echo "验证失败，已恢复备份：${backup}" >&2
  echo "失败版本保存在：${failed}" >&2
  exit 1
fi
