class Panel {
  
  int[][] colors;
  int[][] targetColors = new int[61][3];
  float[] brightVals = new float[61];
  int nPixels = 61;
  ColorWheel wheel;
  int index;
  float[] center;
  int nStrips = rowStarts.length;
  
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

  public void updateRowCol(int[] c, int row, int col) {
    int pixIdx = 0;
    row = row % nStrips;
    col = col % rowLen(row);
    for (int i = 0; i < row; i++) {
      pixIdx += rowLen(i);
    }
    pixIdx += col;
    colors[pixIdx] = c;
  }

  public void updateStrip(int[] c, int row, boolean flip) {
    if (!flip) {
      updateStripNoFlip(c, row);
    } else {
      updateStripFlip(c, row);
    }
  }
  
  public void updateStripNoFlip(int[] c, int row) {
    row = row % nStrips;
    int rowStart = rowStarts[row];
    int rowEnd = rowStart + rowLen(row);
    for (int i = rowStart; i < rowEnd; i++) {
      colors[i] = c;
    }
  }
  
  public void updateStripFlip(int[]c, int row) {
    int centerRow = nStrips / 2;
    int centerCol = rowLen(centerRow) / 2;
    if (row <= nStrips / 2) {
      for (int i = 0; i <= nStrips / 2; i++) {
        updateRowCol(c, centerRow - i, row);
      }
      for (int i = nStrips / 2 + 1; i <= nStrips / 2 + row; i++) {
        updateRowCol(c, i, rowLen(row) - i - 1);
      }
    } else {
      for (int i = row - nStrips / 2 ; i <= nStrips / 2; i++) {
        updateRowCol(c, i, row);
      }
      for (int i = nStrips / 2 + 1; i < nStrips; i++) {
        updateRowCol(c, i, rowLen(i) - (nStrips - row));
      }
    }
      
  }

  public void updateSide(int[] c, int side) {
    switch(side) {
    case(0) : // Top right
      updateStrip(c, 0, false);
      break;
    case(1) : // Right
      for (int i = 0; i <= nStrips / 2; i++) {
        updateOne(c, rowEnds[i]);
      }
      break;
    case(2) : // Bottom Right
      for (int i = nStrips / 2; i < nStrips; i++) {
        updateStrip(c, nStrips - 1, true);
      }
      break;
    case(3) : // Bottom Left
      updateStrip(c, nStrips - 1, false);
      break;
    case(4) : // Left
      for (int i = nStrips / 2; i < nStrips; i++) {
        updateOne(c, rowStarts[i]);
      }
      break;
    case(5) : // Top Left
      updateStrip(c, 0, true);
    }
  }

  public void updateEdge(int[] c) {
    for (int i = 0; i < 6; i++) {
      updateSide(c, i);
    }
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

  private int rowLen(int r) {
    return rowEnds[r] - rowStarts[r] + 1;
  }
  
}