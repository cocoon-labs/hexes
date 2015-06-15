public class GradientWipe extends Mode {
  
  int loopOffset = 1;
  int loopCounter = 0;
  boolean fadingIn = false;
  float fadeInFactor;
  int fadeCounter = 0;
  
  GradientWipe(Panel[] panels, ColorWheel wheel, float fadeFactor, float fadeInFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    delayable = true;
    this.fadeInFactor = fadeInFactor;
  }
  
  public void update() {
    if (justEntered) {
      turnOnRest(0,2);
      refreshColors();
      justEntered = false;
      fadeCounter = 0;
      fadingIn = true;
      super.update();
    } else if (fadingIn) {
      fadeAllIn(fadeInFactor);
      float sinFactor = (1.875 * sin(0.0016 * loopCounter)) + 2.125;
      float colorSpread = 256.0 * sinFactor;
      float pixelStep = colorSpread / nPixels;
      for (int i = 0; i < nPixels; i++) {  
        panels[i / 61].targetColors[i % 61] = wheel.getColor((int) (pixelStep * i), 255);
      }
      wheel.turn((int) (loopOffset * interloopWSF));
      refreshColors();
      if (fadeCounter < 73)
        fadeCounter++;
      else
        fadingIn = false;
      super.update();
    } else {
      float sinFactor = (1.875 * sin(0.0016 * loopCounter)) + 2.125;
      float colorSpread = 256.0 * sinFactor;
      float pixelStep = colorSpread / nPixels;
      fadeAll(fadeFactor);
      super.update();
      for (int i = 0; i < nPixels; i++) {  
        updateByIndex(wheel.getColor((int) (pixelStep * i), 255), i);
      }
      wheel.turn((int) (loopOffset * interloopWSF));
      loopCounter = (loopCounter + 1) % 3927;
    }

  }
  
  public void onBeat() {
    
  }
  
  public void randomize() {
    if (rand.nextInt(chance) == 0) {
      loopOffset = 1 + rand.nextInt(5);
    }
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
}
