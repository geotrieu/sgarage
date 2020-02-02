// sGarage - A Smart Garage for the future of humanity.
// February 1st, 2020. Made for QHacks 5, at Queen's University at Kingston
// George Trieu, Sinan Sinan

#include <Adafruit_MQTT.h>
#include <Adafruit_MQTT_Client.h>
#include <Servo.h>
#include <ESP8266WiFi.h>

Servo open_servo; //Range is from 170 (Closed) to 70 (Open)

const int trigPin = D3;
const int echoPin = D2;

//MQTT Details
#define MQTT_SERVER "5.196.95.208"
#define MQTT_PORT 1883                    
#define MQTT_USERNAME "" 
#define MQTT_PASSWORD "" 

char ssid[10] = "";
char password[20] = "";

WiFiClient client; 
Adafruit_MQTT_Client mqtt(&client, MQTT_SERVER, MQTT_PORT, MQTT_USERNAME, MQTT_PASSWORD); 
Adafruit_MQTT_Publish sgarage = Adafruit_MQTT_Publish(&mqtt, MQTT_USERNAME "sgarage");
Adafruit_MQTT_Subscribe sgarage_p = Adafruit_MQTT_Subscribe(&mqtt, MQTT_USERNAME "sgarage-p");

int pos = 0;
bool mqttConnected = false;
bool doorOpen = false;

long takeMeasurement() {
  long duration;
  int distance;
  // Clears the trigPin
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  // Sets the trigPin on HIGH state for 10 micro seconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  // Reads the echoPin, returns the sound wave travel time in microseconds
  duration = pulseIn(echoPin, HIGH);
  // Calculating the distance
  distance = duration * 0.034 /2;
  return distance;
}

void setup() {
  open_servo.attach(D1);
  pinMode(trigPin, OUTPUT); // Sets the trigPin as an Output
  pinMode(echoPin, INPUT); // Sets the echoPin as an Input
  Serial.begin(9600); // Starts the serial communication

  WiFi.begin(ssid, password);
  Serial.println(""); 
  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  //MQTT Init
  mqtt.subscribe(&sgarage_p);
  mqttConnected = MQTT_connect();
  
  open_servo.write(170);
  delay(500);
}

void loop() {
  Adafruit_MQTT_Subscribe *subscription;
  while ((subscription = mqtt.readSubscription())) {
    if (subscription == &sgarage_p) {
      String lastread;
      lastread = ((char *)sgarage_p.lastread);
      if (lastread == "OPEN") {
        open_servo.write(70);
        Serial.println("OPENING"); 
      }
      else if (lastread == "CLOSE") {
        open_servo.write(170);
        Serial.println("CLOSING");
      }
    }
  }
  String arduinoprocess = "";
  arduinoprocess = readSerial();
  char arduinoprocesschar[arduinoprocess.length() + 1];
  arduinoprocess.toCharArray(arduinoprocesschar, arduinoprocess.length() + 1);
  if (mqttConnected) {
    if (arduinoprocess != "") {
      sgarage.publish(arduinoprocesschar);
    }
  }
}

String readSerial() {
  String input;
  while (Serial.available()) {
    char c = (char)Serial.read();
    if (c != 0x0A && c != 0x0D) {
      //Block Newline / Carriage Return Characters
      input += c;
    }
  }
  return input;
}
