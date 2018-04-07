class Fourier
{
  PVector position;
  PVector size;
  PImage i;
  Fourier(int x, int y)
  {
    i=new PImage(x, y);
  }
  void set(float x_oscillations, float y_oscillations, float amplitude, float phase)
  {
    //amplitude is 0 to 1
    i.loadPixels();
    for (int y=0; y<i.height; y++)
    {
      int y_index_contribution=y*i.width;
      float y_comp_angle=2*PI*((float)y-(float)(i.height-1)/2.0)/(float)(i.height-1)*y_oscillations;
      for (int x=0; x<i.width; x++)
      {
        float x_comp_angle=2*PI*((float)x-(float)(i.width-1)/2.0)/(float)(i.width-1)*x_oscillations;
        float value=amplitude*(cos(x_comp_angle+y_comp_angle+phase)+1)/2.0;
        i.pixels[y_index_contribution+x]=color(value*255);
      }
    }
    i.updatePixels();
  }
}