public class Snake extends Mode {
  
  int maxSnakes = 60;
  int minSnakes = 40;
  int[] snakePos = new int[maxSnakes];
  int numSnakes;
  int beatOffset = 1;
  int snakeOffset = 5;
  int ampFactor = 20;

  Snake(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    highChance = 4;
    delayable = true;
    numSnakes = 0;
    newSnake(minSnakes);
  }

  public void update() {
    fadeAll(fadeFactor);
    super.update();
    moveSnakes();
    drawSnakes();
    wheel.turn((int) intraloopWSF);
  }
  
  public void onBeat() {
    wheel.turn((int) (beatOffset * interloopWSF));
    if (numSnakes < minSnakes) newSnake(numSnakes - minSnakes);
  }
  
  public void randomize() {
    super.randomize();
    if (rand.nextInt(highChance) == 0) {
      newSnake(1);
    }
    if (rand.nextInt(highChance) == 0) {
      killSnake();
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
      fadeFactor = constrain(fadeFactor, 0.5, 0.9);
    }
    if (rand.nextInt(highChance / 2) == 0) {
      fadeFactor = (fadeFactor + 1) / 2;
    }
    if (rand.nextInt(highChance) == 0) {
      int i = rand.nextInt(nPixels);
      int colorOffset = rand.nextInt(30);
      int brightness = 50 + rand.nextInt(205);
      int[] c = wheel.getColor(colorOffset, brightness);
      updateByIndex(c, i);
    }
  }
  
  void newSnake(int n) {
    for (int i = 0; i < n; i++) {
      if (numSnakes < maxSnakes) {
        snakePos[numSnakes] = rand.nextInt(nPixels);
        numSnakes++;
      }
    }
  }
  
  void moveSnakes() {
    for (int i = 0; i < numSnakes; i++) {
      snakePos[i] = randomNeighbor(snakePos[i]);
    }
  }
  
  void drawSnakes() {
    for (int i = 0; i < numSnakes; i++) {
      updateByIndex(wheel.getColor((int) (intraloopWSF * snakeOffset) * i, 255), snakePos[i]);
    }
  }
  
  void killSnake() {
    if (numSnakes > minSnakes) {
      for (int i = 0; i < numSnakes - 1; i++) {
        snakePos[i] = snakePos[i + 1];
      }
      numSnakes--;
    }
  } 
}
