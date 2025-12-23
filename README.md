# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Installation

```sh
git clone git@github.com:alcpereira/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make homebrew  # Install all homebrew packages (macOS)
make install   # Symlink all dotfiles
```

## Commands

- `make install` - Symlink all dotfiles to home directory
- `make uninstall` - Remove all symlinks
- `make homebrew` - Install all packages from homebrew.txt (macOS only)

## Structure

Each package is a directory that mirrors your home directory structure:

```
dotfiles/
├── alacritty/
│   └── .config/alacritty/
├── nvim/
│   └── .config/nvim/
├── zsh/
│   ├── .config/zsh/
│   └── .zshrc
└── ...
```

When stowed, files are symlinked to their corresponding locations in your home directory.
