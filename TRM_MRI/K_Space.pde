class MatrixEntry
{
  int time;
  int x;
  int y;
  float freq;
  float phase;
  boolean val;
  color c=CoilGroup_Color(CoilGroup.signal);
}

class K_Space_2D
{
  private float image_width;
  private float image_height;
  private float middle_x;
  private float middle_y;
  private float right_x;
  private float bottom_y;
  private int matrix_size_x;
  private int matrix_size_y;
  private float x_width;
  private float y_width;
  private PVector position=new PVector();
  private PVector k_space_location=new PVector();
  private PVector k_space_position=new PVector();
  K_Space_2D()
  {
  }

  public void set_dimension(float new_image_width, float new_image_height)
  {
    image_width=new_image_width;
    image_height=new_image_height;

    update();
  }
  public void set_position(float x, float y)
  {
    position.x=x;
    position.y=y;

    update();
  }

  boolean matrix[][];
  color matrixcolors[][];
  public void  set_matrix_size(int x, int y)
  {
    matrix_size_x=x;
    matrix_size_y=y;

    matrix=new boolean[matrix_size_x][matrix_size_y];
    matrixcolors=new color[matrix_size_x][matrix_size_y];
    for (int x1=0; x1<matrix_size_x; x1++)
    {
      for (int y1=0; y1<matrix_size_y; y1++)
      {
        matrix[x1][y1]=false;
        matrixcolors[x1][y1]=color(255);
      }
    }
    update();
  }

  public void set_k_space_location(float x, float y)
  {
    k_space_location.x=x;
    k_space_location.y=y;
    update();
  }

  public void change_matrix_value(MatrixEntry e)
  {
    //println("X="+e.x+" Y="+e.y);
    matrix[e.x][e.y]=e.val;
    matrixcolors[e.x][e.y]=e.c;
  }

  public void update()
  {
    middle_x=position.x+image_width/2;
    middle_y=position.y+image_height/2;
    right_x=position.x+image_width;
    bottom_y=position.y+image_height;

    x_width=(float)image_width/(float)matrix_size_x;
    y_width=(float)image_height/(float)matrix_size_y;

    //k_space_location is ranged from 0 to matrix_size-1
    k_space_position.x=(k_space_location.x+0.5)*x_width+position.x;
    k_space_position.y=(k_space_location.y+0.5)*y_width+position.y;
  }

  float max_matrixcolor_intensity=MIN_FLOAT;
  public void draw(PGraphics maintarget, boolean include_minorlines, boolean scale_matrixcolors)
  {

    maintarget.strokeWeight(1);
    for (int x=0; x<matrix_size_x; x++)
    {
      for (int y=0; y<matrix_size_y; y++)
      {
        if (matrix[x][y])
        {
          //println("Matrix " + x + "," + y + " is true.");
          maintarget.noStroke();
          if (scale_matrixcolors)
          {
            color source_color=matrixcolors[x][y];
            float r=source_color >> 16 & 0xFF;
            float g=source_color >> 8 & 0xFF;
            float b=source_color & 0xFF;
            float intensity=(r+g+b)/3.0/max_matrixcolor_intensity;
            maintarget.fill(intensity);
          } else
          {
            maintarget.fill(matrixcolors[x][y]);
          }
          maintarget.rect(position.x+x_width*x, position.y+y_width*y, x_width, y_width);
        }
      }
    }

    if (include_minorlines)
    {
      maintarget.strokeWeight(2);
      //Axes
      maintarget.stroke(0);
      maintarget.line(middle_x, position.y, middle_x, bottom_y); //Y-axis
      maintarget.line(position.x, middle_y, right_x, middle_y);//X-axis
    }

    if (!include_minorlines)
    {
      maintarget.strokeWeight(1);
      maintarget.stroke(0);
      maintarget.noFill();
      maintarget.rect(position.x, position.y, image_width, image_height);
    }

    maintarget.strokeWeight(1);

    //Steps
    if (include_minorlines)
    {
      maintarget.stroke(255/2);

      for (int x=0; x<=matrix_size_x; x++)
      {
        float x_f=position.x+(float)(x)*x_width;
        maintarget.line(x_f, position.y, x_f, bottom_y);
      }
      for (int y=0; y<=matrix_size_y; y++)
      {
        float y_f=position.y+(float)(y)*y_width;
        maintarget.line(position.x, y_f, right_x, y_f);
      }
    }

    //Location in k_space
    maintarget.stroke(0, 0, 0);
    maintarget.fill(0, 200, 0);
    //println("K space location: " + k_space_location);
    maintarget.ellipse(k_space_position.x, k_space_position.y, x_width*0.4, y_width*0.4);
  }
}