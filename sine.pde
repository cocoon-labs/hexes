public class TrigGradient extends Mode {

  int panelOff = 32;
  float maxTrigCoeff = 2;
  float minTrigCoeff = 0.5;
  float trigCoeff = 1;
  float t0 = 0;
  float timeStep = 0.1;
  float panelTOff = 0;
  float turnBack = random(12.56, 62.8);
  float minTime = 0;
  int sinFactSelect = 2;
  int nSinFacts = 5;
  
  TrigGradient(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    delayable = true;
  }

  public void update() {
    super.update();
    fadeAll(fadeFactor);
    int[] c;
    int[] xy;
    for (int i = 0; i < nPanels; i++) {
      for (int j = 0; j < panels[i].nPixels; j++) {
        xy = iToXY(j);
        float sinFactor = calculateSinFactor(xy, t0 + i * panelTOff);
        c = wheel.getColor((int) (intraloopWSF * abs(sinFactor) * j + i * panelOff),
                           (int) map(sinFactor, -trigCoeff, trigCoeff, 64, 255));
        panels[i].updateOne(c, j);
      }
    }
    t0 = t0 + timeStep;
    wheel.turn((int)interloopWSF);
  }

  public void onBeat() {
    if (t0 > turnBack) {
      println("bigger than " + t0);
      minTime = 0;
      turnBack = t0;
      timeStep = -timeStep;
    } else if (t0 < minTime) {
      minTime = t0;
      timeStep = -timeStep;
      turnBack = random(16, 128);
    }
  }

  public void randomize() {
    if (rand.nextInt(chance) == 0) {
      trigCoeff = map(random(maxTrigCoeff), 0, maxTrigCoeff, minTrigCoeff, maxTrigCoeff + 1);
    }
    if (rand.nextInt(chance) == 0) {
      timeStep = random(0.02, 0.13);
    }
  }

  public float calculateSinFactor(int[] xy, float t) {
    float result = 0.0;
    switch(sinFactSelect) {
    case 0:
      result = trigCoeff * (sin(t + xy[0]) + cos(t + xy[1]));
      break;
    case 1:
      // result = trigCoeff * (constrain(tan(0.1 * t * xy[0]), -1, 1) + constrain(tan(0.1 * t * xy[1]), -1, 1));
      result = trigCoeff * (sin(0.1 * t * (xy[1] + xy[0])));
      break;
    case 2:
      result = trigCoeff * (sin(0.1 * t * xy[1]) + cos(0.1 * t * xy[0]));
      break;
    case 3:
      result = trigCoeff * ( cos(t*xy[0] + 1.57 + xy[1]));
      break;
    case 4:
      result = trigCoeff * (sin(t + xy[0]));
      break;
    }
    return result;
  }

  public void advanceType() {
    sinFactSelect = (sinFactSelect + 1) % nSinFacts;

  }
    

}
