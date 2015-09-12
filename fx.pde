int fxChance = 32;
boolean fxOn = false;
boolean fxRand = true;
int fxTime = 1;
float dryWet = .1;
float coeff = 1;

int numFX = 6;
int fxMode = 5;

int[] fx(int r, int g, int b, int t) {
  float newR = r;
  float newG = g;
  float newB = b;
  
  switch(fxMode) {
    case 0: // ANNE
      newR = sin(coeff * t) * r;
      newG = cos(coeff * t) * g;
      newB = tan(coeff * t) * b;
      break;
    case 1: // BOBO
      newR = cos(coeff * t) * r;
      newG = tan(coeff * t) * g;
      newB = sin(coeff * t) * b;
      break;
    case 2: // CASS
      newR = tan(coeff * t) * r;
      newG = sin(coeff * t) * g;
      newB = cos(coeff * t) * b;
      break;
    case 3: // DIRK
      newR = sin(r * t) * r;
      newG = sin(r * t) * g;
      newB = sin(b * t) * g;
      break;
    case 4: // EARL
      newR = sin(r * t) * r;
      newG = sin(g * t) * g;
      newB = sin(b * t) * b;
      break;
    case 5: // FRAN
      newR = abs(sin(r) * r);
      newG = abs(sin(g) * g);
      newB = abs(sin(b) * b);
      break;
    default:
      break;
    // FRAN, GEO, HANA, IAGO, JOAN, KARL, LILA
  }
  
  int[] c = new int[] {(int) newR, (int) newG, (int) newB}; 
  return field.wheel.applyBrightness(c, globalBrightness);
}

void randomizeFX() {
  if (fxRand && rand.nextInt(fxChance) == 0) {
    fxMode = rand.nextInt(numFX);
  }
}
