import java.util.Random;
import java.lang.Math;
import java.awt.Color;
import ddf.minim.analysis.*;
import ddf.minim.*;
import oscP5.*;
import netP5.*;

Random rand = new Random();

/* TODO:
new OSC controls: 
global fade factor 
global audio threshold factor and amplitude multiplier (maybe xy)
 */

int displaySize = 2000;
Field field;
OPC opc;

// audio crap
BPMDetector bpm;
Minim minim;
AudioPlayer sound;
AudioInput in;
int bufferSize = 1024;
float sampleRate = 44100;
String song = "ohl.mp3";

// remote stuff
int globalBrightness = 255;
boolean modeSwitching = false;
boolean houseLightsOn = false;
float intraloopWSF = 1.0; // WSF = wheel step factor
float midWSF = 1.0; // WSF = wheel step factor
float interloopWSF = 1.0; // WSF = wheel step factor
int delay = 0;
float gainFactor = 1.0;
float fubar = 1.0;

int[] rowStarts = new int[] {0, 5, 11, 18, 26, 35, 43, 50, 56};
int[] rowEnds = new int[] {4, 10, 17, 25, 34, 42, 49, 55, 60};

// Open sound control business
OscP5 oscP5;
NetAddress myRemoteLocation;
NetAddressList myNetAddressList = new NetAddressList();
int myListeningPort = 5001;
int myBroadcastPort = 12000;

void setup() {
  
  size(displaySize, displaySize);
  background(0);
  //strokeWeight(5);
  //stroke(255);
  
  minim = new Minim(this);
  
  // Line in
  in = minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
  bpm = new BPMDetector(in);
  
  // MP3 in
  //sound = minim.loadFile(song);
  //bpm = new BPMDetector(sound);
  
  bpm.setup();
  
  //drawHexes();

  opc = new OPC(this, "127.0.0.1", 7890);
  field = new Field(500, 320, opc);
  
  oscP5 = new OscP5(this, myListeningPort);
 
  // set the remote location to be the localhost on port 5001
  myRemoteLocation = new NetAddress("192.168.2.149", myListeningPort);
}

void draw() {
  field.randomize();
  field.update();
  field.draw();
  //field.send();
}

void keyPressed() {
  if (key == 'f') {
    fxOn = !fxOn;
  } else if (key == 'g') {
    fxMode = (fxMode + 1) % numFX;
  } else {
    field.setMode((field.mode + 1) % field.nModes);
  }
}

void oscEvent(OscMessage theOscMessage) 
{ 
  oscConnect(theOscMessage.netAddress().address());
  
  String addPatt = theOscMessage.addrPattern();
  int patLen = addPatt.length();
  float x, y;
  int a0, a1;
  
  if (addPatt.length() < 3) {
    //println("Page change");
  } else if (patLen == 9 && addPatt.substring(0, 5).equals("/mode")) {
    if (theOscMessage.get(0).floatValue() == 1.0) {
      a0 = 5 - Integer.parseInt(addPatt.substring(6, 7));
      a1 = Integer.parseInt(addPatt.substring(8, 9)) - 1;
      field.setMode((5 * a0 + a1) % field.nModes);
    }
  } else if (patLen == 11 && addPatt.substring(0, 7).equals("/fxMode")) {
    if (theOscMessage.get(0).floatValue() == 1.0) {
      a0 = 3 - Integer.parseInt(addPatt.substring(8, 9));
      a1 = Integer.parseInt(addPatt.substring(10, 11)) - 1;
      fxMode = (4 * a0 + a1) % numFX;
    }
  } else if (patLen == 9 && addPatt.substring(0,7).equals("/faders")) {
    int faderNum = Integer.parseInt(addPatt.substring(8,9));
    float faderVal = theOscMessage.get(0).floatValue();
    switch(faderNum) {
    case 1: // random speed
      field.setModeChance(faderVal);
      break;
    case 2: // brightness
      globalBrightness = (int) map(faderVal, 0.0, 1.0, 0.0, 255.0);
      break;
    case 3: // delay
      field.adjustDelay((int) map(faderVal, 0.0, 1.0, 0.0, 255.0));
      break;
    case 4: // 
      fubar = faderVal;
      break;
    case 5: // incoming audio signal gain
      gainFactor = faderVal;
      break;
    default:
      break;
    }
  } else if (patLen == 12 && addPatt.substring(0,10).equals("/colorStep")) {
    int faderNum = Integer.parseInt(addPatt.substring(11,12));
    float faderVal = theOscMessage.get(0).floatValue();
    switch(faderNum) {
    case 1: // low
      intraloopWSF = map(faderVal, 0.0, 1.0, 0.0, 5.0);
      break;
    case 2: // mid
      midWSF = map(faderVal, 0.0, 1.0, 0.0, 5.0);
      break;
    case 3: // high
      interloopWSF = map(faderVal, 0.0, 1.0, 0.0, 5.0);
      break;
    default:
      break;
    }
  } else if (patLen == 14 && addPatt.substring(0,10).equals("/functions")) {
    if (theOscMessage.get(0).floatValue() == 1.0) {
      a0 = 2 - Integer.parseInt(addPatt.substring(11, 12));
      a1 = Integer.parseInt(addPatt.substring(13, 14)) - 1;
      int func = 2 * a0 + a1;
      switch(func) {
      case 0: // increment the vibe
        field.incVibe();
        break;
      case 1: // generate a new scheme within the current vibe
        field.newScheme();
        break;
      case 2: // set to rainbow scheme and set back to wide vibe
        field.setRainbow();
        break;
      case 3: // select the white vibe
        field.setVibeWhite();
        break;
      default:
        println("Not sure which function that was or how you did that...");
      }
    }
  } else if (addPatt.equals("/random")) {
    if (theOscMessage.get(0).floatValue() == 1.0) {
      modeSwitching = true;
    } else modeSwitching = false;
  } else if (addPatt.equals("/fxOn")) {
    if (theOscMessage.get(0).floatValue() == 1.0) {
      fxOn = true;
    } else fxOn = false;
  } else if (addPatt.equals("/fxRand")) {
    if (theOscMessage.get(0).floatValue() == 1.0) {
      fxRand = true;
    } else fxRand = false;
  } else if (addPatt.equals("/dryWet")) {
    dryWet = theOscMessage.get(0).floatValue();
  } else if (addPatt.equals("/fxChance")) {
    fxChance = (int) theOscMessage.get(0).floatValue();
  } else if (addPatt.equals("/fxTime")) {
    fxTime = (int) theOscMessage.get(0).floatValue();
  } else if (addPatt.equals("/coeff")) {
    coeff = theOscMessage.get(0).floatValue();
  } else if (addPatt.equals("/house")) {
    if (theOscMessage.get(0).floatValue() == 1.0) {
      
      field.setVibeWhite();
      globalBrightness = 255;
      modeSwitching = false;
      houseLightsOn = true;
    } else {
      field.setRainbow();
      field.newScheme();
      houseLightsOn = false;
    }
  } else {
    print("Unexpected OSC Message Recieved: ");
    println("address pattern: " + theOscMessage.addrPattern());
    println("type tag: " + theOscMessage.typetag());
  }
  
  oscSync();
}

void oscSync()
{
  OscMessage message;
  
  message = new OscMessage("/mode/" + str(5 - field.mode / 5) + "/" + str(field.mode % 5 + 1));
  message.add(1.0);
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/fxMode/" + str(3 - fxMode / 4) + "/" + str(fxMode % 4 + 1));
  message.add(1.0);
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/random");
  message.add(modeSwitching ? 1.0 : 0.0);
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/house");
  message.add(houseLightsOn ? 1.0 : 0.0);
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/fxOn");
  message.add(fxOn ? 1.0 : 0.0);
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/fxRand");
  message.add(fxRand ? 1.0 : 0.0);
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/faders/1");
  message.add(field.getModeChanceForFader());
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/faders/2");
  message.add(map(globalBrightness, 0.0, 255.0, 0.0, 1.0));
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/faders/3");
  message.add(map(field.getDelay(), 0.0, 255.0, 0.0, 1.0));
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/faders/4");
  message.add(fubar);
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/faders/5");
  message.add(gainFactor);
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/colorStep/1");
  message.add(map(intraloopWSF, 0.0, 5.0, 0.0, 1.0));
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/colorStep/2");
  message.add(map(midWSF, 0.0, 5.0, 0.0, 1.0));
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/colorStep/3");
  message.add(map(interloopWSF, 0.0, 5.0, 0.0, 1.0));
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/dryWet");
  message.add(dryWet);
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/fxChance");
  message.add(fxChance);
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/fxTime");
  message.add(fxTime);
  oscP5.send(message, myNetAddressList);
  
  message = new OscMessage("/coeff");
  message.add(coeff);
  oscP5.send(message, myNetAddressList);
}

private void oscConnect(String theIPaddress) {
  if (!myNetAddressList.contains(theIPaddress, myBroadcastPort)) {
    myNetAddressList.add(new NetAddress(theIPaddress, myBroadcastPort));
    println("### adding " + theIPaddress + " to the list.");
    //oscSync();
  } else {
    println("### " + theIPaddress + " is already connected.");
  }
  println("### currently there are "+myNetAddressList.list().size()+" remote locations connected.");
}



void drawHexes() {
  
  strokeWeight(1);
  stroke(0);
  // noStroke();
  //fill(0);
  noFill();
  float hexRad = displaySize / 6;
  
  for (int i = 0; i < 7; i++) {
    float[] center = panelCenter(i);
    pushMatrix();
    hexagon(center[0], center[1], hexRad, true);
    popMatrix();
    //drawHexFill(coords[0], coords[1], hexRad, 2);
    drawHexes(center[0], center[1]);
  }
  
}

void drawHexFill(float x, float y, float radius, int depth) {
  
  if (depth > 0) {
    
    pushMatrix();
    hexagon(x, y, radius / 3, true);
    popMatrix();
    
    float theta = TWO_PI * 3 / 4;
    for (int i = 0; i < 6; i++) {
      float[] coords = polar2cart(radius * 2 / 3, theta, x, y);
      pushMatrix();
      hexagon(coords[0], coords[1], radius / 3, true);
      popMatrix();
      drawHexFill(coords[0], coords[1], radius / 3, depth - 1);
      theta += TWO_PI / 6;
    }
    drawHexFill(x, y, radius / 3, depth - 1);
  }
  
}

void drawHexes(float x, float y) {
  
  float radius = displaySize / 54;
  float delta = 2 * radius * sin(PI / 3);
  
  pushMatrix();
  translate(x, y);
  rotate(PI / 6);
  translate(- 4 * radius, - 4 * delta);
  
  for (int row = 0; row < 9; row++) {
    pushMatrix();
    for (int n = rowStarts[row]; n < rowEnds[row] + 1; n++) {
      pushMatrix();
      hexagon(0, 0, radius, false);
      popMatrix();
      translate(2 * radius, 0);
    }
    popMatrix();
    
    int dir = (row < 4) ? -1 : 1; 
    translate(dir * radius, delta);
  }
  
  popMatrix();
  
}

void drawHex(int i0, int i1, int i2, float radius, int[] c) {
  
  float[] center0, center1, center2;
  
  i0 = i0 % 7;
  i1 = i1 % 7;
  i2 = i2 % 7;
  
  if (i0 == 0) {
    center0 = new float[] {displaySize / 2, displaySize / 2};
  } else {
    center0 = polar2cart(displaySize / 3, (i0 - 2) * TWO_PI / 6, displaySize / 2, displaySize / 2);
  }
  
  if (i1 == 0) {
    center1 = center0;
  } else {
    center1 = polar2cart(displaySize / 9, (2 * i1 - 5) * TWO_PI / 12, center0[0], center0[1]);
  }
  
  if (i2 == 0) {
    center2 = center1;
  } else {
    center2 = polar2cart(displaySize / 27, (2 * i2 - 5) * TWO_PI / 12, center1[0], center1[1]);
  }
  
  fill(c[0], c[1], c[2]);
  pushMatrix();
  hexagon(center2[0], center2[1], radius, true);
  popMatrix();
}

void drawHex(int iPanel, int iLED, int[] c) {
  
  float[] center = panelCenter(iPanel);
  int[] xy = iToXY(iLED);
  float radius = displaySize / 54;
  float delta = 2 * radius * sin(PI / 3);
  
  fill(c[0], c[1], c[2]);
  pushMatrix();
  translate(center[0], center[1]);
  rotate(PI / 6);
  float deltaY = xy[1] - 4;
  float deltaX = abs(xy[1] - 4) * radius;
  translate(deltaX - 8 * radius + xy[0] * 2 * radius, deltaY * delta);
  hexagon(0, 0, radius, false);
  popMatrix();
  
}

float[] panelCenter(int iPanel) {
  
  float[] center;
  iPanel = iPanel % 7;
  
  if (iPanel == 0) {
    center = new float[] {displaySize / 2, displaySize / 2};
  } else {
    center = polar2cart(displaySize / 3, (iPanel - 2) * TWO_PI / 6, displaySize / 2, displaySize / 2);
  }
  
  return center;
  
}

void hexagon(float x, float y, float radius, boolean rotate) {
  
  float angle = TWO_PI / 6;
  beginShape();
  for (float a = (rotate ? angle / 2 : 0); a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
  
}

float[] polar2cart(float r, float theta, float xOff, float yOff) {
  
  float x = xOff + r * cos(theta);
  float y = yOff + r * sin(theta);
  
  return new float[] {x, y};
  
}

float[] cart2polar(float x, float y, float xOff, float yOff) {
  
  x -= xOff;
  y -= yOff;
  if (x == 0 && y == 0) return new float[] {0.0, 0.0};
  float r = sqrt(sq(x) + sq(y));
  float theta = atan(y / x);
  if (x < 0) {
    theta += PI;
  } else if (y < 0) {
    theta += TWO_PI;
  }
  
  return new float[] {r, theta};
  
}


int[] iToXY(int n) {
  
  n = n % 61;
  int row = 8;
  
  while (n < rowStarts[row]) {
    row--;
  }
  
  int x = n - rowStarts[row];
  
  return new int[] {x, row};
  
}

int xyToI(int x, int y) {
  
  return rowStarts[y % 9] + x;
  
}

int[] hexToXY(int i0, int i1) {
  
  float[] center = new float[] {0.0, 0.0};
  float radius = displaySize / 54;
  float delta = 2 * radius * sin(PI / 3);
  
  i0 = i0 % 7;
  i1 = i1 % 7;
  
  if (i0 != 0) {
    center = polar2cart(displaySize / 9, (2 * i0 - 5) * TWO_PI / 12, 0, 0);
  }
  if (i1 != 0) {
    center = polar2cart(displaySize / 27, (2 * i1 - 5) * TWO_PI / 12, center[0], center[1]);
  }
  
  float[] rt = cart2polar(center[0], -center[1], 0, 0);
  float[] newXY = polar2cart(rt[0], rt[1] + PI / 6, 4 * radius, 0);
  newXY[1] = 4 * delta - newXY[1];
  int y = round(newXY[1] / delta);
  int x = round(((4 - abs(y - 4)) * (displaySize / 54) + newXY[0]) / (displaySize / 27));
  
  return new int[] {x, y};
}

int hexToI(int i0, int i1) {
  
  int[] xy = hexToXY(i0, i1);
  return xyToI(xy[0], xy[1]);
  
}

int ringToI(int ringRadius, int ringIndex) {
  
  int x = 4;
  int y = 4;
  
  if (ringRadius == 0) return xyToI(x, y);
  
  int side = ringIndex / ringRadius;
  int sideStart = side * ringRadius;
  int sideIndex = ringIndex - sideStart;
  switch(side) {
    case 0:
      x += sideIndex - ringRadius;
      y -= ringRadius;
      break;
    case 1:
      y += sideIndex - ringRadius;
      x += sideIndex;
      break;
    case 2:
      y += sideIndex;
      x += ringRadius - sideIndex;
      break;
    case 3:
      x -= sideIndex;
      y += ringRadius;
      break;
    case 4:
      x -= ringRadius;
      y += (ringRadius - sideIndex);
      break;
    case 5:
      x -= ringRadius;
      y -= sideIndex;
      break;
  }
  
  int i = xyToI(x,y);
  return i;
  
}

int[] iToRing(int index) {
  int indexOnPanel = index % 61;
  int[] xy = iToXY(indexOnPanel);
  int x = xy[0];
  int y = xy[1];
  int radius, ringIndex; // radius = 4;
  if (y == 0) {         // if (y == 4 - radius)
    radius = 4;         //   radius
    ringIndex = x;      //   ringIndex = x - y;
  } else if (x == 0) {  // if (x == 4 - radius)
    radius = 4;         //   radius
    ringIndex = 24 - y; //   ringIndex = radius * 6 + x - y
  } else if (y == 8) {  // if (y == 4 + radius)
    radius = 4;         //   radius
    ringIndex = 16 - x; //   ringIndex = radius * 2 + y - x
  } else if (x == y + 4 || x + y == 12) { // if (x == y + radius || x + y == 8 + radius)
    radius = 4;         //   radius
    ringIndex = y + 4;  //   ringIndex = y + 2 * (radius - 2)
                        // radius--
  } else if (y == 1) {  // if (y == 4 - radius)
    radius = 3;         //   radius
    ringIndex = x - 1;  //   ringIndex = x - y;
  } else if (x == 1) {  // if (x == 4 - radius)
    radius = 3;         //   radius
    ringIndex = 19 - y; //   ringIndex = radius * 6 + x - y
  } else if (y == 7) {  // if (y == 4 + radius)
    radius = 3;         //   radius
    ringIndex = 13 - x; //   ringIndex = radius * 2 + y - x
  } else if (x == y + 3 || x + y == 11) { // if (x == y + radius || x + y == 8 + radius)
    radius = 3;         //   radius
    ringIndex = y + 2;  //   ringIndex = y + 2 * (radius - 2)
                        // radius--
  } else if (y == 2) {  // if (y == 4 - radius)
    radius = 2;         //   radius
    ringIndex = x - 2;  //   ringIndex = x - y;
  } else if (x == 2) {  // if (x == 4 - radius)
    radius = 2;         //   radius
    ringIndex = 14 - y; //   ringIndex = radius * 6 + x - y
  } else if (y == 6) {  // if (y == 4 + radius)
    radius = 2;         //   radius
    ringIndex = 10 - x; //   ringIndex = radius * 2 + y - x
  } else if (x == y + 2 || x + y == 10) { // if (x == y + radius || x + y == 8 + radius)
    radius = 2;         //   radius
    ringIndex = y;      //   ringIndex = y + 2 * (radius - 2)
                        // radius--
  } else if (y == 3) {
    radius = 1;
    ringIndex = x - 3;
  } else if (x == 3) {
    radius = 1;
    ringIndex = 9 - y;
  } else if (y == 5) {
    radius = 1;
    ringIndex = 7 - x;
  } else if (x == y + 1 || x + y == 9) {
    radius = 1;
    ringIndex = y - 2;
                        // radius--
  } else {
    radius = 0;
    ringIndex = 0;
  }
  return new int[] {radius, ringIndex};
}

float[] iToPolar(int i, float xOff, float yOff) {
  int[] xy = iToXY(i);
  float[] rt = cart2polar(xy[0], xy[1], xOff, yOff);
  return rt;
}

// returns {group index, sub index}
int[] iToTriangle0(int i) {
  int[] xy = iToXY(i);
  int x = xy[0];
  int y = xy[1];
  int[] ring = iToRing(i);
  int mainI;
  int subI = ring[0] - 1;
  if (x == 4 && y == 4) {
    mainI = 0;
    subI = 0;
  } else if (x == y && x < 4) {
    mainI = 7;
  } else if (x == 4 && y > 4) {
    mainI = 10;
  } else if (x == 4 && y < 4) {
    mainI = 8;
  } else if (y == 4) {
    if (x < 4) {
      mainI = 12;
    } else {
      mainI = 9;
    }
  } else if (x + y == 8 && y > 4) {
    mainI = 11;
  } else if (y < 4 && x > 4) {
    mainI = 3;
  } else if (y > 4 && x > 4) {
    mainI = 4;
  } else if (x + y > 9) {
    mainI = 5;
  } else if (y > 4) {
    mainI = 6;
  } else if (y < 4 && (x == 0 || (x == 1 && y > 1) || (x == 2 && y == 3))) {
    mainI = 1;
  } else {
    mainI = 2;
  } 
  return new int[] {mainI, subI};
}

// returns {group index, sub index}
int[] iToTriangle1(int i) {
  int[] tri0 = iToTriangle0(i);
  if (tri0[0] > 0) {
    if (tri0[0] < 7) {
      tri0[0] += 6;
    } else {
      tri0[0] -= 6;
    }
  }
  return new int[] {tri0[0], tri0[1]};
}

int[] iToTriangle2(int i) {
  int[] tri1 = iToTriangle1(i);
  int[] ring = iToRing(i);
  if (tri1[0] > 6 && ring[0] == 4) {
    tri1[0] += 6;
    tri1[1] = ring[1];
  }
  return new int[] {tri1[0], tri1[1]};
}

int spiralToI(int spiralIndex, int ringOffset) {
  int panel = spiralIndex / 61;
  spiralIndex = spiralIndex % 61;
  int index = 0;
  if (spiralIndex == 0) return panel * 61 + ringToI(0, 0);
  int startPixel = 1;
  int endPixel = 6;
  for (int r = 1; r < 5; r++) {
    int pixelsOnRing = r * 6;
    if (spiralIndex <= endPixel) {
      index = ringToI(r, (spiralIndex - startPixel + ringOffset) % pixelsOnRing);
      break;
    }
    startPixel += pixelsOnRing;
    endPixel += (r + 1) * 6;
  }
  return panel * 61 + index;
}
