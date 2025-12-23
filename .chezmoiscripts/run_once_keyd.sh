#!/bin/bash
trap 'echo "❌ Error on line $LINENO: $BASH_COMMAND" >&2' ERR
set -Eeuo pipefail

# Upgrade to sudo
if [ "$(id -u)" -ne 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

mkdir -p /etc/keyd
cat << EOF > /etc/keyd/default.conf
[ids]
*
[main]

# Maps capslock to escape when pressed and control when held.
capslock = overload(control, esc)


[meta]
d = toggle(debug)
m = toggle(music)


[debug]
f5 = command(nvim --server /tmp/nvim/server.pipe --remote-send '<C-\><C-N>:DapContinue<CR>')
f10 = command(nvim --server /tmp/nvim/server.pipe --remote-send '<C-\><C-N>:DapStepOver<CR>')
f11 = command(nvim --server /tmp/nvim/server.pipe --remote-send '<C-\><C-N>:DapStepInto<CR>')
esc = clear() # only real escape should clear, we might want to test escape input

[music]
h = command(mpc -p 6600 next)
l = command(mpc -p 6600 cdprev)
j = command(mpc -p 6600 volume -1)
k = command(mpc -p 6600 volume +1)
p = command(mpc -p 6600 toggle)
esc = clear()
capslock = clear()
EOF
