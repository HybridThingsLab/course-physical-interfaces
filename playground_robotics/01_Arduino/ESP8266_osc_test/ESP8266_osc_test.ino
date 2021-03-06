// documentation ESP8266: https://www.mikrocontroller-elektronik.de/nodemcu-esp8266-tutorial-wlan-board-arduino-ide/

// libraries
#include <ArduinoOSC.h> // https://github.com/hideakitai/ArduinoOSC
#include <Chrono.h> // https://github.com/SofaPirate/Chrono

// WiFi stuff
const char* ssid = "maschinenraum";
const char* pwd = "maschinenraum";
const IPAddress ip(192, 168, 1, 200);
const IPAddress gateway(192, 168, 1, 1);
const IPAddress subnet(255, 255, 255, 0);

// for ArduinoOSC
OscWiFi osc;
const char* host = "192.168.1.100";
const int recv_port = 9999;
const int send_port = 8888;

// Instanciate a chrono object.
Chrono replyChrono; 
int timer = 25;

void setup() {
  Serial.begin(115200);

  // pin modes
  pinMode(LED_BUILTIN, OUTPUT);

  // WiFi stuff
  WiFi.begin(ssid, pwd);
  WiFi.config(ip, gateway, subnet);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.print("WiFi connected, IP = "); Serial.println(WiFi.localIP());

  // ArduinoOSC
  osc.begin(recv_port);


  osc.subscribe("/led", [](OscMessage & m) {
    Serial.print("led : ");
    Serial.print(m.ip()); Serial.print(" ");
    Serial.print(m.port()); Serial.print(" ");
    Serial.print(m.size()); Serial.print(" ");
    Serial.print(m.address()); Serial.print(" ");
    Serial.println(m.arg<int>(0));

    int state = m.arg<int>(0);
    controlLED(state);

  });

}

void loop() {
  osc.parse(); // should be called

  // check if chrono
  if (replyChrono.hasPassed(timer) ) {
    replyChrono.restart();
    osc.send(host, send_port, "/send", (int)random(1000));
  }

}

void controlLED(int state) {
  // dirty bugfix touchOSC (is sending 1.0 instead of 1)
  if(state == 1065353216) state = 1;
  digitalWrite(LED_BUILTIN, state);
}
