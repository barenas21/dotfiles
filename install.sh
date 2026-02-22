#!/bin/zsh

DOTFILES="$HOME/.dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d_%H%M%S)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

info() { print -P "%F{green}[info]%f  $1" }
warn() { print -P "%F{yellow}[warn]%f  $1" }
done_() { print -P "%F{cyan}[done]%f  $1" }

mkdir -p "$BACKUP_DIR"

# ── Homebrew ──────────────────────────────────────────────────────────────────
if command -v brew &>/dev/null; then
  info "Homebrew already installed"
else
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)"
fi

# ── Brew packages ─────────────────────────────────────────────────────────────
if [ -f "$DOTFILES/Brewfile" ]; then
  info "Installing packages from Brewfile..."
  brew bundle install --file="$DOTFILES/Brewfile"
else
  warn "No Brewfile found, skipping"
fi

# ── Oh My Zsh ─────────────────────────────────────────────────────────────────
if [ -d "$HOME/.oh-my-zsh" ]; then
  info "Oh My Zsh already installed"
else
  info "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# ── zsh plugins ───────────────────────────────────────────────────────────────
if [ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  info "zsh-autosuggestions already installed"
else
  info "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  info "zsh-syntax-highlighting already installed"
else
  info "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ── Powerlevel10k ─────────────────────────────────────────────────────────────
if [ -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  info "Powerlevel10k already installed"
else
  info "Installing Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# ── .zshrc ────────────────────────────────────────────────────────────────────
if [ -L "$HOME/.zshrc" ]; then
  info ".zshrc is already a symlink, skipping"
elif [ -f "$HOME/.zshrc" ]; then
  warn "Existing .zshrc found — backing up to $BACKUP_DIR/.zshrc and patching"
  cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc"

  # p10k instant prompt — prepend if missing (must be near top of file)
  if ! grep -q "p10k-instant-prompt" "$HOME/.zshrc"; then
    info "  Adding p10k instant prompt block..."
    tmp=$(mktemp)
    printf '# Enable Powerlevel10k instant prompt.\nif [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%%):-%%n}.zsh" ]]; then\n  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%%):-%%n}.zsh"\nfi\n\n' > "$tmp"
    cat "$HOME/.zshrc" >> "$tmp"
    mv "$tmp" "$HOME/.zshrc"
  fi

  # ZSH_THEME
  if grep -q "^ZSH_THEME=" "$HOME/.zshrc"; then
    info "  Updating ZSH_THEME to powerlevel10k..."
    sed -i '' 's|^ZSH_THEME=.*|ZSH_THEME="powerlevel10k/powerlevel10k"|' "$HOME/.zshrc"
  else
    info "  Adding ZSH_THEME..."
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$HOME/.zshrc"
  fi

  # plugins — add missing ones to existing plugins=() line
  for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if grep -q "$plugin" "$HOME/.zshrc"; then
      info "  $plugin already in plugins"
    else
      info "  Adding $plugin to plugins..."
      sed -i '' "s/^plugins=(\(.*\))/plugins=(\1 $plugin)/" "$HOME/.zshrc"
    fi
  done

  # zoxide
  if grep -q "zoxide init" "$HOME/.zshrc"; then
    info "  zoxide already configured"
  else
    info "  Adding zoxide..."
    printf '\neval "$(zoxide init zsh)"\n' >> "$HOME/.zshrc"
  fi

  # eza aliases
  if grep -q "eza --icons" "$HOME/.zshrc"; then
    info "  eza aliases already present"
  else
    info "  Adding eza aliases..."
    printf "\nalias ls='eza --icons'\nalias ll='eza --icons -la'\n" >> "$HOME/.zshrc"
  fi

  # p10k source line
  if grep -q "p10k.zsh" "$HOME/.zshrc"; then
    info "  p10k source already present"
  else
    info "  Adding p10k source..."
    printf '\n[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh\n' >> "$HOME/.zshrc"
  fi
else
  info "No existing .zshrc — will stow from dotfiles"
fi

# ── .p10k.zsh ─────────────────────────────────────────────────────────────────
if [ -L "$HOME/.p10k.zsh" ]; then
  info ".p10k.zsh is already a symlink, skipping"
elif [ -f "$HOME/.p10k.zsh" ]; then
  warn "Existing .p10k.zsh found — backing up and replacing with dotfiles version"
  cp "$HOME/.p10k.zsh" "$BACKUP_DIR/.p10k.zsh"
  rm "$HOME/.p10k.zsh"
fi

# ── Ghostty config ────────────────────────────────────────────────────────────
mkdir -p "$HOME/.config/ghostty"
if [ -L "$HOME/.config/ghostty/config" ]; then
  info "Ghostty config is already a symlink, skipping"
elif [ -f "$HOME/.config/ghostty/config" ]; then
  warn "Existing ghostty config found — backing up and replacing with dotfiles version"
  cp "$HOME/.config/ghostty/config" "$BACKUP_DIR/ghostty-config"
  rm "$HOME/.config/ghostty/config"
fi

# ── macOS settings ────────────────────────────────────────────────────────────
if defaults read NSGlobalDomain NSWindowShouldDragOnGesture &>/dev/null && \
   [ "$(defaults read NSGlobalDomain NSWindowShouldDragOnGesture)" = "1" ]; then
  info "Cmd+drag window setting already enabled"
else
  info "Enabling Cmd+drag to move windows..."
  defaults write NSGlobalDomain NSWindowShouldDragOnGesture -bool true
fi

# ── Stow ──────────────────────────────────────────────────────────────────────
info "Running stow..."
cd "$DOTFILES"

# If .zshrc was patched in place (not a symlink), exclude it from stow
if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
  stow --ignore='\.zshrc$' .
else
  stow .
fi

echo ""
done_ "All done!"
done_ "Backups saved to: $BACKUP_DIR"
done_ "Run: source ~/.zshrc"
