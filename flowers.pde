public class Flowers extends Mode {

  int selector = 0;
  int skipper = 1;
  int nModes = 3;
  int maxSkip = 2;
  int objStep = 16;
  int initBright = 60;
  int brghtness = initBright;
  int[] black = new int[] {0, 0, 0};
  int brghtDir = 5;
  int freqThresh = 80;
  int ampFactor = 30;

  Flowers(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    delayable = true;
  }

  public void update() {
    fadeAll(fadeFactor);
    super.update();
    if (brghtness == initBright) {
      brghtDir = 5;
    } else if (brghtness == 255) {
      brghtDir = -5;
    }
    brghtness += brghtDir;

    int[] c;
    for (int i = 0; i < nPanels; i++) {
      for (int j = 0; j < triangleN - 3; j += skipper) {
        c = wheel.getColor(j * (int) map(interloopWSF, 0, 5, 8, 16),
                           constrain(getPanelBand(i) * ampFactor, 0, 255));
        for (int k = 0; k < nTriangles; k++) {
          if (Arrays.equals(panels[i].getOneByTriangleIndex(k, j), black)) {
            updateTriangleByIndex(c, i, k, j);
          }
        }
      }
    }
    rotateSmallHexes(rand.nextInt(2) == 0 ? false : true);
    wheel.turn((int) intraloopWSF);
  }

  public void onBeat() {
    int[] c;
    for (int i = 0; i < nPanels; i+= skipper) {
      if (rand.nextInt((int) map(fubar, 0, 1, 1, 64)) == 0) {
        for (int j = 0; j < nRings; j += constrain(skipper, 2, maxSkip + 1)) {
          c = wheel.getColor(j * (int) map(interloopWSF, 0, 5, 8, 16),
                             constrain(getPanelBand(i) * ampFactor, 0, 255));
          updateRing(c, j);
        }
      }
      if (rand.nextInt((int) map(fubar, 0, 1, 1, 32)) == 0) {
        for (int j = 0; j < 7; j += skipper) {
          for (int k = 0; k < 7; k += skipper) {
            if (Arrays.equals(panels[i].getOneByHex(j, 6), black)) {
              c = wheel.getColor(k * (int) map(interloopWSF, 0, 5, 8, 16),
                                 constrain(getPanelBand(i) * ampFactor, 0, 255));
              panels[i].updateOneByHex(c, j, k);
            } else rotateSmallHexes(rand.nextInt(2) == 0 ? false : true);
          }
        }
      }
    }
  }

  public int getPanelBand(int pIndex) {
    float indexMap = map(pIndex, 0, 6 * nPanels - 1, 0, 29);
    int lowBandIndex = (int) indexMap;
    float decimal = indexMap - lowBandIndex;
    if (decimal == 0.0) return (int) bpm.getDetailBand(lowBandIndex);
    float weightedLowBand = (1.0 - decimal) * bpm.getDetailBand(lowBandIndex);
    float weightedHighBand = decimal * bpm.getDetailBand(lowBandIndex + 1);
    return (int) (weightedLowBand + weightedHighBand);
  }

  public void randomize() {
    super.randomize();
    if (rand.nextInt(chance / 4) == 0) {
      rotateSmallHexes(rand.nextInt(2) == 0 ? false : true);
    }
  }
}
