{ ... }:

{
  # ibus-rime 外观补丁：预编辑内嵌到应用输入框，直接显示拼音编码。
  # 改完 config/ibus_rime.custom.yaml 后需要 switch，再去 ibus 托盘点「部署」。
  xdg.configFile."ibus/rime/ibus_rime.custom.yaml".source =
    ./config/ibus_rime.custom.yaml;
}
