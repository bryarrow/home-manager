# 用 Home Manager 把任意桌面应用注册为指定 MIME 的默认程序。
#
# 加一个应用只需要在 registrations 里写一段：
#   { app = "mpv.desktop"; default = groups.video; }
# 同一个 MIME 被多个应用声明时，registrations 里靠前的条目获胜。
# 类型名必须是 shared-mime-info 的规范名（可用 `xdg-mime query filetype 文件` 查）。
{ lib, ... }:

let
  # 常用 MIME 分组。分组只是预设，某个应用要更窄的范围时直接写字面量即可。
  groups = {
    # 网页与 http(s) 链接。
    web = [
      "text/html"
      "application/xhtml+xml"
      "application/x-extension-htm"
      "application/x-extension-html"
      "application/x-extension-shtml"
      "application/x-extension-xht"
      "application/x-extension-xhtml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];

    # 纯文本与文档类。
    text = [
      "text/plain"
      "text/markdown"
      "text/csv"
      "text/tab-separated-values"
      "text/org"
      "text/x-bibtex"
      "text/x-gettext-translation"
      "text/x-gettext-translation-template"
      "text/x-log"
      "text/x-patch"
      "text/x-rst"
      "text/x-tex"
    ];

    # 源码、配置与构建脚本。
    code = [
      "text/css"
      "text/javascript"
      "text/julia"
      "text/rust"
      "text/tcl"
      "text/vbscript"
      "text/x-awk"
      "text/x-c++hdr"
      "text/x-c++src"
      "text/x-chdr"
      "text/x-cmake"
      "text/x-common-lisp"
      "text/x-csharp"
      "text/x-csh"
      "text/x-csrc"
      "text/x-cython"
      "text/x-dockerfile"
      "text/x-elixir"
      "text/x-emacs-lisp"
      "text/x-erlang"
      "text/x-fortran"
      "text/x-go"
      "text/x-gradle"
      "text/x-gradle-kts"
      "text/x-groovy"
      "text/x-haskell"
      "text/x-java"
      "text/x-kotlin"
      "text/x-lua"
      "text/x-makefile"
      "text/x-matlab"
      "text/x-meson"
      "text/x-nim"
      "text/x-nix"
      "text/x-objcsrc"
      "text/x-ocaml"
      "text/x-pascal"
      "text/x-python"
      "text/x-python3"
      "text/x-scala"
      "text/x-scheme"
      "text/x-scons"
      "text/x-sed"
      "text/x-shellscript"
      "text/x-systemd-unit"
      "text/x-vb"
      "text/x-verilog"
      "text/x-vhdl"
      "application/json"
      "application/json5"
      "application/sql"
      "application/toml"
      "application/typescript"
      "application/x-code-workspace"
      "application/x-fishscript"
      "application/x-perl"
      "application/x-php"
      "application/x-ruby"
      "application/xml"
      "application/yaml"
    ];

    image = [
      "image/png"
      "image/jpeg"
      "image/gif"
      "image/webp"
      "image/svg+xml"
      "image/bmp"
      "image/tiff"
      "image/avif"
      "image/heif"
      "image/jxl"
      "image/vnd.adobe.photoshop"
      "image/vnd.microsoft.icon"
      "image/x-xcf"
    ];

    video = [
      "video/mp4"
      "video/matroska"
      "video/matroska-3d"
      "video/mp2t"
      "video/mpeg"
      "video/ogg"
      "video/quicktime"
      "video/vnd.avi"
      "video/webm"
      "video/x-flv"
      "video/x-ms-wmv"
    ];

    audio = [
      "audio/aac"
      "audio/flac"
      "audio/matroska"
      "audio/mp4"
      "audio/mpeg"
      "audio/ogg"
      "audio/vnd.wave"
      "audio/x-flac+ogg"
      "audio/x-opus+ogg"
      "audio/x-vorbis+ogg"
      "audio/x-wavpack"
      "audio/x-ms-wma"
    ];

    pdf = [ "application/pdf" ];

    archive = [
      "application/gzip"
      "application/vnd.rar"
      "application/x-7z-compressed"
      "application/x-bzip2"
      "application/x-tar"
      "application/x-xz"
      "application/zip"
      "application/zstd"
    ];
  };

  # 默认程序注册表。
  #   app     = 桌面文件名（如 code.desktop，不是可执行文件路径）
  #   default = 设为默认的 MIME
  #   added   = 只登记进「打开方式」、不设为默认的 MIME（可选）
  # default 里的类型会自动出现在「打开方式」列表中，无需重复写进 added。
  registrations = [
    # 浏览器：网页和 http(s) 链接；chrome:// 链接。
    {
      app = "firefox.desktop";
      default = groups.web ++ [ "x-scheme-handler/chrome" ];
    }

    # 编辑器：文本、源码，以及 VS Code 自己声明的 workspace 类型。
    # 不接管 inode/directory，文件夹仍由文件管理器打开。
    {
      app = "code.desktop";
      default = groups.text ++ groups.code;
      added = [ "application/octet-stream" ];
    }

    # vscode:// 链接由专门的 URL handler 处理。
    {
      app = "code-url-handler.desktop";
      default = [ "x-scheme-handler/vscode" ];
    }

    # 即时通讯：AyuGram 已卸载，tg/tonsite 交给 Telegram Desktop。
    {
      app = "org.telegram.desktop.desktop";
      default = [
        "x-scheme-handler/ton"
        "x-scheme-handler/tg"
        "x-scheme-handler/tonsite"
      ];
    }

    # 代理客户端。
    {
      app = "clash-verge.desktop";
      default = [
        "x-scheme-handler/clash"
        "x-scheme-handler/clash-verge"
      ];
    }
  ];

  # ---------- 以下是通用逻辑，新增应用时不需要改 ----------

  # [Default Applications]：靠前的注册条目优先。
  defaultApplications = lib.foldl' (
    acc: entry: lib.genAttrs (entry.default or [ ]) (_: [ entry.app ]) // acc
  ) { } registrations;

  # 所有被任何条目提到过的 MIME。
  allMimes = lib.unique (
    lib.concatMap (entry: (entry.default or [ ]) ++ (entry.added or [ ])) registrations
  );

  # [Added Associations]：每个 MIME 下登记所有声明过它的应用，按注册表顺序。
  associations = lib.genAttrs allMimes (
    mime:
    lib.unique (
      lib.concatMap (
        entry:
        lib.optional
          (builtins.elem mime ((entry.default or [ ]) ++ (entry.added or [ ])))
          entry.app
      ) registrations
    )
  );
in
{
  xdg.mimeApps = {
    enable = true;

    # 启用后 ~/.config/mimeapps.list 由 Home Manager 只读托管，
    # 在 GNOME「设置 → 默认应用程序」里修改不会持久，请改上面的注册表再 switch。
    inherit defaultApplications;
    associations.added = associations;
  };
}
