// Simple Vector3D Class 

static class Vector3D {
  float x;
  float y;
  float z;

  Vector3D(float x_, float y_, float z_) {
    x = x_; y = y_; z = z_;
  }

  Vector3D(float x_, float y_) {
    x = x_; y = y_; z = 0f;
  }
  
  Vector3D() {
    x = 0f; y = 0f; z = 0f;
  }

  float slope2D() {
    if (x != 0f) return y/x;
    return 0f;
  }
  
  void setX(float x_) {
    x = x_;
  }

  void setY(float y_) {
    y = y_;
  }

  void setZ(float z_) {
    z = z_;
  }
  
  void setXY(float x_, float y_) {
    x = x_;
    y = y_;
  }
  
  void setXYZ(float x_, float y_, float z_) {
    x = x_;
    y = y_;
    z = z_;
  }

  void setXYZ(Vector3D v) {
    x = v.x;
    y = v.y;
    z = v.z;
  }
  
  float magnitude() {
    return (float) Math.sqrt(x*x + y*y + z*z);
  }

  Vector3D copy() {
    return new Vector3D(x,y,z);
  }

  Vector3D copy(Vector3D v) {
    return new Vector3D(v.x, v.y,v.z);
  }
  
  void add(Vector3D v) {
    x += v.x;
    y += v.y;
    z += v.z;
  }

  void sub(Vector3D v) {
    x -= v.x;
    y -= v.y;
    z -= v.z;
  }

  void mult(float n) {
    x *= n;
    y *= n;
    z *= n;
  }

  void div(float n) {
    x /= n;
    y /= n;
    z /= n;
  }

  void normalize() {
    float m = magnitude();
    if (m > 0) {
       div(m);
    }
  }

  void limit(float max) {
    if (magnitude() > max) {
      normalize();
      mult(max);
    }
  }

  float heading2D() {
    float angle = (float) Math.atan2(-y, x);
    return -1*angle;
  }
  
  float angleBetweenTwo2D(Vector3D o) {
    return (float) Math.atan2(o.y,o.x) - atan2(y,x);
  }

  float angleBetween(Vector3D o) {
    return (float) Math.acos( dot(o) / ( length() * o.length() ) );
  }
  
  Vector3D add(Vector3D v1, Vector3D v2) {
    Vector3D v = new Vector3D(v1.x + v2.x,v1.y + v2.y, v1.z + v2.z);
    return v;
  }

  Vector3D sub(Vector3D v1, Vector3D v2) {
    Vector3D v = new Vector3D(v1.x - v2.x,v1.y - v2.y,v1.z - v2.z);
    return v;
  }

  Vector3D div(Vector3D v1, float n) {
    Vector3D v = new Vector3D(v1.x/n,v1.y/n,v1.z/n);
    return v;
  }

  Vector3D mult(Vector3D v1, float n) {
    Vector3D v = new Vector3D(v1.x*n,v1.y*n,v1.z*n);
    return v;
  }
  
  float dot(Vector3D other) {
    return (x * other.x + y * other.y + z * other.z);
  }
  
  boolean sphereIntersection(Vector3D origin, Vector3D sphereCenter, float sphereRadius) {
    Vector3D l = new Vector3D();
    l = sub(sphereCenter, origin);
    float s = l.x * x + l.y * y + l.z * z;
    float s_square = s * s;
    float l_square = l.x * l.x + l.y * l.y + l.z * l.z;
    float r_square = sphereRadius * sphereRadius;
    if ( (s < 0) && (l_square > r_square) ) return false;
    float m_square = l_square - s_square;
    if (m_square > r_square) return false;
    return true;
  }
  
  void rotate2D(float angle) {
    float x_ = x;
    x = x * cos(angle) - y * sin(angle);
    y = x_ * sin(angle) + y * cos(angle);
  }
  
  float length() {
    return (float) Math.sqrt(x*x + y*y + z*z);
  }

  float distance (Vector3D v1, Vector3D v2) {
    float dx = v1.x - v2.x;
    float dy = v1.y - v2.y;
    float dz = v1.z - v2.z;
    return (float) Math.sqrt(dx*dx + dy*dy + dz*dz);
  }
}
