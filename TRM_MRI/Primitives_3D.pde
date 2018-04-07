class ObjectColor
{
 color c;
 ObjectColor()
 {
  c=color(0); 
 }
 ObjectColor(color init)
 {
  c=init; 
 }
 void set_color(color newcolor)
  {
    c=newcolor;
  }
  void set_alpha(float alpha)
  {
   set_alpha((int)lerp(0,255,alpha));
  }
  void set_alpha(int alpha)
  {
    int r = (c >> 16) & 0xFF;
    int g = (c >> 8) & 0xFF;
    int b = c & 0xFF;
    c=color(r, g, b, alpha);
  }
}

class Model
{
  String name = "unnamed";
  private ArrayList<Model> children=new ArrayList<Model>();
  private PVector inherited_displacement=new PVector();
  private PVector model_displacement=new PVector();
  private PVector aggregate_displacement=new PVector();
  protected PGraphics rendertarget;
  Model()
  {
  }
  void add_child(Model child)
  {
    child.set_inherited_displacement(model_displacement);
    children.add(child);
  }
  void add_modelspace_vertex(PVector position)
  {
    rendertarget.vertex(aggregate_displacement.x+position.x, aggregate_displacement.y+position.y, aggregate_displacement.z+position.z);
  }
  void draw_modelspace_origin(float length)
  {
    rendertarget.stroke(255, 0, 0);
    rendertarget.noFill();
    rendertarget.line(aggregate_displacement.x-length, aggregate_displacement.y, aggregate_displacement.z, aggregate_displacement.x+length, aggregate_displacement.y, aggregate_displacement.z);
    rendertarget.line(aggregate_displacement.x, aggregate_displacement.y-length, aggregate_displacement.z, aggregate_displacement.x, aggregate_displacement.y+length, aggregate_displacement.z);
    rendertarget.line(aggregate_displacement.x, aggregate_displacement.y, aggregate_displacement.z-length, aggregate_displacement.x, aggregate_displacement.y, aggregate_displacement.z+length);
  }
  private void calc()
  {
    aggregate_displacement=PVector.add(model_displacement, inherited_displacement); 
    //println();
    //println("For model " +name);
    //println("Inherited displacement updated: " + inherited_displacement);
    //println("New aggregate displacement: " + aggregate_displacement);
    updatechildren();
  }
  void set_model_displacement(PVector new_model_displacement)
  {
    this.model_displacement=new_model_displacement.copy();
    this.calc();
  }
  void set_inherited_displacement(PVector new_inherited_displacement)
  {
    //println("Set inherited called for " + name);
    this.inherited_displacement=new_inherited_displacement.copy();
    this.calc();
  }
  private void updatechildren()
  {
    for (Model child : children)
    {
      //println("Updating child " + child.name);
      child.set_inherited_displacement(aggregate_displacement); //aggregate the displacements to pass to children
    }
  }
}

class vectorgroup
{
  PVector normal;
  PVector vectors[];
  void setnormal(PGraphics rendertarget)
  {
    rendertarget.normal(normal.x, normal.y, normal.z);
  }
}

class Cylinder extends Model
{
  private ObjectColor c=new ObjectColor(color(0, 100, 100));
  vectorgroup side_members[];
  PVector origin = new PVector();
  PVector tip = new PVector();
  PVector normal_component;
  PVector dir;
  PVector rad1;
  PVector rad2;
  float origin_radius;
  float tip_radius;
  int sides=25;
  Cylinder()
  {
  }
  void set(PVector origin, PVector tip, float origin_radius, float tip_radius)
  {
    this.origin=origin.copy();
    this.tip=tip.copy();
    this.origin_radius=origin_radius;
    this.tip_radius=tip_radius;
    calc();
  }
  void calc()
  {
    dir=PVector.sub(tip, origin).normalize();
    //println("Calculating.");
    if (tip.x==origin.x && tip.y==origin.y)
    {
      //println("X and Y the same.");
      rad1=new PVector(1, 0, 0);
      rad2=new PVector(0, 1, 0);
    } else if (tip.y==origin.y && tip.z==origin.z)
    {
      //println("Y and Z the same.");
      rad1=new PVector(0, 1, 0);
      rad2=new PVector(0, 0, 1);
    } else if (tip.x==origin.x && tip.z==origin.z)
    {
      //println("X and Z the same.");
      rad1=new PVector(1, 0, 0);
      rad2=new PVector(0, 0, 1);
    } else
    {
      //println("Cross product method.");
      PVector displaced=new PVector();
      PVector d_origin=PVector.add(origin, displaced);
      PVector d_tip=PVector.add(tip, displaced);
      if (origin.x==tip.x && origin.y==tip.y && origin.z==tip.z) {
        //println("Origin and tip are the same.");
        return;
      }
      //println("Initial angle between = " + PVector.angleBetween(tip,origin));
      int count=0;
      while (PVector.angleBetween(d_tip, d_origin)<1E-6 && count<10)
      {
        count++;
        //println("displaced: " + displaced);
        //println("d_origin: " + d_origin);
        //println("d_tip: " + d_tip);
        //println("Angle between = " + PVector.angleBetween(d_tip,d_origin) +", count=" + count); 
        displaced=PVector.random3D();
        d_origin=PVector.add(origin, displaced);
        d_tip=PVector.add(tip, displaced);
      }

      rad1=d_tip.cross(d_origin).normalize();
      rad2=dir.cross(rad1).normalize();
      
      //println("Cylinder " + origin + "" + tip + "" + rad1 + "" + rad2);
    }

    //println("Origin: " + origin);
    //println("Tip: " + tip);
    //println("Dir: " + dir);
    //println("Rad1: " + rad1);
    //println("Rad2: " + rad2);

    float adjacent=PVector.sub(tip, origin).mag();
    //axial component correction is away from tip of the tip_radius is larger than origin radius and vice versa. 
    float opposite=origin_radius-tip_radius;
    //magnitude of the correction vector is opposite/adjacent*normal_radial_component, and normal_radial_component is normalized
    float correction_magnitude=opposite/adjacent; 
    normal_component=PVector.mult(dir, correction_magnitude);

    //println("origin_radius: " + origin_radius);
    //println("tip_radius: " + tip_radius);
    //println("Opposite: " + opposite);
    //println("Adjacent: " + adjacent);
    //println("Correction_Magnitude: " + correction_magnitude);
    //println("Normal_Axial_Component: " + normal_component);

    float theta;
    PVector vectors[]=new PVector[2];
    PVector normal;
    PVector components_o[]=new PVector[2];
    PVector components_t[]=new PVector[2];
    side_members=new vectorgroup[sides+1];
    //Triangle fans start at the center of the fan
    for (int n=0; n<=sides; n++)
    {

      theta=(float)n/(float)sides*2*PI;
      components_o[0]=PVector.mult(rad1, origin_radius).mult(sin(theta));
      components_o[1]=PVector.mult(rad2, origin_radius).mult(cos(theta));
      vectors[0]=PVector.add(components_o[0], components_o[1]).add(origin);
      components_t[0]=PVector.mult(rad1, tip_radius).mult(sin(theta));
      components_t[1]=PVector.mult(rad2, tip_radius).mult(cos(theta));
      vectors[1]=PVector.add(components_t[0], components_t[1]).add(tip);

      //normals
      //get the radial component first
      if (tip_radius>=origin_radius)
      {
        normal=PVector.add(components_t[0], components_t[1]).normalize();//has to be normalized to be summed with axial component
      } else
      {
        normal=PVector.add(components_o[0], components_o[1]).normalize();//has to be normalized to be summed with axial component
      }

      normal=PVector.add(normal, normal_component).normalize();

      side_members[n]=new vectorgroup();
      side_members[n].vectors=new PVector[2];
      side_members[n].normal=normal.copy();
      side_members[n].vectors[0]=vectors[0].copy();
      side_members[n].vectors[1]=vectors[1].copy();
    }
  }
  void draw(PGraphics rendertarget)
  {
    this.rendertarget=rendertarget;
    //stroke(c);
    rendertarget.noStroke();
    rendertarget.fill(c.c);


    rendertarget.beginShape(QUAD_STRIP);
    for (int n=0; n<=sides; n++)
    {
      side_members[n].setnormal(rendertarget);
      add_modelspace_vertex(side_members[n].vectors[0]);
      add_modelspace_vertex(side_members[n].vectors[1]);
    }
    rendertarget.endShape();

    rendertarget.normal(-dir.x, -dir.y, -dir.z);
    add_modelspace_vertex(origin);
    rendertarget.beginShape(TRIANGLE_FAN);
    for (int n=0; n<=sides; n++)
    {
      add_modelspace_vertex(side_members[n].vectors[0]);
    }
    rendertarget.endShape();

    rendertarget.normal(dir.x, dir.y, dir.z);
    add_modelspace_vertex(tip);
    rendertarget.beginShape(TRIANGLE_FAN);
    for (int n=0; n<=sides; n++)
    {
      add_modelspace_vertex(side_members[n].vectors[1]);
    }
    rendertarget.endShape();

    //draw_modelspace_origin(20);
  }
}

class Box2 extends Model
{
  PVector members[];
  Box2(PVector origin, float w, float h, float d)
  {
    members=new PVector[8];
    members[0]=origin.copy();                            //front bottom left
    members[1]=origin.copy().add(new PVector(w, 0, 0));  //front bottom right
    members[2]=origin.copy().add(new PVector(0, h, 0));  //front top left
    members[3]=origin.copy().add(new PVector(w, h, 0)); //front top right
    members[4]=origin.copy().add(new PVector(0, 0, d));//back bottom left
    members[5]=origin.copy().add(new PVector(w, 0, d));//back bottom right
    members[6]=origin.copy().add(new PVector(0, h, d));//back top left
    members[7]=origin.copy().add(new PVector(w, h, d));//back top right
  }

  void draw(PGraphics rendertarget)
  {
    this.rendertarget=rendertarget;
    rendertarget.beginShape(QUADS);
    //front
    add_modelspace_vertex(members[0]);
    add_modelspace_vertex(members[1]);
    add_modelspace_vertex(members[3]);
    add_modelspace_vertex(members[2]);
    //back
    add_modelspace_vertex(members[4]);
    add_modelspace_vertex(members[5]);
    add_modelspace_vertex(members[7]);
    add_modelspace_vertex(members[6]);
    //right
    add_modelspace_vertex(members[1]);
    add_modelspace_vertex(members[3]);
    add_modelspace_vertex(members[7]);
    add_modelspace_vertex(members[5]);
    //left
    add_modelspace_vertex(members[0]);
    add_modelspace_vertex(members[2]);
    add_modelspace_vertex(members[6]);
    add_modelspace_vertex(members[4]);
    //bottom
    add_modelspace_vertex(members[0]);
    add_modelspace_vertex(members[1]);
    add_modelspace_vertex(members[5]);
    add_modelspace_vertex(members[4]);
    //top
    add_modelspace_vertex(members[2]);
    add_modelspace_vertex(members[3]);
    add_modelspace_vertex(members[7]);
    add_modelspace_vertex(members[6]);
    rendertarget.endShape();
  }
}


class Arrow3D extends Model
{
  PVector origin = new PVector();
  PVector dir = new PVector();
  PVector original_tip = new PVector();
  PVector current_tip = new PVector();
  Cylinder cylinders[];
  float diameter;
  Arrow3D(float d)
  {
    cylinders=new Cylinder[2];
    for (int n=0; n<2; n++)
    {
      cylinders[n]=new Cylinder();
      cylinders[n].name="Cylinder " + n + " for an arrow";
      add_child(cylinders[n]);
    }
    diameter=d;
  }
  void set(PVector origin, PVector tip)
  {
    this.origin=origin.copy();
    this.original_tip=tip.copy();
    this.current_tip=tip.copy();
    dir=PVector.sub(tip, origin).normalize();
    calc();
  }
  void set_color(color c)
  {
    for (int n=0; n<2; n++)
    {
      cylinders[n].c.set_color(c);
    }
  }
  void set_alpha(float a)
  {
    for (int n=0; n<2; n++)
    {
      cylinders[n].c.set_alpha(a);
    }
  }
  void calc()
  {
    PVector tempdir=PVector.sub(current_tip, origin);
    if (origin.x==0 && origin.y==0 && origin.z==0) {
      tempdir=current_tip.copy();
    }
    PVector headbase;//=new PVector();
    float headlength=diameter*1.5;
    if (tempdir.mag()<headlength) {
      headbase=origin.copy();
    } else
    {
      PVector subtractionvec=tempdir.setMag(dir, headlength);
      headbase=PVector.sub(current_tip, subtractionvec);
      //println(subtractionvec + ":" + headbase);
    }
    cylinders[0].set(origin.copy(), headbase.copy(), diameter/2.0, diameter/2.0);
    cylinders[1].set(headbase.copy(), current_tip.copy(), diameter, 0);
    //println("Cylinder: " + origin + "" + headbase + "" + current_tip);
  }
  void changelength(float len)
  {
    dir=PVector.sub(original_tip, origin).setMag(abs(len));
    if (len>=0)
    {
      current_tip=PVector.add(origin, dir);
    } else
    {
      current_tip=PVector.sub(origin, dir);
    }
    calc();
  }
  void changediameter(float di)
  {
    if (di<=0) {
      diameter=0;
      return;
    }
    diameter=abs(di);
    calc();
  }
  void draw(PGraphics rendertarget)
  {
    this.rendertarget=rendertarget;
    cylinders[0].draw(rendertarget);
    cylinders[1].draw(rendertarget);
  }
}