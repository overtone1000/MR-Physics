class Spins extends Model
{
  PVector origin=new PVector(0, 0.01, 0);
  Arrow3D mainmagnet;
  Arrow3D excitation;
  Arrow3D arrows[];
  Spins()
  {
    mainmagnet=new Arrow3D(20);
    mainmagnet.set_color(color(255, 255, 0, 100));
    excitation=new Arrow3D(20);
    excitation.set_color(color(255, 255, 0, 255));
    arrows=new Arrow3D[5];
    for (int n=0; n<arrows.length; n++)
    {
      arrows[n]=new Arrow3D(10);
    }
  }  
  float rotation_rate=0*(2.0*PI)/1000.0;
  float calculate_rotation_Y(int thismillis)
  {
    return thismillis*rotation_rate;
  }

  void draw(PGraphics rendertarget, SpinsState state)
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
    float rot=calculate_rotation_Y(state.millis);
    float s_comp=state.arrow_magnitude*sin(rot);
    float c_comp=state.arrow_magnitude*cos(rot);
    rendertarget.fill(255, 0, 0);
    rendertarget.stroke(255, 0, 0);
    add_modelspace_vertex(new PVector(-c_comp, 0, -s_comp));
    add_modelspace_vertex(new PVector(c_comp, 0, s_comp));
    //Y
    rendertarget.fill(0, 255, 0);
    rendertarget.stroke(0, 255, 0);
    add_modelspace_vertex(new PVector(0, -state.arrow_magnitude, 0));
    add_modelspace_vertex(new PVector(0, state.arrow_magnitude, 0));
    //Z    
    rendertarget.fill(0, 0, 255);
    rendertarget.stroke(0, 0, 255);
    add_modelspace_vertex(new PVector(s_comp, 0, -c_comp));
    add_modelspace_vertex(new PVector(-s_comp, 0, c_comp));
    rendertarget.endShape();

    PVector tip;
    int baseline_arrow_brightness=100;
    for (int n=0; n<arrows.length; n++)
    {
      tip=new PVector();
      /*
      s.z_angle=PI;
       s.xy_angle=PI;
       s.T2_variation_magnitude=1.0;
       */
      tip.y=state.arrow_magnitude*cos(state.y_angle);
      float xz_component=state.arrow_magnitude*sin(state.y_angle);
      float relative_precession=state.xz_angle*((float)n-(float)(arrows.length/2))/(float)(arrows.length);
      tip.x=xz_component*cos(relative_precession);
      tip.z=xz_component*sin(relative_precession);

      //Forced additional rotation around z for showing T2 decay WITH rotations
      PVector current_xy_component=new PVector(tip.x, tip.y, 0);
      float current_xy_angle=atan2(tip.y, tip.x);

      tip.x=current_xy_component.mag()*cos(current_xy_angle+state.forced_xy_angle);
      tip.y=current_xy_component.mag()*sin(current_xy_angle+state.forced_xy_angle);
      
      //This adds displayed_precession_angle for absolute frame of reference
      PVector xz=new PVector(tip.x,0,tip.z);
      float xz_angle=atan2(tip.x,tip.z)+state.displayed_precession_angle;
      tip.x=xz.mag()*sin(xz_angle);
      tip.z=xz.mag()*cos(xz_angle);

      float col_lerp=state.T2_variation_magnitude*((float)n-(float)(arrows.length/2))/(float)(arrows.length/2);

      color c;
      int main=baseline_arrow_brightness+(int)((float)(255-baseline_arrow_brightness)*abs(col_lerp));
      int other=(int)lerp(baseline_arrow_brightness, 0, abs(col_lerp));
      if (col_lerp<0)
      {
        c=color(other, main, other);
      } else
      {
        c=color(main, other, other);
      }

      arrows[n].set_color(c);
      arrows[n].set(origin, tip);
      arrows[n].draw(rendertarget);
    }
    mainmagnet.set(origin, new PVector(0, state.arrow_magnitude, 0));
    mainmagnet.draw(rendertarget);
    if (state.excitation_magnitude>0)
    {
      float x=sin(state.displayed_precession_angle)*state.arrow_magnitude*state.excitation_magnitude;
      float z=cos(state.displayed_precession_angle)*state.arrow_magnitude*state.excitation_magnitude;
      excitation.set(origin, new PVector(x, 0, z));
      excitation.draw(rendertarget);
    }
  }
}