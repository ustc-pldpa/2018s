
<!-- TOC -->

- [Lua setup](#lua-setup)
    - [Install the binaries](#install-the-binaries)
        - [MacOS](#macos)
        - [Ubuntu](#ubuntu)
        - [Windows 10](#windows-10)
    - [Install Lua packages](#install-lua-packages)
    - [REPL(Read-Eval-Print-Loop)](#replread-eval-print-loop)
        - [Install](#install)
        - [Use](#use)
    - [交互式单步执行 lua 环境的设置](#交互式单步执行-lua-环境的设置)

<!-- /TOC -->

# Lua setup

This guide demonstrates how to install/setup Lua and its related programs for
your development environment.

## Install the binaries

You will install Lua and LuaRocks. Lua is the interpreter used to execute Lua
code, and LuaRocks is the package manager used to install Lua code developed by
other people.

### MacOS

Install the [Homebrew package manager](https://brew.sh/). Then run:

``` bash
brew update
brew install lua
```

### Ubuntu

``` bash
sudo apt-get install lua5.3 liblua5.3-dev
pushd /tmp
wget http://luarocks.github.io/luarocks/releases/luarocks-2.4.3.tar.gz
tar -xf luarocks-2.4.3.tar.gz
pushd luarocks-2.4.3
./configure
make build && sudo make bootstrap
popd && popd
```

### Windows 10

Get [Bash on Ubuntu on Windows using these
instructions](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide?f=255&MSPPError=-2147217396)
then follow the Ubuntu guide.

## Install Lua packages

Once Lua and LuaRocks are installed, you can verify this by running the `lua`
command to get an interactive interpreter (**REPL** or read-eval-print-loop). You
should be running Lua 5.3 (check `lua -v`).

Lastly, you’ll need to install the following packages for this course:

``` bash
luarocks install luaposix
luarocks install termfx
```

You can confirm that these packages installed correctly by running:

``` bash
lua -e 'require "termfx"'
```

See more about the interpreter `lua` in [1.4 The Stand-Alone
Interpreter](https://www.lua.org/pil/1.4.html) in the book Programming in Lua
(PIL)


## REPL(Read-Eval-Print-Loop)

Lua 自带的 REPL `lua` 比较简陋, 推荐使用 [TREPL: A REPL for Torch](https://github.com/torch/trepl), which supports Tab-completion, history, pretty print (table introspection and coloring) , etc..

### Install

Via luarocks:

```
luarocks install trepl
```

If failed, use this:

``` bash
luarocks install --server=http://luarocks.org/dev trepl-torchless
```

## Use
After installed successfully, you can run `th` to enter REPL environment.


## 交互式单步执行 lua 环境的设置

你可以将编辑器中选中的代码发送到 REPL 中执行. 这需要安装 Vim 插件 [vim-slime](https://github.com/jpalardy/vim-slime)  和 terminal multiplexer `tmux` (or `screen`, 这里 以 tmux 举例).

如果你使用Emacs，则安装 [lua-mode](https://github.com/immerrr/lua-mode), 其他编辑器也有相应的 Send to Terminal 插件.

1. 安装 Vim 插件管理器 [vim-pathogen](https://github.com/tpope/vim-pathogen), 便于安装插件及其各自目录下的运行时文件.

``` bash
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
```

在 vim 配置文件 `~/.vimrc` 中增加:

```
execute pathogen#infect()
```

2. 安装 Vim 插件  [vim-slime](https://github.com/jpalardy/vim-slime).

``` bash
cd ~/.vim/bundle
git clone git://github.com/jpalardy/vim-slime.git
```

3. 安装 [tmux](https://github.com/tmux/tmux) 终端复用软件.

  - Ubuntu

``` bash
sudo apt install tmux
```

  - macOS

``` bash
brew install tmux
```

4. 在 `~/.vimrc` 中设置 slime的终端为tmux


```
let g:slime_target = "tmux"
```

5. 在一个终端打开 `vim a.lua`, 在另一个终端打开 `tmux` ; 在 tmux 终端中运行 lua 的 REPL，如 `th` 或者 `lua`; 在 vim 终端中让光标指向要执行的代码， 按 `<Ctrl-C> <Ctrl-C>`, 则代码被发送到 tmux 终端执行. 第一次发送代码会提示设置 target tmux panel, 如果只打开了一个 tmux 窗口, 使用默认设置即可。
如果被执行的代码存在无限循环，则可以在 tmux 终端按 `<Ctrl-C>` 中断执行。

