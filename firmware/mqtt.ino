bool MQTT_connect() { 
 int8_t ret;

  // Stop if already connected.
  if (mqtt.connected()) {
    return true;
  }

  Serial.print("Connecting to MQTT... ");

  uint8_t retries = 3;
  while ((ret = mqtt.connect()) != 0) { // connect will return 0 for connected
       Serial.println(mqtt.connectErrorString(ret));
       Serial.println("Retrying MQTT connection in 0.5 seconds...");
       mqtt.disconnect();
       delay(500);  // wait 5 seconds
       retries--;
       if (retries == 0) {
         Serial.println("MQTT Failed!");
         return false;
       }
  }
  Serial.println("MQTT Connected!");
  return true;
}  
