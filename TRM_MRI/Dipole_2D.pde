class dipole_2D
{
  arrow a;
  float length;
  float angle;
  dipole_2D(float size)
  {
    a=new arrow();
    set_size(size);
    length=0;
    angle=0;
  }
  public void set_size(float size)
  {
    a.set_size(size);
  }
  public void set_position(PVector p)
  {
    a.set_origin(p);
  }
  public PVector get_position()
  {
    return a.get_origin();
  }
  public void draw(PGraphics maintarget)
  {
    //for now, 0 degrees is the negative y direction, or straight up on the screen
    PVector dir=new PVector(0, -1).normalize();
    dir.rotate(angle);
    a.set_tip(a.origin.copy().add(dir.mult(length)));
    a.draw(maintarget);
  }
}

class arrow
{
  private PVector origin=new PVector();
  private PVector tip=new PVector();
  private PVector base_end=new PVector();
  private PVector orthogonal=new PVector();
  private PVector direction=new PVector();
  private PVector corner[]=new PVector[6];
  private float size=1;
  arrow()
  {
  }

  public void set_origin(PVector new_origin)
  {
    origin=new_origin;
    update();
  }
  public PVector get_origin()
  {
    return origin;
  }
  public void set_tip(PVector new_tip)
  {
    tip=new_tip;
    update();
  }

  public void set_size(float new_size)
  {
    size=new_size;
    update();
  }

  public void update()
  {
    //Direction
    direction = PVector.sub(tip, origin).normalize();

    //Base end
    base_end = PVector.sub(tip, PVector.mult(direction, (float)(size*5.0F)));

    //orthogonal
    orthogonal=direction.copy().rotate(HALF_PI);

    //Body of arrow
    PVector temp=new PVector();
    temp=orthogonal.copy().mult((float)(size/2.0F));
    corner[0]=origin.copy().add(temp);
    corner[1]=origin.copy().sub(temp);
    corner[2]=base_end.copy().sub(temp);
    corner[3]=base_end.copy().add(temp);

    //Head of arrow
    temp=orthogonal.copy().mult((float)(size*2.0F));
    corner[4]=PVector.add(base_end, temp);
    corner[5]=PVector.sub(base_end, temp);
  }

  public void draw(PGraphics maintarget)
  {  
    maintarget.ellipse(origin.x, origin.y, size, size);

    maintarget.quad(corner[0].x, corner[0].y, corner[1].x, corner[1].y, corner[2].x, corner[2].y, corner[3].x, corner[3].y);

    /*
    printvector("Origin",origin);
     printvector("Tip",tip);
     printvector("Direction",direction);
     printvector("Orthogonal",orthogonal);
     printvector("corner1",corner[0]);
     printvector("corner2",corner[1]);
     printvector("corner3",corner[2]);
     printvector("corner4",corner[3]);
     */

    maintarget.triangle(corner[4].x, corner[4].y, corner[5].x, corner[5].y, tip.x, tip.y);
  }
}



public void printvector(String name, PVector vector)
{
  println(name + ": (" + vector.x + ", " + vector.y + ")");
}
public void drawarrow()
{
  line(30, 20, 85, 75);
}