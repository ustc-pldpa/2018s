
# OCaml setup

This guide demonstrates how to install/setup OCaml and its related programs for your development environment. Only follow this guide for local installation to either OS X, Ubuntu 16.04, or Bash on Ubuntu on Windows.

## 1. Install the binaries

You will install OPAM, the package manager for OCaml.

### OS X

```
brew install opam
```

Ubuntu

```
sudo apt install opam -y
```

Windows 10

Get [Bash on Ubuntu on Windows using these instructions](https://msdn.microsoft.com/en-us/commandline/wsl/install_guide?f=255&MSPPError=-2147217396) then follow the Ubuntu guide.

## 2. Install OCaml packages

We use [OPAM](https://opam.ocaml.org/) to manage OCaml packages and install new OCaml versions.

```
opam init -y
opam switch 4.05.0
eval `opam config env`
opam install core menhir utop merlin ocp-indent user-setup -y
```
(之前写成 4.06.1 了, 更正为 4.05.0) 
如果有其他环境问题, 参考 [piazza](https://piazza.com/class/jecsnyvleiq5ib?cid=38)

可以指定如下安装版本：

```
opam install core=v0.9.1 menhir=20170712 utop=2.0.1 merlin=3.0.2 ocp-indent=1.6.1 user-setup=0.6
```
然后执行 `assign3/solution.sh` 的话, 如果你的 glibc 版本是 2.26 (执行 ldd --version 查看) 可能会出这个 bug  
```
   `unix_sysconf` throws `Illegal seek` when glibc-2.26 is used
``` 
那么安装一个旧的 glibc 或者换个 Linux.

This step will take a while!

### REPL(Read-Eval-Print-Loop)

[`utop`](https://github.com/diml/utop) is a smart repl with tab-completion and highlights.

```
utop
```

[`ocaml`](https://ocaml.org/) is the default repl.

```
ocaml
```

## 3.Configuring your editor

The most crucial component of the OCaml development toolchain is [merlin](https://github.com/ocaml/merlin), a tool that drives many IDE features like getting the types of variables, jumping to symbols, showing syntax errors, and so on. It will make your life much easier, so you really should get it installed.


## 4.Setup Ocaml env for future startup

Add to your `.bashrc` (or equivalent)

```
eval `opam config env`
```

### Vim and Emacs

Configuring Merlin for Vim and Emacs is simple:

```
opam user-setup install
```

### Anything else

Any other editor (Atom, VSCode, Sublime) requires more work. See the Merlin wiki page for installation instructions.

