
//Dual Serial Test using FTDI USB-Serial interface
//OPTIX 2022

void setup() 
{
  Serial.begin(9600);
  Serial1.begin(9600);
}

void loop() 
{
  Serial.println("LOLCATZ");
  delay(40);
  Serial1.println("LOLDOGZ");
  delay(40);
}
