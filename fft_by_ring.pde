public class FFTByRing extends Mode {
  
  int freqThresh = 120;
  int ampFactor = 20;
  int beatOffset = 11;
  int panelOffset = 10;
  boolean isShifting = false;

  FFTByRing(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    highChance = 8;
    delayable = true;
  }

  public void update() {
    fadeAll(fadeFactor);
    super.update();
    
    int rAmp = constrain(getRingBand(0) * ampFactor, 0, 255);
    float pixelStep = 256.0 / 61;
    
    for (int p = 0; p < nPanels; p++) {
      for (int r = 0; r < 5; r++) {
        rAmp = constrain(getRingBand(r) * ampFactor, 0, 255);
        for (int i = 0; i < max(1, r * 6); i++) {
          int n = ringToI(r, i);
          if (rAmp < freqThresh) fadeRing(fadeFactor, r);
          else {
            int[] c = wheel.getColor((int) ((int) (pixelStep * intraloopWSF) * n) + (p * (int) (panelOffset * interloopWSF)), rAmp);
            panels[p].updateOneByAverage(new int[] {c[0], c[1], c[2]}, n, .999);
            //panels[p].updateOne(new int[] {c[0], c[1], c[2]}, n);
          }
        }
      }
    }
    if (isShifting) {
      shift(shiftDir);
    }
    wheel.turn((int) intraloopWSF);
  }
  
  public void onBeat() {
    wheel.turn((int) (beatOffset * interloopWSF));
    if (rand.nextInt(128) == 0) {
      ampFactor = 10 + rand.nextInt(20);
    }
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
  }
  
  public int getRingBand(int ring) {
    float indexMap = map(ring, 0, 4, 0, 29);
    int lowBandIndex = (int) indexMap;
    float decimal = indexMap - lowBandIndex;
    if (decimal == 0.0) return (int) bpm.getDetailBand(lowBandIndex);
    float weightedLowBand = (1.0 - decimal) * bpm.getDetailBand(lowBandIndex);
    float weightedHighBand = decimal * bpm.getDetailBand(lowBandIndex + 1);
    return (int) (weightedLowBand + weightedHighBand);
  }
}
