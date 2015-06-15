class Field {
  
  Panel[] panels;
  ColorWheel wheel;
  int nPanels, chance;
  int modeChance = 5000;
  float faderModeChance = 0.02;
  Mode[] modes = new Mode[3];
  int nModes;
  int mode = 2;
  
  Field(int chanceFactor) {
    
    nPanels = 7;
    nModes = modes.length;
    panels = new Panel[nPanels];
    wheel = new ColorWheel();
    for (int i = 0; i < nPanels; i++) {
      panels[i] = new Panel(i, wheel);
    }
    
    chance = chanceFactor;
    modes[0] = new FFTByPixel(panels, wheel, 0.98, chance);
    modes[1] = new FFTByPanel(panels, wheel, 0.8, chance);
    modes[2] = new Hypnotize(panels, wheel, 0.98, chance);
    
  }
  
  void draw() {
    
    for (int i = 0; i < nPanels; i++) {
      panels[i].draw();
    }
    
  }
  
  public void update() {
    modes[mode].advance();
  }
  
  public void randomize() {
    //if (rand.nextInt(modeChance) == 0 && modeSwitching) {
    //  setMode(rand.nextInt(nModes));
    //}
  }
  
  public void newScheme() {
    wheel.newScheme();
  }
  
  public void setVibeWhite() {
    wheel.vibe = 3;
    wheel.newScheme();
  }
  
  public void incVibe() {
    if (wheel.vibe == 3) wheel.vibe = 0;
    else wheel.vibe = (wheel.vibe + 1) % 3;
    wheel.newScheme();
  }

  public void setRainbow() {
    wheel.vibe = 0;
    wheel.setScheme(0);
  }
  
  public void setMode(int m) {
    mode = m;
    modes[mode].justEntered = true;
  }
  
  public void adjustDelay(int step) {
    delay = step;
  }
  
  public int getDelay() {
    return delay;
  }

  public void setModeChance(float factor) {
    modeChance = (int) (5100.0 - 5000.0 * factor);
    faderModeChance = factor;
  }
  
  public float getModeChanceForFader() {
    return faderModeChance;
  }
  
}
