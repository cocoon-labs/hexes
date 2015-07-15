public class Ninja extends Mode {

  int expansionFactor = 0;
  int inc = -1;
  int index = 0;
  int direction = 1;
  int freqThresh = 80;
  int ampFactor = 20;
  boolean started = true;

  Ninja(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    delayable = true;
  }
  
  public void update() {
    fadeAll(fadeFactor);
    super.update();
    int centerRow = 4;
    int centerCol = 4;
    int[] white = {255, 255, 255};
    int[] black = {0, 0, 0};

    for (int i = 0; i < nPanels; i++) {
      drawFlower(i, centerRow, centerCol);
      updateFFT(i);
    }

    if (rand.nextInt(40) == 0 || index == 0)
      direction = -direction;
    
    index = Math.abs((index + direction) % (6 * triangleN));
    if (index % triangleN == 0) {
      int next = rand.nextInt(4) + 1;
      if (next != 3)
        index = Math.abs((index + direction * (rand.nextInt(4) + 1) * triangleN) % (6 * triangleN));
    }

    wheel.turn((int) intraloopWSF);
  }

  public void onBeat() {
    wheel.turn((int) (8 * interloopWSF));
  }

  public void drawFlower(int pIdx, int row, int col) {
    int[] c = wheel.getColor((int) (pIdx * 4 * intraloopWSF), 255);
    
    updateTriangleByIndex(c, pIdx, index / triangleN + pIdx, index % triangleN);
    updateTriangleByIndex(c, pIdx, (index / triangleN) + 3 + pIdx, index % triangleN);

  }

  public void updateFFT(int pIdx) {
    for (int i = 0; i < nPanels * 6; i++) {
      int iAmp = constrain(getTriangleBand(i) * ampFactor, 0, 255);
      float triStep = 8;
      if (iAmp < freqThresh) {
        for (int j = 12; j < 15; j++) {
          fadeOne(fadeFactor, pIdx * 61 + panels[pIdx].triangleToI(i % 6, j));
        }
      } else {
        int[] c = wheel.getColor((int) ((int) (triStep * intraloopWSF) * i), iAmp);
        for (int j = 12; j < 15; j++) {
          updateTriangleByIndex(c, pIdx, i % 6, j);
        }
      }
    }
  }

  public int getTriangleBand(int triIndex) {
    float indexMap = map(triIndex, 0, 6 * nPanels - 1, 0, 29);
    int lowBandIndex = (int) indexMap;
    float decimal = indexMap - lowBandIndex;
    if (decimal == 0.0) return (int) bpm.getDetailBand(lowBandIndex);
    float weightedLowBand = (1.0 - decimal) * bpm.getDetailBand(lowBandIndex);
    float weightedHighBand = decimal * bpm.getDetailBand(lowBandIndex + 1);
    return (int) (weightedLowBand + weightedHighBand);
  }

}
