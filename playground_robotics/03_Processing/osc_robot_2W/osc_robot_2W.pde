// libraries
import oscP5.*; // http://www.sojamo.de/oscP5
import netP5.*;

OscP5 oscP5;
NetAddress remoteLocation;
OscMessage message;
int receivedData;

int generalSpeed = 1023;

void setup() {
  size(400, 400);
  frameRate(60);
  /* start oscP5, listening for incoming messages at port 8888 */
  oscP5 = new OscP5(this, 8888);

  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. usage see below. for testing purposes the listening port
   * and the port of the remote location address are the same, hence you will
   * send messages back to this sketch.
   */
  remoteLocation = new NetAddress("192.168.1.200", 9999);
}


void draw() {
  background(0);
  
  // show values received via osc
  fill(255);
  text("some random data: "+receivedData,100,height/2);
}

// custom function motor
void controlMotor(int ID, int dir, int speed) {
  message = new OscMessage("/motor");
  message.add(ID); // ID
  message.add(dir); // direction
  message.add(speed); // speed (0-1023)
  oscP5.send(message, remoteLocation);
}

// key interaction
void keyPressed() {
  switch(keyCode) {
  case 38:
    // forward
    // motor 1 + 2
    controlMotor(0, 0, generalSpeed);
    controlMotor(1, 1, generalSpeed);
    break;
  case 40:
    // backward
    // motor 1 + 2
    controlMotor(0, 1, generalSpeed);
    controlMotor(1, 0, generalSpeed);
    break;
  case 37: 
    // left
    // motor 2
    controlMotor(1, 1, generalSpeed);
    break;
  case 39: 
    // right
    // motor 1
    controlMotor(0, 0, generalSpeed);
    break;
  }
}

void keyReleased() {
  // stop
  // motor 1 + 2
  controlMotor(0, 0, 0);
  controlMotor(1, 0, 0);
}


/* incoming osc message are forwarded to the oscEvent method. */
void oscEvent(OscMessage theOscMessage) {
  if (theOscMessage.checkAddrPattern("/send")==true) {
    receivedData = theOscMessage.get(0).intValue();
  }
}
