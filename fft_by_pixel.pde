public class FFTByPixel extends Mode {
  
  int freqThresh = 80;
  int ampFactor = 20;
  int beatOffset = 11;

  FFTByPixel(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
  }

  public void update() {
    fadeAll(fadeFactor);
    super.update();
    for (int i = 0; i < nPixels; i++) {
      int iAmp = constrain(getPixelBand(i) * ampFactor, 0, 255);
      float pixelStep = 256.0 / nPixels;
      if (iAmp < freqThresh) fadeOne(fadeFactor, i);
      else updateByIndex(wheel.getColor((int) ((int) (pixelStep * intraloopWSF) * i), iAmp), i);
    }
  }
  
  public void onBeat() {
    wheel.turn((int) (beatOffset * interloopWSF));
    if (rand.nextInt(128) == 0) {
      ampFactor = 10 + rand.nextInt(20);
    }
  }
  
  public int getPixelBand(int pixelIndex) {
    float indexMap = map(pixelIndex, 0, nPixels - 1, 0, 29);
    int lowBandIndex = (int) indexMap;
    float decimal = indexMap - lowBandIndex;
    if (decimal == 0.0) return (int) bpm.getDetailBand(lowBandIndex);
    float weightedLowBand = (1.0 - decimal) * bpm.getDetailBand(lowBandIndex);
    float weightedHighBand = decimal * bpm.getDetailBand(lowBandIndex + 1);
    return (int) (weightedLowBand + weightedHighBand);
  }
}
