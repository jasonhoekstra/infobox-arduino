// Library to connect to various info sources on the Internet and
// display to LCD display
//
// Thanks to David A. Mellis for the Web Client sketch example
// Thanks to David A. Mellis, Limor Fried and Tom Igoe for LCD sketch example

#include <SPI.h>
#include <Ethernet.h>
#include <LiquidCrystal.h>

LiquidCrystal lcd(1,8,3,5,6,9);  // let's try less pins - LiquidCrystal(rs, enable, d4, d5, d6, d7) 
int backLight = 0;    // pin 0 will control the backlight

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
byte mac[] = {  0x90, 0xA2, 0xDA, 0x00, 0x8D, 0xB5 };
byte ip[] = { 192,168,1,200 };
//byte server[] = { 72,14,204,99 }; // Google
byte server[] = {199,59,148,87}; //Twitter

// Initialize the Ethernet client library
Client client(server, 80);

void setup()
{
    Serial.begin(9600);
  // give the Ethernet shield a second to initialize:
  Serial.println("setting...");
  // setupLCD;
  setupEthernet;
}

void loop()
{
  // if there are incoming bytes available 
  // from the server, read them and print them:
  if (client.available()) {
    char c = client.read();
    Serial.print(c);
  }

  // if the server's disconnected, stop the client:
  if (!client.connected()) {
    Serial.println();
    Serial.println("disconnecting.");
    client.stop();

    // do nothing forevermore:
    for(;;)
      ;
  }
}


void writeMessage()
{
  lcd.setCursor(0,0);           // set cursor to column 0, row 0 (the first row)
  lcd.print("tinybox");    // change this text to whatever you like. keep it clean.
  lcd.setCursor(0,1);           // set cursor to column 0, row 1
  lcd.print("version 0.1");
}

void setupLCD()
{
  pinMode(backLight, OUTPUT);
  digitalWrite(backLight, HIGH); // turn backlight on. Replace 'HIGH' with 'LOW' to turn it off.
  delay(2000);
  lcd.begin(16,2);              // columns, rows.  use 16,2 for a 16x2 LCD, etc.
  lcd.clear();                  // start with a blank screen
}

void setupEthernet()
{
    // start the Ethernet connection:
  Ethernet.begin(mac, ip);
  // give the Ethernet shield a second to initialize:
  delay(1000);
  Serial.println("connecting...");
  
  Client client(server, 80); // 199.59.149.232  

  // if you get a connection, report back via serial:
  if (client.connect()) {
    Serial.println("connected");
    // Make a HTTP request:
    // https://api.twitter.com/1/statuses/user_timeline.json?screen_name=jasonhoekstra&count=2
    //client.println("GET /search?q=arduino HTTP/1.0");
    client.println("GET /1/statuses/user_timeline.json?screen_name=jasonhoekstra&count=2");    
    client.println();
  } 
  else {
    // kf you didn't get a connection to the server:
    Serial.println("connection failed");
  }
}
