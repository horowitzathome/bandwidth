#!/bin/bash 
 
sudo apt update
sudo apt -y install git
git --version

sudo apt install -y curl build-essential
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
cargo -V

mkdir Rust
cd Rust
git clone https://github.com/horowitzathome/bandwidth.git
cd bandwidth/

