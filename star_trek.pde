public class StarTrek extends Mode {
  
  StarTrek(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    delayable = true;
  }
  
  public void update() {
    fadeAllInThenDisappear(fadeFactor);
    turnOnPixels(rand.nextInt(10), 0, 1);
    super.update();
    refreshColors();
    wheel.turn((int) (1 * interloopWSF));
  }
  
  public void onBeat() {
  }
  
  public void turnOnPixels(int nOn, int wheelOffset, int brightness) {
    for (int n = 0; n < nOn; n++) {
      int i = rand.nextInt(nPixels);
      if (panels[i / 61].brightVals[i % 61] == 0) {
        panels[i / 61].targetColors[i % 61] = wheel.getColor(wheelOffset, 255);
        panels[i / 61].brightVals[i % 61] = brightness;
      }
    } 
  }
  
  public void randomize() {
    super.randomize();
    if (rand.nextInt(chance) == 0) {
      fadeFactor = 1.01 + rand.nextInt(50) / 100.0;
    }
  }
}
