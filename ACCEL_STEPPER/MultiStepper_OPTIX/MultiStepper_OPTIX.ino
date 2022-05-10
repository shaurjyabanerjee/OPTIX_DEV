
int max_speed = 220;

#include <AccelStepper.h>
#include <MultiStepper.h>

// Alas its not possible to build an array of these with different pins for each :-(
AccelStepper stepper1(AccelStepper::DRIVER, 3, 2);
AccelStepper stepper2(AccelStepper::DRIVER, 5, 4);
AccelStepper stepper3(AccelStepper::DRIVER, 7, 6);
AccelStepper stepper4(AccelStepper::DRIVER, 9, 8);
AccelStepper stepper5(AccelStepper::DRIVER, 11, 10);

AccelStepper stepper6(AccelStepper::DRIVER, 45, 44);
AccelStepper stepper7(AccelStepper::DRIVER, 47, 46);
AccelStepper stepper8(AccelStepper::DRIVER, 49, 48);
AccelStepper stepper9(AccelStepper::DRIVER, 51, 50);
AccelStepper stepper10(AccelStepper::DRIVER, 53, 52);

AccelStepper stepper11(AccelStepper::DRIVER, 23, 22);
AccelStepper stepper12(AccelStepper::DRIVER, 25, 24);
AccelStepper stepper13(AccelStepper::DRIVER, 27, 26);
AccelStepper stepper14(AccelStepper::DRIVER, 29, 28);
AccelStepper stepper15(AccelStepper::DRIVER, 31, 30);

AccelStepper stepper16(AccelStepper::DRIVER, 33, 32);


// Up to 10 steppers can be handled as a group by MultiStepper
MultiStepper steppers_1;
MultiStepper steppers_2;

void setup() {
  Serial.begin(9600);

  // Configure each stepper
  stepper1.setMaxSpeed(max_speed);
  stepper2.setMaxSpeed(max_speed);
  stepper3.setMaxSpeed(max_speed);
  stepper4.setMaxSpeed(max_speed);
  stepper5.setMaxSpeed(max_speed);
  stepper6.setMaxSpeed(max_speed);
  stepper7.setMaxSpeed(max_speed);
  stepper8.setMaxSpeed(max_speed);
  stepper9.setMaxSpeed(max_speed);
  stepper10.setMaxSpeed(max_speed);
  stepper11.setMaxSpeed(max_speed);
  stepper12.setMaxSpeed(max_speed);
  stepper13.setMaxSpeed(max_speed);
  stepper14.setMaxSpeed(max_speed);
  stepper15.setMaxSpeed(max_speed);
  stepper16.setMaxSpeed(max_speed);

  // Then give them to MultiStepper to manage
  steppers_1.addStepper(stepper1);
  steppers_1.addStepper(stepper2);
  steppers_1.addStepper(stepper3);
  steppers_1.addStepper(stepper4);
  steppers_1.addStepper(stepper5);
  steppers_1.addStepper(stepper6);
  steppers_1.addStepper(stepper7);
  steppers_1.addStepper(stepper8);
  steppers_1.addStepper(stepper9);
  steppers_1.addStepper(stepper10);

  steppers_2.addStepper(stepper11);
  steppers_2.addStepper(stepper12);
  steppers_2.addStepper(stepper13);
  steppers_2.addStepper(stepper14);
  steppers_2.addStepper(stepper15);
  steppers_2.addStepper(stepper16);

  
}

void loop() {
  long positions[10]; // Array of desired stepper positions
  long positions_2[6]; // Array of desired stepper positions
  
  positions[0] = 200; positions[1] = 400; positions[2] = 600; positions[3] = 800;
  positions[4] = 1000; positions[5] = 800; positions[6] = 600; positions[7] = 400;
  positions[8] = 200; positions[9] = 100; positions_2[0] = 200; positions_2[1] = 400; 
  positions_2[2] = 600; positions_2[3] = 800; positions_2[4] = 1000; positions_2[5] = 800;
  
  steppers_1.moveTo(positions);
  steppers_1.runSpeedToPosition(); // Blocks until all are in position

  delay(1000);
  
  // Move to a different coordinate
  positions[0] = 0;
  positions[1] = 0;
  positions[2] = 0;
  positions[3] = 0;
  positions[4] = 0;
  positions[5] = 0;
  positions[6] = 0;
  positions[7] = 0;
  positions[8] = 0;
  positions[9] = 0;
  positions_2[0] = 0;
  positions_2[1] = 0;
  positions_2[2] = 0;
  positions_2[3] = 0;
  positions_2[4] = 0;
  positions_2[5] = 0;
  
  steppers_1.moveTo(positions);
  steppers_1.runSpeedToPosition(); // Blocks until all are in position
  delay(1000);
}
