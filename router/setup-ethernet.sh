#!/bin/bash
LAN_INTERFACE="enx34298f7155d6"   
LAN_IP="192.168.1.2"              
STM32_IP="192.168.1.24"           

echo "=== Настройка сети для STM32 ==="
echo "Интерфейс: $LAN_INTERFACE"
echo "Linux IP:  $LAN_IP"
echo "STM32 IP:  $STM32_IP"
echo ""


echo "[1] Настройка $LAN_INTERFACE..."
sudo ip addr flush dev $LAN_INTERFACE 2>/dev/null
sudo ip addr add ${LAN_IP}/24 dev $LAN_INTERFACE
sudo ip link set $LAN_INTERFACE up
echo "Готово: $LAN_IP/24 на $LAN_INTERFACE"

# 2. Проверка связи
echo ""
echo "[2] Проверка связи..."
sleep 2
ping -c 3 $STM32_IP && echo "STM32 доступен!" || echo "STM32 не отвечает"

echo ""
echo "=== Готово! ==="
echo "Linux: $LAN_IP"
echo "STM32: $STM32_IP"