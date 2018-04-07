class Dipole extends Arrow3D
{
  boolean low_energy;
  float xz_angle_when_flipped;
  float base_xz_angle;
  boolean xz_delta_positive;
  float T2=1500;
  float probability_of_flip=0.005; // chance per second
  int time_flipped;
  int lastmillis;

  boolean flipped=false;

  Dipole(float size, float base_xz_angle)
  {
    super(size);
    this.base_xz_angle=base_xz_angle;
    this.xz_angle_when_flipped=base_xz_angle;
    this.xz_angle=base_xz_angle;
  }
  float xz_angle_exciting(int thismillis)
  {
    float e=exp(-(thismillis-time_flipped)/T2);

    if (low_energy)
    {
      if (xz_delta_positive)
      {
        return 2*PI-(2*PI-xz_angle_when_flipped)*e;
      } else
      {
        return xz_angle_when_flipped*e;
      }
    } else
    {
      if (xz_delta_positive)
      {
        return PI+(xz_angle_when_flipped-PI)*e;
      } else
      {
        return PI-(PI-xz_angle_when_flipped)*e;
      }
    }
  }
  float xz_angle_decaying(int thismillis)
  {
    float e=exp(-thismillis/T2);
    return base_xz_angle+(xz_angle_when_flipped-base_xz_angle)*e;
  }
  float xz_angle;

  void flip(int thismillis)
  {
    flipped=!flipped;

    xz_angle_when_flipped=xz_angle;

    time_flipped=thismillis;
    low_energy=!low_energy;
    xz_delta_positive=xz_angle_when_flipped>PI;
    if (abs(xz_angle_when_flipped-PI)<PI/20.0 && random(1)<0.5) {
      xz_delta_positive=!xz_delta_positive;
    }
    //
  }

  void force_flip_state(boolean flipstate)
  {
    if (flipped!=flipstate)
    {
      flip(0);
    }
  }

  void update(int thismillis, boolean exciting, boolean allowflips)
  {

    if (exciting) {
      xz_angle=xz_angle_exciting(thismillis);
    } else {
      xz_angle=xz_angle_decaying(thismillis);
    }

    float probability=probability_of_flip*exp((thismillis-lastmillis)/1000.0);
    if (allowflips && random(1.0)<probability) {
      flip(thismillis);
    }

    lastmillis=thismillis;
  }
}

class Quantum extends Model
{
  PVector origin=new PVector(0, 0.01, 0);
  Dipole sumvector;
  Dipole theones[];
  Dipole arrows[];
  Arrow3D mainmagnet;
  Arrow3D excitation;
  int grey_population_size=20;
  int red_population_size=grey_population_size/2;
  Quantum()
  {
    mainmagnet=new Arrow3D(20);
    mainmagnet.set_color(color(255, 255, 0, 100));
    excitation=new Arrow3D(20);
    excitation.set_color(color(255, 255, 0, 255));
    int size=10;

    arrows=new Dipole[grey_population_size*2];
    for (int n=0; n<grey_population_size; n++)
    {
      arrows[n]=new Dipole(size, ((float)n/(float)grey_population_size*2.0*PI)-PI);
      arrows[n].set_color(color(100));
      arrows[n].low_energy=false;
    }
    for (int n=0; n<grey_population_size; n++)
    {
      arrows[n+grey_population_size]=new Dipole(size, ((float)n/(float)grey_population_size*2.0*PI)-PI);
      arrows[n+grey_population_size].set_color(color(100));
      arrows[n+grey_population_size].low_energy=true;
    }
    theones=new Dipole[red_population_size];
    for (int n=0; n<red_population_size; n++)
    {
      theones[n]=new Dipole(size*1.3, ((float)n/(float)red_population_size*2*PI)-PI);
      theones[n].set_color(color(255, 0, 0, 255));
      theones[n].low_energy=true;
    }
    sumvector=new Dipole(size, 0);
    sumvector.set_color(color(255, 0, 0, 255));
  }

  void draw(PGraphics rendertarget, QuantumState state)
  {
    this.rendertarget=rendertarget;
    state.set_perspective(rendertarget);

    rendertarget.background(255);
    rendertarget.lights();
    rendertarget.directionalLight(200, 200, 255, -0.5, -1, -0.25);
    //rendertarget.camera();
    //Now draw everything
    rendertarget.noStroke();
    rendertarget.fill(155);

    rendertarget.beginShape(LINES);
    //Axes
    //X
    rendertarget.fill(255, 0, 0);
    rendertarget.stroke(255, 0, 0);
    add_modelspace_vertex(new PVector(-state.arrow_magnitude, 0, 0));
    add_modelspace_vertex(new PVector(state.arrow_magnitude, 0, 0));
    //Y
    rendertarget.fill(0, 255, 0);
    rendertarget.stroke(0, 255, 0);
    add_modelspace_vertex(new PVector(0, -state.arrow_magnitude, 0));
    add_modelspace_vertex(new PVector(0, state.arrow_magnitude, 0));
    //Z    
    rendertarget.fill(0, 0, 255);
    rendertarget.stroke(0, 0, 255);
    add_modelspace_vertex(new PVector(0, 0, -state.arrow_magnitude));
    add_modelspace_vertex(new PVector(0, 0, state.arrow_magnitude));
    rendertarget.endShape();


    if (state.draw_energy_rings)
    {

      float h=state.arrow_magnitude*cos(state.y_angle);
      float xy=state.arrow_magnitude*sin(state.y_angle);
      rendertarget.noFill();
      rendertarget.stroke(0);
      for (int m=-1; m<=2; m+=2) {
        float h2=h*m;
        rendertarget.beginShape();
        for (float theta=0; theta<=2*PI; theta+=2*PI/200.0)
        {
          PVector add=new PVector(sin(theta)*xy, h2, cos(theta)*xy);
          add_modelspace_vertex(add);
          //println("Adding + " + add);
        }
        rendertarget.endShape(CLOSE);
      }
    }

    if (state.draw_grey_dipoles)
    {
      for (int n=0; n<arrows.length; n++)
      {
        set_and_draw_dipole(arrows[n], state, color(100, 100, 100, state.grey_alpha), false);
        set_and_draw_dipole(arrows[n], state, color(100, 100, 100, state.grey_alpha), true);
      }
    }
    float oldmag=state.arrow_magnitude;
    state.arrow_magnitude*=1.01;

    if (state.draw_red_dipoles)
    {

      int numberflipped=(int)(state.T1*theones.length);
      for (int n=0; n<theones.length; n++)
      {
        theones[n].force_flip_state(false);
      }
      if (numberflipped>0) {
        if (numberflipped<theones.length)
        {
          for (int n=0; n<numberflipped; n++)
          {
            theones[n*theones.length/numberflipped].force_flip_state(true);
          }
        } else
        {
          for (int n=0; n<theones.length; n++)
          {
            theones[n].force_flip_state(true);
          }
        }
      }
      for (int n=0; n<theones.length; n++)
      {
        set_and_draw_dipole(theones[n], state, color(255, 0, 0, state.red_alpha), false);
        if(state.show_red_opposites){set_and_draw_dipole(theones[n], state, color(255, 0, 0, state.red_alpha), true);}
      }
    }
    state.arrow_magnitude=oldmag;

    if (state.draw_sum_vector)
    {
      sumvector.set_color(color(255, 0, 0, state.sum_vector_alpha));

      float arrow_length=state.arrow_magnitude*1.2;

      //Sets up vector in rotating frame of reference
      PVector sv_tip=new PVector();
      float xz_component=arrow_length*sin(state.y_angle)*(1-state.T2);
      sv_tip.x=xz_component*cos(state.xz_angle);
      sv_tip.z=xz_component*sin(state.xz_angle);
      sv_tip.y=arrow_length*cos(state.y_angle)*(0.5-state.T1)*2;

      //Adds displayed_precession angle to show precession in laboratory frame of reference
      PVector xz=new PVector(sv_tip.x, 0, sv_tip.z);
      float xz_angle=atan2(sv_tip.x, sv_tip.z)+state.displayed_precession_angle;
      sv_tip.x=xz.mag()*sin(xz_angle);
      sv_tip.z=xz.mag()*cos(xz_angle);

      sumvector.set(origin, sv_tip);   
      sumvector.draw(rendertarget);
    }
    if (state.draw_primary_magnet) {
      mainmagnet.set(origin, new PVector(0, state.arrow_magnitude, 0));
      mainmagnet.draw(rendertarget);
    }
    if (state.excitation_magnitude>0)
    {
      float x=sin(state.displayed_precession_angle)*state.arrow_magnitude*state.excitation_magnitude;
      float z=cos(state.displayed_precession_angle)*state.arrow_magnitude*state.excitation_magnitude;
      excitation.set(origin, new PVector(x, 0, z));
      excitation.draw(rendertarget);
    }
  }
  void set_and_draw_dipole(Dipole d, QuantumState state, color c, boolean invert_xz)
  {
    //d.update(state.millis, state.excitation_magnitude!=0.0, false);
    //d.update();

    float xzangle=d.xz_angle;
    xzangle*=state.T2;
    if (invert_xz)
    {
      xzangle+=PI;
    }

    //Sets up vector in rotating frame of reference
    PVector onetip=new PVector();
    float xz_component=state.arrow_magnitude*sin(state.y_angle);
    onetip.x=xz_component*cos(xzangle);
    onetip.z=xz_component*sin(xzangle);
    onetip.y=state.arrow_magnitude*cos(state.y_angle);
    if (!d.low_energy) {
      onetip.y=-onetip.y;
    }

    //Adds displayed_precession angle to show precession in laboratory frame of reference
    PVector xz=new PVector(onetip.x, 0, onetip.z);
    float xz_angle=atan2(onetip.x, onetip.z)+state.displayed_precession_angle;
    onetip.x=xz.mag()*sin(xz_angle);
    onetip.z=xz.mag()*cos(xz_angle);

    d.set_color(c);

    d.set(origin, onetip);   
    d.draw(rendertarget);
  }
}