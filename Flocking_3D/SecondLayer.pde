class SecondLayer {
  color[] px = new color[width * height];
  
  SecondLayer() {
    for (int i=0; i < width * height; i++)
      px[i] = color(0);  
  }
  
  void setPixel(int address, color col) {
    if ((address >= 0) && (address < width * height)) px[address] = col;
  }
  
  void setStamp(int edge, int address, color col) {
    int tempAddress;
    for (int i = -edge; i < edge; i++)
     for (int j = -edge; j < edge; j++) {
       tempAddress = address + i + j * width;
       setPixel(tempAddress, col + i * 5 + j * 5);
     }
  }  
  
  void render(){
    //loadPixels();
    //for (int i=0; i < width * height; i++)
      //if (px[i] != color(0)) pixels[i] = px[i];
    //updatePixels();
  }
}
