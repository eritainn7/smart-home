#include "wifi_setup.h"
#include <WiFi.h>

const char* ssid = "Stalin";
const char* password = "pivolublu";
WiFiServer server(80);

void connectToWiFi() {
    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED) {
        delay(500);
        Serial.print(".");
    }

    Serial.println("Подключено к Wi-Fi!");
    Serial.print("IP-адрес: ");
    Serial.println(WiFi.localIP());
    server.begin();
}

void runServer(float lux, float temp) {
    WiFiClient client = server.available();

    if (!client) return;

    while (client.connected() && !client.available()) {
        delay(1);
    }

    while (client.available()) {
      client.read();
    }

    client.println("HTTP/1.1 200 OK");
    
    client.println("Content-Type: text/html; charset=utf-8");
    client.println("Connection: close");
    client.println();
    
    client.println("<!DOCTYPE html>");
    client.println("<html>");
    client.println("<head>");
    client.println("  <meta charset='UTF-8'>");
    client.println("  <meta name='viewport' content='width=device-width, initial-scale=1.0'>");
    client.println("  <title>ESP32 Датчики</title>");
    client.println("  <style>");
    client.println("    body { font-family: Arial; text-align: center; margin-top: 50px; background: #f0f4f8; }");
    client.println("    .card { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 8px rgba(0,0,0,0.1); display: inline-block; }");
    client.println("    .value { font-size: 3em; font-weight: bold; color: #2c3e50; }");
    client.println("    .label { font-size: 1.2em; color: #7f8c8d; }");
    client.println("    .sensor { margin: 20px 0; }");
    client.println("    .update { color: #95a5a6; font-size: 0.9em; margin-top: 20px; }");
    client.println("  </style>");
    client.println("</head>");
    client.println("<body>");
    client.println("  <div class='card'>");
    client.println("    <h1>Метеостанция ESP32</h1>");
    
    client.println("    <div class='sensor'>");
    client.println("      <div class='label'>Освещенность</div>");
    client.print("      <div class='value'>");
    client.print(lux, 1);
    client.println("</div>");
    client.println("      <div class='label'>люкс (lx)</div>");
    client.println("    </div>");
    
    client.println("    <div class='sensor'>");
    client.println("      <div class='label'>Температура</div>");
    client.print("      <div class='value'>");
    client.print(temp, 1);
    client.println("</div>");
    client.println("      <div class='label'>градусов Цельсия (°C)</div>");
    client.println("    </div>");
    
    client.println("    <div class='update'>");
    client.println("      Данные обновляются при каждом обновлении страницы");
    client.println("    </div>");
    
    client.println("  </div>");
    client.println("</body>");
    client.println("</html>");
    
    client.stop();
    Serial.println("Ответ отправлен, соединение закрыто.");
    Serial.println("============================");
  
    delay(10);  
}

