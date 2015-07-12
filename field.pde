class Field {
  
  Panel[] panels;
  ColorWheel wheel;
  int nPanels, chance;
  //int modeChance = 5000;
  int modeChance;
  float faderModeChance = 0.02;
  Mode[] modes = new Mode[6];
  int nModes;
  int mode = 5;
  OPC opc;
  
  Field(int chanceFactor, int modeChance, OPC opc) {
    
    this.opc = opc;
    nPanels = 7;
    nModes = modes.length;
    panels = new Panel[nPanels];
    wheel = new ColorWheel();
    for (int i = 0; i < nPanels; i++) {
      panels[i] = new Panel(i, opc, wheel);
    }
    
    chance = chanceFactor;
    this.modeChance = modeChance;
    modes[0] = new FFTByRing(panels, wheel, 0.99, chance);
    modes[1] = new FFTByPanel(panels, wheel, 0.8, chance);
    modes[2] = new FFTByPixel(panels, wheel, 0.98, chance);
    modes[3] = new FFTByRandomPixel(panels, wheel, 0.99, chance);
    modes[4] = new Hypnotize(panels, wheel, 0.98, chance);
    modes[5] = new Ninja(panels, wheel, 0.93, chance);
    
  }
  
  void draw() {
    
    for (int i = 0; i < nPanels; i++) {
      panels[i].draw();
    }
    
  }

  void send() {
    for (int i = 0; i < nPanels; i++) {
      panels[i].ship(i * panels[0].nPixels);
  }
  }
  
  public void update() {
    modes[mode].advance();
  }
  
  public void randomize() {
    if (rand.nextInt(modeChance) == 0 && modeSwitching) {
      setMode(rand.nextInt(nModes));
    }
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
    modeChance = (int) (5024.0 - 5000.0 * factor);
    faderModeChance = factor;
  }
  
  public float getModeChanceForFader() {
    return faderModeChance;
  }
  
}
