/* Library to connect to various info sources on the Internet and
   display to LCD display
 
   Thanks to David A. Mellis for the Web Client sketch example
   Thanks to David A. Mellis, Limor Fried and Tom Igoe for LCD sketch example 
*/
#include <SPI.h>
#include <Ethernet.h>
#include <LiquidCrystal.h>

LiquidCrystal lcd(2,8,3,5,6,9);  // let's try less pins - LiquidCrystal(rs, enable, d4, d5, d6, d7) 
int backLight = 7;    // pin 0 will control the backlight

byte mac[] = {  0x90, 0xA2, 0xDA, 0x00, 0x8D, 0xB5 };
byte ip[] = { 192,168,2,200 };
//byte server[] = { 199,59,148,87 }; //Twitter
//byte server[] = { 140,90,113,229 }; // NWS
//byte server[] = { 173,203,125,200 }; // jasonhoekstra.com
byte server[] = { 74,125,115,121 }; // slashdot

boolean sent = false;
String host = "";
String buffer = "";
String selected = "";

Client client(server, 80);

void setup()
{
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
  delay(50000);
  
    lcd.clear();                  // start with a blank screen
    lcd.setCursor(0,0);           // set cursor to column 0, row 0 (the first row)
  /* lcd.print("Now (12/21 @ 13:16)");    // change thi s text to whatever you like. keep it clean.
    lcd.setCursor(0,1);           // set cursor to column 0, row 0 (the first row)
  lcd.print("Partly Cloudy");    // change thi s text to whatever you like. keep it clean.
    lcd.setCursor(0,2);           // set cursor to column 0, row 0 (the first row)
  lcd.print("Temp: 58F Vis: 10mi");    // change thi s text to whatever you like. keep it clean.
    lcd.setCursor(0,3);           // set cursor to column 0, row 0 (the first row)
  lcd.print("Wind: 3mph East");    // change thi s text to whatever you like. keep it clean. */
  
  lcd.print("Tonight: Sunny. Highs in the mid 50s to lower 60s. Northeast winds 5 to 15 mph.");
  
}

void loop()
{
  // http://www.weather.gov/xml/current_obs/KSFO.xml
  // 140.90.113.229 /xml/current_obs/KSFO.xml
  // http://rss.slashdot.org/Slashdot/slashdot - 74.125.115.121

  selected = "slashdot";

  if (sent == false && selected == "slashdot") {
    if (client.connect()) {
      Serial.println("connected");
      client.println("GET /Slashdot/slashdot HTTP/1.0");
      client.println("Host: rss.slashdot.org");
      client.println();
      host = "slashdot";
    } 
    else {
      Serial.println("connection failed");
    }
    sent = true;
  }
    
  
  if (sent == false && selected == "nws") {
    if (client.connect()) {
      Serial.println("connected");
      client.println("GET /KSFO.xml HTTP/1.0");
      client.println("Host: www.jasonhoekstra.com");
      client.println();
      host = "nws";
    } 
    else {
      // kf you didn't get a connection to the server:
      Serial.println("connection failed");
    }
    sent = true;
  }
  
  
  if (sent == false && selected == "twitter") {
      // if you get a connection, report back via serial:
    if (client.connect()) {
      Serial.println("connected");
      // Make a HTTP request:
      client.println("GET /1/statuses/user_timeline.json?screen_name=jasonhoekstra&count=2 HTTP/1.0");
      client.println("Host: api.twitter.com");
      client.println();
      host = "twitter";
    } 
    else {
      // kf you didn't get a connection to the server:
      Serial.println("connection failed");
    }
    sent = true;
  }
  
  // if there are incoming bytes available 
  // from the server, read them and print them:
  if (client.available()) {
    
    char c = client.read();
    
    if(c=='\n') {
      //Serial.println(buffer);
      //Serial.println("===========================");
      
      checkRSS(buffer);
      // For NWS
      //checkWeather(buffer);
      buffer = "";
    } else
    {
      buffer.concat(c);
    }
    
    //Serial.print(c);
  }

  // if the server's disconnected, stop the client:
  if (!client.connected() && sent) {
    Serial.println("disconnecting.");
    client.stop();
    host = "";
    sent = false;
    
    for(;;)
     ;
 }
}

void writeMessage()
{
  //lcd.setCursor(0,0);           // set cursor to column 0, row 0 (the first row)
  //lcd.print("tinybox");    // change this text to whatever you like. keep it clean.
  //lcd.setCursor(0,1);           // set cursor to column 0, row 1
  //lcd.print("version 0.1");
}

void setupLCD()
{
  //pinMode(backLight, OUTPUT);
  //digitalWrite(backLight, HIGH); // turn backlight on. Replace 'HIGH' with 'LOW' to turn it off.
  //delay(2000);
  //lcd.begin(16,2);              // columns, rows.  use 16,2 for a 16x2 LCD, etc.
  //lcd.clear();                  // start with a blank screen
}

void checkWeather(String str)
{
  // <temp_f>54.0 F</temp_f>
  // <wind_mph>5.8</wind_mph> <wind_dir>Northeast</wind_dir>
  // <visibility_mi>7.00</visibility_mi>
  
  if (str.indexOf("<observation_time>") >= 0 || str.indexOf("<weather>") >= 0 || 
  str.indexOf("<temp_f>") >= 0 || str.indexOf("<wind_mph>") >= 0 ||
  str.indexOf("<wind_dir>") >= 0 || str.indexOf("<visibility_mi>") >= 0 ) {
    Serial.println(popString(str));
  }
}

void checkRSS(String str)
{  
  if (str.indexOf("<title>") >= 0) {
    Serial.println(popString(str));
  }
}

String popString(String str)
{
    int istart = str.indexOf(">") + 1;
    int iend = str.lastIndexOf("<");
    return str.substring(istart, iend);
}
