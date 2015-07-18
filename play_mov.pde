public class PlayMov extends Mode {
  
  int[] pixelBands = new int[nPixels];
  int[] panelBands = new int[nPanels];
  int nImages = 6;
  int iImage = 3;
  PImage[] frames = new PImage[nImages];
  int gifCount;
  int pixelOffset = 1;
  int beatOffset = 1;
  boolean movieOn = true;
  int freqThresh = 100;
  int ampFactor = 50;
  int vidGain = 30;
  boolean isShifting = false;

  PlayMov(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    super(panels, wheel, fadeFactor, chance);
    delayable = true;
    assignBands();
    
    frames[0] = loadImage("smiley.jpg");
    frames[1] = loadImage("fire.jpg");
    frames[2] = loadImage("mask.png");
    frames[3] = loadImage("eye.jpg");
    frames[4] = loadImage("lotus.jpg");
    frames[5] = loadImage("rainbowSmoke.jpg");
    
    gifCount = 0;
    
  }
  
  void update() {
    fadeAll(fadeFactor);
    super.update();
    
    wheel.turn((int) (pixelOffset * intraloopWSF));
    
    rotateSmallHexes(rand.nextInt(2) == 0 ? false : true);
  }

  public void onBeat() {
    wheel.turn((int) (beatOffset * interloopWSF));
    movieOn = fubar < 0.5;
    if (movieOn) {
      drawFrame(gif[gifCount]);
      gifCount = (gifCount + 1) % gif.length;
    } else {
      drawFrame(frames[iImage]);
    }
    shift(shiftDir);
  }
  
  public void randomize() {
    super.randomize();
    if (rand.nextInt(highChance) == 0) {
      shiftDir = !shiftDir;
    }
    if (rand.nextInt(highChance) == 0) {
      shiftStyle = rand.nextInt(nShiftStyles);
    }
    if (rand.nextInt(highChance) == 0) {
      assignOneBand(rand.nextInt(nPanels));
    }
    if (rand.nextInt(highChance) == 0) {
      assignOnePixelBand(rand.nextInt(nPixels));
    }
    if (rand.nextInt(highChance) == 0) {
      isShifting = !isShifting;
    }
    if (rand.nextInt(highChance * 2) == 0) {
      iImage = rand.nextInt(nImages);
    }
  }
  
  private void assignBands() {
    for (int i = 0; i < nPanels; i++) {
      panelBands[i] = rand.nextInt(10);
    }
    for (int i = 0; i < nPixels; i++) {
      pixelBands[i] = rand.nextInt(30);
    }
  }
  
  private void assignOneBand(int index) {
    panelBands[index] = rand.nextInt(10);
  }
  
  private void assignOnePixelBand(int index) {
    pixelBands[index] = rand.nextInt(30);
  }
  
  void drawFrame(PImage image) {
    if (image.width > image.height) {
      image.resize(0, videoSize);
      image = image.get((image.width - videoSize) / 2, 0, videoSize, videoSize);
    } else {
      image.resize(videoSize, 0);
      image = image.get(0, (image.height - videoSize) / 2, videoSize, videoSize);
    }
    image.loadPixels();
    for (int p = 0; p < nPanels; p++) {
      int pAmp = constrain(bpm.getBand(panelBands[p]) * ampFactor, 0, 255);
      for (int i = 0; i < 61; i++) {
        int iAmp = constrain(bpm.getBand(pixelBands[i]) * ampFactor, 0, 255);
        if (iAmp < freqThresh) fadeOne(fadeFactor, i);
        else {
          float x = panels[p].videoMap[i][0];
          float y = panels[p].videoMap[i][1];
          int lowX = floor(x);
          int highX = ceil(x);
          int lowY = floor(y);
          int highY = ceil(y);
          
          color LL = image.pixels[lowY*image.width + lowX];
          int rLL = (LL >> 16) & 0xFF;
          int gLL = (LL >> 8) & 0xFF;
          int bLL = LL & 0xFF;
          float distLL = dist(x, y, lowX, lowY);
          
          color LH = image.pixels[highY*image.width + lowX];
          int rLH = (LH >> 16) & 0xFF;
          int gLH = (LH >> 8) & 0xFF;
          int bLH = LH & 0xFF;
          float distLH = dist(x, y, lowX, highY);
          
          color HL = image.pixels[lowY*image.width + highX];
          int rHL = (HL >> 16) & 0xFF;
          int gHL = (HL >> 8) & 0xFF;
          int bHL = HL & 0xFF;
          float distHL = dist(x, y, highX, lowY);
          
          color HH = image.pixels[highY*image.width + highX];
          int rHH = (HH >> 16) & 0xFF;
          int gHH = (HH >> 8) & 0xFF;
          int bHH = HH & 0xFF;
          float distHH = dist(x, y, highX, highY);
          
          float dist = distLL + distLH + distHL + distHH;
          
          if (dist == 0) {
            int[] c = {rLL, gLL, bLL};
            c = wheel.applyBrightness(c, pAmp);
            c = wheel.applyBrightness(c, globalBrightness);
            panels[p].updateOne(c, i);
          } else {
            int r = (int) ((rLL * distLL + rLH * distLH + rHL * distHL + rHH * distHH) / dist);
            int g = (int) ((gLL * distLL + gLH * distLH + gHL * distHL + gHH * distHH) / dist);
            int b = (int) ((bLL * distLL + bLH * distLH + bHL * distHL + bHH * distHH) / dist);
            r = min(r + vidGain, 255);
            g = min(g + vidGain, 255);
            b = min(b + vidGain, 255);
            int[] c = {r, g, b};
            c = wheel.applyBrightness(c, pAmp);
            c = wheel.applyBrightness(c, globalBrightness);
            panels[p].updateOne(c, i);
          }
        }
      }
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
