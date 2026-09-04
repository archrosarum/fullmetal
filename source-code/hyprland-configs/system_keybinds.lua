-- SYSTEM KEYBINDS --

    -- Open launcher --
    hl.bind("SUPER + SUPER_L", hl.dsp.exec_cmd("sh -c 'pkill rofi; W=$WAYLAND_DISPLAY; WAYLAND_DISPLAY= rofi -normal-window -show drun -run-shell-command \"env WAYLAND_DISPLAY=$W {cmd}\" -run-command \"env WAYLAND_DISPLAY=$W {cmd}\"'"))
    -- Close window --
    hl.bind("SUPER + Q", hl.dsp.window.close())

    -- Toggle floating window --
    hl.bind("SUPER + F", hl.dsp.window.float({ action = "toggle" }))
    -- Drag floating window --
    hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
    -- Resize floating window --
    hl.bind("SUPER + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })
   
    -- Launch default web browser --
    hl.bind("SUPER + W", hl.dsp.exec_cmd(favorite_web_browser))
    -- Launch default file explorer --
    hl.bind("SUPER + E", hl.dsp.exec_cmd(favorite_file_explorer))
    -- Launch default terminal --
    hl.bind("SUPER + R", hl.dsp.exec_cmd(favorite_terminal))	
    -- Launch default text editor  --
    hl.bind("SUPER + T", hl.dsp.exec_cmd(favorite_text_editor))

    -- Exit the window manager --
    hl.bind("SUPER + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

    hl.bind(screenshot_keybind, hl.dsp.exec_cmd("grim " .. screenshot_dir .. screenshot_format))
