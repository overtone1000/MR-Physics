boolean isEven(int n) {
  return n % 2 == 0;
}

color CoilGroup_Color(CoilGroup group)
{
  switch(group)
  {
  case RF:
    return color(150, 150, 0); //yellow
  case slice:
    return color(0, 0, 200); //blue
  case phase:
    return color(0, 200, 0); //green
  case freq:
    return color(200, 0, 0); //red
  case signal:
    return color(125, 0, 125); //purple
  case primary:
    return color(0, 0, 0);
  default:
    return color(0, 0, 0); //black
  }
}

static int coil_count=15;//2 slice select, 2 freq encode, 2 phase encode, 4 transmit, 4 receive, 1 primary
static int coilgroup_count=6;

class Scanner extends Model
{
  Coil coils[];

  Box2 table;
  float coil_distance_from_center=100;
  float coil_radius=20;
  float coil_pitch=3;
  int coil_rotations=10;
  float max_dimension=1;

  Scanner()
  {
    coils=new Coil[coil_count]; 
    for (int n=0; n<coil_count; n++)
    {
      coils[n]=new Coil();
      coils[n].name="Coil " + n;
      coils[n].pitch=coil_pitch;
      coils[n].radius=coil_radius;
      coils[n].rotations=coil_rotations;
      add_child(coils[n]);
    }

    //X coils, frequency encode    
    coils[0].set_model_displacement(new PVector(coil_distance_from_center, 0, 0));
    coils[1].set_model_displacement(new PVector(-coil_distance_from_center, 0, 0));
    coils[0].c.set_color(CoilGroup_Color(CoilGroup.freq));
    coils[1].c.set_color(CoilGroup_Color(CoilGroup.freq));
    //Y coils, phase encode
    coils[2].set_model_displacement(new PVector(0, coil_distance_from_center, 0));
    coils[3].set_model_displacement(new PVector(0, -coil_distance_from_center, 0));
    coils[2].c.set_color(CoilGroup_Color(CoilGroup.phase));
    coils[3].c.set_color(CoilGroup_Color(CoilGroup.phase));
    //Z coils, slice select
    coils[4].set_model_displacement(new PVector(0, 0, coil_distance_from_center));
    coils[5].set_model_displacement(new PVector(0, 0, -coil_distance_from_center));
    coils[4].c.set_color(CoilGroup_Color(CoilGroup.slice));
    coils[5].c.set_color(CoilGroup_Color(CoilGroup.slice));
    //RF
    float factor1=1.5;
    coils[6].set_model_displacement(new PVector(coil_distance_from_center*factor1, 0, 0));
    coils[7].set_model_displacement(new PVector(-coil_distance_from_center*factor1, 0, 0));
    coils[6].set_orientation(CoilOrientation.x);
    coils[7].set_orientation(CoilOrientation.x);
    coils[6].c.set_color(CoilGroup_Color(CoilGroup.RF));
    coils[7].c.set_color(CoilGroup_Color(CoilGroup.RF));
    coils[8].set_model_displacement(new PVector(0, coil_distance_from_center*factor1, 0));
    coils[9].set_model_displacement(new PVector(0, -coil_distance_from_center*factor1, 0));
    coils[8].set_orientation(CoilOrientation.y);
    coils[9].set_orientation(CoilOrientation.y);
    coils[8].c.set_color(CoilGroup_Color(CoilGroup.RF));
    coils[9].c.set_color(CoilGroup_Color(CoilGroup.RF));
    max_dimension=1.6*(coil_distance_from_center*factor1+2*coil_pitch*coil_rotations); //estimates the maximum width of the model on the screen
    //Receive
    float factor2=2.2/3.0;
    coils[10].set_model_displacement(new PVector(coil_distance_from_center*factor2, 0, 0));
    coils[11].set_model_displacement(new PVector(-coil_distance_from_center*factor2, 0, 0));
    coils[10].set_orientation(CoilOrientation.x);
    coils[11].set_orientation(CoilOrientation.x);
    coils[10].c.set_color(CoilGroup_Color(CoilGroup.signal));
    coils[11].c.set_color(CoilGroup_Color(CoilGroup.signal));
    coils[12].set_model_displacement(new PVector(0, coil_distance_from_center*factor2, 0));
    coils[13].set_model_displacement(new PVector(0, -coil_distance_from_center*factor2, 0));
    coils[12].set_orientation(CoilOrientation.y);
    coils[13].set_orientation(CoilOrientation.y);
    coils[12].c.set_color(CoilGroup_Color(CoilGroup.signal));
    coils[13].c.set_color(CoilGroup_Color(CoilGroup.signal));
    //Primary
    coils[14].pitch=coil_pitch*2;
    coils[14].radius=coil_radius*2;
    coils[14].rotations=coil_rotations*3;
    coils[14].c.set_color(CoilGroup_Color(CoilGroup.primary));  

    //set_coils(CoilGroup.freq, true, 0.5);
    //set_coils(CoilGroup.phase, true, 0.25);
    //set_coils(CoilGroup.slice, true, 1.0);
    //set_coils(CoilGroup.RF,true,0.25);
    //set_coils(CoilGroup.signal,true,-0.25);
    //set_coils(CoilGroup.primary, true, 1);

    float x=coil_distance_from_center/2;
    float y=coil_distance_from_center/10;
    float z=coil_distance_from_center*0.7;
    table=new Box2(new PVector(-x, -x, -z), x*2, y, z*2);
    add_child(table);
  }

  void draw(PGraphics rendertarget, ScannerState state)
  {
    this.rendertarget=rendertarget;

    state.set_perspective(rendertarget); //only to be done by the top level model. Scanner, Chart, and Encoding_Spaces
    rendertarget.background(255);
    rendertarget.lights();
    rendertarget.directionalLight(200, 200, 255, -0.5, -1, -0.25);
    //rendertarget.camera();
    //Now draw everything
    rendertarget.noStroke();
    rendertarget.fill(155);
    table.draw(rendertarget);
    //println("Drawing inside arrows.");

    drawinsidearrows(CoilGroup.primary, state.getstate(CoilGroup.primary));
    drawinsidearrows(CoilGroup.freq, state.getstate(CoilGroup.freq));
    drawinsidearrows(CoilGroup.phase, state.getstate(CoilGroup.phase));
    drawinsidearrows(CoilGroup.slice, state.getstate(CoilGroup.slice));
    drawinsidearrows(CoilGroup.RF, state.getstate(CoilGroup.RF));
    drawinsidearrows(CoilGroup.signal, state.getstate(CoilGroup.signal));

    //println("Done drawing inside arrows.");
    //Primary first
    for (int n=14; n==14; n++)
    {
      CoilGroup currentgroup=CoilGroup.primary;
      drawcoils(currentgroup, state.getstate(currentgroup));
    }
    //RF next
    for (int n=6; n<=9; n++)
    {
      CoilGroup currentgroup=CoilGroup.RF;
      drawcoils(currentgroup, state.getstate(currentgroup));
    }
    //Freq next
    for (int n=0; n<=1; n++)
    {
      CoilGroup currentgroup=CoilGroup.freq;
      drawcoils(currentgroup, state.getstate(currentgroup));
    }
    //Phase next
    for (int n=2; n<=3; n++)
    {
      CoilGroup currentgroup=CoilGroup.phase;
      drawcoils(currentgroup, state.getstate(currentgroup));
    }
    //Slice next
    for (int n=4; n<=5; n++)
    {
      CoilGroup currentgroup=CoilGroup.slice;
      drawcoils(currentgroup, state.getstate(currentgroup));
    }
    //Signal last
    for (int n=10; n<=13; n++)
    {
      CoilGroup currentgroup=CoilGroup.signal;
      drawcoils(currentgroup, state.getstate(currentgroup));
    }
  }
  float max_dimension()
  {
    return max_dimension;
  }

  void drawcoils(CoilGroup group, CoilGroupState state)
  {
    CoilGroupState modified_state;
    float current_sin;
    float current_cos;
    switch(group)
    {
    case freq:
      modified_state=new CoilGroupState(state);
      modified_state.current=-modified_state.current;
      coils[0].draw(rendertarget, state);
      coils[1].draw(rendertarget, modified_state);
      break;
    case phase:
      modified_state=new CoilGroupState(state);
      modified_state.current=-modified_state.current;
      coils[2].draw(rendertarget, state);
      coils[3].draw(rendertarget, modified_state);
      break;
    case slice:
      modified_state=new CoilGroupState(state);
      modified_state.current=-modified_state.current;
      coils[4].draw(rendertarget, state);
      coils[5].draw(rendertarget, modified_state);
      break;
    case RF:
      modified_state=new CoilGroupState(state);
      current_sin=sin(state.phase)*modified_state.current;
      current_cos=cos(state.phase)*modified_state.current;
      modified_state.current=current_cos;
      coils[6].draw(rendertarget, modified_state);
      coils[7].draw(rendertarget, modified_state);
      modified_state.current=current_sin;
      coils[8].draw(rendertarget, modified_state);
      coils[9].draw(rendertarget, modified_state);
      break;
    case signal:
      modified_state=new CoilGroupState(state);
      current_sin=sin(state.phase)*modified_state.current;
      current_cos=cos(state.phase)*modified_state.current;
      modified_state.current=current_cos;
      coils[10].draw(rendertarget, modified_state);
      coils[11].draw(rendertarget, modified_state);
      modified_state.current=current_sin;
      coils[12].draw(rendertarget, modified_state);
      coils[13].draw(rendertarget, modified_state);
      break;
    case primary:
      coils[14].draw(rendertarget, state);
      break;
    default:
      return;
    }
  }

  void drawinsidearrows(CoilGroup group, CoilGroupState state)
  {
    if (!state.showinsidearrows) {
      return;
    }
    //println("Insidearrows state: Visible=" + state.insidearrows_visible + ", Group=" + state.insidearrows_group + ", Magnitude=" + state.insidearrows_magnitude); 
    if (state.alpha>0 && abs(state.current)>0)
    {
      Arrow3D insidearrow=new Arrow3D(0);
      insidearrow.set_color(CoilGroup_Color(group));
      int arrowcount;
      float fraction;
      float magnitude;
      PVector origin;
      PVector change;
      PVector tip;
      switch(group)
      {
      case freq:
        arrowcount=5;
        for (int n=0; n<arrowcount; n++)
        {
          insidearrow.changediameter(coil_radius/4);
          fraction=(float)n/(float)(arrowcount-1);
          origin=new PVector(-coil_distance_from_center/2+coil_distance_from_center*fraction, 0, 0);
          if (state.current<0) {
            fraction=1-fraction;
          }
          change=new PVector(0, 0, coil_distance_from_center/10+abs(state.current)*fraction*coil_distance_from_center/5);
          tip=PVector.add(origin, change);
          insidearrow.set(origin, tip);
          insidearrow.draw(rendertarget);
          //println("Printing inside arrow " + n + ", magnitude " + PVector.sub(tip, origin).mag());
        }
        break;
      case phase:
        arrowcount=5;
        for (int n=0; n<arrowcount; n++)
        {
          insidearrow.changediameter(coil_radius/4);
          fraction=(float)n/(float)(arrowcount-1);
          origin=new PVector(0, -coil_distance_from_center/2+coil_distance_from_center*fraction, 0);
          if (state.current<0) {
            fraction=1-fraction;
          }
          change=new PVector(0, 0, coil_distance_from_center/10+abs(state.current)*fraction*coil_distance_from_center/5);
          tip=PVector.add(origin, change);
          insidearrow.set(origin, tip);
          insidearrow.draw(rendertarget);
          //println("Printing inside arrow " + n + ", magnitude " + PVector.sub(tip, origin).mag());
        }
        break;
      case slice:
        arrowcount=5;
        for (int n=0; n<arrowcount; n++)
        {
          insidearrow.changediameter(coil_radius/4);
          fraction=(float)n/(float)(arrowcount-1);
          origin=new PVector(0, 0, -coil_distance_from_center/2+coil_distance_from_center*fraction);
          if (state.current<0) {
            fraction=1-fraction;
          }
          change=new PVector(0, 0, coil_distance_from_center/10+abs(state.current)*fraction*coil_distance_from_center/5);
          tip=PVector.add(origin, change);
          insidearrow.set(origin, tip);
          insidearrow.draw(rendertarget);
          //println("Printing inside arrow " + n + ", magnitude " + PVector.sub(tip, origin).mag());
        }
        break;
      case RF:
        arrowcount=3;
        for (int n=0; n<arrowcount; n++)
        {
          insidearrow.changediameter(coil_radius/2);
          origin=new PVector(0, 0, coil_radius*2*(1-n)-0.00001);
          //origin=new PVector();//There's some problem with rendering the arrowheads when the origin is at zero
          magnitude=abs(coil_distance_from_center/2.5*state.current);
          change=new PVector(cos(state.phase)*magnitude, sin(state.phase)*magnitude, 0);
          tip=PVector.add(origin, change);
          //println("Setting RF " + origin + "" + tip);
          insidearrow.set(origin, tip);
          //println("Drawing RF");
          insidearrow.draw(rendertarget);
          //println("RF drawn");
          //println("Printing inside arrow, magnitude " + PVector.sub(tip, origin).mag());
        }
        break;
      case signal:
        arrowcount=4;
        for (int n=0; n<arrowcount; n++)
        {
          for (int m=0; m<arrowcount; m++)
          {
            insidearrow.changediameter(coil_radius/8);
            origin=new PVector((float)n/(float)(arrowcount-1)*coil_distance_from_center/2-coil_distance_from_center/4, (float)m/(float)(arrowcount-1)*coil_distance_from_center/2-coil_distance_from_center/4, 0);
            magnitude=abs(coil_distance_from_center/8*state.current);
            change=new PVector(cos(state.phase)*magnitude, sin(state.phase)*magnitude, 0);
            tip=PVector.add(origin, change);
            insidearrow.set(origin, tip);
            insidearrow.draw(rendertarget);
            //println("Printing inside arrow " + n + ", magnitude " + PVector.sub(tip, origin).mag());
          }
        }
        break;
      default:
        break;
      }
    }
  }
}

enum CoilOrientation
{
  x, 
    y, 
    z;
}
class Coil extends Model
{
  private Arrow3D arr;
  private ObjectColor c=new ObjectColor();
  private float pitch = 5;
  private float radius = 35;
  private int rotations = 10;
  private CoilOrientation o=CoilOrientation.z;
  Coil()
  {
    arr=new Arrow3D(radius/4);
    arr.name="Arrow for a coil";
    add_child(arr);
    //rotation_vector.z=0.0;
    set_orientation(CoilOrientation.z);
  }
  void set_orientation(CoilOrientation new_o)
  {
    o=new_o;
    switch(new_o)
    {
    case x:
      arr.set(new PVector(0, 0, 0), new PVector(1, 0, 0));
      break;
    case y:
      arr.set(new PVector(0, 0, 0), new PVector(0, 1, 0));
      break;
    case z:
      arr.set(new PVector(0, 0, 0), new PVector(0, 0, 1));
      break;
    default:
      break;
    }
  }
  void set_current(float c)
  {
    float current;
    if (c>1.0) {
      current=1.0;
    } else if (c<-1.0) {
      current=-1.0;
    } else {
      current=c;
    }
    float length=pitch*rotations*current; //maximum arrow length is the length of the coil, so half the arrow will be sticking outside the coil
    arr.changelength(length);
  }

  void draw(PGraphics rendertarget, CoilGroupState state)
  {    
    this.rendertarget=rendertarget;
    if (state.alpha<0.1) {
      return;
    }
    set_current(state.current);
    c.set_alpha(state.alpha);

    rendertarget.stroke(c.c);
    rendertarget.noFill();

    rendertarget.beginShape();
    int theta_steps=25;
    float theta_interval=2*PI/theta_steps;
    float theta;
    PVector start=new PVector();
    PVector finish=new PVector();
    for (int rotation = 0; rotation<rotations; rotation++)
    {
      for (int theta_inc=0; theta_inc<theta_steps; theta_inc++)
      {
        theta=(float)theta_inc*theta_interval;
        switch(o)
        {
        case z:
          finish.x=sin(theta)*radius;
          finish.y=cos(theta)*radius;
          finish.z=pitch*((float)(-rotations/2.0)+(float)rotation+(float)theta_inc/(float)theta_steps);
          break;
        case x:
          finish.z=sin(theta)*radius;
          finish.y=cos(theta)*radius;
          finish.x=pitch*((float)(-rotations/2.0)+(float)rotation+(float)theta_inc/(float)theta_steps);
          break;
        case y:
          finish.x=sin(theta)*radius;
          finish.z=cos(theta)*radius;
          finish.y=pitch*((float)(-rotations/2.0)+(float)rotation+(float)theta_inc/(float)theta_steps);
          break;
        }
        if (theta_inc>0)
        {
          add_modelspace_vertex(start);
          add_modelspace_vertex(finish);
        }
        start.x=finish.x;
        start.y=finish.y;
        start.z=finish.z;
      }
    }
    rendertarget.endShape();

    arr.set_alpha(state.alpha);
    if (abs(state.current)>0.0) {
      arr.draw(rendertarget);
    }

    //draw_modelspace_origin(10);
  }
}