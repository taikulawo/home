# home

home 全部配置文件

## 下载

### SSH clone

```bash
# 先去home，避免在其他目录误删除
cd ~
git init
git remote add origin git@github.com:taikulawo/home.git
git fetch origin master
git remote update
git checkout -b master origin/master -ft
git submodule update --remote --recursive --init
chmod -R 700 .ssh/
```

### HTTPS clone

```bash
# 先去home，避免在其他目录误删除
cd ~
git init
git remote add origin https://github.com/taikulawo/home.git
git fetch origin master
git remote update
git checkout -b master origin/master -ft
git submodule update --remote --recursive --init
chmod -R 700 .ssh/
```

## 初始化

```bash
git init
git config status.showUntrackedFiles no
```

安装下面依赖

```bash
fzf
```

## diff

```bash
gitui
```

或使用 .gitconfig 配置的 alias

```bash
git diffhome
```

## 其他选项

### nvm

设置全局生效的 node 版本为 `v22.21.0`

```bash
set --universal nvm_default_version v22.21.0
```

### gitui

#### debian/ubuntu

```bash
cargo install --git https://github.com/extrawurst/gitui
```

#### mac

```bash
brew install gitui
```

### VIM

安装插件

```vim
:PlugInstall
```

软链 vim 配置目录

```bash
ln ~/.config/vim ~/.vim
```

## FAQ

### vim

mac 自带的 vim 有问题，重新安装

```bash
brew install vim
```

### SSH 断连

将

```
ClientAliveInterval 300
ClientAliveCountMax 3
```

添加到 `/etc/ssh/sshd_config`，再 `systemctl restart sshd`

### mac vscode ctrl + left arrow 失效解决

禁用 settings=>keyboard=>function keys=>mission control=>mission control 全部快捷键

### vim 报错 Sorry, the command is not available in this version: py3 import vim

https://askubuntu.com/questions/284957/vi-getting-multiple-sorry-the-command-is-not-available-in-this-version-af

```bash
sudo apt-get install vim-gui-common
sudo apt-get install vim-runtime
```
