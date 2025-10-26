# Installation Guide for mxp

## Package Managers

### Homebrew (macOS/Linux)

```bash
# Install directly from the repository
brew install https://raw.githubusercontent.com/agzam/emacs-piper/main/Formula/mxp.rb

# Or add the tap (if you create one)
brew tap agzam/tap
brew install mxp
```

### AUR (Arch Linux)

```bash
# Using yay (installs from git)
yay -S mxp-git

# Using paru
paru -S mxp-git

# Manual installation
git clone https://aur.archlinux.org/mxp-git.git
cd mxp-git
makepkg -si
```

### Debian/Ubuntu

```bash
# Build from source
git clone https://github.com/agzam/emacs-piper.git
cd emacs-piper
sudo apt-get install debhelper
dpkg-buildpackage -us -uc
sudo dpkg -i ../mxp_0.4.0-1_all.deb

# Or use manual install (simpler)
curl -fsSL https://raw.githubusercontent.com/agzam/emacs-piper/main/mxp -o /usr/local/bin/mxp
chmod +x /usr/local/bin/mxp
```

## Manual Installation

### Quick Install (curl)

```bash
curl -fsSL https://raw.githubusercontent.com/agzam/emacs-piper/main/mxp -o ~/.local/bin/mxp
chmod +x ~/.local/bin/mxp
```

### From Source

```bash
git clone https://github.com/agzam/emacs-piper.git
cd emacs-piper
sudo install -m755 mxp /usr/local/bin/mxp
```

## Prerequisites

- **Emacs** with emacsclient (25.1 or later recommended)
- **Bash** (4.0 or later) or **Zsh**
- Standard Unix utilities (base64, grep, sed, mktemp)

## Post-Installation

### Start Emacs Daemon

mxp requires an Emacs daemon to be running:

```bash
# Start manually
emacs --daemon

# Or add to your shell config (~/.bashrc, ~/.zshrc)
if ! pgrep -x "emacs" > /dev/null; then
    emacs --daemon
fi
```

### Verify Installation

```bash
# Check version
mxp --version

# Run tests
make test
```

## Package Maintainer Notes

### No GitHub Releases Required!

All packages pull directly from the git repository, so you don't need to maintain GitHub Releases. Just push your changes and the packages will pick them up.

### Testing Homebrew Formula

```bash
brew install --build-from-source Formula/mxp.rb
brew test mxp
```

### Publishing to AUR

1. Create AUR account at https://aur.archlinux.org
2. Generate .SRCINFO: `makepkg --printsrcinfo > .SRCINFO`
3. Test build: `makepkg -si`
4. Push to AUR:
   ```bash
   git clone ssh://aur@aur.archlinux.org/mxp-git.git
   cp PKGBUILD .SRCINFO mxp-git/
   cd mxp-git
   git add PKGBUILD .SRCINFO
   git commit -m "Initial commit"
   git push
   ```

### Building Debian Package

```bash
# Install build dependencies
sudo apt-get install debhelper dh-make

# Build the package
dpkg-buildpackage -us -uc

# Test installation
sudo dpkg -i ../mxp_0.4.0-1_all.deb
```

## Troubleshooting

### Command not found

Ensure the installation directory is in your PATH:
```bash
echo $PATH | grep -o '/usr/local/bin\|~/.local/bin'
```

### Cannot connect to Emacs server

Start the Emacs daemon:
```bash
emacs --daemon
```

Or check if it's running:
```bash
pgrep -x emacs
emacsclient --eval "t"
```

### Permission denied

Make sure the script is executable:
```bash
chmod +x $(which mxp)
```
