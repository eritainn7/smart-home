#!/bin/bash

ETH="enx34298f7155d6"
BRIDGE="br0"
STM32_IP="192.168.1.24"

echo "=== Подключаем STM32 в сеть Stalin ==="

if [ "$EUID" -ne 0 ]; then 
    echo "Запустите с sudo!"
    exit 1
fi

# 1. Снимаем старый IP с Ethernet
echo "[1] Очистка Ethernet..."
ip addr flush dev $ETH 2>/dev/null

# 2. Создаём мост
echo "[2] Создание моста..."
ip link add name $BRIDGE type bridge 2>/dev/null

# Добавляем Ethernet в мост
ip link set $ETH master $BRIDGE
ip link set $ETH up
ip link set $BRIDGE up

echo "Мост $BRIDGE создан"

echo ""
echo "[3] Проверка..."
sleep 2

echo -n "STM32 ($STM32_IP): "
ping -c 2 -W 1 $STM32_IP > /dev/null 2>&1 && echo "доступен" || echo "Не отвечает"

echo ""
echo "Устройства в сети:"
arp -a | grep -E "192.168.1\."

echo ""
echo "=== Готово! ==="
echo "STM32 теперь в сети Stalin"
echo "Проверьте: ping $STM32_IP"