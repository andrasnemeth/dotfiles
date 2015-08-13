#!/usr/bun/env bash
sudo cp ~/systemd/pacman-synchronize.* /etc/systemd/system/
sudo systemctl enable pacman-synchronize.timer
