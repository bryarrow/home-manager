#!/usr/bin/env bash
set -euo pipefail

hm_dir="${HM_DIR:-/home/berry/.config/home-manager}"
packages_file="${hm_dir}/packages.nix"
backup_dir="${hm_dir}/backups"

usage() {
  cat <<EOF
用法：
  hm-apps list
  hm-apps add nixpkgs#codex
  hm-apps add codex
  hm-apps remove codex

说明：
  add 接受 nixpkgs#属性名 或直接属性名，并写入 packages.nix 的 home.packages 列表。
EOF
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "缺少命令：$1" >&2
    exit 1
  fi
}

normalize_pkg() {
  local spec="$1"

  case "${spec}" in
    nixpkgs#*)
      spec="${spec#nixpkgs#}"
      ;;
    legacyPackages.*)
      spec="${spec#legacyPackages.}"
      spec="${spec#*.}"
      ;;
    pkgs.*)
      spec="${spec#pkgs.}"
      ;;
  esac

  if [[ ! "${spec}" =~ ^[A-Za-z0-9_][A-Za-z0-9_+.-]*(\.[A-Za-z0-9_][A-Za-z0-9_+.-]*)*$ ]]; then
    echo "不支持的软件包属性名：${spec}" >&2
    exit 1
  fi

  printf '%s\n' "${spec}"
}

backup_file() {
  local timestamp backup
  timestamp="$(date +%Y%m%d-%H%M%S-%N)"
  backup="${backup_dir}/packages.nix.${timestamp}"
  mkdir -p "${backup_dir}"
  cp -a "${packages_file}" "${backup}"
  printf '%s\n' "${backup}"
}

validate_home_manager() {
  echo "验证 Home Manager flake"
  nix flake check "path:${hm_dir}" --no-build
}

list_packages() {
  perl -0ne '
    if (/home\.packages\s*=\s*with\s+pkgs;\s*\[(.*?)\];/s) {
      my $body = $1;
      $body =~ s/#.*$//mg;
      while ($body =~ /([A-Za-z0-9_][A-Za-z0-9_+.-]*(?:\.[A-Za-z0-9_][A-Za-z0-9_+.-]*)*)/g) {
        print "$1\n";
      }
    } else {
      die "找不到标准的 home.packages = with pkgs; [ ... ]; 块\n";
    }
  ' "${packages_file}"
}

rewrite_packages() {
  local action="$1"
  local package="$2"

  perl - "${packages_file}" "${action}" "${package}" <<'PERL'
use strict;
use warnings;

my ($file, $action, $package) = @ARGV;
my $content = do {
  open my $fh, "<", $file or die "无法读取 $file: $!";
  local $/;
  <$fh>;
};

my $changed = 0;

$content =~ s{
  (home\.packages\s*=\s*with\s+pkgs;\s*\[\n)
  (.*?)
  (\s*\];)
}{
  my ($head, $body, $tail) = ($1, $2, $3);
  my @items;
  my %seen;

  for my $line (split /\n/, $body) {
    if ($line =~ /^\s*([A-Za-z0-9_][A-Za-z0-9_+.-]*(?:\.[A-Za-z0-9_][A-Za-z0-9_+.-]*)*)\s*(?:#.*)?$/) {
      my $item = $1;
      next if $seen{$item}++;
      push @items, $item;
    }
  }

  if ($action eq "add") {
    if (!$seen{$package}) {
      push @items, $package;
      $changed = 1;
    }
  } elsif ($action eq "remove") {
    my @next = grep { $_ ne $package } @items;
    $changed = @next != @items ? 1 : 0;
    @items = @next;
  } else {
    die "未知操作：$action\n";
  }

  my $new_body = "";
  $new_body .= "    $_\n" for sort @items;
  "$head$new_body$tail";
}xes or die "找不到标准的 home.packages = with pkgs; [ ... ]; 块\n";

open my $out, ">", $file or die "无法写入 $file: $!";
print {$out} $content;
close $out;

exit($changed ? 0 : 10);
PERL
}

need_cmd nix
need_cmd perl

if [[ $# -lt 1 ]]; then
  usage
  exit 1
fi

if [[ ! -f "${packages_file}" ]]; then
  echo "找不到 packages.nix：${packages_file}" >&2
  exit 1
fi

cmd="$1"
shift

case "${cmd}" in
  list)
    list_packages
    ;;
  add|remove)
    if [[ $# -ne 1 ]]; then
      usage
      exit 1
    fi

    package="$(normalize_pkg "$1")"
    backup="$(backup_file)"

    if rewrite_packages "${cmd}" "${package}"; then
      :
    else
      status="$?"
      if [[ "${status}" == "10" ]]; then
        rm -f "${backup}"
        if [[ "${cmd}" == "add" ]]; then
          echo "${package} 已在 packages.nix 中"
        else
          echo "${package} 不在 packages.nix 中"
        fi
        exit 0
      fi
      cp -a "${backup}" "${packages_file}"
      exit "${status}"
    fi

    if [[ "${cmd}" == "add" ]]; then
      action_label="添加"
    else
      action_label="移除"
    fi

    if validate_home_manager; then
      echo "已${action_label}：${package}"
      echo "备份：${backup}"
    else
      failed="${backup_dir}/packages.nix.failed-$(date +%Y%m%d-%H%M%S-%N)"
      cp -a "${packages_file}" "${failed}"
      cp -a "${backup}" "${packages_file}"
      echo "验证失败，已恢复：${backup}" >&2
      echo "失败版本：${failed}" >&2
      exit 1
    fi
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "未知命令：${cmd}" >&2
    usage
    exit 1
    ;;
esac
