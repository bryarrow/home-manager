{ ... }:

{
  # 允许 Home Manager 在切换配置时写入用户级 dconf 数据库。
  # 系统侧仍建议在 /etc/nixos 里启用 programs.dconf.enable。
  dconf.enable = true;

  dconf.settings = {
    # GNOME 外观：主题、字体、光标和强调色。
    "org/gnome/desktop/interface" = {
      accent-color = "pink";
      clock-format = "12h";
      cursor-theme = "Sweet-cursors";
      enable-animations = true;
      font-antialiasing = "rgba";
      font-hinting = "full";
      gtk-theme = "adw-gtk3";
      show-battery-percentage = true;
    };


    # 触摸板手势和滚动行为。
    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    # 窗口按钮布局。
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
    };

    # 显示注销按键
    "org/gnome/shell" = {
      always-show-log-out = true;
    };

    # Dash to Dock 扩展：Dock 位置、大小和透明度。
    "org/gnome/shell/extensions/dash-to-dock" = {
      always-center-icons = true;
      apply-custom-theme = false;
      background-color = "rgb(154,153,150)";
      background-opacity = 0.80000000000000004;
      click-action = "focus-minimize-or-previews";
      custom-background-color = false;
      custom-theme-customize-running-dots = false;
      custom-theme-shrink = false;
      customize-alphas = true;
      dash-max-icon-size = 48;
      dock-fixed = false;
      dock-position = "BOTTOM";
      extend-height = false;
      height-fraction = 0.90000000000000002;
      intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
      isolate-workspaces = true;
      max-alpha = 0.40000000000000002;
      middle-click-action = "launch";
      preferred-monitor = -2;
      preferred-monitor-by-connector = "DSI-1";
      running-indicator-dominant-color = true;
      running-indicator-style = "DOTS";
      scroll-action = "cycle-windows";
      shift-click-action = "minimize";
      shift-middle-click-action = "launch";
      show-icons-emblems = true;
      show-show-apps-button = true;
      transparency-mode = "DYNAMIC";
      unity-backlit-items = false;
    };


    # Blur my Shell 扩展的全局状态。
    "org/gnome/shell/extensions/blur-my-shell" = {
      rounded-blur-found = true;
      settings-version = 8;
    };

    # Blur my Shell 的子页面设置。
    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      blur = true;
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = false;
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/coverflow-alt-tab" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      corner-radius = 24;
      override-background = true;
      pipeline = "pipeline_liquid_glass";
      static-blur = false;
      style-dash-to-dock = 3;
    };
    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      blur = true;
      pipeline = "pipeline_default";
      style-components = 2;
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      corner-radius = 0;
      force-light-text = false;
      gradient-panel = false;
      match-theme-in-overview = false;
      override-background = true;
      override-background-dynamically = true;
      override-background-dynamically-mode = 1;
      rounded-corners = 1;
      static-blur = false;
      style-panel = 0;
    };
    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      pipeline = "pipeline_liquid_glass";
    };
    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/popup" = {
      override-background = true;
      pipeline = "pipeline_liquid_glass";
      preserve-shell-theme = false;
      style-popup = 3;
    };

    # Just Perfection 扩展：GNOME Shell 元素显示/隐藏和布局偏好。
    "org/gnome/shell/extensions/just-perfection" = {
      accent-color-icon = false;
      accessibility-menu = true;
      background-menu = true;
      calendar = true;
      clock-menu-position = 0;
      controls-manager-spacing-size = 0;
      dash = true;
      dash-icon-size = 0;
      double-super-to-appgrid = true;
      events-button = true;
      invert-calendar-column-items = false;
      osd = true;
      panel = true;
      panel-in-overview = true;
      power-icon = true;
      quick-settings-airplane-mode = false;
      ripple-box = true;
      search = true;
      show-apps-button = true;
      startup-status = 0;
      support-notifier-type = 0;
      theme = false;
      top-panel-position = 0;
      weather = false;
      window-demands-attention-focus = true;
      window-picker-icon = true;
      window-preview-caption = true;
      window-preview-close-button = true;
      workspace = true;
      workspace-background-corner-size = 0;
      workspace-popup = true;
      workspace-switcher-size = 0;
      workspace-wrap-around = false;
      workspaces-in-app-grid = true;
      world-clock = true;
    };

    "org/gnome/shell/extensions/nightthemeswitcher/time" = {
      manual-schedule = true;
      nightthemeswitcher-ondemand-keybinding = ["<Shift><Super>t"];
    };
    "org/gnome/shell/extensions/nightthemeswitcher/color-scheme" = {
      day = "prefer-light";
      night = "prefer-dark";
    };

    "org/gnome/shell/extensions/chinese-calendar" = {
      show-lunar-in-panel = false;
      show-lunar-detail-in-calendar = false;
    };
  };
}
