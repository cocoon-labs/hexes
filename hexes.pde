import java.util.Random;
import java.lang.Math;
import java.util.Date;
import java.awt.Color;
import ddf.minim.analysis.*;
import ddf.minim.*;
import oscP5.*;
import netP5.*;

Random rand = new Random();

int displaySize = 2500;
int iHex = 0;
Field field;

// audio crap
BPMDetector bpm;
Minim minim;
AudioPlayer sound;
AudioInput in;
int bufferSize = 1024;
float sampleRate = 44100;
String song = "dlp.mp3";

// remote stuff
int globalBrightness = 255;
boolean modeSwitching = false;
int modeC = 2;
boolean houseLightsOn = false;
float intraloopWSF = 1.0; // WSF = wheel step factor
float interloopWSF = 1.0; // WSF = wheel step factor
int delay = 0;

void setup() {
  
  size(displaySize, displaySize);
  background(0);
  //strokeWeight(5);
  //stroke(255);
  
  minim = new Minim(this);
  
  // Line in
  //in = minim.getLineIn(Minim.MONO, bufferSize, sampleRate);
  //bpm = new BPMDetector(in);
  
  // MP3 in
  sound = minim.loadFile(song);
  bpm = new BPMDetector(sound);
  
  bpm.setup();
  field = new Field(500);
  
  //drawHexes();
}

void draw() {
  
  field.randomize();
  field.update();
  field.draw();
  
}

void keyPressed() {
  
  int[] c = new int[] {255, 0, 0};
  drawHex(0, iHex, c);
  iHex = (iHex + 1) % 61;
  
}

void drawHexes() {
  
  strokeWeight(5);
  stroke(255);
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

int[] rowStarts = new int[] {0, 5, 11, 18, 26, 35, 43, 50, 56};
int[] rowEnds = new int[] {4, 10, 17, 25, 34, 42, 49, 55, 60};

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


int[] iToXY(int n) {
  
  n = n % 61;
  int row = 8;
  
  while (n < rowStarts[row]) {
    row--;
  }
  
  int x = n - rowStarts[row];
  
  return new int[] {x, row};
  
}
