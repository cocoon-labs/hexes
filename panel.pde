class Panel {
  
  int[][] colors;
  int[][] targetColors = new int[61][3];
  float[] brightVals = new float[61];
  int nPixels = 61;
  ColorWheel wheel;
  int index;
  float[] center;
  int nStrips = rowStarts.length;
  int DOWNDIAG = 0, UPDIAG = 1, VERTICAL = 2;
  OPC opc;
  
  Panel(int index, OPC opc, ColorWheel wheel) {
    
    colors = new int[nPixels][3];
    this.index = index;
    this.wheel = wheel;
    this.center = panelCenter(index);
    this.opc = opc;
    
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
    
    
    int t = millis();
    for (int row = 0; row < 9; row++) {
      pushMatrix();
      for (int n = rowStarts[row]; n < rowEnds[row] + 1; n++) {
        fill(colors[n][0], colors[n][1], colors[n][2]);
        // ADDED THIS ///////////////////////////////////////////////////////////////////////////
        if (fxOn) {
          if (fxTimed) {
            t = millis();
          }
          int[] colorsFX = fx(colors[n][0], colors[n][1], colors[n][2], t);
          colorsFX = averageColor(colors[n], colorsFX, 1.0 - fxGain);
          fill(colorsFX[0], colorsFX[1], colorsFX[2]);
        }
        ////////////////
        pushMatrix();
        hexagon(0, 0, radius, false);
        popMatrix();
        /*fill(255);
        textSize(radius);
        text("" + n, -radius/2 - 10, radius/2 - 10);*/
        translate(2 * radius, 0);
      }
      popMatrix();
      
      int dir = (row < 4) ? -1 : 1; 
      translate(dir * radius, delta);
    }
    
    popMatrix();
    
  }

  public void ship(int idxOffset) {
    for (int i = 0; i < nPixels; i++) {
      opc.setPixel(idxOffset + i, colors[i][0] << 16 | colors[i][1] << 8 | colors[i][2]);
    }
    opc.writePixels();
  }
  
  public void updateAll(int[] c) {
    for (int i = 0; i < 61; i++) {
      updateOne(c, i);
    }
  }
  
  public void updateOne(int[] c, int index) {
    colors[index] = c;
  }
  
  public void updateOneByAverage(int[] c, int index, float factor) {
    colors[index] = averageColor( new int[] {c[0], c[1], c[2]} , colors[index], factor);
  }
  
  public void updateOneByHex(int[] c, int j, int k) {
    int[] newC = new int[] {c[0], c[1], c[2]};
    colors[hexToI(j, k)] = newC;
  }
  
  public void updateSmallHex(int[] c, int j) {
    int[] newC = new int[] {c[0], c[1], c[2]};
    for (int k = 0; k < 7; k++) {
      updateOneByHex(newC, j, k);
    }
  }
  
  public void updateByRingIndex(int[] c, int ring, int index) {
    int[] newC = new int[] {c[0], c[1], c[2]};
    colors[ringToI(ring, index)] = newC;
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

  public int rowColToI(int row, int col) {
    row = row % nStrips;
    col = col % rowLen(row);
    return rowStarts[row] + col;
  }    

  // add pixel offset to strip update
  public void updateStrip(int[] c, int row, boolean flip) {
      updateStrip(c, row, flip, 0, rowLen(row) - 1);
  }

  public void updateStrip(int[] c, int row, boolean flip, int beg, int end) {
    if (!flip) {
      row = row % nStrips;
      int rowStart = rowStarts[row];
      int rowEnd = rowStart + rowLen(row);
      for (int i = rowStart + beg; i <= rowStart + end; i++) {
        colors[i] = c;
      }

      // updateStripNoFlip(c, row, beg, end);
    } else {
      int centerRow = nStrips / 2;
      int centerCol = rowLen(centerRow) / 2;
      if (row <= nStrips / 2) {
        for (int i = 0; i <= nStrips / 2 - (rowLen(row) - end) + 1; i++) {
          updateRowCol(c, centerRow - i, row);
        }
        for (int i = nStrips / 2 + 1; i <= nStrips / 2 + row - beg; i++) {
          updateRowCol(c, i, rowLen(row) - i - 1);
        }
      } else {
        for (int i = row - nStrips / 2 + (rowLen(row) - end) - 1; i <= nStrips / 2; i++) {
          updateRowCol(c, i, row);
        }
        for (int i = nStrips / 2 + 1; i < nStrips - beg; i++) {
          updateRowCol(c, i, rowLen(i) - (nStrips - row));
        }
      }
    }
  }
  
  public void updateRing(int[] c, int radius) {
    radius = radius % 5;
    
    for (int i = 0; i < max(1, radius * 6); i++) {
      updateOne(new int[] {c[0], c[1], c[2]}, ringToI(radius, i));
    }
  }
  
  public void updateRing(int wheelPos, int pixelOffset, int radius) {
    radius = radius % 5;
    for (int i = 0; i < max(1, radius * 6); i++) {
      updateOne(wheel.getColor(wheelPos + i * pixelOffset, 255), ringToI(radius, i));
    }
  }
  
  public void updateRingByAverage(int[] c, int radius, float factor) {
    radius = radius % 5;
    
    for (int i = 0; i < max(1, radius * 6); i++) {
      int pixelIndex = ringToI(radius, i);
      updateOne( averageColor( new int[] {c[0], c[1], c[2]} , colors[pixelIndex], factor) , pixelIndex);
    }
  }
  
  public int[] averageColor(int[] c0, int[] c1, float factor) {
    int[] averageC = new int[3];
    for (int i = 0; i < 3; i++) {
      averageC[i] = (int) ((c0[i] * factor + c1[i] * (1.0 - factor)) / 2);
    }
    return averageC;
  }
  
  public void fadeRing(float fadeFactor, int radius) {
    radius = radius % 5;
    
    for (int i = 0; i < max(1, radius * 6); i++) {
      int pixI = ringToI(radius, i);
      fadeOne(fadeFactor, pixI);
    }
  }
  
  public int[] getRing(int radius) {
    radius = radius % 5;
    int[] c = new int[] {0, 0, 0};
    int n = max(1, radius * 6);
    for (int i = 0; i < n; i++) {
      int[] ci = colors[ringToI(radius, i)];
      c[0] += ci[0];
      c[1] += ci[1];
      c[2] += ci[2];
    }
    c[0] /= n;
    c[1] /= n;
    c[2] /= n;
    
    return c;
  }
  
  public int[] getOne(int index) {
    return colors[index];
  }

  public int[] getOneRowCol(int row, int col) {
    int pixIdx = 0;
    row = (row + nStrips) % nStrips;
    col = (col + rowLen(row)) % rowLen(row);
    for (int i = 0; i < row; i++) {
      pixIdx += rowLen(i);
    }
    pixIdx += col;
    return colors[pixIdx];
  }
  
  public int[] getOneByHex(int j, int k) {
    return colors[hexToI(j, k)];
  }
  
  public int[] getOneByRingIndex(int ring, int index) {
    return colors[ringToI(ring, index)];
  }

  public int[] getOneByTriangleIndex(int tri, int index) {
    return colors[triangleToI(tri, index)];
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
    r = (r + nStrips) % nStrips;
    return rowEnds[r] - rowStarts[r] + 1;
  }

  private int triangleToI(int tri, int index) {
    tri = tri % 6;
    index = index % 15;

    int result = 0;
    int center = nStrips / 2;
    int indexFactor = (tri == 0 || tri == 4 || tri == 5) ? -1 : 1;
    int side = index / center;
    int initOrient = (VERTICAL + 2 * tri); 
    int orient = (initOrient + side) % 3;
    int[] factors = {};
    int[] innerFactors = {};

    index = index - side * center;

    switch(tri) {
    case (0):
      factors = new int[] {-index, 0, index, rowLen(center) - index - 1};
      innerFactors = new int[] {1, 2 - index, 1, 3};
      break;
    case (1):
      factors = new int[] {index, nStrips-1, index, rowLen(center) - index - 1};
      innerFactors = new int[] {1, rowLen(center+1) - 3 + index, nStrips - 2, 3};
      break;
    case (2):
      factors = new int[] {index, nStrips-1, rowLen(nStrips-1) - index - 1, rowLen(center) - index - 1};
      innerFactors = new int[] {1, rowLen(center+1) - 3 + index, nStrips - 2, 2};
      break;
    case (3):
      factors = new int[] {index, nStrips-1, rowLen(nStrips-1) - index - 1, index};
      innerFactors = new int[] {-1, rowLen(center-1) - 3 + index, nStrips - 2, 2};
      break;
    case (4):
      factors = new int[] {-index, 0, rowLen(0) - index - 1, index};
      innerFactors = new int[] {-1, 2 - index, 1, 2};
      break;
    case (5):
      factors = new int[] {-index, 0, index, index};
      innerFactors = new int[] {-1, 2 - index, 1, 3};
      break;
    }

    if (side == 0) {
      result = lineToI(center, center + factors[0], orient);
    } else if (side == 1) {
      result = lineToI(factors[1], factors[2], orient); 
    } else if (side == 2) {
      result = lineToI(center, factors[3], orient);
    } else if (side == 3) {
      if (index < 2) {
        result = lineToI(center + innerFactors[0], innerFactors[1], orient);
      } else {
        result = lineToI(innerFactors[2], innerFactors[3], (orient + 1) % 3);
      }
    }

    return result;
  }

  private int lineToI(int lin, int index, int orientation) {
    int result = 0;
    int centerLin = nStrips / 2;
    lin = lin % nStrips;
    index = index % rowLen(lin);
    if (orientation == DOWNDIAG) {
      result = rowColToI(lin, index);
    } else if (orientation == UPDIAG) {
      if (lin <= centerLin) {
        if (index <= lin) {
          result = rowColToI(centerLin + lin - index, index);
        } else {
          result = rowColToI(centerLin + lin - index, lin);
        }
      } else {
        if (index <= centerLin) {
          result = rowColToI(nStrips - index - 1, index + lin - centerLin);
        } else {
          result = rowColToI(nStrips - index - 1, lin);
        }
      }
    } else if (orientation == VERTICAL) {
      if (lin <= centerLin) {
        if (index < lin) {
          result = rowColToI(centerLin - lin + index, index);
        } else {
          result = rowColToI(centerLin  - lin + index, lin);
        }
      } else {
        if (index <= centerLin) {
          result = rowColToI(index, index + lin - centerLin);
        } else {
          result = rowColToI(index, lin);
        }
      }
    }
    return result;
  }
}
