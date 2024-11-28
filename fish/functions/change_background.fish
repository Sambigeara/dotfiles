# ref: https://arslan.io/2021/02/15/automatic-dark-mode-for-terminal-applications/
# https://github.com/fatih/dotfiles/blob/main/fish/functions/change_background.fish
function change_background --argument mode_setting
    # change background to the given mode. If mode is missing,
    # we try to deduct it from the system settings.
    # https://comp.lang.tcl.narkive.com/nuJl8GVt/read-if-dark-mode-is-currently-used-on-macos-mojave#post2
    set -l mode light # default value

    # Rather than relying on OS setting as per original example, infer from nvim config as source of truth
    if ! test -f ~/.config/nvim/init.lua
        echo "file ~/.config/nvim/init.lua doesn't exist"
        return
    end
    set -l nvim_conf_path (realpath ~/.config/nvim/init.lua)

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

    # change neovim
    for addr in (/opt/homebrew/bin/nvr --serverlist)
        # /opt/homebrew/bin/nvr --servername "$addr" -c "set background=$mode | colorscheme $colour | lua require('lualine').setup({options={theme=\"$colour\"}})"
        /opt/homebrew/bin/nvr --servername "$addr" -c "set background=$mode"
    end

    # change alacritty
    switch $mode
        case dark
            alacritty-theme dark
        case light
            alacritty-theme light
    end
end

# switch light<->dark
function alacritty-theme --argument theme
    # Define the theme file path
    set -l theme_file ~/.config/alacritty/color_$theme.toml

    # Check if the theme file exists
    if not test -f $theme_file
        echo "File '$theme_file' doesn't exist."
        return
    end

    # Path to the main Alacritty configuration file
    set -l config_path ~/.config/alacritty/alacritty.toml

    # Update the 'import' line in the configuration file
    sed -i '' "s#^import = \[\".*\"\]#import = [\"$theme_file\"]#" $config_path
end
