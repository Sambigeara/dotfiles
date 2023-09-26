# ref: https://arslan.io/2021/02/15/automatic-dark-mode-for-terminal-applications/
# https://github.com/fatih/dotfiles/blob/main/fish/functions/change_background.fish
function change_background --argument mode_setting
    # change background to the given mode. If mode is missing,
    # we try to deduct it from the system settings.
    # https://comp.lang.tcl.narkive.com/nuJl8GVt/read-if-dark-mode-is-currently-used-on-macos-mojave#post2
    set -l mode light # default value
    # if test -z $mode_setting
    #   set -l val (defaults read -g AppleInterfaceStyle) >/dev/null
    #   if test $status -eq 0
    #     set mode "dark"
    #   end
    # else
    #   switch $mode_setting
    #     case light
    #       osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = false" >/dev/null
    #       set mode "light"
    #     case dark
    #       osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = true" >/dev/null
    #       set mode "dark"
    #   end
    # end

    # Rather than relying on OS setting as per original example, infer from nvim config as source of truth
    if ! test -f ~/.config/nvim/lua/conf.lua
        echo "file ~/.config/nvim/lua/conf.lua doesn't exist"
        return
    end
    set -l nvim_conf_path (realpath ~/.config/nvim/lua/conf.lua)

    set -l current_mode (awk -F'"' '/vim.opt.background/ {print $2}' $nvim_conf_path)

    if test -z $mode_setting
        # Negate the current setting if mode not passed
        switch $current_mode
            case light
                set mode dark
            case dark
                set mode light
        end
    else
        switch $mode_setting
            case light
                osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = false" >/dev/null
                set mode light
            case dark
                osascript -l JavaScript -e "Application('System Events').appearancePreferences.darkMode = true" >/dev/null
                set mode dark
        end
    end

    # Update nvim cfg for new buffer opens (sed doesn't like symlinks, get the absolute path)
    sed -i "" -e "s#^vim.opt.background = .*#vim.opt.background = \"$mode\"#g" $nvim_conf_path

    # Update colour which is used for both global nvim colorscheme, and lualine colour conf
    if ! test -f ~/.config/nvim/lua/colorconf.lua
        echo "file ~/.config/nvim/lua/colorconf.lua doesn't exist"
        return
    end
    set -l colour_path (realpath ~/.config/nvim/lua/colorconf.lua)

    set -l colour ""
    switch $mode
        case dark
            set colour tokyonight
        case light
            # set colour "PaperColor"
            # set colour gruvbox
            set colour tokyonight
        case '*'
            echo "unknown colorscheme"
            return
    end

    # Update colour for new nvim instances
    sed -i "" -e "s#^local colour = .*#local colour = \"$colour\"#g" $colour_path

    # change neovim
    for addr in (/opt/homebrew/bin/nvr --serverlist)
        /opt/homebrew/bin/nvr --servername "$addr" -c "set background=$mode | colorscheme $colour | lua require('lualine').setup({options={theme=\"$colour\"}})"
    end

    # change alacritty
    switch $mode
        case dark
            alacritty-theme tokyo-night
        case light
            alacritty-theme pencil_light
            # alacritty-theme gruvbox_light
    end
end

# switch light<->dark
function alacritty-theme --argument theme
    if ! test -f ~/.config/alacritty/color.yml
        echo "file ~/.config/alacritty/color.yml doesn't exist"
        return
    end

    # sed doesn't like symlinks, get the absolute path
    set -l config_path (realpath ~/.config/alacritty/color.yml)

    sed -i "" -e "s#^colors: \*.*#colors: *$theme#g" $config_path
end
