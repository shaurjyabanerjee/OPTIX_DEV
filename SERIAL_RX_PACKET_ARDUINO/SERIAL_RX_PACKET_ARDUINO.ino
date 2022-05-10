//Recive packets of the 6 integer standard used for controlling OPTIX
//Recieved packets are printed to Serial1. This can be monitored with
//an FTDI USB Serial Adapter.

const byte numChars = 128;
char receivedChars[numChars];   // an array to store the received data
char tempChars[numChars]; 

//Variables to hold the parsed data -
int cmd = 0;
int scope = 0;
int p1,p2,p3,p4 = 0;

boolean newData = false;

int dataNumber = 0;

void setup() {
    Serial.begin(250000);
    Serial1.begin(250000);
    Serial.println("<Packet Serial RX Test>");
    Serial1.println("<Packet Serial RX Test>");
}

void loop() {

    recvWithStartEndMarkers();
    if (newData == true) {
        strcpy(tempChars, receivedChars);
            // this temporary copy is necessary to protect the original data
            //   because strtok() used in parseData() replaces the commas with \0
        parseData();
        showParsedData();
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
