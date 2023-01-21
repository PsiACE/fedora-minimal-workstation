#!/bin/bash

# DNF config
echo "max_parallel_downloads=20
defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf

###
# RpmFusion Free & NoneFree Repo
###
while IFS= read -r line
do
    # do something with $line
    sudo dnf install -y '%s\n' "$line"
done <"./repo/rpmfusion.install"

dnf clean all

# enable COPRs
while read line; do
    # do something with $line
    sudo dnf copr enable -y $line
done < ./repo/copr.enable

sudo dnf upgrade -y --refresh

# remove some packages
sudo dnf remove $(cat repo/packages.remove) -y

# grab all packages to install from repos
sudo dnf install $(cat repo/packages.install) -y

# swap packages
while read line; do
    # do something with $line
    sudo sudo dnf swap -y $line
done < ./repo/packages.swap

# grab all packages to install from flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --enable flathub
flatpak install flathub $(cat flat.packages) -y

# setup Rustup and install Cargo packages
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
cargo install $(cat cargo.packages) --locked

# setup pdm as python manager
curl -sSL https://raw.githubusercontent.com/pdm-project/pdm/main/install-pdm.py | python3 -

# setup dotfiles
echo "Intalling Chezmoi"
sh -c "$(curl -fsLS https://chezmoi.io/get)" -- -b $HOME/.local/bin
# need enable later
# chezmoi init --apply https://github.com/psiace/dotfiles.git

# font setup
if [[ -d ~/.local/share/fonts/ ]]
then
  echo "Downloading terminal font"
else
  mkdir -vp ~/.local/share/fonts/
fi

cd
wget https://github.com/laishulu/Sarasa-Mono-SC-Nerd/archive/refs/tags/v2.1.0.zip
unzip v2.1.0.zip -d ~/.local/share/fonts/
rm v2.1.0.zip
