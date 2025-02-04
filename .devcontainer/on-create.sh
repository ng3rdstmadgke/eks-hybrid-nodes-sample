#!/bin/bash
set -ex

cp ${PROJECT_DIR}/.devcontainer/etc/.tmux.conf ~/.tmux.conf
cp ${PROJECT_DIR}/.devcontainer/etc/.vimrc ~/.vimrc

cat <<EOF >> ~/.bashrc

source ${PROJECT_DIR}/.devcontainer/.bashrc_private
EOF
