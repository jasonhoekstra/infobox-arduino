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
unsigned long changedTime = 0;

static boolean rotating=false;
static boolean sent=false;
static boolean update=false;
static boolean receiving=false;
String buffer = "";
char* menuItems[] = {"","","","","","","","","",""};

byte mac[] = { 
  0x90, 0xA2, 0xDA, 0x00, 0x8D, 0xB5 };
byte server[] = { 
  192,168,1,65 };
  //173,203,125,200 }; // jasonhoekstra.com  //infoserver/weather.php
Client client(server, 80);

void setup() {
  Serial.begin(9600);
  lcd.begin(20,4);
  
  pinMode(2, INPUT); 
  digitalWrite(2, HIGH);
  attachInterrupt(0, changeLCD, CHANGE);

  delay(1000);
  pinMode(backLight, OUTPUT);
  digitalWrite(backLight, HIGH);
  lcd.clear();
  lcd.setCursor(2,1);
  lcd.print("--- infobox ---");
  lcd.setCursor(0,3);
  lcd.print("Booting up...");
  ////////////////////////////////////////////////delay(5000);

  lcd.setCursor(0,3);
  lcd.print("Finding IP address..");
  EthernetDHCP.begin(mac); // this is a blocking call

  lcd.setCursor(0,3);
  lcd.print("IP:");
  const byte* ipAddr = EthernetDHCP.ipAddress();
  lcd.print(ip_to_str(ipAddr));
  lcd.print("         "); // just in case there is junk left over
  /////////////////////////////////////////////delay(5000);
}

void changeLCD() {  
  rotating=true;
}

void loop() {
  while(rotating) {
    delay(500);
    lcd.clear();

    pointer++;
    if (pointer > 3)
      pointer=0;

    displayMessage(pointer);

    rotating=false;
    changedTime = millis()/1000;
    update=true;
  }
  
  if (update && (changedTime+2) < (millis() / 1000)) {
    lcd.clear();
    lcd.setCursor(0,0);
    lcd.print("Updating ");
    lcd.print(getService(pointer));
    getPage(getService(pointer).toLowerCase());
    update = false;    
  }
  
  if (client.available()) {
    char c = client.read();
    Serial.print(c);
    if (!receiving) {
      if (c == '#') {
        c = client.read();
        if (c == '@') {
          c = client.read();
          if (c == '!') {
            receiving = true;
          }
        }
      }
    }      
    else {
      buffer.concat(c);
    }
  }
  
  if (!client.connected() && sent) {
    sent = false;
    lcd.clear();
    Serial.println(buffer);
    if (buffer.length() > 0) { 
      writeString(buffer);
    }
    buffer="";
    client.stop();
  }
}

void displayMessage(byte i) {
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("Change to:");
  lcd.setCursor(0,2);
  lcd.print(getService(i));  
  lcd.setCursor(0,3);
  //lcd.print(memoryTest());
}

const char* ip_to_str(const uint8_t* ipAddr) {
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}

String getService(byte i) {
  switch (i) {
  case 0:
    return "Weather";
    break;
  case 1: 
    return "Slashdot";
    break;
  case 2: 
    return "Twitter";
    break;
  case 3: 
    return "Market";
    break;
  }  
}

void getPage(String page) {
  if (sent == false) {
    sent = true;
    if (client.connect()) {
          client.print("GET /infoserver/");
          client.print(page);
          client.println(".php HTTP/1.0");
    }  
  client.println("Host: infobox.jasonhoekstra.com");
  client.println();
  }    
}  

void writeString(String str) {
  lcd.clear();
  lcd.setCursor(0,0);
  
  if (str.length() < 21) {
    lcd.print(str);
  }
  else {
    byte line=0;
    byte chars=0;
    for (byte i=0; i<str.length() && i<80; i++)
    {
      if (str[i]=='#') {
        line++;
        chars=0;
        lcd.setCursor(0,line);
      } else {
        lcd.print(str[i]);
        if (chars==20) {
          chars=0;
          line++;
          lcd.setCursor(0,line);
        }        
      }
    }
  }

/*    int itrs = str.length() / 20;
    Serial.println(itrs);
    if (itrs > 3) { itrs=3; }
    for (byte i=0; i<=itrs; i++) {
      lcd.setCursor(0,i);
      lcd.print(str.substring((i*20), (i*20)+20));   
      Serial.println(str.substring((i*20), (i*20)+20));
    }
//  } */
}

/*
// this function will return the number of bytes currently free in RAM
int memoryTest() {
  int byteCounter = 0; // initialize a counter
  byte *byteArray; // create a pointer to a byte array
  // More on pointers here: http://en.wikipedia.org/wiki/Pointer#C_pointers

  // use the malloc function to repeatedly attempt allocating a certain number of bytes to memory
  // More on malloc here: http://en.wikipedia.org/wiki/Malloc
  while ( (byteArray = (byte*) malloc (byteCounter * sizeof(byte))) != NULL ) {
    byteCounter++; // if allocation was successful, then up the count for the next try
    free(byteArray); // free memory after allocating it
  }
  
  free(byteArray); // also free memory after the function finishes
  return byteCounter; // send back the highest number of bytes successfully allocated
}
*/
