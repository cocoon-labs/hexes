public class GradientWipe extends Mode {
  
  int loopOffset = 1;
  int loopCounter = 0;
  boolean fadingIn = false;
  float fadeInFactor;
  int fadeCounter = 0;
  int fadeCounterMax = 73;
  int counter = 0;
  float xOff = 0.0;
  float yOff = 0.0;
  
  int wipeTypeChance = 128;
  int typesOfWipe = 7;
  int wipeType = 6;
  
  GradientWipe(Panel[] panels, ColorWheel wheel, float fadeFactor, float fadeInFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    highChance = 32;
    delayable = true;
    this.fadeInFactor = fadeInFactor;
  }
  
  public void update() {
    super.update();
    if (justEntered) {
      turnOnRest(0,2);
      refreshColors();
      justEntered = false;
      fadeCounter = 0;
      fadingIn = true;
    } else if (fadingIn) {
      fadeAllIn(fadeInFactor);
      for (int i = 0; i < nPixels; i++) {  
        panels[i / 61].targetColors[i % 61] = targetColor(i);
      }
      wheel.turn((int) (loopOffset * interloopWSF));
      refreshColors();
      if (fadeCounter < fadeCounterMax)
        fadeCounter++;
      else {
        fadingIn = false;
      }
    } else {
      wipe();
    }
  }
  
  public void onBeat() {
    
  }
  
  public void randomize() {
    if (rand.nextInt(highChance) == 0) {
      loopOffset = 1 + rand.nextInt(5);
    }
    if (rand.nextInt(wipeTypeChance) == 0 && !justEntered && !fadingIn) {
      int newType = rand.nextInt(typesOfWipe);
      if (wipeType != newType) {
        justEntered = true;
        fadingIn = false;
        counter++;
        wipeType = newType;
        if (wipeType == 4) {
          xOff = random(15) + 5;
          yOff = random(15) + 5;
        }
      }
    }
  }
  
  public void wipe() {
    fadeAll(fadeFactor);
    for (int i = 0; i < nPixels; i++) {  
      updateByIndex(targetColor(i), i);
    }
    wheel.turn((int) (loopOffset * interloopWSF));
    loopCounter = (loopCounter + 1) % 3927;
  }
  
  public int[] targetColor(int i) {
    float sinFactor = (1.875 * sin(0.0016 * loopCounter)) + 2.125;
    float colorSpread = 256.0 * sinFactor;
    float pixelStep;
    int[] c;
    //xOff = map(mouseX, 0.0, width, 5.0, 20.0);
    //yOff = map(mouseX, 0.0, height, 5.0, 20.0);
    switch(wipeType) {
      case 0: // BY INDEX
        pixelStep = colorSpread / nPixels;
        c = wheel.getColor((int) (pixelStep * i), 255);
        break;
      case 1: // BY RING
        pixelStep = colorSpread / 100 / nRings;
        int[] ringStuff = iToRing(i);
        int radius = ringStuff[0];
        int ringIndex = ringStuff[1];
        c = wheel.getColor((int) (pixelStep * radius) + ringIndex * max(1, radius * 6), 255);
        break;
      case 2: // BY TRIANGLE 0
        pixelStep = 10; // something
        int[] tri0 = iToTriangle0(i);
        c = wheel.getColor((int) (tri0[0] * pixelStep) + tri0[1] * 10, 255); // define target color
        break;
      case 3: // BY TRIANGLE 1
        pixelStep = 10; // something
        int[] tri1 = iToTriangle1(i);
        c = wheel.getColor((int) (tri1[0] * pixelStep) + tri1[1] * 10, 255); // define target color
        break;
      case 4: // BY POLAR COORDINATES
        pixelStep = colorSpread / 100 / nRings;
        float[] rt = iToPolar(i, xOff, yOff);
        c = wheel.getColor((int) (pixelStep * rt[0] + rt[1] * max(1, rt[0] * 6)), 255);
        break;
      case 5: // BY TRIANGLE 2
        pixelStep = 10; // something
        int[] tri2 = iToTriangle2(i);
        c = wheel.getColor((int) (tri2[0] * pixelStep) + tri2[1] * 10, 255); // define target color
        break;
      case 6: // BY TRIANGLE 3
        int[] tri3 = iToTriangle0(i);
        int step = 0;
        pixelStep = 10;
        for (int j = 0; j < nPanels; j++) {
          if (tri3[1] > 3 && tri3[1] < 9) {
            step = 0;
          } else if (tri3[1] == 3 || tri3[1] == 13 || tri3[1] == 14 || tri3[1] == 9) {
            step = 3;
          } else if (tri3[1] == 2 || tri3[1] == 12 || tri3[1] == 10) {
            step = 6;
          } else if (tri3[1] == 11 || tri3[1] == 1) {
            step = 9;
          } else {
            step = 12;
          }
        }
        c = wheel.getColor((int) (tri3[0] * pixelStep) + step * 10, 255);
        break;
      default:
        c = wheel.getColor(0, 255);
        break;
    }
    return c;
  }
  
  public void turnOnRest(int wheelOffset, int brightness) {
    float sinFactor = (1.875 * sin(0.0016 * loopCounter)) + 2.125;
    float colorSpread = 256.0 * sinFactor;
    float pixelStep = colorSpread / nPixels;
    for (int i = 0; i < nPixels; i++) {
      int pixelAmp = panels[i / 61].getPixelAmp(i % 61);
      if (pixelAmp == 0) {
        panels[i / 61].targetColors[i % 61] = wheel.getColor((int) (pixelStep * i), 255);
        panels[i / 61].brightVals[i % 61] = brightness;
      } else {
        panels[i / 61].targetColors[i % 61] = wheel.getColor((int) (pixelStep * i), 255);
        panels[i / 61].brightVals[i % 61] = pixelAmp;
      }
    }
  }

  public void advanceType() {
    wipeType = (wipeType + 1) % typesOfWipe;
  }
}
