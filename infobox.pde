/* Library to connect to various info sources on the Internet and
   display to LCD display
 
   Thanks to David A. Mellis for the Web Client sketch example
   Thanks to David A. Mellis, Limor Fried and Tom Igoe for LCD sketch example 
*/
#include <SPI.h>
#include <Ethernet.h>
#include <LiquidCrystal.h>

LiquidCrystal lcd(3,8,4,5,6,9);  // (rs, enable, d4, d5, d6, d7) 
int backLight = 7;
int pointer = 0;
static boolean rotating=false;

byte mac[] = {  0x90, 0xA2, 0xDA, 0x00, 0x8D, 0xB5 };
byte ip[] = { 192,168,2,200 };
//byte server[] = { 173,203,125,200 }; // jasonhoekstra.com
byte server[] = { 74,125,115,121 }; // slashdot

boolean sent = false;
String host = "";
String buffer = "";
String selected = "";

Client client(server, 80);

void setup()
{
  //pinMode(2, INPUT);  
  pinMode(2, INPUT); 
  digitalWrite(2, HIGH);
  attachInterrupt(0, changeLCD, CHANGE);
  
  // start the Ethernet connection:
  Ethernet.begin(mac, ip);
  // start the serial library:
  Serial.begin(9600);
  // give the Ethernet shield a second to initialize:
  delay(1000);
  Serial.println("connecting...");
    Serial.begin(9600);
  pinMode(backLight, OUTPUT);
  digitalWrite(backLight, HIGH);
  delay(2000);
  lcd.begin(20,4);
  lcd.clear();
  lcd.setCursor(2,1);
  lcd.print("--- infobox ---");
  lcd.setCursor(0,3);
  lcd.print("Obtaining IP...");
  delay(5000);
  
    lcd.clear();                  // start with a blank screen
    lcd.setCursor(0,0);           // set cursor to column 0, row 0 (the first row)
  
  lcd.print("Tonight: Sunny. Highs in the mid 50s to lower 60s. Northeast winds 5 to 15 mph.");
  
}

void changeLCD()
{  
  rotating=true;
}

void loop()
{
  while(rotating)
  {
    delay(500); // debounce by waiting 2 milliseconds
    lcd.clear();
    displayMessage(pointer);
    pointer++;
    if (pointer > 3)
      pointer=0;
    
    rotating=false; // Reset the flag
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
