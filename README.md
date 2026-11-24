# Berry 的 Home Manager 配置

这个目录只管理 berry 用户环境，不由 `/etc/nixos` 导入。

- `home.nix`：用户入口和通用 Home Manager 设置。
- `gnome-dconf.nix`：GNOME 和扩展的 dconf 声明。
- `packages.nix`：用户级软件包。
- `rime.nix`：把 `config/ibus_rime.custom.yaml` 部署为 ibus-rime 的外观补丁（预编辑内嵌、显示拼音编码）。
- `mimeapps.nix`：MIME 默认程序注册表，不绑定某个应用。用 `groups`（web/text/code/image/video/audio/pdf/archive）
  挑类型，用 `registrations` 声明「哪个应用接管哪些类型」：
  `{ app = "mpv.desktop"; default = groups.video; }`。
  同一类型被多个应用声明时靠前的条目优先；`default` 会自动进「打开方式」，`added` 只登记不设默认。
  改完 switch 即可，`~/.config/mimeapps.list` 由 Home Manager 只读托管（GNOME 设置里改默认程序不会持久）。
  查文件类型用 `xdg-mime query filetype 文件`，查某类型的默认与候选应用用 `gio mime 类型`。
- `pkgs/hm-apps`：包装 `hm-apps` 命令，用来维护 `packages.nix` 中的用户软件。
- `pkgs/hm-sync-dconf`：把 dconf 同步工具包装成用户包，安装后命令为 `hm-sync-dconf`。

应用配置：

```bash
home-manager switch --impure --flake path:/home/berry/.config/home-manager#berry
```

`--impure` 是必需的：`fonts.nix` 和 `flake.nix` 里用到了纯粹求值模式不允许的 `builtins.currentSystem`
与 `/home/berry/.nix-profile` 绝对路径。首次接管已被手工修改的文件时加 `-b backup`，旧文件会保留为 `*.backup`。

如果系统还没有 `home-manager` 命令，可临时执行：

```bash
nix run github:nix-community/home-manager -- switch --impure --flake path:/home/berry/.config/home-manager#berry
```

同步 GNOME/dconf 设置：

```bash
hm-sync-dconf
```

查看当前可同步的类别和已发现扩展：

```bash
hm-sync-dconf --list
```

也可以跳过选单，直接同步指定路径：

```bash
hm-sync-dconf -y org/gnome/desktop/interface
```

脚本会动态枚举 GNOME Shell 扩展：优先读取 `gnome-extensions list`，再补充当前 dconf 中已有配置的扩展路径。

管理用户软件：

```bash
hm-apps list
hm-apps add nixpkgs#codex
hm-apps remove codex
```
