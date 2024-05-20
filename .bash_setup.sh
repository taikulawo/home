#!/usr/bin/env bash
# 后处理脚本

# https://stackoverflow.com/questions/17397069/unset-readonly-variable-in-bash
# 禁用ssh不活跃 auto logout
unset TMOUT > /dev/null 2>&1
if [ $? -ne 0 ]; then
    gdb -q -n <<EOF > /dev/null 2>&1
 attach $$
 call unbind_variable("TMOUT")
 detach
 quit
EOF
fi