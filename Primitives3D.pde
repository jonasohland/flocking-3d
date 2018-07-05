// [toxi040413] cylinder/cone 3d primitives
// use cylinderDetail(n) to set the resolution of the generated meshes
// both cone() and cylinder() methods have options to disable top/bottom caps
// cone() can only have a bottom cap

int cylinder_detail=0;
float[] cylinderX,cylinderZ;

float sinLUT[];
float cosLUT[];
float SINCOS_PRECISION = 0.5f;
int SINCOS_LENGTH = int(360.0 / SINCOS_PRECISION);


void cylinderDetail(int res) {
  
  sinLUT = new float[SINCOS_LENGTH];
  cosLUT = new float[SINCOS_LENGTH];

  for (int i = 0; i < SINCOS_LENGTH; i++) {
    sinLUT[i] = (float) Math.sin(i * DEG_TO_RAD * SINCOS_PRECISION);
    cosLUT[i] = (float) Math.cos(i * DEG_TO_RAD * SINCOS_PRECISION);
  }

  if (res<3) res=3; // force a minimum res
  if (res != cylinder_detail) {
    float delta = (float)SINCOS_LENGTH/res;
    cylinderX = new float[res];
    cylinderZ = new float[res];
    // calc unit circle in current resolution in XZ plane
    for (int i = 0; i < res; i++) {
      cylinderX[i] = cosLUT[(int) (i*delta) % SINCOS_LENGTH];
      cylinderZ[i] = sinLUT[(int) (i*delta) % SINCOS_LENGTH];
    }
    cylinder_detail = res;
  }
}

void cone(float r, float h, boolean bottomCap) {
  if (cylinder_detail == 0) {
    cylinderDetail(30);
  }
  h*=0.5; // center along Y axis
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < cylinder_detail; i++) {
    vertex(0,-h,0);
    vertex(cylinderX[i]*r, h, cylinderZ[i]*r);
  }
  vertex(0,-h,0);
  vertex(cylinderX[0]*r, h, cylinderZ[0]*r);
  endShape();
  if (bottomCap) {
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < cylinder_detail; i++) {
      vertex(0,h,0);
      vertex(cylinderX[i]*r, h, cylinderZ[i]*r);
    }
    vertex(0,h,0);
    vertex(cylinderX[0]*r, h, cylinderZ[0]*r);
    endShape();
  }
}

void cylinder(float r1, float r2, float h, boolean topCap, boolean bottomCap) {
  if (cylinder_detail == 0) {
    cylinderDetail(30);
  }
  h*=0.5;
  if (topCap) {
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < cylinder_detail; i++) {
      vertex(0,-h,0);
      vertex(cylinderX[i]*r1, -h, cylinderZ[i]*r1);
    }
    vertex(0,-h,0);
    vertex(cylinderX[0]*r1, -h, cylinderZ[0]*r1);
    endShape();
  }
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i < cylinder_detail; i++) {
    vertex(cylinderX[i]*r1, -h, cylinderZ[i]*r1);
    vertex(cylinderX[i]*r2, h, cylinderZ[i]*r2);
  }
  vertex(cylinderX[0]*r1, -h, cylinderZ[0]*r1);
  vertex(cylinderX[0]*r2, h, cylinderZ[0]*r2);
  endShape();
  if (bottomCap) {
    beginShape(TRIANGLE_STRIP);
    for (int i = 0; i < cylinder_detail; i++) {
      vertex(0,h,0);
      vertex(cylinderX[i]*r2, h, cylinderZ[i]*r2);
    }
    vertex(0,h,0);
    vertex(cylinderX[0]*r2, h, cylinderZ[0]*r2);
    endShape();
  }
}