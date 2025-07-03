#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc


if [[ $XDG_VTNR -eq 1 ]]; then
    clear
    typefetch
fi
