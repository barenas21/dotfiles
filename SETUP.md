# Dotfiles Setup

## On a new machine

### 1. Install Homebrew
```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install dependencies
```zsh
brew install stow eza zoxide fzf
brew install --cask ghostty
```

### 3. Install Oh My Zsh
```zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### 4. Install zsh plugins
```zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

### 5. Install Powerlevel10k
```zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### 6. Clone dotfiles and stow
```zsh
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && stow .
```

---

## What's included

- `.zshrc` — Oh My Zsh config with p10k, autosuggestions, syntax highlighting, zoxide, eza aliases
- `.p10k.zsh` — Powerlevel10k prompt config
- `.config/ghostty/config` — Ghostty terminal config (TokyoNight, Fira Code Nerd Font, transparency, splits)

## Day to day

Configs are symlinked from `~/.dotfiles` into `~`. Edit them normally and they're automatically tracked in git.

```zsh
cd ~/.dotfiles
git add .
git commit -m "update configs"
git push
```

On another machine to pull latest:
```zsh
cd ~/.dotfiles && git pull
```
