//Recive packets of the 6 integer standard used for controlling OPTIX
//Recieved packets are printed to Serial1. This can be monitored with
//an FTDI USB Serial Adapter.

#include <AccelStepper.h>
#include <MultiStepper.h>
#include <Adafruit_NeoPixel.h>

Adafruit_NeoPixel strip(6, 14, NEO_GRB + NEO_KHZ800);

AccelStepper stepper1(AccelStepper::DRIVER, 2, 3);
AccelStepper stepper2(AccelStepper::DRIVER, 4, 5);
AccelStepper stepper3(AccelStepper::DRIVER, 6, 7);
AccelStepper stepper4(AccelStepper::DRIVER, 8, 9);
AccelStepper stepper5(AccelStepper::DRIVER, 10, 11);

AccelStepper stepper6(AccelStepper::DRIVER, 30, 31);
AccelStepper stepper7(AccelStepper::DRIVER, 32, 33);
AccelStepper stepper8(AccelStepper::DRIVER, 34, 35);
AccelStepper stepper9(AccelStepper::DRIVER, 36, 37);
AccelStepper stepper10(AccelStepper::DRIVER, 38, 39);

AccelStepper stepper11(AccelStepper::DRIVER, 42, 43);
AccelStepper stepper12(AccelStepper::DRIVER, 44, 45);
AccelStepper stepper13(AccelStepper::DRIVER, 46, 47);
AccelStepper stepper14(AccelStepper::DRIVER, 48, 49);
AccelStepper stepper15(AccelStepper::DRIVER, 50, 51);

AccelStepper stepper16(AccelStepper::DRIVER, 12, 13);

//Variables to set laser and fog control pins
const int laser_r_pin = 22;
const int laser_g_pin = 23;
const int laser_b_pin = 24;
const int laser_p_pin = 26;
const int fog_pin = 25;

//Variables to hold laser and fog machine states
int laser_r_state = 0;
int laser_g_state = 0;
int laser_b_state = 0;
int laser_p_state = 0;
int fog_state = 0;

int max_speed = 2200;

//Variables for Serial unpacking
const byte numChars = 128;
char receivedChars[numChars];   // an array to store the received data
char tempChars[numChars]; 

//Variables to hold the parsed data -
int cmd = 0;
int scope = 0;
int p1,p2,p3,p4 = 0;

boolean newData = false;

int dataNumber = 0;

void setup() 
{
    Serial.begin(250000);
    Serial1.begin(250000);
    Serial.println("<OPTIX MOTOR CONTROLLER READY>");
    Serial1.println("<OPTIX MOTOR CONTROLLER READY>");

    pinMode(laser_r_pin, OUTPUT);
    pinMode(laser_g_pin, OUTPUT);
    pinMode(laser_b_pin, OUTPUT);
    pinMode(laser_p_pin, OUTPUT);
    pinMode(fog_pin, OUTPUT);

    digitalWrite(laser_r_pin, HIGH);
    digitalWrite(laser_g_pin, HIGH);
    digitalWrite(laser_b_pin, HIGH);
    digitalWrite(laser_p_pin, HIGH);
    digitalWrite(fog_pin, HIGH);

    // Configure each stepper
    set_speeds(max_speed);
    set_accels(1000);

    strip.begin();           
    strip.show();
    strip.setBrightness(255);
}

void loop() 
{
  handle_serial();
  run_steppers();
}

void motor_controller()
{
  //Homing routine
  if (cmd == 1)
  {
    if (scope == 1) {stepper1.setCurrentPosition(0);}
    else if (scope == 2) {stepper2.setCurrentPosition(0);}
    else if (scope == 3) {stepper3.setCurrentPosition(0);}
    else if (scope == 4) {stepper4.setCurrentPosition(0);}
    else if (scope == 5) {stepper5.setCurrentPosition(0);}
    else if (scope == 6) {stepper6.setCurrentPosition(0);}
    else if (scope == 7) {stepper7.setCurrentPosition(0);}
    else if (scope == 8) {stepper8.setCurrentPosition(0);}
    else if (scope == 9) {stepper9.setCurrentPosition(0);}
    else if (scope == 10) {stepper10.setCurrentPosition(0);}
    else if (scope == 11) {stepper11.setCurrentPosition(0);}
    else if (scope == 12) {stepper12.setCurrentPosition(0);}
    else if (scope == 13) {stepper13.setCurrentPosition(0);}
    else if (scope == 14) {stepper14.setCurrentPosition(0);}
    else if (scope == 15) {stepper15.setCurrentPosition(0);}
    else if (scope == 16) {stepper16.setCurrentPosition(0);}
  }
  
  //Move to step now
  if (cmd == 3)
  {
    if (scope == 1) {stepper1.setMaxSpeed(p2); stepper1.moveTo(p1);stepper1.setAcceleration(p3);}
    else if (scope == 2) {stepper2.setMaxSpeed(p2); stepper2.moveTo(p1);stepper2.setAcceleration(p3);}
    else if (scope == 3) {stepper3.setMaxSpeed(p2); stepper3.moveTo(p1);stepper3.setAcceleration(p3);}
    else if (scope == 4) {stepper4.setMaxSpeed(p2); stepper4.moveTo(p1);stepper4.setAcceleration(p3);}
    else if (scope == 5) {stepper5.setMaxSpeed(p2); stepper5.moveTo(p1);stepper5.setAcceleration(p3);}
    else if (scope == 6) {stepper6.setMaxSpeed(p2); stepper6.moveTo(p1);stepper6.setAcceleration(p3);}
    else if (scope == 7) {stepper7.setMaxSpeed(p2); stepper7.moveTo(p1);stepper7.setAcceleration(p3);}
    else if (scope == 8) {stepper8.setMaxSpeed(p2); stepper8.moveTo(p1);stepper8.setAcceleration(p3);}
    else if (scope == 9) {stepper9.setMaxSpeed(p2); stepper9.moveTo(p1);stepper9.setAcceleration(p3);}
    else if (scope == 10) {stepper10.setMaxSpeed(p2); stepper10.moveTo(p1);stepper10.setAcceleration(p3);}
    else if (scope == 11) {stepper11.setMaxSpeed(p2); stepper11.moveTo(p1);stepper11.setAcceleration(p3);}
    else if (scope == 12) {stepper12.setMaxSpeed(p2); stepper12.moveTo(p1);stepper12.setAcceleration(p3);}
    else if (scope == 13) {stepper13.setMaxSpeed(p2); stepper13.moveTo(p1);stepper13.setAcceleration(p3);}
    else if (scope == 14) {stepper14.setMaxSpeed(p2); stepper14.moveTo(p1);stepper14.setAcceleration(p3);}
    else if (scope == 15) {stepper15.setMaxSpeed(p2); stepper15.moveTo(p1);stepper15.setAcceleration(p3);}
    else if (scope == 16) {stepper16.setMaxSpeed(p2); stepper16.moveTo(p1);stepper16.setAcceleration(p3);}
    else if (scope == 20)
    {
      set_speeds(p2);
      stepper1.moveTo(0); stepper2.moveTo(0); stepper3.moveTo(0); stepper4.moveTo(0);
      stepper5.moveTo(0); stepper6.moveTo(0); stepper7.moveTo(0); stepper8.moveTo(0);
      stepper9.moveTo(0); stepper10.moveTo(0); stepper11.moveTo(0); stepper12.moveTo(0);
      stepper13.moveTo(0); stepper14.moveTo(0); stepper15.moveTo(0); stepper16.moveTo(0);
    }
  }

  //Quickset Group 1 Positions
  if (cmd == 21)
  {stepper1.moveTo(p1); stepper2.moveTo(p2); stepper3.moveTo(p3); stepper4.moveTo(p4);}
   
  //Quickset Group 1 Speeds
  if (cmd == 22)
  {stepper1.setMaxSpeed(p1); stepper2.setMaxSpeed(p2); stepper3.setMaxSpeed(p3); stepper4.setMaxSpeed(p4);}
    
  //---------------------------------------------------------------------
  //Quickset Group 2 Positions
  if (cmd == 23)
  {stepper5.moveTo(p1); stepper6.moveTo(p2); stepper7.moveTo(p3); stepper8.moveTo(p4);}
   
  //Quickset Group 2 Speeds
  if (cmd == 24)
  {stepper5.setMaxSpeed(p1); stepper6.setMaxSpeed(p2); stepper7.setMaxSpeed(p3); stepper8.setMaxSpeed(p4);}
   
  //---------------------------------------------------------------------
  //Quickset Group 3 Positions
  if (cmd == 25)
  {stepper9.moveTo(p1); stepper10.moveTo(p2); stepper11.moveTo(p3); stepper12.moveTo(p4);}
   
  //Quickset Group 3 Speeds
  if (cmd == 26)
  {stepper9.setMaxSpeed(p1); stepper10.setMaxSpeed(p2); stepper11.setMaxSpeed(p3); stepper12.setMaxSpeed(p4);}
   
  //---------------------------------------------------------------------
  //Quickset Group 4 Positions
  if (cmd == 27)
  {stepper13.moveTo(p1); stepper14.moveTo(p2); stepper15.moveTo(p3); stepper16.moveTo(p4);}
   
  //Quickset Group 4 Speeds
  if (cmd == 28)
  {stepper13.setMaxSpeed(p1); stepper14.setMaxSpeed(p2); stepper15.setMaxSpeed(p3); stepper16.setMaxSpeed(p4);}
}

void laser_controller()
{
  //Lasers On/Off 
  if (cmd == 4)
  {
    if (scope == 1) 
    {
      if (p1 == 0)  {laser_r_state = 0; digitalWrite(laser_r_pin, HIGH);}  //Red Laser Off
      else if (p1 == 1) {laser_r_state = 1;  digitalWrite(laser_r_pin, LOW);} //Red Laser On
    }

    else if (scope == 2)
    {
      if (p1 == 0)  {laser_g_state = 0; digitalWrite(laser_g_pin, HIGH);}  //Green Laser Off
      else if (p1 == 1) {laser_g_state = 1;  digitalWrite(laser_g_pin, LOW);} //Green Laser On
    }
    
    else if (scope == 3)
    {
      if (p1 == 0)  {laser_b_state = 0; digitalWrite(laser_b_pin, HIGH);}  //Blue Laser Off
      else if (p1 == 1) {laser_b_state = 1;  digitalWrite(laser_b_pin, LOW);} //Blue Laser On
    }

    else if (scope == 4)
    {
      if (p1 == 0)  {laser_p_state = 0; digitalWrite(laser_p_pin, HIGH);}  //Purple Laser Off
      else if (p1 == 1) {laser_p_state = 1;  digitalWrite(laser_p_pin, LOW);} //Purple Laser On
    }
  }

  //Turn Fog Machine on and off
  else if (cmd == 5)
  {
    if (p1 == 0)  {fog_state = 0; digitalWrite(fog_pin, HIGH);}  //Fog Machine Off
    else if (p1 == 1) {fog_state = 1;  digitalWrite(fog_pin, LOW);} //Fog Machine On
  }

  //Control entire Neopixel strip from Serial data
  else if (cmd == 6)
  {
    uint32_t clr = strip.Color(p1, p2, p3);
    strip.fill(clr);
    strip.show();
  }

  //Control single Neopixel pixel from Serial data
  else if (cmd == 12)
  {
    strip.setPixelColor(p4, p1, p2, p3);
    strip.show();   
  }
}

void run_steppers ()
{
  stepper1.run(); stepper2.run(); stepper3.run(); stepper4.run();
  stepper5.run(); stepper6.run(); stepper7.run(); stepper8.run();
  stepper9.run(); stepper10.run(); stepper11.run(); stepper12.run();
  stepper13.run(); stepper14.run(); stepper15.run(); stepper16.run();
}

void set_accels(int accel)
{
  stepper1.setAcceleration(accel); stepper2.setAcceleration(accel);
  stepper3.setAcceleration(accel); stepper4.setAcceleration(accel);
  stepper5.setAcceleration(accel); stepper6.setAcceleration(accel);
  stepper7.setAcceleration(accel); stepper8.setAcceleration(accel);
  stepper9.setAcceleration(accel); stepper10.setAcceleration(accel);
  stepper11.setAcceleration(accel); stepper12.setAcceleration(accel);
  stepper13.setAcceleration(accel); stepper14.setAcceleration(accel);
  stepper15.setAcceleration(accel); stepper16.setAcceleration(accel);
}

void set_speeds(int spd)
{
  stepper1.setMaxSpeed(spd); stepper2.setMaxSpeed(spd);
  stepper3.setMaxSpeed(spd); stepper4.setMaxSpeed(spd);
  stepper5.setMaxSpeed(spd); stepper6.setMaxSpeed(spd);
  stepper7.setMaxSpeed(spd); stepper8.setMaxSpeed(spd);
  stepper9.setMaxSpeed(spd); stepper10.setMaxSpeed(spd);
  stepper11.setMaxSpeed(spd); stepper12.setMaxSpeed(spd);
  stepper13.setMaxSpeed(spd); stepper14.setMaxSpeed(spd);
  stepper15.setMaxSpeed(spd); stepper16.setMaxSpeed(spd);
}

//SERIAL INPUT FUNCTIONS -------------------------------------
void handle_serial()
{
  recvWithStartEndMarkers();
    if (newData == true) {
        strcpy(tempChars, receivedChars);
            // this temporary copy is necessary to protect the original data
            //   because strtok() used in parseData() replaces the commas with \0
        parseData();
        motor_controller();
        laser_controller();
        //showParsedData();
        newData = false;
    }
}

void recvWithStartEndMarkers() {
    static boolean recvInProgress = false;
    static byte ndx = 0;
    char startMarker = '<';
    char endMarker = '>';
    char rc;

    while (Serial.available() > 0 && newData == false) {
        rc = Serial.read();

        if (recvInProgress == true) {
            if (rc != endMarker) {
                receivedChars[ndx] = rc;
                ndx++;
                if (ndx >= numChars) {
                    ndx = numChars - 1;
                }
            }
            else {
                receivedChars[ndx] = '\0'; // terminate the string
                recvInProgress = false;
                ndx = 0;
                newData = true;
            }
        }

        else if (rc == startMarker) {
            recvInProgress = true;
        }
    }
}

void parseData() {      // split the data into its parts

    char * strtokIndx; // this is used by strtok() as an index

    strtokIndx = strtok(tempChars,",");
    cmd = atoi(strtokIndx); 
    strtokIndx = strtok(NULL, ",");
    scope = atoi(strtokIndx);
    strtokIndx = strtok(NULL, ",");
    p1 = atoi(strtokIndx);
    strtokIndx = strtok(NULL, ",");
    p2 = atoi(strtokIndx);
    strtokIndx = strtok(NULL, ",");
    p3 = atoi(strtokIndx);
    strtokIndx = strtok(NULL, ",");
    p4 = atoi(strtokIndx);
}

void showParsedData() {
    Serial1.print("CMD : ");
    Serial1.print(cmd);
    Serial1.print(", SCOPE : ");
    Serial1.print(scope);
    Serial1.print(", PARAMS : ");
    Serial1.print(p1);
    Serial1.print(", ");
    Serial1.print(p2);
    Serial1.print(", ");
    Serial1.print(p3);
    Serial1.print(", ");
    Serial1.println(p4);

    Serial.print("CMD : ");
    Serial.print(cmd);
    Serial.print(", SCOPE : ");
    Serial.print(scope);
    Serial.print(", PARAMS : ");
    Serial.print(p1);
    Serial.print(", ");
    Serial.print(p2);
    Serial.print(", ");
    Serial.print(p3);
    Serial.print(", ");
    Serial.println(p4);   
}
