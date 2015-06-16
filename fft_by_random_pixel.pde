public class FFTByRandomPixel extends Mode {
  
  int[] pixelBands = new int[nPixels];
  int freqThresh = 100;
  int ampFactor = 10;
  int beatOffset = 11;

  FFTByRandomPixel(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    assignBands();
    delayable = true;
  }

  public void update() {
    fadeAll(fadeFactor);
    super.update();
    for (int i = 0; i < nPixels; i++) {
      int iAmp = constrain(bpm.getBand(pixelBands[i]) * ampFactor, 0, 255);
      if (iAmp < freqThresh) fadeOne(fadeFactor, i);
      else updateByIndex(wheel.getColor(0, iAmp), i);
    }
    wheel.turn((int) intraloopWSF);
  }
  
  public void onBeat() {
    wheel.turn((int) (beatOffset * interloopWSF));
    if (rand.nextInt(4) == 0) {
      assignOneBand(rand.nextInt(nPixels));
    }
    if (rand.nextInt(128) == 0) {
      ampFactor = 10 + rand.nextInt(20);
    }
  }
  
  public void randomize() {
    super.randomize();
    if (rand.nextInt(highChance) == 0) {
      shiftDir = !shiftDir;
    }
    if (rand.nextInt(highChance) == 0) {
      fadeFactor = 0.8 + rand.nextInt(18) / 100;
    }
    if (rand.nextInt(highChance) == 0) {
      shift(shiftDir);
    }
    if (rand.nextInt(highChance) == 0) {
      shiftStyle = rand.nextInt(nShiftStyles);
    }
  }
  
  private void assignBands() {
    for (int i = 0; i < nPixels; i++) {
      pixelBands[i] = rand.nextInt(30);
    }
  }
  
  private void assignOneBand(int index) {
    pixelBands[index] = rand.nextInt(30);
  }
}
