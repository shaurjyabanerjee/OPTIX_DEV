// Example by Tom Igoe

import processing.serial.*;
// The serial port:
Serial myPort;
String msg;


void setup()
{
  // List all the available serial ports:
  printArray(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[0], 250000);
}

void draw()
{
  // Send a capital "A" out the serial port
  //myPort.write("<");
  //myPort.write(2);
  //myPort.write(",");
  //myPort.write(20);
  //myPort.write(",");
  //myPort.write(50);
  //myPort.write(",");
  //myPort.write(90);
  //myPort.write(",");
  //myPort.write(10);
  //myPort.write(",");
  //myPort.write(88);
  //myPort.write(">");
  
  msg = "<"+cmd+","+scope+","p1","+p2+","+p3+","+p4+">";
  myPort.write(msg);
  
  delay(900);
  
  myPort.write("<20,10,300,5000,666,9000>");


  delay(1000);
}
