#!/bin/bash -exu

function base_dependencies() {
  apt-get update && apt-get -y upgrade

  apt-get -y install vim tmux jq wget git
}

function setup_om() {
  curl -o /usr/local/bin/om -L https://github.com/pivotal-cf/om/releases/download/0.35.0/om-linux
  chmod +x /usr/local/bin/om
}

function setup_nvim() {
  apt-get install -y nodejs npm python python-pip python3 python3-pip python-dev python3-dev

  curl -o /usr/local/bin/nvim -L https://github.com/neovim/neovim/releases/download/v0.2.2/nvim.appimage
  chmod u+x /usr/local/bin/nvim

  update-alternatives --install /usr/bin/vi vi /usr/local/bin/nvim 60
  update-alternatives --skip-auto --config vi
  update-alternatives --install /usr/bin/vim vim /usr/local/bin/nvim 60
  update-alternatives --skip-auto --config vim
  update-alternatives --install /usr/bin/editor editor /usr/local/bin/nvim 60
  update-alternatives --skip-auto --config editor

  # this is required because the default npm from apt is old
  npm config set strict-ssl false --global

  export HOME=/root
  export TERM=xterm

  if [ ! -d "/root/.vim" ]; then
    curl vimfiles.luan.sh/install | bash
  else
    pushd /root/.vim
      ./update --non-interactive
    popd
  fi
}

function setup_go() {
  pushd /tmp
    pushd /usr/local/
     curl -L "https://dl.google.com/go/go1.10.1.linux-amd64.tar.gz" | tar xz
    popd

    mkdir -p "/root/go"
  popd
}

function setup_dotfiles() {
  if ! grep -q "/var/vcap/jobs/machine-setup/dotfiles/env_vars" "/root/.bashrc" ; then
    echo "source /var/vcap/jobs/machine-setup/dotfiles/env_vars" >> "/root/.bashrc"
    source /var/vcap/jobs/machine-setup/dotfiles/env_vars
  fi

  pushd /root
    curl -OL https://raw.githubusercontent.com/zankich/dotfiles/master/.tmux.conf
  popd
}

function main() {
  base_dependencies
  setup_dotfiles
  setup_om
  setup_go
  setup_nvim
}

main
