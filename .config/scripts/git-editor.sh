#!/bin/bash
cmd="vim"
if [ -x "$(command -v code)" ]; then
    cmd="code --wait $@"
elif [ -x "$(command -v vim)" ]; then
    cmd="vim $@"
else
    cmd="vi $@"
fi
eval "$cmd"