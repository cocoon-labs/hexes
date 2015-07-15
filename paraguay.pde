public class Paraguay extends Mode {
  
  int[] panelBands = new int[nPanels];
  int beatOffset = 11;
  int pixelOffset = 1;
  boolean isShifting = true;
  int ampFactor = 20;

  Paraguay(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    highChance = 1;
    delayable = true;
    assignBands();
  }

  public void update() {
    fadeAll(fadeFactor);
    super.update();
    
    for (int p = 0; p < nPanels; p++) {
      int t = millis();
      int amp = constrain(bpm.getBand(panelBands[p]) * ampFactor, 0, 255);
      for (int i = 0; i < 61; i++) {
        int[] xy = iToXY(i);
        int x = xy[0];
        int y = xy[1];
        int index = p * 61 + i;
        //float r = amp * cos(x + t) * sin(y + t);
        //float g = amp * sin(x + t) * sin(y + t);
        //float b = amp * cos(y + t);
        //int[] c = new int[] {(int) r, (int) g, (int) b};
        int offset = (int) sqrt(sq(x) + sq(y) + sq(t / (amp + 1))); 
        //updateByIndex(wheel.getColor(offset + pixelOffset * i, amp), index);
        panels[p].updateOneByAverage(wheel.getColor(offset + pixelOffset * i, amp), i, 0.9);
      }
    }
    if (isShifting) {
      shiftStyle = 2;
      shift(shiftDir);
    }
    wheel.turn((int) intraloopWSF);
  }
  
  public void onBeat() {
    wheel.turn((int) (beatOffset * interloopWSF));
    
  }
  
  public void randomize() {
    super.randomize();
    if (rand.nextInt(highChance) == 0) {
      shiftDir = !shiftDir;
    }
    if (rand.nextInt(100) == 0) {
      isShifting = !isShifting;
    }
    if (rand.nextInt(highChance) == 0) {
      fadeFactor = 0.8 + rand.nextInt(18) / 100;
    }
    if (rand.nextInt(highChance) == 0) {
      shiftStyle = rand.nextInt(nShiftStyles);
    }
   if (rand.nextInt(highChance) == 0) {
      assignOneBand(rand.nextInt(nPanels));
    }
    if (rand.nextInt(128) == 0) {
      ampFactor = 10 + rand.nextInt(20);
    }
  }
  
  private void assignBands() {
    for (int i = 0; i < nPanels; i++) {
      panelBands[i] = rand.nextInt(10);
    }
  }
  
  private void assignOneBand(int index) {
    panelBands[index] = rand.nextInt(10);
  }
}
