class Chart
{
  private PVector position=new PVector();
  private float image_width;
  private float image_height;
  private PVector values[];
  private float xmin;
  private float xmax;
  private float ymin;
  private float ymax;
  Chart()
  {
  }
  void set_position(PVector im_position)
  {
    position=im_position;
  }
  void set_size(float im_width, float im_height)
  {
    image_width=im_width;
    image_height=im_height;
  }
  void set_values(PVector new_values[])
  {
    values=new_values;
  }
  void set_scale(float x_min, float x_max, float y_min, float y_max)
  {
    xmin=x_min;
    xmax=x_max;
    ymin=y_min;
    ymax=y_max;
  }
  void draw(PGraphics maintarget)
  {
    maintarget.strokeWeight(1);

    maintarget.stroke(230);
    maintarget.fill(255);
    maintarget.rect(position.x, position.y, image_width, image_height); //Borders

    maintarget.stroke(0);
    PVector p1=new PVector();
    PVector p2=new PVector();
    for (int n=0; n<values.length-1; n++)
    {
      p1.x=(values[n].x-xmin)/(xmax-xmin);
      p1.y=(values[n].y-ymin)/(ymax-ymin);
      p2.x=(values[n+1].x-xmin)/(xmax-xmin);
      p2.y=(values[n+1].y-ymin)/(ymax-ymin);
      if (p1.x>1.0) {
        p1.x=1.0;
      }
      if (p1.y<0.0) {
        p1.y=0.0;
      }
      if (p1.x>1.0) {
        p1.x=1.0;
      }
      if (p1.y<0.0) {
        p1.y=0.0;
      }
      if (p2.x>1.0) {
        p2.x=1.0;
      }
      if (p2.y<0.0) {
        p2.y=0.0;
      }
      if (p2.x>1.0) {
        p2.x=1.0;
      }
      if (p2.y<0.0) {
        p2.y=0.0;
      }
      p1.x=position.x+image_width*p1.x;
      p1.y=position.y+image_height*(1.0-p1.y);
      p2.x=position.x+image_width*p2.x;
      p2.y=position.y+image_height*(1.0-p2.y);
      maintarget.line(p1.x, p1.y, p2.x, p2.y);

      //println("Point 1: " + p1.x + ", " + p1.y);
      //println("Point 2: " + p2.x + ", " + p2.y);
    }

    maintarget.hint(DISABLE_DEPTH_TEST);
    maintarget.noFill();
    maintarget.stroke(0);
    maintarget.rect(position.x, position.y, image_width, image_height);
    maintarget.hint(ENABLE_DEPTH_TEST);
    
  }

  void draw_vertical(PGraphics maintarget)
  {
    maintarget.strokeWeight(1);

    maintarget.stroke(230);
    maintarget.fill(255);
    maintarget.rect(position.x, position.y, image_width, image_height); //Borders

    maintarget.stroke(0);
    PVector p1=new PVector();
    PVector p2=new PVector();
    for (int n=0; n<values.length-1; n++)
    {
      p1.x=(values[n].x-xmin)/(xmax-xmin);
      p1.y=(values[n].y-ymin)/(ymax-ymin);
      p2.x=(values[n+1].x-xmin)/(xmax-xmin); 
      p2.y=(values[n+1].y-ymin)/(ymax-ymin);
      if (p1.x>1.0) {
        p1.x=1.0;
      }
      if (p1.y<0.0) {
        p1.y=0.0;
      }
      if (p1.x>1.0) {
        p1.x=1.0;
      }
      if (p1.y<0.0) {
        p1.y=0.0;
      }
      if (p2.x>1.0) {
        p2.x=1.0;
      }
      if (p2.y<0.0) {
        p2.y=0.0;
      }
      if (p2.x>1.0) {
        p2.x=1.0;
      }
      if (p2.y<0.0) {
        p2.y=0.0;
      }
      p1.x=position.y+image_height*(1.0-p1.x); //To get positive x-axis to be at the top, do 1.0-x
      p1.y=position.x+image_width*(1.0-p1.y);
      p2.x=position.y+image_height*(1.0-p2.x); //To get positive x-axis to be at the top, do 1.0-x
      p2.y=position.x+image_width*(1.0-p2.y);
      maintarget.line(p1.y, p1.x, p2.y, p2.x);

      //println("Point 1: " + p1.x + ", " + p1.y);
      //println("Point 2: " + p2.x + ", " + p2.y);
    }
  }
}

class CosineChart extends Chart
{
  private float oscil;
  private float phase;
  CosineChart()
  {
    super();
    set_scale(-0.5, 0.5, -1.1, 1.1);
  }
  void set_oscillations(float oscillations, float phase)
  {
    oscil=oscillations;
    this.phase=phase;
    update();
  }
  void set_size(float im_width, float im_height)
  {
    int arraysize=ceil((float)im_width/2.0)*4;
    //println("Array size: " + arraysize);
    super.values=new PVector[arraysize];
    super.set_size(im_width, im_height);
  }
  void update()
  {
    int arraylength = super.values.length;
    //println("Array length: " + arraylength);
    for (int n=0; n<arraylength; n++)
    {
      float x=((float)n-(float)(arraylength-1)/2.0)/((float)(arraylength-1)); //length of array will always be a multiple of two because of how it's set
      float y=cos(x*oscil*2*PI+phase);
      //println("Point added: " + x + ", " + y);
      super.values[n]=new PVector(x, y);
    }
  }
}