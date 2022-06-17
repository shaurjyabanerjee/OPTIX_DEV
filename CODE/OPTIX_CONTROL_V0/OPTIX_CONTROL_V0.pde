//GUI to interact with and program OPTIX
//Serial control of 16 stepper motors with variable microstepping
//Shaurjya Banerjee 2022

import controlP5.*;
import processing.serial.*;
import java.util.*;

ControlP5 cp5;
Serial myPort;
String msg = "<>";

//ANIMATION PLAYBACK HANDLING VARIABLES ---------------------
String packets1[];
String packets2[];
String packets3[];

String anim1_name = "animation1.txt";
String anim2_name = "animation2.txt";
String anim3_name = "animation3.txt";

int anim1_length = 899;
int anim2_length = 23;
int anim3_length = 23;

PrintWriter anim_output;

int serial_delay = 5;

int default_speed = 2200;
int default_accel = 1000;
int max_speed = default_speed;
int max_accel = default_accel;

//GUI Styling Variables
int myColorBackground = color(0,0,0);
int knob_size = 35;
int knob_spacing = 200;
int knob_base_x = 100;
int knob_base_y = 180;
int g_base_x = 830;
int g_base_y = 170;
int g_button_width = 170;
int g_button_height = 50;
int g_spacing_x = 180;
int g_spacing_y = 60;
int pos_base_x = g_base_x;
int pos_base_y = 15;
int pos_spacing_x = 90;
int pos_spacing_y = 38;

//Position variables 
final int steps_per_rev = 200;
int microstep_multiplier = 4;
float step_angle = 360.0/(steps_per_rev*microstep_multiplier);
int positions[] = new int [16];

//GUI state storage variables
int position_vals[] = new int[16];
int speed_vals[] = new int[16];
int home_vals[] = new int[16];
int laser_vals [] = new int[4];
int laser_counts[] = new int [4];
int fog_state = 0;
int fog_count = 0;
int esc_state = 0;

//LED control variables
int r1_val, g1_val, b1_val = 0;
int r2_val, g2_val, b2_val = 0;
int num_pixels = 6;
int pix_val = 0;

//Create global Control P5 GUI Elements
Knob position_knobs[] = new Knob[16];
Knob speed_knobs[] = new Knob[16];
Slider speed_slider;
Slider accel_slider;
Knob led_index_select;
Knob led_fade_length;

//KEYFRAMING VARIABLES -----------------------------------------------
int anim_length = 20000;

void setup() {
  size(2000,1000);
  smooth();
  
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[0], 250000);
  
  cp5 = new ControlP5(this);
  
  anim_output = createWriter("positions.txt"); 
    
  //Set font for ControlP5 objects as well as text objects
   PFont p = createFont("OCRAExtended", 14); 
   ControlFont font = new ControlFont(p);
   textFont(p);
   cp5.setFont(font);
   cp5.setColorForeground(0xff6BD425);
   cp5.setColorBackground(0xff42113C);
   cp5.setColorActive(0xff618B25);

  //Style and setup all repeated GUI elements within this for loop
  for(int i = 0; i < position_knobs.length; i++)
  {
    position_knobs[i] = cp5.addKnob("POSITION " + (i+1))
                 .setRange(0,360)
                 .setValue(0)
                 .setPosition(knob_base_x + (i%4 * knob_spacing), knob_base_y + (i/4 * knob_spacing))
                 .setRadius(knob_size)
                 .showTickMarks()
                 .setTickMarkLength(knob_size/4)
                 .setTickMarkWeight(2.5)
                 .setDragDirection(Knob.VERTICAL)
                 .setAngleRange(2*PI)
                 .setStartAngle(PI/2)
                 .setResolution(microstep_multiplier*steps_per_rev);
                 
     speed_knobs[i] = cp5.addKnob("SPEED " + (i+1))
                 .setRange(10,4200)
                 .setValue(2200)
                 .setPosition(knob_base_x - 75 + (i%4 * knob_spacing), knob_base_y + (i/4 * knob_spacing))
                 .setRadius(knob_size/2)
                 .setDragDirection(Knob.VERTICAL);
                 
     cp5.addButton("HOME" + (i+1))
     .setValue(0)
     .setPosition(knob_base_x - 90 + (i%4 * knob_spacing), knob_base_y + 80 + (i/4 * knob_spacing))
     .setSize(66,20)
     .setSwitch(true)
     .setId(i+100);
    
    cp5.addButton((i+1) + " +")
     .setValue(0)
     .setPosition(knob_base_x - 52 + (i%4 * knob_spacing), knob_base_y + 105 + (i/4 * knob_spacing))
     .setSize(31,19)
     .setId(i+20);
     
    cp5.addButton((i+1) + " -")
     .setValue(0)
     .setPosition(knob_base_x - 90 + (i%4 * knob_spacing), knob_base_y + 105 + (i/4 * knob_spacing))
     .setSize(30,19)
     .setId(i+40);
     
    cp5.addButton((i+1) + " +45°")
     .setValue(0)
     .setPosition(knob_base_x + 45 + (i%4 * knob_spacing), knob_base_y + 105 + (i/4 * knob_spacing))
     .setSize(50,19)
     .setId(i+60);
     
    cp5.addButton((i+1) + " -45°")
     .setValue(0)
     .setPosition(knob_base_x - 10 + (i%4 * knob_spacing), knob_base_y + 105 + (i/4 * knob_spacing))
     .setSize(50,19)
     .setId(i+80);
     
    cp5.addButton((i+1) + " +15°")
     .setValue(0)
     .setPosition(knob_base_x + 45 + (i%4 * knob_spacing), knob_base_y + 129 + (i/4 * knob_spacing))
     .setSize(50,19)
     .setId(i+200);
     
    cp5.addButton((i+1) + " -15°")
     .setValue(0)
     .setPosition(knob_base_x - 10 + (i%4 * knob_spacing), knob_base_y + 129 + (i/4 * knob_spacing))
     .setSize(50,19)
     .setId(i+220);
     
    cp5.addButton((i+1) + " +5°")
     .setValue(0)
     .setPosition(knob_base_x + 45 + (i%4 * knob_spacing), knob_base_y + 153 + (i/4 * knob_spacing))
     .setSize(50,19)
     .setId(i+240);
     
    cp5.addButton((i+1) + " -5°")
     .setValue(0)
     .setPosition(knob_base_x - 10 + (i%4 * knob_spacing), knob_base_y + 153 + (i/4 * knob_spacing))
     .setSize(50,19)
     .setId(i+260);
  }
  
  //Style and setup all global GUI elements  here ----------------------------
  cp5.addButton("SEND COMMAND")
     .setValue(0)
     .setPosition(g_base_x, g_base_y)
     .setSize(g_button_width, g_button_height)
     .setId(1010);
     
   cp5.addButton("SEND ALL TO ZERO")
     .setValue(0)
     .setPosition(g_base_x, g_base_y + (g_spacing_y*1))
     .setSize(g_button_width, g_button_height)
     .setId(1000);
     
   cp5.addButton("ALL +45° CW")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1), g_base_y + (g_spacing_y*0))
     .setSize(g_button_width, g_button_height)
     .setId(1001);
     
   cp5.addButton("ALL -45° CCW")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1), g_base_y + (g_spacing_y*1))
     .setSize(g_button_width, g_button_height)
     .setId(1002);
     
    cp5.addButton("RANDOM")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1), g_base_y + (g_spacing_y*2))
     .setSize(g_button_width, g_button_height)
     .setSwitch(true)
     .setId(1003);
     
   cp5.addButton("RANDOM 45°")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1), g_base_y + (g_spacing_y*3))
     .setSize(g_button_width, g_button_height)
     .setSwitch(true)
     .setId(1004);
     
  speed_slider = cp5.addSlider("SPEED")
     .setPosition(610,100)
     .setSize(140,16)
     .setRange(50,4200)
     .setValue(2200)
     .setId(1005);
     
  accel_slider = cp5.addSlider("ACCEL")
     .setPosition(610,125)
     .setSize(140,16)
     .setRange(500,2000)
     .setValue(1000)
     .setId(1006);
     
  cp5.addButton("RESET MATRIX")
     .setValue(0)
     .setPosition(610,48)
     .setSize(140,20)
     .setId(1007);
     
  cp5.addButton("HOME ALL")
     .setValue(0)
     .setPosition(610,74)
     .setSize(140,20)
     .setId(1008);
     
  cp5.addButton("LASER RED")
     .setValue(0)
     .setPosition(g_base_x, g_base_y + (g_spacing_y*2))
     .setSize(g_button_width, g_button_height)
     .setSwitch(true)
     .setId(1020);
     
  cp5.addButton("LASER GREEN")
     .setValue(0)
     .setPosition(g_base_x, g_base_y + (g_spacing_y*3))
     .setSize(g_button_width, g_button_height)
     .setSwitch(true)
     .setId(1021);
     
  cp5.addButton("LASER BLUE")
     .setValue(0)
     .setPosition(g_base_x, g_base_y + (g_spacing_y*4))
     .setSize(g_button_width, g_button_height)
     .setSwitch(true)
     .setId(1022);
     
  cp5.addButton("LASER PURPLE")
     .setValue(0)
     .setPosition(g_base_x, g_base_y + (g_spacing_y*5))
     .setSize(g_button_width, g_button_height)
     .setSwitch(true)
     .setId(1023);
     
  cp5.addButton("FOG MACHINE")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1), g_base_y + (g_spacing_y*5))
     .setSize(g_button_width, g_button_height)
     .setSwitch(true)
     .setId(1024);
     
  cp5.addButton("ADD KEYFRAME")
     .setValue(0)
     .setPosition(g_base_x, g_base_y + 410)
     .setSize(g_button_width, g_button_height)
     .setId(1011);
     
  cp5.addButton("PREVIOUS KEYFRAME")
     .setValue(0)
     .setPosition(g_base_x, g_base_y + 410 + (g_spacing_y*1))
     .setSize(g_button_width, g_button_height)
     .setId(1012);
     
  cp5.addButton("NEXT KEYFRAME")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1), g_base_y + 410 + (g_spacing_y*1))
     .setSize(g_button_width, g_button_height)
     .setId(1013);
     
  cp5.addButton("EXPORT ANIMATION")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1), g_base_y + 410 + (g_spacing_y*2))
     .setSize(g_button_width, g_button_height)
     .setId(1014);
     
  cp5.addButton("PLAY ANIM 1")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1), g_base_y + 410 + (g_spacing_y*3))
     .setSize(g_button_width, g_button_height)
     .setId(1015);
     
  cp5.addButton("PLAY ANIM 2")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1), g_base_y + 410 + (g_spacing_y*4))
     .setSize(g_button_width, g_button_height)
     .setId(1016);
     
  cp5.addButton("PLAY ANIM 3")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1), g_base_y + 410 + (g_spacing_y*5))
     .setSize(g_button_width, g_button_height)
     .setId(1017);
     
  cp5.addButton("RANDOMIZE ANIMS")
     .setValue(0)
     .setPosition(g_base_x, g_base_y + 410 + (g_spacing_y*3))
     .setSize(g_button_width, g_button_height)
     .setId(1018);
     
  cp5.addButton("CLOCK MODE")
     .setValue(0)
     .setPosition(g_base_x, g_base_y + 410 + (g_spacing_y*4))
     .setSize(g_button_width, g_button_height)
     .setId(1019);
     
  cp5.addButton("SEND COLOR TO LEDs")
     .setValue(0)
     .setPosition(g_base_x + 390 , g_base_y + (g_spacing_y*4))
     .setSize(170, g_button_height)
     .setId(1030);
     
  cp5.addButton("BLACKOUT LEDs")
     .setValue(0)
     .setPosition(g_base_x + 390 , g_base_y + (g_spacing_y*5))
     .setSize(170, g_button_height)
     .setId(1031);
     
  cp5.addButton("SEND COLOR TO PIXEL")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1) + 390 , g_base_y + (g_spacing_y*4))
     .setSize(170, g_button_height)
     .setId(1032);
     
  cp5.addButton("SEND FADE TO STRIP")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*1) + 390 , g_base_y + (g_spacing_y*5))
     .setSize(170, g_button_height)
     .setId(1033);
     
  cp5.addButton("SEND GRADIENT")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*2) + 390 , g_base_y + (g_spacing_y*4))
     .setSize(170, g_button_height)
     .setId(1034);
     
  cp5.addButton("SEND RANDOM COLORS")
     .setValue(0)
     .setPosition(g_base_x + (g_spacing_x*2) + 390 , g_base_y + (g_spacing_y*5))
     .setSize(170, g_button_height)
     .setId(1035);
     
  led_index_select = cp5.addKnob("LED INDEX")
                 .setRange(0,10)
                 .setValue(0)
                 .setPosition(1450,180)
                 .setRadius(knob_size)
                 .showTickMarks()
                 .setTickMarkLength(knob_size/4)
                 .setTickMarkWeight(2.5)
                 .setDragDirection(Knob.VERTICAL)
                 .setAngleRange(2*PI)
                 .setStartAngle(PI/2)
                 .setResolution(10);
                 
  led_fade_length = cp5.addKnob("FADE LENGTH")
                 .setRange(0,10)
                 .setValue(0)
                 .setPosition(1450,300)
                 .setRadius(knob_size)
                 .showTickMarks()
                 .setTickMarkLength(knob_size/4)
                 .setTickMarkWeight(2.5)
                 .setDragDirection(Knob.VERTICAL)
                 .setAngleRange(2*PI)
                 .setStartAngle(PI/2)
                 .setResolution(10);
     
  cp5.addColorWheel("c", 1220, 170, 200).setRGB(color(255,0,0));
  cp5.addColorWheel("c2", 1555, 170, 200).setRGB(color(255,0,0));
}

void draw() 
{
  draw_gui_overlay();
  display_positions();
  update_gui_vals();
  draw_packet(msg);
}

void keyPressed()
{
  if (key == 'e')
  {
    esc_state = 1;
  }
  
}

//ANIMATION PLAYBACK ENGINE ----------------------------------------
void playback_animation(String a_name, String pkts[], int a_length)
{
  pkts = loadStrings(a_name);
  for (int i=0; i<=a_length; i+=2)
  {
    msg = pkts[i];
    myPort.write(msg);
    draw_packet(msg);
    println(msg);
    
    delay(int(pkts[i+1]));
  }
}

//KEYFRAME ENGINE ----------------------------------------------------------
//This function writes a new packet to the animaion output file
void add_keyframe()
{
  
  
  
}

//This function handles and interprets all GUI control events
//It sends serial to the motor controller when nedded, and
//updates values in Processing when needed
public void controlEvent(ControlEvent theEvent) {
  int id = theEvent.getController().getId();
  
  
  
  //Real time clock mode has been engaged
  if (id == 1019)
  {
    esc_state = 0;
    int sec = second();
    int min = minute();
    int hr = hour();
    int day = day();
    int month = month();
    int yr = year();
    
    if (esc_state == 0)
    {
      
      sec = second();
      min = minute();
      hr = hour();
      day = day();
      month = month();
      yr = year();
      
      //First lets set AM/PM. Mirror cell vertical means AM, mirror cell horizontal means PM
      if (hr < 12) 
      {
        positions[0] = 0;
        msg = "<"+3+","+0+","+positions[0]+","+max_speed+","+max_accel+","+0+">";
        myPort.write(msg);
      }
      
      else if (hr >= 12) 
      {
        positions[0] = angle_to_steps(90);
        msg = "<"+3+","+0+","+positions[0]+","+max_speed+","+max_accel+","+0+">";
        myPort.write(msg);
      }
      
      //Now lets set hours
      positions[1] = angle_to_steps((hr%12)*30.0);
      msg = "<"+3+","+1+","+positions[1]+","+max_speed+","+max_accel+","+0+">";
      myPort.write(msg);
      
      //Now lets set minutes
      positions[2] = angle_to_steps(min*6.0);
      msg = "<"+3+","+2+","+positions[2]+","+max_speed+","+max_accel+","+0+">";
      myPort.write(msg);
      
      //Now lets set seconds
      positions[3] = angle_to_steps(sec*6.0);
      msg = "<"+3+","+3+","+positions[3]+","+max_speed+","+max_accel+","+0+">";
      myPort.write(msg);
      
      delay(50);
    }
  }
  
  //Global Speed is being adjusted
  if (id == 1005) {max_speed = int(speed_slider.getValue());}
  
  //Global Accleration is being adjusted
  if (id == 1006) {max_accel = int(accel_slider.getValue());}
  
  //Reset Matrix is being requested
  if (id == 1007)
  {
    for (int i = 0; i<16; i++) {position_knobs[i].setValue(0);speed_knobs[i].setValue(default_speed);}
  }
  
  //Send Homing Position Reached Command
  if (id >=100 && id < 120)
  {
    positions[id%20] = 0;
    
    msg = "<"+1+","+(id%20+1)+","+0+","+0+","+0+","+0+">";
    myPort.write(msg);
  }
  
  //Send home all motors command
  if (id == 1008)
  {home_all_motors();}
  
  //One step positive is being requested
  if (id >= 20 && id < 40) 
  {
    positions[id%20]++;
    msg = "<"+3+","+(id%20+1)+","+positions[id%20]+","+max_speed+","+max_accel+","+0+">";
    myPort.write(msg);
  }
  
  //One step negative is being requested
  if (id >= 40 && id < 60) 
  {
    positions[id%20]--;
    msg = "<"+3+","+(id%20+1)+","+positions[id%20]+","+max_speed+","+max_accel+","+0+">";
    myPort.write(msg);
  }
  
  //Single Motor +45 degree is being requested
  if (id >= 60 && id < 80) 
  {
    positions[id%20] = positions[id%20]+angle_to_steps(45);
    msg = "<"+3+","+(id%20+1)+","+positions[id%20]+","+max_speed+","+max_accel+","+0+">";
    myPort.write(msg);
  }
  
  //Single Motor -45 degree is being requested
  if (id >= 80 && id < 100) 
  {
    positions[id%20] = positions[id%20]+angle_to_steps(-45);
    msg = "<"+3+","+(id%20+1)+","+positions[id%20]+","+max_speed+","+max_accel+","+0+">";
    myPort.write(msg);
  }
  
  //Single motor +15 degree is being requested
  if (id >= 200 && id < 220) 
  {
    positions[id%20] = positions[id%20]+ angle_to_steps(15);
    msg = "<"+3+","+(id%20+1)+","+positions[id%20]+","+max_speed+","+max_accel+","+0+">";
    myPort.write(msg);
  }
  
  //Single motor -15 degree is being requested
  if (id >= 220 && id < 240) 
  {
    positions[id%20] = positions[id%20]+ angle_to_steps(-15);
    msg = "<"+3+","+(id%20+1)+","+positions[id%20]+","+max_speed+","+max_accel+","+0+">";
    myPort.write(msg);
  }
  
  //Single motor +5 degree is being reqeusted
  if (id >= 240 && id < 260) 
  {
    positions[id%20] = positions[id%20]+ angle_to_steps(5);
    msg = "<"+3+","+(id%20+1)+","+positions[id%20]+","+max_speed+","+max_accel+","+0+">";
    myPort.write(msg);
  }
  
  //Single motor -5 degree is being requested
  if (id >= 260 && id < 280) 
  {
    positions[id%20] = positions[id%20]+ angle_to_steps(-5);
    msg = "<"+3+","+(id%20+1)+","+positions[id%20]+","+max_speed+","+max_accel+","+0+">";
    myPort.write(msg);
  }
  
  //All to zero is being requested
  if (id == 1000) 
  {
    for(int i=0; i<16; i++) {positions[i] = 0;}
    msg = "<"+3+","+20+","+0+","+max_speed+","+max_accel+","+0+">";
    myPort.write(msg);
  }
  
  //All +45 is being requested
  if (id == 1001) {for(int i=0; i<16; i++) 
  {
    positions[i] = positions[i]+angle_to_steps(45);}
    send_speeds_positions_serial();
  }
  
  //All -45 is being requested
  if (id == 1002) {for(int i=0; i<16; i++) 
  {
    positions[i] = positions[i]+angle_to_steps(-45);}
    send_speeds_positions_serial();
  }
  
  //Send speeds and positions is being requested
  if (id == 1010) {for(int i=0; i<16; i++) 
  {
    positions[i] = angle_to_steps(position_vals[i]);}
    send_speeds_positions_serial();
  }
  
  //All to random is being requested
  if (id == 1003) {for(int i=0; i<16; i++) 
  {
    positions[i] = angle_to_steps(random(-360,360));}
    send_speeds_positions_serial();
  }
  
  //All to random 45s is being requested
  if (id == 1004)
  {
    for (int i=0; i<16; i++)
    {
      positions[i] = angle_to_steps(45*int(random(8)));
      send_speeds_positions_serial();
    }
  }
  
  //LASER CONTROL ----------------------------------------------------------
  //Laser 1 On/Off
  if (id == 1020) 
  {
    laser_counts[0]++;
    if (laser_counts[0]%2 == 0) {msg = "<"+4+","+1+","+0+","+0+","+0+","+0+">";myPort.write(msg);}
    if (laser_counts[0]%2 == 1) {msg = "<"+4+","+1+","+1+","+0+","+0+","+0+">";myPort.write(msg);}
  }
  //Laser 2 On/Off
  if (id == 1021) 
  {
    laser_counts[1]++;
    if (laser_counts[1]%2 == 0) {msg = "<"+4+","+2+","+0+","+0+","+0+","+0+">";myPort.write(msg);}
    if (laser_counts[1]%2 == 1) {msg = "<"+4+","+2+","+1+","+0+","+0+","+0+">";myPort.write(msg);}
  }
  //Laser 3 On/Off
  if (id == 1022) 
  {
    laser_counts[2]++;
    if (laser_counts[2]%2 == 0) {msg = "<"+4+","+3+","+0+","+0+","+0+","+0+">";myPort.write(msg);}
    if (laser_counts[2]%2 == 1) {msg = "<"+4+","+3+","+1+","+0+","+0+","+0+">";myPort.write(msg);}
  }
  //Laser 4 On/Off
  if (id == 1023) 
  {
    laser_counts[3]++;
    if (laser_counts[3]%2 == 0) {msg = "<"+4+","+4+","+0+","+0+","+0+","+0+">";myPort.write(msg);}
    if (laser_counts[3]%2 == 1) {msg = "<"+4+","+4+","+1+","+0+","+0+","+0+">";myPort.write(msg);}
  }
  //Fog Machine
  if (id == 1024) 
  {
    fog_count++;
    if (fog_count%2 == 0) {msg = "<"+5+","+0+","+0+","+0+","+0+","+0+">";myPort.write(msg);}
    if (fog_count%2 == 1) {msg = "<"+5+","+0+","+1+","+0+","+0+","+0+">";myPort.write(msg);}
  }
  
  //Playback animation 1 is being requested
  if (id == 1015)
  {
    //Need to implement a way to break out of an animation cycle
    //while one is still playing. Also need to creates some kind
    //of GUI display for commands being sent from a pre-written
    //animation file
    while (true)
    {
      playback_animation(anim1_name, packets1, anim1_length);
    }
  }
  
  //Playback animation 2 is being requested
  if (id == 1016)
  {playback_animation(anim2_name, packets2, anim2_length);}
  
  //Playback animation 3 is being requested
  if (id == 1017)
  {playback_animation(anim3_name, packets3, anim3_length);}
  
  //Playback animations at random is being requested
  if (id == 1018)
  {
    
    
  }
  
  //Send color wheel value to LEDs
  if (id == 1030)
  {
    r1_val = cp5.get(ColorWheel.class,"c").r();
    g1_val = cp5.get(ColorWheel.class,"c").g();
    b1_val = cp5.get(ColorWheel.class,"c").b();
    msg = "<"+6+","+0+","+r1_val+","+g1_val+","+b1_val+","+0+">";
    myPort.write(msg);
  }
  
  //Blackout LEDs
  if (id == 1031)
  {msg = "<"+6+","+0+","+0+","+0+","+0+","+0+">";myPort.write(msg);}
  
  //Send color wheel value to pixel
  if (id == 1032)
  {
    r1_val = cp5.get(ColorWheel.class,"c").r();
    g1_val = cp5.get(ColorWheel.class,"c").g();
    b1_val = cp5.get(ColorWheel.class,"c").b();
    pix_val = int(led_index_select.getValue());
    msg = "<"+12+","+0+","+r1_val+","+g1_val+","+b1_val+","+pix_val+">";
    myPort.write(msg);
  }
  
  //Send random values scaled by color wheel to all LEDs
  if (id == 1035)
  {
    r1_val = cp5.get(ColorWheel.class,"c").r();
    g1_val = cp5.get(ColorWheel.class,"c").g();
    b1_val = cp5.get(ColorWheel.class,"c").b();
    
    for (int i = 0; i < num_pixels; i++)
    {
      msg = "<"+12+","+0+","+int(random(r1_val))+","+int(random(g1_val))+","+int(random(b1_val))+","+i+">";
      myPort.write(msg);
      delay(serial_delay);
    }
  }
  
  //Send gradient to strip (naive)
  if (id == 1034)
  {
    color lerp;
    int r, g, b = 0;
    
    r1_val = cp5.get(ColorWheel.class,"c").r();
    g1_val = cp5.get(ColorWheel.class,"c").g();
    b1_val = cp5.get(ColorWheel.class,"c").b();
    color color1 =  color(r1_val, g1_val, b1_val);
    
    r2_val = cp5.get(ColorWheel.class,"c2").r();
    g2_val = cp5.get(ColorWheel.class,"c2").g();
    b2_val = cp5.get(ColorWheel.class,"c2").b();
    color color2 =  color(r2_val, g2_val, b2_val);
    
    for (int i = 0; i < num_pixels; i++)
    {
      lerp = lerpColor(color1, color2, (1.0/num_pixels)*i);
      r = int(red(lerp));
      g = int(green(lerp));
      b = int(blue(lerp));
      msg = "<"+12+","+0+","+r+","+g+","+b+","+i+">";
      myPort.write(msg);
      delay(serial_delay);
    }
    
  }
}


//Function to send homing commands to all 16 motors sequentially
void home_all_motors()
{
  for (int i=1; i<=16; i++)
  {
    msg = "<"+1+","+i+","+0+","+0+","+0+","+0+">";
    myPort.write(msg);
    delay(serial_delay);
  }
}

//Function to handle sending all 16 stepper motor positions only
void send_positions_serial()
{
    msg = "<"+21+","+21+","+positions[0]+","+positions[1]+","+positions[2]+","+positions[3]+">";
    myPort.write(msg);
    delay(serial_delay);
    msg = "<"+23+","+23+","+positions[4]+","+positions[5]+","+positions[6]+","+positions[7]+">";
    myPort.write(msg);
    delay(serial_delay);
    msg = "<"+25+","+25+","+positions[8]+","+positions[9]+","+positions[10]+","+positions[11]+">";
    myPort.write(msg);
    delay(serial_delay);
    msg = "<"+27+","+27+","+positions[12]+","+positions[13]+","+positions[14]+","+positions[15]+">";
    myPort.write(msg);
    delay(serial_delay);
}

//Function to handle sending all 16 stepper motor speeds and positions
void send_speeds_positions_serial()
{
    msg = "<"+21+","+21+","+positions[0]+","+positions[1]+","+positions[2]+","+positions[3]+">";
    myPort.write(msg);
    delay(serial_delay);
    msg = "<"+22+","+22+","+speed_vals[0]+","+speed_vals[1]+","+speed_vals[2]+","+speed_vals[3]+">";
    myPort.write(msg);
    delay(serial_delay);
    
    msg = "<"+23+","+23+","+positions[4]+","+positions[5]+","+positions[6]+","+positions[7]+">";
    myPort.write(msg);
    delay(serial_delay);
    msg = "<"+24+","+24+","+speed_vals[4]+","+speed_vals[5]+","+speed_vals[6]+","+speed_vals[7]+">";
    myPort.write(msg);
    delay(serial_delay);
    
    msg = "<"+25+","+25+","+positions[8]+","+positions[9]+","+positions[10]+","+positions[11]+">";
    myPort.write(msg);
    delay(serial_delay);
    msg = "<"+26+","+26+","+speed_vals[8]+","+speed_vals[9]+","+speed_vals[10]+","+speed_vals[11]+">";
    myPort.write(msg);
    delay(serial_delay);
    
    msg = "<"+27+","+27+","+positions[12]+","+positions[13]+","+positions[14]+","+positions[15]+">";
    myPort.write(msg);
    delay(serial_delay);
    msg = "<"+28+","+28+","+speed_vals[12]+","+speed_vals[13]+","+speed_vals[14]+","+speed_vals[15]+">";
    myPort.write(msg);
    delay(serial_delay);
}

//MOTION CONTROL FUNCTIONS ----------------------------------------
int angle_to_steps (float angle)
{
  int result = int((angle) / step_angle);
  return result;
}

//GUI STATE FUNCTIONS ---------------------------------------------
void update_gui_vals ()
{
  for(int i = 0; i < 16; i++)
  {
    position_vals[i] = int(position_knobs[i].getValue());
    speed_vals[i] = int(speed_knobs[i].getValue());
  }
}

//GUI DISPLAY FUNCTIONS -------------------------------------------
void draw_packet(String pkt)
{
  textSize(30);
  text(pkt, 1210, 30);
  fill(0xff96E363); 
}

void draw_gui_overlay()
{
  background(0xff1C0118);
  
  //Display Text for Titles
  textSize(70);
  text("OPTIX CONTROL", 10, 70);
  textSize(25);
  text("SB 2022", 15, 100);
  fill(0xff96E363); 
  
  //Display set motor parameters
  textSize(18);
  text(steps_per_rev + " STEPS PER REV", 400, 100);
  text(step_angle + "° STEP ANGLE", 400, 120);
  text(microstep_multiplier + "x MICROSTEPPING", 400, 140);
  
  //Partition Grid
  stroke(0xff3B0233);
  strokeWeight(2.5);
  line(0, 150, width, 150);
  line(810, 0, 810, height);
  line(1200,0,1200,height);
  
  //Main subdivision grid for knob matrix
  for (int i = 1; i< 4; i++)
  {
    if (i != 3)line(i * knob_spacing + knob_base_x - 98 , 150, i * knob_spacing + knob_base_x - 98 , height);
    else line(i * knob_spacing + knob_base_x - 98 , 0, i * knob_spacing + knob_base_x - 98 , height);

    
    if (i != 2) line(0, i * knob_spacing + 160, 810, i * knob_spacing + 160);
    else line(0, i * knob_spacing + 160, width, i * knob_spacing + 160);
  }
}

//This displays the currently requested step position in a 4x4 grid for ease in debugging
void display_positions()
{
  //Subdivision grid
  for (int i = 0; i < 4; i ++)
  {
    if (i !=0) line(i * pos_spacing_x + pos_base_x, 0, i * pos_spacing_x + pos_base_x, 150);
    line(810, i * pos_spacing_y, 1200, i * pos_spacing_y);
  }
  
  //Position text
  textSize(20);
  for (int i = 0; i < 16; i++)
  {
    text(positions[i], pos_base_x + i%4*pos_spacing_x + 15, pos_base_y + i/4*pos_spacing_y + 10);
  }
}
