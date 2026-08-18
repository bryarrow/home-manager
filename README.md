# Berry 的 Home Manager 配置

这个目录只管理 berry 用户环境，不由 `/etc/nixos` 导入。

- `home.nix`：用户入口和通用 Home Manager 设置。
- `gnome-dconf.nix`：GNOME 和扩展的 dconf 声明。
- `packages.nix`：用户级软件包。
- `pkgs/hm-apps`：包装 `hm-apps` 命令，用来维护 `packages.nix` 中的用户软件。
- `pkgs/hm-sync-dconf`：把 dconf 同步工具包装成用户包，安装后命令为 `hm-sync-dconf`。

应用配置：

```bash
home-manager switch --flake path:/home/berry/.config/home-manager#berry
```

如果系统还没有 `home-manager` 命令，可临时执行：

```bash
nix run github:nix-community/home-manager -- switch --flake path:/home/berry/.config/home-manager#berry
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
