// sGarage - A Smart Garage for the future of humanity.
// February 1st, 2020. Made for QHacks 5, at Queen's University at Kingston
// George Trieu, Sinan Sinan

#include <Servo.h>

Servo open_servo;

int pos = 0;

void setup() {
  open_servo.attach(D1);
  open_servo.write(70);
  delay(10000);
}

void loop() {
  open_servo.write(170);
}
