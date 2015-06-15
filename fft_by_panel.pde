public class FFTByPanel extends Mode {
  
  int[] panelBands = new int[nPanels];
  int freqThresh = 200;
  int ampFactor = 20;
  int beatOffset = 11;

  FFTByPanel(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    assignBands();
  }

  public void update() {
    fadeAll(fadeFactor);
    super.update();
    for (int i = 0; i < nPanels; i++) {
      int iAmp = constrain(bpm.getBand(panelBands[i]) * ampFactor, 0, 255);
      if (iAmp < freqThresh) {
        panels[i].fadeOne(fadeFactor, 30);
      } else { 
        panels[i].updateOne(wheel.getColor(0, iAmp), 30);
      }
    }
    for (int p = 0; p < nPanels; p++) {
      int[] c = panels[p].getOneByRingIndex(0, 0);
      shiftOutOne(c, p, true);
    }
    wheel.turn(1);
  }
  
  public void onBeat() {
    wheel.turn((int) (beatOffset * interloopWSF));
    /*for (int p = 0; p < nPanels; p++) {
      int[] c = panels[p].getOneByRingIndex(0, 0);
      shiftOutOne(c, p, true);
    }*/
  }
  
  public void randomize() {
    super.randomize();
    if (rand.nextInt(32) == 0) {
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
