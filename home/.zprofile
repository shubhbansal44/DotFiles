#
# ~/.zprofile
#

[[ -f ~/.zshrc ]] && source ~/.zshrc


if [[ $XDG_VTNR -eq 1 ]]; then
    typefetch
elif [[ $XDG_VTNR -eq 2 ]]; then
    skull
fi
