{ ... }:

{
  # ibus-rime 外观补丁：预编辑内嵌到应用输入框，直接显示拼音编码。
  # 改完 config/ibus_rime.custom.yaml 后需要 switch，再去 ibus 托盘点「部署」。
  xdg.configFile."ibus/rime/ibus_rime.custom.yaml".source =
    ./config/ibus_rime.custom.yaml;

  # Rime 全局按键补丁：Ctrl+Space 切换中英文（ascii_mode）。
  # 改完同样需要 switch + 重新部署（ibus restart）。
  xdg.configFile."ibus/rime/default.custom.yaml".source =
    ./config/default.custom.yaml;
}
