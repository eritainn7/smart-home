#include <Arduino.h>
#include <Wire.h>
#include <BH1750.h>
#include <LM75.h>
#include "wifi/wifi_setup.h"

LM75 tempSensor;
BH1750 lightMeter;

void setup() {
  Serial.begin(115200);
  Wire.begin();
  
  connectToWiFi();

  if (lightMeter.begin()) {
    Serial.println("Датчик BH1750 инициализирован успешно.");
  } else {
    Serial.println("Ошибка инициализации датчика!");
  }

  Wire.beginTransmission(LM75_ADDRESS);
  if (Wire.endTransmission() == 0) {
    Serial.println("LM75A найден на шине I2C.");
    Serial.print("Конфигурация LM75: 0x");
    Serial.println(tempSensor.conf(), HEX);
  } else {
    Serial.println("LM75A не обнаружен! Проверьте подключение.");
  }

  Serial.println("==============================");
}

void loop() {
  float lux = lightMeter.readLightLevel();
  float temperature = tempSensor.temp();
  
  Serial.print("Освещенность: ");
  Serial.print(lux);
  Serial.print(" lx —————————————");

  Serial.print("Температура: ");
  Serial.print(temperature);
  Serial.println(" °C");

  runServer(lux, temperature);

  delay(1000);
}
