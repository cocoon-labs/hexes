class Field {
  
  Panel[] panels;
  ColorWheel wheel;
  int nPanels, chance;
  int modeChance;
  float faderModeChance = 0.02;
  int nModes = 14;
  Mode[] modes = new Mode[nModes];
  int mode = 12;
  int gwModeNum = nModes - 1;
  OPC opc;

  int GRAD_IDX = 12;
  int TRIG_IDX = 13;
  
  Field(int chanceFactor, int modeChance, OPC opc) {
    
    this.opc = opc;
    nPanels = 7;
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
    modes[6] = new Vertigo(panels, wheel, 0.70, chance);
    modes[7] = new Flowers(panels, wheel, 0.85, chance);
    modes[8] = new Paraguay(panels, wheel, 0.99, chance);
    modes[9] = new Snake(panels, wheel, 0.50, chance);
    modes[10] = new StarTrek(panels, wheel, 1.1, chance);
    modes[11] = new Spiral(panels, wheel, 0.50, chance);
    modes[12] = new GradientWipe(panels, wheel, 0.9, 1.17, chance); // was 1.07
    modes[13] = new TrigGradient(panels, wheel, 0.99, chance);
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
      int newMode = rand.nextInt(nModes);
      setMode(newMode);
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
    if (!soundReactive && mode < 4 || mode == 8) {
      mode = rand.nextInt(2) + 12;
    }
    oscSync();
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

  public void nextType() {
    modes[mode].advanceType();
  }
  
}
