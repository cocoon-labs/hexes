public class Spiral extends Mode {
  
  int maxSpirals = 50;
  int minSpirals = 10;
  int[] indexHigh = new int[maxSpirals];
  int[] indexLow = new int[maxSpirals];
  int numSpirals;
  int pixelOffset = 10;
  int beatOffset = 1;
  int spiralOffset = 5;
  int loopsPerUpdate = 200;
  int brightness = 255;
  int speed = 10;
  int ringOffset = 0;

  Spiral(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    delayable = true;
    numSpirals = 0;
    newSpiral(minSpirals);
  }
  
  void update() {
    fadeAll(fadeFactor);
    super.update();
    
    moveSpirals();
    wheel.turn((int) (pixelOffset * intraloopWSF));
  }

  public void onBeat() {
    minSpirals = (int) map(fubar, 0, 1, 1, 10);
    wheel.turn((int) (beatOffset * interloopWSF));
    if (numSpirals < minSpirals) newSpiral(numSpirals - minSpirals);
  }
  
  public void randomize() {
    super.randomize();
    if (rand.nextInt(highChance) == 0) {
      ringOffset++;
    }
    if (rand.nextInt(chance) == 0) {
      loopsPerUpdate = 1 + rand.nextInt(4);
    }
    if (rand.nextInt(chance) == 0) {
      speed = 5 + rand.nextInt(40);
    }
//    if (rand.nextInt(highChance) == 0) {
//      fadeFactor = 0.5 + rand.nextInt(500) / 1000;
//    }
    if (rand.nextInt(highChance) == 0) {
      if (rand.nextInt(2) == 0) {
        fadeFactor = fadeFactor + 0.05;
      } else {
        fadeFactor = fadeFactor - 0.05;
      }
      fadeFactor = constrain(fadeFactor, 0.5, 0.95);
    }
    if (rand.nextInt(highChance / 2) == 0) {
      fadeFactor = (fadeFactor + 1) / 2;
    }
    if (rand.nextInt(highChance) == 0) {
      newSpiral(1);
    }
    if (rand.nextInt(highChance / 2) == 0) {
      killSpiral();
    }
  }
  
  void newSpiral(int n) {
    maxSpirals = (int) map(fubar, 0, 1, 30, 50);
    for (int i = 0; i < n; i++) {
      if (numSpirals < maxSpirals) {
        indexHigh[numSpirals] = rand.nextInt(nPixels);
        indexLow[numSpirals] = indexHigh[numSpirals];
        numSpirals++;
      }
    }
  }
  
  void moveSpirals() {
    for (int i = 0; i < numSpirals; i++) {
      boolean needsReset = true;
      if (indexHigh[i] < nPixels) {
        updateBySpiralIndex(wheel.getColor((int) (intraloopWSF * spiralOffset) * i, 255), indexHigh[i], ringOffset);
        indexHigh[i]++;
        needsReset = false;
      }
      if (indexLow[i] > -1) {
        updateBySpiralIndex(wheel.getColor((int) (intraloopWSF * spiralOffset) * i, 255), indexLow[i], ringOffset);
        indexLow[i]--;
        needsReset = false;
      }
      if (needsReset) killSpiral(i);
    }
  }
  
  void killSpiral() {
    boolean needsNew = false;
    if (numSpirals <= minSpirals) {
      needsNew = true;
    }
    for (int i = 0; i < numSpirals - 1; i++) {
      indexHigh[i] = indexHigh[i + 1];
      indexLow[i] = indexLow[i + 1];
    }
    if (needsNew) {
      newSpiral(1);
    } else {
      numSpirals--;
    }
  }
  
  void killSpiral(int iToKill) {
    boolean needsNew = false;
    if (numSpirals <= minSpirals) {
      needsNew = true;
    }
    if (iToKill >= numSpirals) return;
    for (int i = iToKill; i < numSpirals - 1; i++) {
      indexHigh[i] = indexHigh[i + 1];
      indexLow[i] = indexLow[i + 1];
    }
    if (needsNew) {
      newSpiral(1);
    } else {
      numSpirals--;
    }
  }
}
