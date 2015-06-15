class Panel {
  
  int[][] colors;
  int[][] targetColors = new int[61][3];
  float[] brightVals = new float[61];
  int nPixels = 61;
  ColorWheel wheel;
  int index;
  float[] center;
  
  Panel(int index, ColorWheel wheel) {
    
    colors = new int[nPixels][3];
    this.index = index;
    this.wheel = wheel;
    this.center = panelCenter(index);
    
    for (int i = 0; i < nPixels; i++) {
      for (int j = 0; j < 3; j++) {
        colors[i][j] = 0;
        targetColors[i][j] = 0;
      }
      brightVals[i] = 0;
    }
  }
  
  void draw() {
    
    float radius = displaySize / 54;
    float delta = 2 * radius * sin(PI / 3);
    
    pushMatrix();
    translate(center[0], center[1]);
    rotate(PI / 6);
    translate(- 4 * radius, - 4 * delta);
    
    for (int row = 0; row < 9; row++) {
      pushMatrix();
      for (int n = rowStarts[row]; n < rowEnds[row] + 1; n++) {
        fill(colors[n][0], colors[n][1], colors[n][2]);
        pushMatrix();
        hexagon(0, 0, radius, false);
        popMatrix();
        translate(2 * radius, 0);
      }
      popMatrix();
      
      int dir = (row < 4) ? -1 : 1; 
      translate(dir * radius, delta);
    }
    
    popMatrix();
    
  }
  
  public void updateAll(int[] c) {
    for (int i = 0; i < 61; i++) {
      updateOne(c, i);
    }
  }
  
  public void updateOne(int[] c, int index) {
    colors[index] = c;
  }
  
  public int[] getOne(int index) {
    return colors[index];
  }
  
  void fadeAll(float factor) {
    for (int i = 0; i < 61; i++) {
      fadeOne(factor, i);
    }
  }
  
  public void fadeOne(float factor, int index) {
    colors[index][0] = int(colors[index][0] * factor);
    colors[index][1] = int(colors[index][1] * factor);
    colors[index][2] = int(colors[index][2] * factor);
  }
  
  public void refreshColors() {
    for (int i = 0; i < nPixels; i++) {
      colors[i][0] = int(map(brightVals[i], 0, 255, 0, targetColors[i][0]));
      colors[i][1] = int(map(brightVals[i], 0, 255, 0, targetColors[i][1]));
      colors[i][2] = int(map(brightVals[i], 0, 255, 0, targetColors[i][2]));
    }
  }
  
  public void fadeAllIn(float factor) {
    for (int i = 0; i < nPixels; i++) {
      brightVals[i] = constrain(factor * brightVals[i], 0, 255);
    }
  }
  
  public void fadeAllIn(float factor, int maxBrightness) {
    for (int i = 0; i < nPixels; i++) {
      brightVals[i] = factor * brightVals[i];
      if (brightVals[i] > maxBrightness)
        brightVals[i] = 0;
    }
  }
  
  public void fadeAllOut(float factor) {
    for (int i = 0; i < nPixels; i++) {
      brightVals[i] = factor * brightVals[i];
    }
  }
  
  public int getPixelAmp(int i) {
    return (colors[i][0] + colors[i][1] + colors[i][2]) / 3;
  }
  
}
