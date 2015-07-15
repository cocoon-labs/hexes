float a = 1;
int fxChance = 500;
boolean fxOn = false;
boolean fxTimed = true;
float fxGain = .1;

int numFX = 5;
int fxNum = 4;

int[] fx(int r, int g, int b, int t) {
  fxGain = map(mouseY, 0, height, 0, 1);
  float newR = r;
  float newG = g;
  float newB = b;
  
  switch(fxNum) {
    case 0:
      newR = sin(a * t) * r;
      newG = cos(a * t) * g;
      newB = tan(a * t) * b;
      break;
    case 1:
      newR = cos(a * t) * r;
      newG = tan(a * t) * g;
      newB = sin(a * t) * b;
      break;
    case 2:
      newR = tan(a * t) * r;
      newG = sin(a * t) * g;
      newB = cos(a * t) * b;
      break;
    case 3:
      newR = sin(r * t) * r;
      newG = sin(r * t) * g;
      newB = sin(b * t) * g;
      break;
    case 4:
      newR = sin(r * t) * r;
      newG = sin(g * t) * g;
      newB = sin(b * t) * b;
      break;
  }
  
  return new int[] {(int) newR, (int) newG, (int) newB};
}

void randomizeFX() {
  if (rand.nextInt(fxChance) == 0) {
    a = random(1);
  }
  if (rand.nextInt(fxChance) == 0) {
    fxOn = !fxOn;
  }
  if (rand.nextInt(fxChance) == 0) {
    fxNum = rand.nextInt(numFX);
  }
  if (rand.nextInt(4) == 0) {
    fxTimed = !fxTimed;
  }
}
