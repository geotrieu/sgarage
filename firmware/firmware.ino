// sGarage - A Smart Garage for the future of humanity.
// February 1st, 2020. Made for QHacks 5, at Queen's University at Kingston
// George Trieu, Sinan Sinan

#include <Servo.h>

Servo open_servo; //Range is from 170 (Closed) to 70 (Open)

const int trigPin = D3;
const int echoPin = D2;

int pos = 0;

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
  open_servo.write(170);
}

void loop() {
  open_servo.write(170);
  delay(500);
  Serial.println(takeMeasurement());
  delay(1000);
  open_servo.write(70);
  delay(500);
  Serial.println(takeMeasurement());
}
