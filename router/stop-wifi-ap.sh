#!/bin/bash

echo "=== Остановка WiFi точки доступа ==="

sudo pkill hostapd
sudo ip addr flush dev wlp1s0 2>/dev/null
sudo ip link set wlp1s0 down
sudo systemctl stop dnsmasq 2>/dev/null
sudo systemctl start NetworkManager 2>/dev/null

echo "WiFi точка доступа остановлена"
echo "NetworkManager восстановлен"