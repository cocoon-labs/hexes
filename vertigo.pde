public class Vertigo extends Mode {
  
  int[] panelBands = new int[nPanels];
  int freqThresh = 200;
  int beatOffset = 1;
  int panelOffset = 10;
  int ringOffset = 25;
  int ampFactor = 20;
  int[][] ringIndex = new int[nPanels][4];
  boolean[][] dirs = new boolean[nPanels][4];

  Vertigo(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    highChance = 4;
    delayable = true;
    assignBands();
    seed();
  }

  public void update() {
    fadeAll(fadeFactor);
    super.update();
    rotateRings();
    drawRings();
    drawCenters();
    wheel.turn((int) intraloopWSF);
  }
  
  public void onBeat() {
    wheel.turn((int) (beatOffset * interloopWSF));
    
  }
  
  public void randomize() {
    super.randomize();
    if (rand.nextInt(highChance) == 0) {
      if (rand.nextInt(2) == 0) {
        fadeFactor = fadeFactor + 0.05;
      } else {
        fadeFactor = fadeFactor - 0.05;
      }
      fadeFactor = constrain(fadeFactor, 0.6, 0.9);
    }
    if (rand.nextInt(1) == 0) {
      int panel = rand.nextInt(nPanels);
      int ring = rand.nextInt(4);
      dirs[panel][ring] = !dirs[panel][ring];
    }
    if (rand.nextInt(highChance) == 0) {
      assignOneBand(rand.nextInt(nPanels));
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
  
  void seed() {
    for (int i = 0; i < nPanels; i++) {
      for (int r = 0; r < 4; r++) {
        //ringIndex[i][r] = rand.nextInt((r + 1) * 6);
        ringIndex[i][r] = 0;
        dirs[i][r] = (rand.nextInt(2) == 0) ? true : false;
      }
    }
  }
  
  void rotateRings() {
    for (int i = 0; i < nPanels; i++) {
      for (int r = 0; r < 4; r++) {
        int ring = r + 1;
        if (dirs[i][r]) {
          ringIndex[i][r] = (ringIndex[i][r] + 1) % (ring * 6);
        } else {
          if (ringIndex[i][r] == 0) {
            ringIndex[i][r] = ring * 6 - 1;
          } else {
            ringIndex[i][r] = (ringIndex[i][r] - 1) % (ring * 6);
          } 
        }
      }
    }
  }
  
  void drawRings() {
    for (int i = 0; i < nPanels; i++) {
      for (int r = 0; r < 4; r++) {
        updateByRingIndex(wheel.getColor((int) (intraloopWSF * panelOffset) * i + (int) (r * ringOffset * intraloopWSF), 255), i, r + 1, ringIndex[i][r]);
      }
    }
  }
  
  void drawCenters() {
    for (int i = 0; i < nPanels; i++) {
      int iAmp = constrain(bpm.getBand(panelBands[i]) * ampFactor, 0, 255);
      if (iAmp < freqThresh) {
        panels[i].fadeOne(fadeFactor, 30);
      } else { 
        panels[i].updateOne(wheel.getColor(0, iAmp), 30);
      }
    }
  }
}
