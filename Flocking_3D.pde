/**
 * Boid flocking implementation featuring: <br>
 * - obstacle avoidance <br>
 * - conic perception field <br>
 * - flight perturbation <br>
 * - field of perception visualization (mousecklick or 'n' for neighborhood) <br>
 * - interaction network visualization ('w' for web) <br>
 * - press 'space' to pause the simulation <br>

 * built on top of: <br>
 *
 * Flocking
 * by Daniel Shiffman. 
*/


float separation = 0.6f;
float alignment = 0.5f;
float cohesion = 0.7f;

float randomisation = 0.01f;

int graincount = 100;


import processing.opengl.*;
import processing.dxf.*;


import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress remote;


boolean record;

boolean pause;
boolean webview;
boolean neighborhoodview;

int mX,mY,camX,camY;

Vector3D ghetto;

Flock flock;
Matter matter;
SecondLayer layer;

void setup() {
  
   oscP5 = new OscP5(this,12000);
   remote = new NetAddress("127.0.0.1",10002);
  
  
  
  size(800,600,P3D); 
  //size(320, 240, P3D);
  colorMode(RGB,255,255,255,100);

  cylinderDetail(300);
  noStroke();
  
  // allowed depth interval for the swarm
  ghetto = new Vector3D(500,500,500); 
  
  flock = new Flock();
  // Add an initial set of boids into the system
  for (int i = 0; i < graincount; i++) {
    flock.addBoid(new Boid(new Vector3D(random(width/2),random(height/2)),2.0f,0.05f, i));
  }
  
  matter = new Matter();
  // Add some particles to the system
  matter.addParticle(new Particle(new Vector3D(250,250,250), 100f, color(180,180,180)));
  /*matter.addParticle(new Particle(new Vector3D(300,300,330), 92f, color(180,180,180)));
  matter.addParticle(new Particle(new Vector3D(80,120,220), 34f, color(180,180,180)));
  matter.addParticle(new Particle(new Vector3D(220,60,320), 10f, color(180,180,180))); 
  matter.addParticle(new Particle(new Vector3D(60,400,20), 70f, color(180,180,180))); 
  matter.addParticle(new Particle(new Vector3D(140,200,90), 40f, color(180,180,180))); 
  matter.addParticle(new Particle(new Vector3D(140,200,300), 30f, color(180,180,180))); */
  
  layer = new SecondLayer();
  
  // smooth();
}

void keyPressed() {
  if (key == 32) pause = !pause;
  if (key == 110) flock.toggleNbhdRep(); // 110 is 'n' for neighborhood
  if (key == 119) flock.toggleWebRepp(); // 119 is 'w' for web-view
  if (key == 'r') record = true;

}

void draw() {
  
   if (record) {
    beginRaw(DXF, "output.dxf");
  }

  //saveFrame(); 

  if (pause == true) return;
  background(255);
  //camera(mouseX, ghetto.y/2.0, mouseY + 00, ghetto.x/2.0, ghetto.y/2.0,0,   0,1,0); 
  camera(-70,ghetto.y/2.0, 550, ghetto.x/2.0, ghetto.y/2.0, 0,  0,1,0);
  rotateY(PI/3);


  matter.render();
  flock.run();

  if (record) {
    endRaw();
    record = false;
  }

}

class Flock {
  ArrayList boids; // An arraylist for all the boids

  Flock() {
    boids = new ArrayList(); // Initialize the arraylist
  }

  void toggleNbhdRep() {
     for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);  
      b.neighborhoodrepresentation = !b.neighborhoodrepresentation;
     }
  }
  
  void toggleWebRepp() {
     for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);  
      b.connectivity = !b.connectivity;
     }
  }
  
  void run() {
    OscMessage boidcoordinatesx = new OscMessage("");
    OscMessage boidcoordinatesy = new OscMessage("");
    OscMessage boidcoordinatesz = new OscMessage("");
    OscMessage boidgroup = new OscMessage("");
    OscBundle boidBundle = new OscBundle();
    for (int i = 0; i < boids.size(); i++) {
      Boid b = (Boid) boids.get(i);  
      b.run(boids);  // Passing the entire list of boids to each boid individually
       boidcoordinatesx.setAddrPattern("/boid" + i + "/x");
       boidcoordinatesy.setAddrPattern("/boid" + i + "/y");
       boidcoordinatesz.setAddrPattern("/boid" + i + "/z");
       boidgroup.setAddrPattern("/boid" + i + "/grp");
         boidcoordinatesx.add(b.loc.z);
         boidcoordinatesy.add(b.loc.y);
         boidcoordinatesz.add(b.loc.x);
         boidgroup.add(b.group);
      boidBundle.add(boidcoordinatesx); 
      boidBundle.add(boidcoordinatesy);
      boidBundle.add(boidcoordinatesz);
      boidBundle.add(boidgroup);
        boidcoordinatesx.clear();
        boidcoordinatesy.clear();
        boidcoordinatesz.clear();
        boidgroup.clear();
        
    }
    oscP5.send(boidBundle, remote);
    boidBundle.clear();
    

  }

  void addBoid(Boid b) {
    boids.add(b);
  }

}


class Boid {

  Vector3D loc;
  Vector3D vel;
  Vector3D acc;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  int group;
  
  
  float neighbordist;
  float desiredseparation;
  float perceptionangle;
  ArrayList neighbors;
  
  // for visualization
  boolean neighborhoodrepresentation;
  boolean connectivity;
  
  // construction particle
  Particle construction;
  
  Boid(Vector3D l, float ms, float mf, int _grp) {
    acc = new Vector3D(0,0);
    vel = new Vector3D(random(-1,1),random(-1,1));
    loc = l.copy();
    r = 2.0f;
    maxspeed = ms;
    maxforce = mf;
    group = _grp;
    neighbors = new ArrayList();
    neighbordist = 60f;
    perceptionangle = 2f;
    desiredseparation = 15f;
    neighborhoodrepresentation = false;
    connectivity = false;
    construction = new Particle(20f);
    construction.col = color(180,180,180);
  }
  
  void run(ArrayList boids) {
    avoidParticles(matter.particles);
    updateNeighbors(boids);
    flock(neighbors);
    avoidParticles(matter.particles);
    updateFlocking();
    borders();
    render();
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList boids) {
    Vector3D sep = separate(boids);   // Separation
    Vector3D ali = align(boids);      // Alignment
    Vector3D coh = cohesion(boids);   // Cohesion
    // Arbitrarily weight these forces
    sep.mult(separation);
    ali.mult(alignment);
    coh.mult(cohesion);
    // Add the force vectors to acceleration
    acc.add(sep);
    acc.add(ali);
    acc.add(coh);
    
    Vector3D rand = new Vector3D(random(-1,1),random(-1,1),random(-1,1));
    rand.mult(randomisation);
    acc.add(rand);
    
  // if (random(1.0f) > 0.99f) placeParticle();

    
  }
  
  void placeParticle() {
    // where in relation of the boid should the particle be placed?
    Vector3D offset = new Vector3D(loc.x,loc.y,loc.z);
    Vector3D translation = new Vector3D(vel.x,vel.y,vel.z);
    translation.normalize();
    translation.mult(construction.radius);
    offset.sub(translation);
    
    // avoid bulldozering an agent
    for (int i = 0 ; i < flock.boids.size(); i++) { 
      Boid b = (Boid) flock.boids.get(i);
      if (offset.distance(b.loc, offset) <= construction.radius) return;
    }
    
    // no conflicts, we can build...
    matter.addParticle(new Particle(offset, construction.radius, construction.col));
  }
  
  // Method to update location
  void updateFlocking() {
    // Update velocity
    vel.add(acc);
    // Limit speed
    vel.limit(maxspeed);
    loc.add(vel);
    
    // avoid flying into a particle
    for (int i = 0 ; i < matter.particles.size(); i++) { 
      Particle p = (Particle) matter.particles.get(i);
      if (loc.distance(loc, p.loc) <= p.radius) loc.sub(vel);
    }
    // Reset accelertion to 0 each cycle
    acc.setXYZ(0,0,0);
  }

  void updateNeighbors(ArrayList boids) {
    // forget your former neighbors
    neighbors.clear();
    for (int i = 0 ; i < boids.size(); i++) {   
      Boid other = (Boid) boids.get(i);
      Vector3D d = new Vector3D();
      d = d.sub(loc, other.loc);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d.length() > 0) && (d.length() < neighbordist))
        if (vel.angleBetweenTwo2D(d) <= perceptionangle / 2.0)
        {
          neighbors.add(other);   
          
          if (connectivity == true) {
            noFill();
            stroke(90);
            line(loc.x,loc.y,loc.z,other.loc.x,other.loc.y,other.loc.z);    
          }
          int grp = other.group;
            if(grp != this.group){
              this.group = grp;
          }
        }
        
        
        
        
       
    }
  }

  void avoidParticles(ArrayList particles) {
    for (int i = 0 ; i < particles.size(); i++) {   
      Particle other = (Particle) particles.get(i);
     
      Vector3D d = new Vector3D();
      d = d.sub(loc, other.loc);
      float effectiveDist = d.length() - other.radius; // if negative, we are within (!) the circle
       
      if( effectiveDist < neighbordist) {
        
        
        // we know that the particle is within the agent's radius
        // but is it also within the angle of its field of perception?
        // (1) the abs(angle) between AGENT | PARTICLE => 0 and <= alpha / 2.0
        // (2) test intersection right-hand border
        // (3) test intersection left-hand border
        
        Vector3D border = vel.copy();
        boolean intersection = false; 
        
        if ( (0 >= abs(vel.angleBetweenTwo2D(other.loc))) && 
             (abs(vel.angleBetweenTwo2D(other.loc)) <= perceptionangle / 2.0) ) intersection = true;
        
        border.rotate2D(perceptionangle /2.0);
        if (border.sphereIntersection(loc, other.loc, other.radius)) intersection = true;
        
        border.rotate2D(- perceptionangle);        
        if (border.sphereIntersection(loc, other.loc, other.radius))  intersection = true;
        
        if (!intersection) continue;

        // float weight = - vel.angleBetweenTwo2D(d) ;
        // float weight = (10 / (1 + neighbordist - effectiveDist));
        float weight = 2f / (effectiveDist);
        acc.x = vel.x * weight;
        acc.y = vel.y * weight;
        acc.rotate2D(vel.angleBetweenTwo2D(d));
      }
    }
  }

  void seek(Vector3D target) {
    acc.add(steer(target,false));
  }
 
  void arrive(Vector3D target) {
    acc.add(steer(target,true));
  }

  // A method that calculates a steering vector towards a target
  // Takes a second argument, if true, it slows down as it approaches the target
  Vector3D steer(Vector3D target, boolean slowdown) {
    Vector3D steer;  // The steering vector
    Vector3D desired = target.sub(target,loc);  // A vector pointing from the location to the target
    float d = desired.magnitude(); // Distance from the target is the magnitude of the vector
    // If the distance is greater than 0, calc steering (otherwise return zero vector)
    if (d > 0) {
      // Normalize desired
      desired.normalize();
      // Two options for desired vector magnitude (1 -- based on distance, 2 -- maxspeed)
      if ((slowdown) && (d < 100.0f)) desired.mult(maxspeed*(d/100.0f)); // This damping is somewhat arbitrary
      else desired.mult(maxspeed);
      // Steering = Desired minus Velocity
      steer = target.sub(desired,vel);
      steer.limit(maxforce);  // Limit to maximum steering force
    } else {
      steer = new Vector3D(0,0);
    }
    return steer;
  }
  
  void render() {
    if (neighborhoodrepresentation == true)
    {
      // visualize the field of perception
      noFill();
      stroke(150);
    //  arc(loc.x, loc.y, 2 * neighbordist, 2 * neighbordist, vel.heading2D() - (perceptionangle / 2.0), vel.heading2D() + (perceptionangle / 2.0));
    //  line(loc.x,loc.y,loc.x + neighbordist * cos(vel.heading2D() - (perceptionangle / 2.0)),loc.y + neighbordist * sin(vel.heading2D() - (perceptionangle / 2.0)));
    //  line(loc.x,loc.y,loc.x + neighbordist * cos(vel.heading2D() + (perceptionangle / 2.0)),loc.y + neighbordist * sin(vel.heading2D() + (perceptionangle / 2.0)));
    }
    
    //  fillConePixelwise();
    // layer.setStamp(5,(int)(loc.x) + (int)(loc.y) * width, color(0,100,200));
    
    // Draw a triangle rotated in the direction of velocity
    fill(255);
    stroke(0);
    
    pushMatrix();
    translate(loc.x,loc.y,loc.z);
    
    //rotateX(vel.angleBetween(new Vector3D(1,0,0))); 
    //rotateY(vel.angleBetween(new Vector3D(0,1,0)));
    //rotateZ(vel.angleBetween(new Vector3D(0,0,1)));

    //cone(r, 2*r, true);
    sphereDetail(4);
    sphere(2*r);
    popMatrix();
  }
  
  // Wraparound
  void borders() {
    if (loc.x < -r) loc.x = ghetto.x+r;
    if (loc.y < -r) loc.y = ghetto.y+r;
    if (loc.z < -r) loc.z = ghetto.z+r;
    if (loc.x > ghetto.x+r) loc.x = -r;
    if (loc.y > ghetto.y+r) loc.y = -r;
    if (loc.z > ghetto.z+r) loc.z = -r;
 
   pushMatrix();
    noFill();
    translate(ghetto.x/2.0,ghetto.y/2.0,ghetto.z/2.0);
    box(ghetto.x,ghetto.y,ghetto.z);
   popMatrix();
  }

  // Separation
  // Method checks for nearby boids and steers away
  Vector3D separate (ArrayList neighbors) {
    Vector3D sum = new Vector3D(0,0,0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (int i = 0 ; i < neighbors.size(); i++) {
      Boid other = (Boid) neighbors.get(i);
      float d = loc.distance(loc,other.loc);
      // too close? then separate!
      if (d < desiredseparation) {
        // Calculate vector pointing away from neighbor
        Vector3D diff = loc.sub(loc,other.loc);
        diff.normalize();
        diff.div(d);        // Weight by distance
        sum.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      sum.div((float)count);
    }
    return sum;
  }
  
  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  Vector3D align (ArrayList neighbors) {
    Vector3D sum = new Vector3D(0,0,0);
    // no neighbors, let's stop this.
    if (neighbors.size() == 0) return sum;
    for (int i = 0 ; i < neighbors.size(); i++) {
      Boid other = (Boid) neighbors.get(i);
      sum.add(other.vel);
      }
    sum.div((float)neighbors.size());
    sum.limit(maxforce);
    return sum;
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  Vector3D cohesion (ArrayList neighbors) {
    Vector3D sum = new Vector3D(0,0,0);   // Start with empty vector to accumulate all locations
    // no neighbors, let's stop this.
    if (neighbors.size() == 0) return sum;
    for (int i = 0 ; i < neighbors.size(); i++) {
      Boid other = (Boid) neighbors.get(i);
      float d = loc.distance(loc,other.loc);
      sum.add(other.loc); // Add location
    }
    sum.div((float)neighbors.size());
    return steer(sum,false);  // Steer towards the location
  }
}