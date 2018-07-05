
class Matter {
  ArrayList particles;
  
  Matter() {
    particles = new ArrayList();
  }
  
  void addParticle(Particle p) {
    particles.add(p);
  }
  
  void render() {
     for (int i = 0; i < particles.size(); i++) {
      Particle p = (Particle) particles.get(i);  
      p.render();
    }   
  }
}

class Particle {
  Vector3D loc;
  float radius;
  color col;

  // constructor
  Particle(float r) {
    loc = new Vector3D();
    col = color(180,180,180);
    radius = r;
  }
  
  // constructor
  Particle(Vector3D l, float r, color c) {
    loc = l;
    col = c;
    radius = r;
  }
  
  void render() {
     // noStroke();
     sphereDetail(24);
     pushMatrix();
    fill(col);
    translate(loc.x,loc.y,loc.z);
    sphere(radius);
    popMatrix();
  } 
}