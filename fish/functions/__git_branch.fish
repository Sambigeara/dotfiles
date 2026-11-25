# Reads HEAD directly: fish_vcs_prompt spawns several git processes on every prompt.
function __git_branch
    set -l dir $PWD
    while test "$dir" != /
        if test -e $dir/.git
            set -l git $dir/.git
            if test -f $git
                read -l line <$git
                set git (string replace 'gitdir: ' '' -- $line)
                string match -q '/*' -- $git; or set git $dir/$git
            end
            read -l head <$git/HEAD; or return
            string replace -rf '^ref: refs/heads/' '' -- $head; or string sub -l 7 -- $head
            return
        end
        set dir (path dirname $dir)
    end
    return 1
end
