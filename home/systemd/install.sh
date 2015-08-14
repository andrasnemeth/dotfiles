#!/usr/bun/env bash
sudo cp ~/systemd/pacman-synchronize.* /etc/systemd/system/
sudo systemctl enable pacman-synchronize.timer

sudo cp ~/systemd/00-wireless-dhcp.conf /etc/systemd/network/
sudo systemctl enable wpa_supplicant@wlo1
