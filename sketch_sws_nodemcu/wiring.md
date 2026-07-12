# Verdrahtung – Solar WiFi Weather Station (NodeMCU V3)

Board: **NodeMCU V3** (ESP8266 12F, CH340)

---

## Pinbelegung

| NodeMCU Pin | GPIO | Funktion | Bauteil |
|-------------|------|----------|---------|
| 3V3 | – | Versorgung | BME280 VCC, DS18B20 VCC |
| GND | – | Masse | alle Bauteile |
| D1 | GPIO5 | I²C SCL | BME280 SCL |
| D2 | GPIO4 | I²C SDA | BME280 SDA |
| D6 | GPIO12 | Config-Button | Taster gegen GND |
| D7 | GPIO13 | OneWire Data | DS18B20 Data |
| D0 | GPIO16 | Deep-Sleep Wake | mit RST verbinden |

---

## BME280 (Temperatur / Luftfeuchtigkeit / Luftdruck)

```
NodeMCU V3             BME280
──────────             ──────
3V3             ────  VCC
GND             ────  GND
D1 (GPIO5)      ────  SCL
D2 (GPIO4)      ────  SDA
```

> Adresse: 0x76 (SDO → GND) oder 0x77 (SDO → VCC)

---

## DS18B20 (Pooltemperatur, OneWire)

```
NodeMCU V3             DS18B20
──────────             ───────
3V3             ────  VCC  (Pin 3)
GND             ────  GND  (Pin 1)
D7 (GPIO13)     ────  Data (Pin 2)

3V3 ── 4,7kΩ ──┬── D7 (GPIO13)
               └── DS18B20 Data
```

---

## Config-Button

```
D6 (GPIO12) ── Taster ── GND
```

Beim Boot gedrückt halten → Config-Portal (AP: "SWS-Config", 192.168.4.1)

---

## Deep Sleep (Batteriebetrieb)

```
D0 (GPIO16) ──── RST
```

> GPIO16 liefert beim Deep-Sleep-Wakeup einen LOW-Puls → RST startet den ESP neu.
> Ohne diese Brücke kein Aufwachen aus Deep Sleep!
