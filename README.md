# devshells

Development shells powered by Nix

## Installation

**Prerequisites**:

- **Nix**: A purely functional package manager **and** language

### Install Nix

You can follow the instructions for installing Nix from [their documentation online](https://nixos.org/download.html).


> ⚠️ For the [typical security reasons](https://spin.atomicobject.com/2016/12/12/security-spectrum-curl-sh/), I would suggest that you
> downloading the script first, validate it looks correct, and then execute it via the shell.

```shell
curl -L https://nixos.org/nix/install > nix-install.sh
echo "2a1d16068a7c8fa835faf721b16fda1b5279f47f90d785aec7fa9e795d827a31 nix-install.sh" | sha256sum -c"
less nix-install.sh
sh nix-install.sh
```

### Install `devshells`

The `devshells` repository is directly referencable by Nix, and if you already have SSH keys configured this will be the easiest way to get started.

You can clone this to a local directory, or reference the repo on GitHub.

```shell
# from a local directory
cd
git clone git@github.com:tcarrio/devshells.git
nix develop ~/devshells#php82

# or from Git directly
nix develop "git+ssh://git@github.com:/tcarrio/devshells#$target"
```

This will drop you into a Bash shell for the project. We will discuss the `$target` value next. You can also specify to use `zsh` with the following command:

```shell
nix develop ... --command zsh
```

⚠️ **Keep in mind that `zsh` will source the `~/.zshrc` file, which could unintentionally break your Nix environment!**

### Specifying targets

There are multiple targets available. Targets are meant to provide dev shells for specific projects or for general purposes. The following targets are defined:

- **node**: for general NodeJS development, includes NodeJS, Yarn, pnpm, and Python (native compilation support for modules like node-sass)
- **php##**: for general PHP development, versioning by PHP. v7.4 being EOL requires compilation, whereas the other PHP versions have binary caches available for `arm64` and `amd64`.
    - **php74**: includes PHP 7.4 and composer
    - **php80**: includes PHP 8.0 and composer
    - **php81**: includes PHP 8.1 and composer
    - **php82**: includes PHP 8.2 and composer
- **python**: for general Python development

To start a specific target's dev shell, such as PHP 8.1, run the command:

```shell
nix develop ~/devshells#php81

# or from the repository reference

nix develop "git+ssh://git@github.com:/tcarrio/devshells#php81"
```

#### Convenient Access

You could also generate aliases or a helper function in your shell's config file:


```shell
function devshells() {
    if [ -n "$1" ]; then
        nix develop "git+ssh://git@github.com:/tcarrio/devshells#$1"
    else
        echo "You must provide a target shell"
    fi
}
```
