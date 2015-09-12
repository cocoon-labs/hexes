class Mode {
  
  Panel[] panels;
  ColorWheel wheel;
  float fadeFactor;
  int chance;
  int nPanels, nPixels;
  int nRings = 5;
  int triangleN = 15;
  int nTriangles = 6;
  int prevTime;
  boolean justEntered = false;
  boolean delayable = false;
  int minDelay = 0;
  int shiftStyle = 0;
  int nShiftStyles = 3;
  boolean shiftDir = true;
  int highChance = 8;
  
  Mode(Panel[] panels, ColorWheel wheel, float fadeFactor, int chance) {
    this.panels = panels;
    this.wheel = wheel;
    this.fadeFactor = fadeFactor;
    this.chance = chance;
    this.nPanels = panels.length;
    this.prevTime = millis();
    nPixels = nPanels * 61;
  }
  
  public void advance() {
    int time = millis();
    if (!delayable) {
      update();
    } else if (delay() == 0 || (time - prevTime) > delay()) {
      update();
      prevTime = time;
    }
  }

  public void update() {
    if (bpm.isBeat() || (!soundReactive && rand.nextInt(100) == 0)) {
      onBeat();
      randomize();
    }
  }
  
  public void onBeat() {
    // behavior that should only happen on the beat
  }
  
  public void randomize() {
    if (rand.nextInt(chance) == 0) {
      wheel.newScheme();
    }
    randomizeFX();
  }
  
  public void fadeAll(float factor) {
    for (int i = 0; i < nPanels; i++) {
      panels[i].fadeAll(factor);
    }    
  }
  
  public void fadeOne(float factor, int index) {
    panels[index / 61].fadeOne(factor, index % 61);
  }
  
  public void updateByIndex(int[] c, int index) {
    panels[index / 61].updateOne(c, index % 61);
  }
  
  public void updateBySpiralIndex(int[] c, int spiralIndex, int ringOffset) {
    int index = spiralToI(spiralIndex, ringOffset);
    panels[index / 61].updateOne(c, index % 61);
  }
  
  public void updateRing(int[] c, int r) {
    for (int i = 0; i < nPanels; i++) {
      panels[i].updateRing(c, r);
    }
  }
  
  public void updateRing(int wheelPos, int pixelOffset, int r) {
    for (int i = 0; i < nPanels; i++) {
      panels[i].updateRing(wheelPos, pixelOffset, r);
    }
  }
  
  public void updateByRingIndex(int[] c, int panel, int radius, int index) {
    panels[panel].updateByRingIndex(c, radius, index);
  }
  
  public void refreshColors() {
    for (int i = 0; i < nPanels; i++) {
      panels[i].refreshColors();
    }
  }
  
  public void fadeAllInThenDisappear(float factor) {
    for (int i = 0; i < nPanels; i++) {
      panels[i].fadeAllIn(factor, 255);
    }
  }
  
  public void fadeAllIn(float factor) {
    for (int i = 0; i < nPanels; i++) {
      panels[i].fadeAllIn(factor);
    }
  }
  
  public void turnOnAll(int wheelOffset, int brightness) {
    for (int i = 0; i < nPixels; i++) {
      panels[i / 61].targetColors[i % 61] = wheel.getColor(wheelOffset, 255);
      panels[i / 61].brightVals[i % 61] = brightness;
    } 
  }
  
  public void fadeAllOut(float factor) {
    for (int i = 0; i < nPanels; i++) {
      panels[i].fadeAllOut(factor);
    }
  }
  
  public void rotateSmallHexes(boolean clockwise) {
    for (int i = 0; i < nPanels; i++) {
      for (int j = 0; j < 7; j++) {
        rotateSmallHex(i, j, clockwise);
      }
    }
  }
  
  public void rotateSmallHexesOne(boolean clockwise, int p) {
    for (int j = 0; j < 7; j++) {
        rotateSmallHex(p, j, clockwise);
    }
  }
  
  public void fadeRing(float fadeFactor, int radius) {
    for (int i = 0; i < nPanels; i++) {
      panels[i].fadeRing(fadeFactor, radius);
    }
  }
  
  public void rotateSmallHex(int i, int j, boolean clockwise) {
    int[] c;
    if (!clockwise) {
      c = panels[i].getOneByHex(j, 1);
      for (int k = 1; k < 6; k++) {
        panels[i].updateOneByHex(panels[i].getOneByHex(j, k+1), j, k);
      }
      panels[i].updateOneByHex(c, j, 6);
    } else {
      c = panels[i].getOneByHex(j, 6);
      for (int k = 6; k > 1; k--) {
        panels[i].updateOneByHex(panels[i].getOneByHex(j, k - 1), j, k);
      }
      panels[i].updateOneByHex(c, j, 1);
    }
  }
  
  public void shiftOutAll(int[] c, boolean out) {
    for (int i = 0; i < nPanels; i++) {
      shiftOutOne(c, i, out);
    }
  }
  
  public void shiftOutOne(int[] c, int p, boolean out) {
    if (out) {
      for (int r = 4; r > 0; r--) {
        panels[p].updateRing( panels[p].getRing(r - 1), r );
      }
      panels[p].updateRing(c, 0);
    } else {
      for (int r = 0; r < 4; r++) {
        panels[p].updateRing( panels[p].getRing(r + 1), r);
      }
      panels[p].updateRing(c, 4);
    }
  }
  
  public void spiralOutAll(int[] c, boolean out) {
    for (int i = 0; i < nPanels; i++) {
      spiralOutOne(c, i, out);
    }
  }
  
  public void spiralOutOne(int[] c, int p, boolean out) {
    if (out) {
      for (int r = 4; r > 0; r--) {
        int n = max(1, r * 6);
        for (int i = 0; i < n - 1; i++) {
          panels[p].updateByRingIndex( panels[p].getOneByRingIndex(r, i+1), r, i);
        }
        panels[p].updateByRingIndex( panels[p].getOneByRingIndex(r-1, 0), r, n-1);
      }
      panels[p].updateByRingIndex( c, 0, 0);
    } else {
      for (int r = 0; r <= 4; r++) {
        int n = max(1, r * 6);
        int nNext = max(1, (r+1) * 6);
        for (int i = n - 1; i > 0; i--) {
          panels[p].updateByRingIndex( panels[p].getOneByRingIndex(r, i-1), r, i);
        }
        if (r == 4) panels[p].updateByRingIndex( c, 4, 0);
        else panels[p].updateByRingIndex( panels[p].getOneByRingIndex(r+1, nNext-1), r, 0);
      }
    }
  }
  
  void shift(boolean direction) {
    int[] c = wheel.getColor(0, globalBrightness);
    switch(shiftStyle) {
      case 0 :
        //shiftOutAll(c, direction);
        shiftOutAll(c, true);
        break;
      case 1 :
        spiralOutAll(c, direction);
        break;
      case 2 :
        rotateSmallHexes(direction);
        break;
    }
  }
  
  void shiftRandomPanel(boolean direction) {
    int[] c = wheel.getColor(0, globalBrightness);
    int p = rand.nextInt(nPanels);
    switch(shiftStyle) {
      case 0 :
        //shiftOutOne(c, p, direction);
        shiftOutOne(c, p, true);
        break;
      case 1 :
        spiralOutOne(c, p, direction);
        break;
      case 2 :
        rotateSmallHexesOne(direction, p);
        break;
    }
  }

  public void updateTriangleByIndex(int[] c, int panel, int tri, int index) {
    panels[panel].updateOne(c, panels[panel].triangleToI(tri, index));
  }

  public void updateInnerTriangles(int[] c) {
    for (int i = 0; i < nPanels; i++) {
      updateInnerTrianglesByPanel(c, i);
    }
  }
  
  public void updateInnerTrianglesByPanel(int[] c, int pIdx) {
    for (int i = 0; i < 6; i++) {
      updateOneInnerTriangle(c, pIdx, i);
    }
  }

  public void updateOneInnerTriangle(int[] c, int pIdx, int tri) {
    for (int j = 12; j < 15; j++) {
      updateTriangleByIndex(c, pIdx, tri, j);
    }
  }
  
  public void advanceType() {
  }
  
  int randomNeighbor(int index) {
    int panel = index / 61;
    int indexOnPanel = index % 61;
    int[] xy = iToXY(index);
    int x = xy[0];
    int y = xy[1];
    int neighborIndex = 0;
    int[] neighbors = new int[6];
    int pixelsInRow = pixelsInRow(y);
    if (x > 0) {
      neighbors[neighborIndex] = xyToI(x - 1, y);
      neighborIndex++;
    }
    if (x < pixelsInRow - 1) {
      neighbors[neighborIndex] = xyToI(x + 1, y);
      neighborIndex++;
    }
    if (y > 4) {
      neighbors[neighborIndex] = xyToI(x, y - 1);
      neighborIndex++;
      neighbors[neighborIndex] = xyToI(x + 1, y - 1);
      neighborIndex++;
    } else if (y > 0) {
      if (x > 0) {
        neighbors[neighborIndex] = xyToI(x - 1, y - 1);
        neighborIndex++;
      }
      if (x < pixelsInRow - 1) {
        neighbors[neighborIndex] = xyToI(x, y - 1);
        neighborIndex++;
      }
    }
    if (y < 4) {
      neighbors[neighborIndex] = xyToI(x, y + 1);
      neighborIndex++;
      neighbors[neighborIndex] = xyToI(x + 1, y + 1);
      neighborIndex++;
    } else if (y < 8) {
      if (x > 0) {
        neighbors[neighborIndex] = xyToI(x - 1, y + 1);
        neighborIndex++;
      }
      if (x < pixelsInRow - 1) {
        neighbors[neighborIndex] = xyToI(x, y + 1);
        neighborIndex++;
      }
    }
    return panel * 61 + neighbors[rand.nextInt(neighborIndex)];
  }
  
  int pixelsInRow(int row) {
    return 1 + rowEnds[row] - rowStarts[row];
  }

  int delay() {
    return delay + minDelay;
  }
}
