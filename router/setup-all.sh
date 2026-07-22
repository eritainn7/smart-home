#!/bin/bash

# ============================================
# Запуск Ethernet + WiFi для STM32
# ============================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "========================================="
echo "  STM32: Ethernet + WiFi"
echo "========================================="
echo ""

# Проверка прав
if [ "$EUID" -ne 0 ]; then 
    echo "Запустите с sudo!"
    exit 1
fi

echo ">>> Запуск Ethernet..."
bash "$SCRIPT_DIR/setup-ethernet.sh"
echo ""

echo ">>> Запуск WiFi..."
bash "$SCRIPT_DIR/setup-wifi-ap.sh"
echo ""

echo "========================================="
echo " Всё запущено!"
echo "========================================="
echo ""
echo "Ethernet: 192.168.1.1 (Linux) → 192.168.1.24 (STM32)"
echo "WiFi AP:  192.168.1.2 (Linux)"
echo "          192.168.1.100-200 (DHCP клиенты)"
echo ""
echo "STM32 доступен через оба интерфейса:"
echo "  http://192.168.1.24"