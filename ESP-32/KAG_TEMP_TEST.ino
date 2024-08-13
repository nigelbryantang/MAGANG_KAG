float ppm, Temp, Hum, finaltemp, finalppm;
unsigned long sendDataPrevMillis = 0;
unsigned long hourlyDataPrevMillis = 0;
unsigned long hourlyInterval = 3600000;
//const int maxEntries = 72;
#include <time.h>
#include "DHT.h"
#include "WiFi.h"
#include <Firebase_ESP_Client.h>
#include <MQ135.h>
#define SUHU 2
#define DHTTYPE DHT22
DHT dht(SUHU, DHTTYPE);
#define pin 36
MQ135 CO2(pin);
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>
// const char* SSID= "CHINANUMBAWAN";
// const char* pass= "88888888";
const char* SSID= "SCAN1-N";
const char* pass= "p@ssw0rd";
#define API_KEY "AIzaSyDjZnrWLuLI_J9g_MbMz_vHOS6_MHCsZyw"
#define DATABASE_URL "https://aaamin-53ef0-default-rtdb.firebaseio.com/"
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
bool signupOK=false;

void setup() {
  Serial.begin(115200);
  dht.begin();
  WiFi.begin(SSID,pass);
  Serial.print("CONNECTING");
  while (WiFi.status()!= WL_CONNECTED){
    //Serial.print(".");
    delay(100);
  }
  //Serial.println();
  //Serial.println(WiFi.localIP());
  config.api_key=API_KEY;
  config.database_url=DATABASE_URL;
  if (Firebase.signUp(&config, &auth, "", "")){
    //Serial.println("ok");
    signupOK = true;
  }
  else{
    //Serial.printf("%s\n", config.signer.signupError.message.c_str());
  }
  config.token_status_callback=tokenStatusCallback;
  Firebase.begin(&config,&auth);
  Firebase.reconnectWiFi(true);
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  setenv("TZ", "UTC-7", 1); // Set the time zone, adjust as needed
  tzset();
}

void loop() {
  sensor_dht();
  mq135();
  DATA();
  // Serial.print("Temp: "); Serial.println(Temp);
  // Serial.print("Hum: "); Serial.println(Hum);
  // Serial.print("CO2: "); Serial.println(ppm);
  finaltemp= Temp-8.5;
  finalppm= ppm+100;
  delay(1000);
}

void sensor_dht(){
  Temp= dht.readTemperature();
  Hum=dht.readHumidity();
}

void mq135(){
  ppm = CO2.getPPM();
}

String formatTimestamp(time_t rawTime) {
  struct tm* timeInfo;
  char buffer[25];

  timeInfo = localtime(&rawTime);
  strftime(buffer, sizeof(buffer), "%Y-%m-%d %H:%M:%S", timeInfo);
  return String(buffer);
}

void logDataWithTimestamp() {
  time_t now;
  time(&now);
  String timestamp = formatTimestamp(now);
  int maxRetries = 5;
  int attempt = 0;
  bool success = false;

  while (attempt < maxRetries && !success) {
    attempt++;
    // if (Firebase.RTDB.setFloat(&fbdo, "Place 1/CS_2/" + timestamp + "/Temp", finaltemp) &&
    //     Firebase.RTDB.setFloat(&fbdo, "Place 1/CS_2/" + timestamp + "/Hum", Hum) &&
    //     Firebase.RTDB.setFloat(&fbdo, "Place 1/CS_2/" + timestamp + "/CO2", finalppm)) {
    //   //Serial.println("Logged data with timestamp.");
    //   success = true;
      
    // } 
    if (Firebase.RTDB.setFloat(&fbdo, "Place 1/CS 1/" + timestamp + "/Temp", finaltemp) &&
        Firebase.RTDB.setFloat(&fbdo, "Place 1/CS 1/" + timestamp + "/Hum", Hum) &&
        Firebase.RTDB.setFloat(&fbdo, "Place 1/CS 1/" + timestamp + "/CO2", finalppm)) {
      //Serial.println("Logged data with timestamp.");
      success = true;
      
    } 
  }
}

void DATA(){
  if (Firebase.ready() && signupOK){

    // if (millis() - sendDataPrevMillis > 10000 || sendDataPrevMillis == 0) {
    //   sendDataPrevMillis = millis();
    //   Firebase.RTDB.setFloat(&fbdo, "Place 1/Current/CS_2/Temp", finaltemp);
    //   Firebase.RTDB.setFloat(&fbdo, "Place 1/Current/CS_2/Hum", Hum);
    //   Firebase.RTDB.setFloat(&fbdo, "Place 1/Current/CS_2/CO2", finalppm);
    // }
    if (millis() - sendDataPrevMillis > 10000 || sendDataPrevMillis == 0) {
      sendDataPrevMillis = millis();
      Firebase.RTDB.setFloat(&fbdo, "Place 1/Current/CS 1/Temp", finaltemp);
      Firebase.RTDB.setFloat(&fbdo, "Place 1/Current/CS 1/Hum", Hum);
      Firebase.RTDB.setFloat(&fbdo, "Place 1/Current/CS 1/CO2", finalppm);
    }

    if (millis() - hourlyDataPrevMillis > hourlyInterval) {
      hourlyDataPrevMillis = millis();
      logDataWithTimestamp();
    }
  }
}
