class Mode {
  
  Panel[] panels;
  ColorWheel wheel;
  float fadeFactor;
  int chance;
  int nPanels, nPixels;
  int prevTime;
  boolean justEntered = false;
  boolean delayable = false;
  
  Mode(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    this.panels = panels;
    this.wheel = wheel;
    this.fadeFactor = fadeFactor;
    this.chance = chance;
    this.nPanels = panels.length;
    this.prevTime = millis();
    nPixels = nPanels * 61;
  }
  
  public void advance() {
    int time = millis();
    if (!delayable) {
      update();
    } else if (delay == 0 || (time - prevTime) > delay) {
      update();
      prevTime = time;
    }
  }

  public void update() {
    if (bpm.isBeat()) {
      onBeat();
      randomize();
    }
  }
  
  public void onBeat() {
    // behavior that should only happen on the beat
  }
  
  public void randomize() {
    if (rand.nextInt(chance) == 0) {
      wheel.newScheme();
    }
  }
  
  public void fadeAll(float factor) {
    for (int i = 0; i < nPanels; i++) {
      panels[i].fadeAll(factor);
    }    
  }
  
  public void fadeOne(float factor, int index) {
    panels[index / 61].fadeOne(factor, index % 61);
  }
  
  public void updateByIndex(int[] c, int index) {
    panels[index / 61].updateOne(c, index % 61);
  }
  
  public void refreshColors() {
    for (int i = 0; i < nPanels; i++) {
      panels[i].refreshColors();
    }
  }
  
  public void fadeAllInThenDisappear(float factor) {
    for (int i = 0; i < nPanels; i++) {
      panels[i].fadeAllIn(factor, 255);
    }
  }
  
  public void fadeAllIn(float factor) {
    for (int i = 0; i < nPanels; i++) {
      panels[i].fadeAllIn(factor);
    }
  }
  
  public void turnOnAll(int wheelOffset, int brightness) {
    for (int i = 0; i < nPixels; i++) {
      panels[i / 61].targetColors[i % 61] = wheel.getColor(wheelOffset, 255);
      panels[i / 61].brightVals[i % 61] = brightness;
    } 
  }
  
  public void fadeAllOut(float factor) {
    for (int i = 0; i < nPanels; i++) {
      panels[i].fadeAllOut(factor);
    }
  }
  
}
