public class Hypnotize extends Mode {
  
  int beatOffset = 31;
  boolean direction = true;
  int randomChance = 60;
  int mainMove = 0;
  int nMainMoves = 2;

  Hypnotize(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    delayable = true;
    
  }
  
  public void update() {
    fadeAll(fadeFactor);
    super.update();
    shift(direction);
    wheel.turn(1);
    randomize();
  }
  
  public void onBeat() {
    wheel.turn((int) (beatOffset * interloopWSF));
  }
  
  public void randomize() {
    super.randomize();
    if (rand.nextInt(randomChance) == 0) {
      direction = !direction;
    }
    if (rand.nextInt(randomChance) == 0) {
      fadeFactor = 0.8 + rand.nextInt(18) / 100;
    }
    if (rand.nextInt(randomChance) == 0) {
      int p = rand.nextInt(nPanels);
      int colorOffset = rand.nextInt(30);
      int ring = rand.nextInt(5);
      int brightness = 50 + rand.nextInt(205);
      int[] c = wheel.getColor(colorOffset, (int)map(globalBrightness, 0, 255, 0, brightness));
      panels[p].updateRing(c, ring);
    }
    if (rand.nextInt(randomChance) == 0) {
      int p = rand.nextInt(nPanels);
      int ring = rand.nextInt(5);
      panels[p].fadeRing(fadeFactor, ring);
    }
    if (rand.nextInt(randomChance) == 0) {
      int p = rand.nextInt(nPanels);
      int colorOffset = rand.nextInt(30);
      int brightness = 50 + rand.nextInt(205);
      int[] c = wheel.getColor(colorOffset, (int)map(globalBrightness, 0, 255, 0, brightness));
      //panels[p].updateEdge(c);
    }
    if (rand.nextInt(randomChance) == 0) {
      int i = rand.nextInt(nPixels);
      int colorOffset = rand.nextInt(30);
      int brightness = 50 + rand.nextInt(205);
      int[] c = wheel.getColor(colorOffset, (int)map(globalBrightness, 0, 255, 0, brightness));
      updateByIndex(c, i);
    }
    if (rand.nextInt(randomChance) == 0) {
      shiftStyle = rand.nextInt(nShiftStyles);
    }
  }
  
}
