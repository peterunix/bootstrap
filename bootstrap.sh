#!/usr/bin/env bash
#Qemu setup bridge
#https://gist.github.com/extremecoders-re/e8fd8a67a515fee0c873dcafc81d811c
function main {
    installParu
    installPackages
    installFonts
    installEmacsConfig
    installHostsFile
    setupCrontab
    setMimeTypes
}

# AUR Helper Program
function installParu {
    sudo sed -i 's;^#ParallelDownloads.*;ParallelDownloads = 8;g' /etc/pacman.conf
    sudo pacman -Sy --noconfirm base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
}

# Installs arch packages from Official+AUR repositories
function installPackages {
    # Running Paru on multiple lines to keep my sanity and avoid using a separate text file
    paru -S --noconfirm brave-bin chromium
    paru -S --noconfirm filezilla veracrypt emacs mpv youtube-dlc feh ffmpeg libreoffice obs scrot tldr zsh
    paru -S --noconfirm zathura zathura-cb zathura-djvu zathura-pdf-mupdf zathura-ps zaread-git
    paru -S --noconfirm qemu qemu-arch-extra qemu-block-gluster qemu-block-iscsi qemu-block-rbd qemu-guest-agent qemu-user-static-bin spice-gtk samba
    paru -S --noconfirm pandoc texlive-most imagemagick
    paru -S --noconfirm curl wget git php rclone rsync netcat
    paru -S --noconfirm wine winetricks zenity
    paru -S --noconfirm qbittorrent wireguard wireguard-tools openvpn resolvconf
    paru -S --noconfirm dnsutils bridge-utils tunctl
    paru -S --noconfirm linux-headers virtualbox virtualbox-guest-iso
    # Set ZSH as the default shell
    sudo chsh -s /usr/bin/zsh anon
    # Add user to Virtualbox group and load the vbox kernel module on boot
    sudo usermod -aG vboxusers $(whoami)
    sudo modprobe vboxdrv
    echo "vboxdrv" | sudo tee /etc/modules-load.d/virtualbox.conf
    # Update the TLDR database
    tldr -u
    # Start the printing service
    sudo systemctl enable --now cups
    echo "Cups Server: http://localhost:631"
}

# Installs third party fonts
function installFonts {
    # Installing Terminess
    FONTHOME=~/.local/share/fonts/
    mkdir -p $FONTHOME/terminus
    cd $FONTHOME/terminus
    wget 'https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Terminus.zip'
    unzip Terminus.zip && rm Terminus.zip
    fc-cache -fv

    # Installing Comic Mono
    FONTHOME=~/.local/share/fonts/
    mkdir -p $FONTHOME/comicmono
    cd $FONTHOME/comicmono
    wget 'https://dtinth.github.io/comic-mono-font/ComicMono.ttf'
    wget 'https://dtinth.github.io/comic-mono-font/ComicMono-Bold.ttf'
    fc-cache -fv

    # Installing Sauce Code Pro
    FONTHOME=~/.local/share/fonts/
    mkdir -p $FONTHOME/source-code-pro
    cd $FONTHOME/source-code-pro
    wget 'https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/SourceCodePro.zip'
    unzip SourceCodePro.zip && rm SourceCodePro.zip
    fc-cache -fv
}

# Downloads an Adblocking hosts file
function installHostsFile {
    HOSTNAME=$(hostname)
    sudo wget 'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts' -O /etc/hosts
    sudo sed -i "s;127.0.0.1 localhost;127.0.0.1 localhost $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;127.0.0.1 localhost.localdomain;127.0.0.1 localhost.localdomain $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;127.0.0.1 local;127.0.0.1 local $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;255.255.255.255 broadcasthost;255.255.255.255 broadcasthost $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;::1 localhost;::1 localhost $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;::1 ip6-localhost;::1 ip6-localhost $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;::1 ip6-loopback;::1 ip6-loopback $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;fe80::1%lo0 localhost;fe80::1%lo0 localhost $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;ff00::0 ip6-localnet;ff00::0 ip6-localnet $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;ff00::0 ip6-mcastprefix;ff00::0 ip6-mcastprefix $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;ff02::1 ip6-allnodes;ff02::1 ip6-allnodes $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;ff02::2 ip6-allrouters;ff02::2 ip6-allrouters $HOSTNAME;g" /etc/hosts
    sudo sed -i "s;ff02::3 ip6-allhosts;ff02::3 ip6-allhosts $HOSTNAME;g" /etc/hosts
    sudo chmod 0644 /etc/hosts
}

function rebindCapsToCtrl {
    /usr/bin/setxkbmap -option "ctrl:nocaps"
}

function setupCrontab {
    # First crontab entry here
    echo '@reboot modprobe zram && zramctl -a lzo-rle -s 12G zram0 && mkswap /dev/zram0 && swapon /dev/zram0' | sudo tee mycrontab
    sudo crontab mycrontab

    # Subsequent cron entries here
    sudo crontab -l | sudo tee mycrontab
    echo '@reboot ntpd -qg' | sudo tee -a mycrontab
    #echo '' | sudo tee -a mycrontab
    sudo crontab mycrontab
    sudo rm mycrontab
}

function setMimeTypes {
    xdg-mime default feh.desktop image/png
    xdg-mime default feh.desktop image/jpg
    xdg-mime default org.pwmt.zathura.desktop application/pdf
}

function createFolders{
    mkdir -p "$HOME/src"
    sudo mkdir -p /media/{dmi,server,bin}
}

function installDotfiles{
    git clone github:/peterunix/dotfiles.git "$HOME/src/dotfiles"
    git clone github:/peterunix/website.git "$HOME/src/website"
}

main
