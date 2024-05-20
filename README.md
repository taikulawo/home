# home

home全部配置文件

## 下载

### SSH clone

```bash
# 先去home，避免在其他目录误删除
cd ~
git init
git remote add origin git@github.com:taikulawo/home.git
git fetch origin master
git checkout origin/master -ft
git submodule update --remote --recursive --init
chmod -R 700 .ssh/
```

### 使用 token clone private repo

go to https://github.com/settings/personal-access-tokens/new 申请 token 作为后续 git 登陆的密码。
token只开放 home/ 读写权限，一年有效期

```bash
# 先去home，避免在其他目录误删除
cd ~
git init
git remote add origin https://taikulawo:<MYTOKEN>@github.com/taikulawo/home.git
git fetch origin master
git checkout origin/master -ft
git submodule update --remote --recursive --init
chmod -R 700 .ssh/
```

## 初始化

```bash
git init
git config status.showUntrackedFiles no
```

## diff

```bash
gitui
```

或使用 .gitconfig 配置的alias

```bash
git diffhome
```
## 其他选项

### .ssh

```bash
ln -sr ./.private-home/.ssh .ssh/
chmod -R 700 .ssh/
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

## FAQ

### vim

mac 自带的vim有问题，重新安装

```bash
brew install vim
```

### mac vscode ctrl + left arrow 失效解决

禁用 settings=>keyboard=>function keys=>mission control=>mission control 全部快捷键

### vim 报错 Sorry, the command is not available in this version: py3 import vim

https://askubuntu.com/questions/284957/vi-getting-multiple-sorry-the-command-is-not-available-in-this-version-af

```bash
sudo apt-get install vim-gui-common
sudo apt-get install vim-runtime
```
