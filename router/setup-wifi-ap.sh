#!/bin/bash
WIFI_INTERFACE="wlp1s0"
AP_SSID="Stalin"
AP_PASSWORD="pivolublu"
AP_IP="192.168.1.2"              
STM32_IP="192.168.1.24"

echo "SSID:      $AP_SSID"
echo "Пароль:    $AP_PASSWORD"
echo "IP:        $AP_IP"
echo ""

if [ "$EUID" -ne 0 ]; then 
    echo "Необходимо запустить с sudo: sudo $0"
    exit 1
fi

# Остановка мешающих сервисов
echo "[1/4] Остановка конфликтующих сервисов..."
sudo systemctl stop wpa_supplicant 2>/dev/null
sudo rfkill unblock wifi
echo "Готово"

# Настройка и запуск hostapd
echo "[2/4] Запуск WiFi точки доступа..."

sudo tee /etc/hostapd-stm32.conf > /dev/null <<EOF
interface=$WIFI_INTERFACE
driver=nl80211
ssid=$AP_SSID
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$AP_PASSWORD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

sudo pkill hostapd 2>/dev/null
sleep 1
sudo hostapd -B /etc/hostapd-stm32.conf

if [ $? -eq 0 ]; then
    echo "Точка доступа запущена"
else
    echo "Ошибка запуска hostapd"
    exit 1
fi

# Настройка IP на WiFi интерфейсе
echo "[3/4] Настройка IP адреса..."
sudo ip addr flush dev $WIFI_INTERFACE 2>/dev/null
sudo ip addr add ${AP_IP}/24 dev $WIFI_INTERFACE
sudo ip link set $WIFI_INTERFACE up
echo "✅ IP $AP_IP/24 на $WIFI_INTERFACE"

# DHCP сервер для WiFi клиентов
echo "[4/4] Настройка DHCP сервера..."

sudo tee /etc/dnsmasq-stm32.conf > /dev/null <<EOF
# WiFi интерфейс
interface=$WIFI_INTERFACE

# Не слушать Ethernet (там уже ваш скрипт работает)
no-dhcp-interface=enx34298f7155d6

# Диапазон IP для WiFi клиентов
dhcp-range=192.168.1.100,192.168.1.200,255.255.255.0,12h

# Шлюз и DNS
dhcp-option=option:router,$AP_IP
dhcp-option=option:dns-server,8.8.8.8,1.1.1.1
EOF

# Перезапуск dnsmasq
sudo systemctl restart dnsmasq 2>/dev/null || sudo dnsmasq -C /etc/dnsmasq-stm32.conf

echo "DHCP сервер запущен"

# Форвардинг между WiFi и Ethernet
sudo sysctl -w net.ipv4.ip_forward=1 > /dev/null
sudo iptables -A FORWARD -i $WIFI_INTERFACE -o enx34298f7155d6 -j ACCEPT 2>/dev/null
sudo iptables -A FORWARD -i enx34298f7155d6 -o $WIFI_INTERFACE -j ACCEPT 2>/dev/null

echo "Плов готов"
echo "Сеть:    $AP_SSID"
echo "Пароль:  $AP_PASSWORD"
echo "IP AP:   $AP_IP"
echo "STM32:   $STM32_IP"
echo ""
echo "Подключитесь к WiFi с телефона/ноутбука"
echo "   и открывайте http://$STM32_IP"
echo ""
echo "Подключённые клиенты:"
echo "   sudo hostapd_cli -i $WIFI_INTERFACE all_sta"
echo "   cat /var/lib/misc/dnsmasq.leases"