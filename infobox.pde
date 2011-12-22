/* Library to connect to various info sources on the Internet and
 display to LCD display
 
 Thanks to David A. Mellis for the Web Client sketch example
 Thanks to David A. Mellis, Limor Fried and Tom Igoe for LCD sketch example 
 */
#include <SPI.h>
#include <Ethernet.h>
#include <LiquidCrystal.h>
#include <EthernetDHCP.h>

LiquidCrystal lcd(3,8,4,5,6,9);  // (rs, enable, d4, d5, d6, d7) 
int backLight = 7;
int pointer = 0;
static boolean rotating=false;
static boolean sent=false;
String buffer;

byte mac[] = { 
  0x90, 0xA2, 0xDA, 0x00, 0x8D, 0xB5 };
byte server[] = { 
  192,168,1,65 };
  //173,203,125,200 }; // jasonhoekstra.com  //infoserver/weather.php
Client client(server, 80);

void setup()
{
  Serial.begin(9600);
  
  pinMode(2, INPUT); 
  digitalWrite(2, HIGH);
  attachInterrupt(0, changeLCD, CHANGE);

  delay(1000);
  pinMode(backLight, OUTPUT);
  digitalWrite(backLight, HIGH);
  lcd.begin(20,4);
  lcd.clear();
  lcd.setCursor(2,1);
  lcd.print("--- infobox ---");
  lcd.setCursor(0,3);
  lcd.print("Booting up...");
  delay(5000);

  lcd.setCursor(0,3);
  lcd.print("Finding IP address..");
  EthernetDHCP.begin(mac); // this is a blocking call

  lcd.setCursor(0,3);
  lcd.print("IP:");
  const byte* ipAddr = EthernetDHCP.ipAddress();
  lcd.print(ip_to_str(ipAddr));
  lcd.print("         "); // just in case there is junk left over
  delay(5000);
}

void changeLCD()
{  
  rotating=true;
}

void loop()
{
  while(rotating)
  {
    delay(500);
    lcd.clear();
    displayMessage(pointer);

    pointer++;

    if (pointer > 3)
      pointer=0;

    rotating=false;
  }

  //selected = "slashdot";

  if (sent == false) {
    if (client.connect()) {
      Serial.println("connected");
      client.println("GET /infoserver/weather.php HTTP/1.0");
      //client.println("Host: infobox.jasonhoekstra.com");
      client.println();
      //host = "slashdot";
    } 
    else {
      Serial.println("connection failed");
    }
    sent = true;
  }

  if (client.available()) {
    char c = client.read();
    buffer.concat(c);
    Serial.print(c);
  }
  
  

  // if the server's disconnected, stop the client:
  if (!client.connected() && sent) {
    Serial.println("disconnecting.");
    client.stop();
    
    Serial.print(buffer);

    //host = "";
    sent = false;

    for(;;)
      ;
  }


}

void displayMessage(int i) 
{
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("Change to:");
  lcd.setCursor(0,2);

  switch (i) {
  case 0:
    lcd.print("Weather");
    break;
  case 1: 
    lcd.print("Slashdot");
    break;
  case 2: 
    lcd.print("Twitter");
    break;
  case 3: 
    lcd.print("Market");
    break;
  }
}

const char* ip_to_str(const uint8_t* ipAddr)
{
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}


