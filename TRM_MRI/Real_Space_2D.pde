
class Real_Space_2D
{
  private float image_width;
  private float image_height;
  private float middle_x;
  private float middle_y;
  private float right_x;
  private float bottom_y;
  private int x_axis_dipole_count;
  private int y_axis_dipole_count;
  private PVector position=new PVector();
  private dipole_2D[][] dipoles;
  private float smallerdimension;
  private float x_oscillations;
  private float y_oscillations;
  private float overall_angle;
  private float fraction_for_charts=0.1f;

  CosineChart xchart=new CosineChart();
  CosineChart ychart=new CosineChart();

  //x-axis is frequency encoding
  //y-axis is phase encoding
  Real_Space_2D()
  {
  }
  public void set_dimension(float new_image_width, float new_image_height)
  {
    image_width=new_image_width*(1-fraction_for_charts);
    image_height=new_image_height*(1-fraction_for_charts);
    xchart.set_size(image_width, new_image_height*fraction_for_charts);    
    ychart.set_size(new_image_width*fraction_for_charts, image_height);
    set_cosine_charts();
    update();
  }
  public void set_dipole_counts(int x_axis, int y_axis)
  {
    x_axis_dipole_count=x_axis;
    y_axis_dipole_count=y_axis;

    dipoles=new dipole_2D[x_axis_dipole_count][y_axis_dipole_count];

    for (int x=0; x<x_axis_dipole_count; x++)
    {
      for (int y=0; y<y_axis_dipole_count; y++)
      {
        dipoles[x][y]=new dipole_2D(0);
      }
    }

    update();
  }
  public void set_position(float x, float y)
  {
    position.x=x;
    position.y=y;
    set_cosine_charts();
    update();
  }
  public void set_cosine_charts()
  {
    xchart.set_position(new PVector(position.x, position.y+image_height));
    ychart.set_position(new PVector(position.x+image_width, position.y));
  }
  public void set_precession(float x_axis_oscillations, float y_axis_oscillations, float all_precession)
  {
    //Sets the total number of oscillations in each encoding direction
    x_oscillations=x_axis_oscillations*(2*PI);
    y_oscillations=y_axis_oscillations*(2*PI);
    //Sets the procession of all the dipoles together (for static coordinate system, will set to 0 for relative coordinate system)
    overall_angle=all_precession;

    xchart.set_oscillations(x_axis_oscillations, all_precession);
    ychart.set_oscillations(y_axis_oscillations, all_precession);

    update();
  }


  public void update()
  {
    middle_x=position.x+image_width/2;
    middle_y=position.y+image_height/2;
    right_x=position.x+image_width;
    bottom_y=position.y+image_height;

    PVector dipole_size=new PVector(image_width/x_axis_dipole_count, image_height/y_axis_dipole_count);
    smallerdimension=min(dipole_size.x, dipole_size.y);
    float x_angle_contribution;
    float y_angle_contribution;
    for (int x=0; x<x_axis_dipole_count; x++)
    {
      for (int y=0; y<y_axis_dipole_count; y++)
      {
        PVector pos=new PVector();
        pos.x=(x+0.5f)*dipole_size.x;
        pos.y=(y+0.5f)*dipole_size.y;
        pos=PVector.add(pos, position);
        dipoles[x][y].set_size(smallerdimension/32);
        dipoles[x][y].set_position(pos);
        dipoles[x][y].length=smallerdimension/2;
        x_angle_contribution=(pos.x-middle_x)/image_width*x_oscillations; //frequency encoding is x-axis
        y_angle_contribution=(pos.y-middle_y)/image_height*y_oscillations; //phase encoding is y-axis
        dipoles[x][y].angle=overall_angle+x_angle_contribution+y_angle_contribution;
      }
    }
  }
  public void draw(PGraphics maintarget, boolean draw_realspace_phase_colors)
  {
    maintarget.strokeWeight(1);
    maintarget.fill(255);
    maintarget.stroke(0);

    maintarget.stroke(230);
    maintarget.fill(255);
    maintarget.rect(position.x, position.y, image_width, image_height); //Borders
    maintarget.stroke(0);
    maintarget.line(middle_x, position.y, middle_x, bottom_y); //Y-axis
    maintarget.line(position.x, middle_y, right_x, middle_y);//X-axis

    strokeWeight(1);
    for (int x=0; x<x_axis_dipole_count; x++)
    {
      for (int y=0; y<y_axis_dipole_count; y++)
      {
        PVector center=dipoles[x][y].get_position();
        if (draw_realspace_phase_colors)
        {
          maintarget.fill(phase_to_color(dipoles[x][y].angle));
        } else {
          maintarget.fill(255);
        }
        maintarget.ellipse(center.x, center.y, smallerdimension, smallerdimension);
        maintarget.fill(0);
        dipoles[x][y].draw(maintarget);
      }
    }

    xchart.draw(maintarget);
    ychart.draw_vertical(maintarget);
  }
}