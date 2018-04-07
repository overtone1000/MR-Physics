static class TimeInterpolation
{
  static float linear(int thismillis, int startmillis, int stopmillis)
  {
    float linear_fraction = (float)(thismillis-startmillis)/(float)(stopmillis-startmillis);
    if (linear_fraction>1.0) {
      linear_fraction= 1.0;
    } else if (linear_fraction<0.0) {
      linear_fraction= 0.0;
    }
    return linear_fraction;
  }
  static float sinusoidal(int thismillis, int startmillis, int stopmillis)
  {
    return (sin((linear(thismillis, startmillis, stopmillis)-0.5)*PI))/2.0+0.5;
  }
}

enum InterpolationType
{
  linear, 
    sinusoidal;
}
class PanelState
{
  int millis;
  PVector panel_position;
  PVector panel_size;
  PVector rotation;
  String name;
  InterpolationType interp_type=InterpolationType.sinusoidal;
  PanelState(String statename, int time)
  {
    name=statename;
    millis=time;
    panel_position=new PVector();
    rotation=new PVector();
    panel_size=new PVector(1, 1, 1);
  }
  PanelState(PanelState start, PanelState stop, float lerp_mag)
  {
    panel_position=PVector.lerp(start.panel_position, stop.panel_position, lerp_mag);
    rotation=PVector.lerp(start.rotation, stop.rotation, lerp_mag);
    panel_size=PVector.lerp(start.panel_size, stop.panel_size, lerp_mag);
  }
  PanelState(PanelState original)
  {
    millis=original.millis;
    panel_position=original.panel_position;
    rotation=original.rotation;
    panel_size=original.panel_size;
    interp_type=original.interp_type;
    name=original.name;
  }
  float intrinsic_scale_factor(PGraphics rendertarget)
  {
    return min((float)panel_size.x/rendertarget.width, (float)panel_size.y/rendertarget.height);
  }
  void set_perspective(PGraphics rendertarget)
  {   
    //rendertarget.translate(translation.x, translation.y, translation.z);

    rendertarget.rotateX(rotation.x);
    rendertarget.rotateY(rotation.y);
    rendertarget.rotateZ(rotation.z);
    //float scale=scale(rendertarget);
    float scale=this.intrinsic_scale_factor(rendertarget);//just overload intrinsic_scale_factor with a better one that takes panel size into account;
    //println("Scale="+scale);

    rendertarget.scale(scale, scale, scale);
  }
}

class QuantumState extends SpinsState
{
  boolean draw_energy_rings;
  boolean draw_grey_dipoles;
  boolean draw_red_dipoles;
  boolean draw_sum_vector;
  boolean draw_primary_magnet;
  boolean draw_excitation;
  boolean show_red_opposites;
  
  float hide_alpha;
  
  float T1; //ranges 0 to 1. 0 is unexcited. 1 is after a 180 degree pulse
  float T2; //ranges from 0 to 1. 1 is completely decayed. 0 is completely coherent 

  float grey_alpha;
  float red_alpha;
  float sum_vector_alpha;
  QuantumState(String statename, int time)
  {
    super(statename, time);
    draw_energy_rings=false;
    draw_grey_dipoles=false;
    draw_red_dipoles=false;
    draw_sum_vector=false;
    draw_primary_magnet=false;
    show_red_opposites=false;
    hide_alpha=0;
    T1=0;
    T2=1;
  }
  QuantumState(QuantumState original)
  {
    super(original);
    this.draw_energy_rings=original.draw_energy_rings;
    this.draw_grey_dipoles=original.draw_grey_dipoles;
    this.draw_red_dipoles=original.draw_red_dipoles;
    this.draw_sum_vector=original.draw_sum_vector;
    this.grey_alpha=original.grey_alpha;
    this.red_alpha=original.red_alpha;
    this.sum_vector_alpha=original.sum_vector_alpha;
    this.T1=original.T1;
    this.T2=original.T2;
    this.draw_primary_magnet=original.draw_primary_magnet;
    this.hide_alpha=original.hide_alpha;
    this.show_red_opposites=original.show_red_opposites;
  }
  QuantumState(QuantumState start, QuantumState stop, float lerp_mag)
  {
    super(start, stop, lerp_mag);
    this.draw_energy_rings=start.draw_energy_rings;
    this.draw_primary_magnet=start.draw_primary_magnet;
    this.show_red_opposites=start.show_red_opposites;
    this.draw_sum_vector=start.draw_sum_vector;
    
    this.grey_alpha=lerp(start.grey_alpha, stop.grey_alpha, lerp_mag);
    this.red_alpha=lerp(start.red_alpha, stop.red_alpha, lerp_mag);
    this.sum_vector_alpha=lerp(start.sum_vector_alpha, stop.sum_vector_alpha, lerp_mag);
    this.T1=lerp(start.T1, stop.T1, lerp_mag);
    this.T2=lerp(start.T2, stop.T2, lerp_mag);
    this.hide_alpha=lerp(start.hide_alpha,stop.hide_alpha,lerp_mag);
    
    this.draw_grey_dipoles=false;
    if (this.grey_alpha>10 && (start.draw_grey_dipoles || stop.draw_grey_dipoles)) {
      this.draw_grey_dipoles=true;
    }

    this.draw_red_dipoles=false;
    if (this.red_alpha>10 && (start.draw_red_dipoles || stop.draw_red_dipoles)) {
      this.draw_red_dipoles=true;
    }

    this.draw_sum_vector=false;
    if (this.sum_vector_alpha>10 && (start.draw_sum_vector || stop.draw_sum_vector)) {
      this.draw_sum_vector=true;
    }
  }
}

class SpinsState extends PanelState
{
  float excitation_magnitude=0;
  float y_angle=0;
  float xz_angle=0;
  float forced_xy_angle=0; //for showing rotations WITH a component of T2 decay
  float displayed_precession_angle=0;
  float T2_variation_magnitude=1; //-1.0 to 1.0 to change arrow colors to represent spins. For spin echo, just keep at 1. 
  PVector default_perspective=new PVector(-9*PI/8, 3*PI/4, 0);
  float arrow_magnitude=200.0;
  SpinsState(String statename, int time)
  {
    super(statename, time);
    this.rotation=default_perspective.copy();
  }
  SpinsState(SpinsState original)
  {
    super(original);
    this.y_angle=original.y_angle;
    this.xz_angle=original.xz_angle;
    this.forced_xy_angle=original.forced_xy_angle;
    this.T2_variation_magnitude=original.T2_variation_magnitude;
    this.arrow_magnitude=original.arrow_magnitude;
    this.excitation_magnitude=original.excitation_magnitude;
    this.displayed_precession_angle=original.displayed_precession_angle;
  }
  SpinsState(SpinsState start, SpinsState stop, float lerp_mag)
  {
    super(start, stop, lerp_mag);
    this.y_angle=lerp(start.y_angle, stop.y_angle, lerp_mag);
    this.xz_angle=lerp(start.xz_angle, stop.xz_angle, lerp_mag);
    this.forced_xy_angle=lerp(start.forced_xy_angle, stop.forced_xy_angle, lerp_mag);
    this.T2_variation_magnitude=lerp(start.T2_variation_magnitude, stop.T2_variation_magnitude, lerp_mag);
    this.arrow_magnitude=lerp(start.arrow_magnitude, stop.arrow_magnitude, lerp_mag);
    //this.excitation_magnitude=lerp(start.excitation_magnitude,stop.excitation_magnitude,lerp_mag);
    this.excitation_magnitude=start.excitation_magnitude;
    this.displayed_precession_angle=lerp(start.displayed_precession_angle, stop.displayed_precession_angle, lerp_mag);
  }

  float intrinsic_scale_factor(PGraphics rendertarget)
  {
    //println("Arrow magnitude = " + arrow_magnitude);
    return (min(panel_size.x, panel_size.y))/arrow_magnitude/2.5; //scaled to 1
  }
}

class SpacesState
{
  //supply freq as a float from -1 to 1
  //supply phase as an int from -matrix_size_y/2 to +matrix_size_y/2
  int time;
  float freq;
  float phase;
  float result_phase;
  float result_amplitude;
  SpacesState(int time)
  { 
    this.time=time;
  }
  SpacesState(SpacesState start, SpacesState stop, float lerp_mag)
  {
    this.time=(int)lerp(start.time, stop.time, lerp_mag);
    this.freq=lerp(start.freq, stop.freq, lerp_mag);
    this.phase=lerp(start.phase, stop.phase, lerp_mag);
    this.result_phase=lerp(start.result_phase, stop.result_phase, lerp_mag);
    this.result_amplitude=lerp(start.result_amplitude, stop.result_amplitude, lerp_mag);
  }
  SpacesState(SpacesState original)
  {
    this.time=original.time;
    this.freq=original.freq;
    this.phase=original.phase;
    this.result_phase=original.result_phase;
    this.result_amplitude=original.result_amplitude;
  }
}

class CoilGroupState
{
  float alpha=1;
  float current=0.0;
  float phase=0.0;
  boolean showinsidearrows=false;
  CoilGroupState() {
  }
  CoilGroupState(CoilGroupState start, CoilGroupState stop, float lerp_mag)
  {
    alpha=lerp(start.alpha, stop.alpha, lerp_mag);
    current=lerp(start.current, stop.current, lerp_mag);
    phase=lerp(start.phase, stop.phase, lerp_mag);
    showinsidearrows=start.showinsidearrows || stop.showinsidearrows;
  }
  CoilGroupState(CoilGroupState original)
  {
    this.alpha=original.alpha;
    this.current=original.current;
    this.phase=original.phase;
    this.showinsidearrows=original.showinsidearrows;
  }
}
static enum CoilGroup
{
  RF, 
    freq, 
    phase, 
    slice, 
    signal, 
    primary;
}
class ScannerState extends PanelState
{
  CoilGroupState coilstates[]=new CoilGroupState[coilgroup_count];
  CoilGroupState getstate(CoilGroup group)
  {
    switch(group)
    {
    case RF:
      return coilstates[0];
    case freq:
      return coilstates[1];
    case phase:
      return coilstates[2];
    case slice:
      return coilstates[3];
    case signal:
      return coilstates[4];
    case primary:
      return coilstates[5];
    default:
      return coilstates[5];
    }
  }
  Scanner s;
  ScannerState(String statename, int time, Scanner parent_s)
  {
    super(statename, time);
    this.s=parent_s;
    for (int n=0; n<6; n++)
    {
      coilstates[n]=new CoilGroupState();
    }
  }
  ScannerState(ScannerState original)
  {
    super(original);
    this.s=original.s;
    for (int n=0; n<coilgroup_count; n++)
    {
      coilstates[n]=new CoilGroupState(original.coilstates[n]);
    }
  }
  ScannerState(ScannerState start, ScannerState stop, float lerp_mag)
  {
    super(start, stop, lerp_mag);
    this.s=start.s;
    for (int n=0; n<coilgroup_count; n++)
    {
      coilstates[n]=new CoilGroupState(start.coilstates[n], stop.coilstates[n], lerp_mag);
    }
    this.name=start.name;
  }
  float intrinsic_scale_factor(PGraphics rendertarget) 
  {
    return (min(panel_size.x, panel_size.y))/s.max_dimension(); //This worked for FSE show but not scanner orientation //***The problem is that super(statename,time) calls this function before s is defined.
    //return (min(panel_size.x, panel_size.y))/s.max_dimension()/1.2; //Scanner orientation
  }
  void set_coils(CoilGroup group, float alpha, float current, float phase)
  {
    CoilGroupState s=getstate(group);
    s.alpha=alpha;
    s.current=current;
    s.phase=phase;
  }
  void set_inside_arrows(CoilGroup group, boolean show)
  {
    getstate(group).showinsidearrows=show;
  }
  void set_rotation_by_coilgroup(CoilGroup group)
  {
    switch(group)
    {
    case freq:
      rotation=new PVector(PI/2, 0, 0);
      //name="Frequency";
      break;
    case phase:
      rotation=new PVector(PI, PI/2, 0);
      //name="Phase";
      break;
    case slice:
      rotation=new PVector(3*PI/4, PI/4, 0);
      //name="Slice";
      break;
    case RF:
      rotation=new PVector(PI, PI/4, 0);
      //name="RF";
      break;
    case signal:
      rotation=new PVector(PI, 0, 0);
      //name="Signal";
      break;
    case primary:
      rotation=new PVector(3*PI/4, PI/4, 0);
      //name="Primary";
      break;
    default:
      rotation=new PVector();
      //name="unnamed";
      break;
    }
  }
}