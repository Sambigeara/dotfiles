function reboot-windows --description 'Reboot into Windows once, bypassing Limine'
    set -l entry (efibootmgr | string match -rg '^Boot([0-9A-F]{4})\*? Windows Boot Manager')
    if test -z "$entry"
        echo "No Windows Boot Manager entry found" >&2
        return 1
    end

    read -l -P 'Reboot into Windows now? [y/N] ' confirm
    string match -qi y -- $confirm; or return 1

    sudo efibootmgr --quiet --bootnext $entry; and systemctl reboot
end
