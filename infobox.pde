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
static int backLight = 7;
static int pointer = 0;
unsigned long changedTime = 0;
unsigned long pageTime = 0;
unsigned long refreshTime = 0;

static boolean rotating=false;
static boolean sent=false;
static boolean update=false;
static boolean receiving=false;
static boolean haveMenuItems=false;

String buffer = "";
char displayItems[5][81]; // buffer for info retrieved from web
static int displayPages=-1;
static int numMenuItems=0;
String menuItemString = "";
char menuItems[10][10]; // max of 10 items, 10 chars long (TODO: would be great to do this as a dynamic list)
static int indexPage=0;


byte mac[] = { 
  0x90, 0xA2, 0xDA, 0x00, 0x8D, 0xB5 };
byte server[] = { 
  173,203,125,200 }; // infobox.betaspaces.com  //infoserver/weather.php
Client client(server, 80);

void setup() {
  //Serial.begin(9600);

  // Prepare rotary encoder
  pinMode(2, INPUT); 
  digitalWrite(2, HIGH);
  
  // Boot up LCD
  lcd.begin(20,4);
  pinMode(backLight, OUTPUT);
  digitalWrite(backLight, HIGH);
  lcd.clear();
  lcd.setCursor(2,1);
  lcd.print("--- infobox ---");
  lcd.setCursor(0,3);
  lcd.print("Booting up...");
  ////////////////////////////////////////////////delay(5000);

  // Find IP address via DHCP
  lcd.setCursor(0,3);
  lcd.print("Finding IP address..");
  EthernetDHCP.begin(mac); // this is a blocking call

  // Display IP address
  lcd.setCursor(0,3);
  lcd.print("IP:");
  const byte* ipAddr = EthernetDHCP.ipAddress();
  lcd.print(ip_to_str(ipAddr));
  lcd.print("         "); // just in case there is junk left over
  delay(1000);
  
  // Get menu items
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("Downloading services");
  delay(5000);
}

void changeLCD() {  
  rotating=true;
}

void loop() {
  // Change the menu while the encoder is rotating
  while(haveMenuItems && rotating) {
    delay(500);
    lcd.clear();

    pointer++;
    if (pointer > numMenuItems) {
      pointer=0;
    }

    displayMessage(pointer);
    lcd.setCursor(0,3);
    //lcd.print(memoryTest()); //DEBUG: show free memory

    rotating=false;
    changedTime = millis()/1000;
    update=true;
  }
  
  // Request menu items from server
  if (!haveMenuItems && !sent) {
    sent=true;
    if (client.connect()) {
      client.println("GET /infoserver/v1/services.php HTTP/1.0");
      client.println("Host: infobox.betaspaces.com");
      client.println();
    } else {
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("Cannot get services.");
      sent=false;
    }
  }
  
  // Change the menu page once it stops rotating
  if (haveMenuItems && !rotating && !update && displayPages>=0 && millis()>pageTime) {
    if (indexPage >= displayPages) {
      indexPage=0;
    }
    else {
      indexPage++;
    }
    writeString(displayItems[indexPage]);
    pageTime=millis()+10000;
  }
  
  // Get an info update from the web
  if ((haveMenuItems && update && (changedTime+2) < (millis() / 1000)) || refreshTime+300000 < millis()) {
    refreshTime=millis();
    clearDisplayBuffer();
    lcd.clear();
    lcd.setCursor(0,0);
    lcd.print("Updating ");
    lcd.print(getService(pointer));
    getPage(getService(pointer).toLowerCase());
    update = false;    
  }
  
  // If inbound traffic, add it to a buffer
  if (client.available()) {
    char c = client.read();
    // Serial.print(c);
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
    sent=false;
    receiving=false;
    if (haveMenuItems) { 
      // If we have menu items, this is an info update
      if (buffer.length() > 0) {
      
        int charpos = 0;
        int disppos = 0;
        
        // Extract pages of information from buffer
        for (int index=0; index<buffer.length() && disppos<6; index++) {
          if (buffer[index]=='|' || charpos==80 || (index==buffer.length()-1)) {  
            displayItems[disppos][charpos]=0;
            charpos=0;
            disppos++;
          }
          else {
            displayItems[disppos][charpos]=buffer[index];
            charpos++;
          }
        }
        displayItems[disppos][charpos]=0;
        displayPages=disppos;

        writeString(displayItems[0]);
        pageTime=millis()+10000;
      }
    } else {
      // Else, we should get the menu items.
      if (buffer.length() > 0) {
        menuItemString=buffer;
        buffer="";
        haveMenuItems=true;
        
        int tick=0;
        for (int i=0; i<menuItemString.length(); i++) {
          if (menuItemString[i] == ',' || i == (menuItemString.length())-1) {
            numMenuItems++;
            tick=0;
          } else {
            menuItems[numMenuItems][tick] = menuItemString[i];
            tick++;
          }
        }
        
        numMenuItems--;
                
        // Update to the first panel
        displayMessage(0);
        update=true;
        
        // Enable the encoder
        attachInterrupt(0, changeLCD, CHANGE);
      } else {
        lcd.clear();
        lcd.setCursor(0,0);
        lcd.println("Unable to download");
        lcd.println("services...");
      }
    }
    buffer="";
    client.stop();
  }
}

void displayMessage(byte i) {
  refreshTime=millis();
  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print("Change to:");
  lcd.setCursor(0,2);
  lcd.print(getService(i));  
  lcd.setCursor(0,3);
}

const char* ip_to_str(const uint8_t* ipAddr) {
  static char buf[16];
  sprintf(buf, "%d.%d.%d.%d\0", ipAddr[0], ipAddr[1], ipAddr[2], ipAddr[3]);
  return buf;
}

String getService(byte i) {
  return menuItems[i]; 
}

void getPage(String page) {
  if (sent == false) {
    sent = true;
    if (client.connect()) {
          client.print("GET /infoserver/v1/");
          client.print(page);
          client.println(".php HTTP/1.0");
    }  
  client.println("Host: infobox.betaspaces.com");
  client.println();
  }    
}  

void writeString(String str) {
  if (str.length() > 0) {
  lcd.clear();
  lcd.setCursor(0,0);
  
  if (str.length() < 21) {
    lcd.print(str);
  }
  else {
    int line=0;
    int chars=0;
    for (int i=0; i<str.length() && i<80; i++)
    {
      if (str[i]=='^') {
        line++;
        chars=0;
        lcd.setCursor(0,line);
      } else {
        if (chars==20) {
          chars=1;
          line++;
          lcd.setCursor(0,line);
        } 
        else { 
          chars++; 
        }    
        lcd.print(str[i]);    
      }
    }
  } }
}


void clearDisplayBuffer() {
  for (byte y=0; y<5; y++) {
    for (byte x=0; x<80; x++) {
      displayItems[y][x] = 0;
    }
  }
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
