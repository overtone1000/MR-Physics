class QuantumScene
{
  ArrayList<QuantumState> states=new ArrayList<QuantumState>();
  QuantumScene()
  {
    QuantumState state=new QuantumState("Quantum State", 0);
    state.panel_position=new PVector(0, 0);
    state.panel_size=new PVector(rendertarget.width, rendertarget.height);
    state.interp_type=InterpolationType.linear;
    state.arrow_magnitude=200;
    //quantum_state.y_angle=PI/2.0;//Angle from the Z axis. Should be 54 degrees, right?
    state.y_angle=0.955276877; //http://www.okbu.net/chemistry/mrjordan/inorganic1/nmr/NMR.HTML, 54 degrees 44 arcminutes
    //quantum_state.xz_angle=PI/4.0;//Set so they are evenly distributed
    state.excitation_magnitude=0;
    state.T2_variation_magnitude=1; //Leave it at 1.0 for FSE
    state.draw_grey_dipoles=true;
    state.grey_alpha=0;
    state.T1=0.5;
    state.draw_primary_magnet=false;
    state.draw_sum_vector=true;
    state.sum_vector_alpha=255;
    states.add(state);

    state=new QuantumState(state);
    state.name="Grey alpha = 255";
    state.millis=2000;
    state.grey_alpha=255;
    state.red_alpha=0;
    states.add(state);

    state=new QuantumState(state);
    state.name="Grey alpha = 255";
    state.millis=8000;
    state.draw_red_dipoles=true;
    state.grey_alpha=255;
    state.red_alpha=0;
    states.add(state);

    state=new QuantumState(state);
    state.name="Red alpha = 255";
    state.millis+=13000;
    state.red_alpha=255;
    states.add(state);

    int magnet_time_on=state.millis=17000;
    
    float real_T1=4000;
    float real_T2=2000;
    int time_for_relaxation=(int)(real_T1*4);
    
    //Turn on magnet and show initial equilibrium
    state=new QuantumState(state);
    state.name="Turn on magnet";
    state.millis=magnet_time_on;
    state.red_alpha=255;
    state.draw_primary_magnet=true;
    states.add(state);
    
    state=add_a_decay(state,real_T1,real_T2,0,1,time_for_relaxation); 

    //Show an excitation then a decay with reds only
    state=new QuantumState(state);
    state.name="Hide greys";
    state.millis=45000;
    state.grey_alpha=0;
    states.add(state);
    
    state=new QuantumState(state);
    state.name="Done hiding greys";
    state.millis=56000;
    state.draw_grey_dipoles=false;
    states.add(state);
    
    state=add_excitation(state,0.5,0.5,false);    
    state=add_a_decay(state,real_T1,real_T2,0,1,time_for_relaxation);
    
    //Now show what the greys are doing during an excitation
     state=new QuantumState(state);
    state.name="Show greys, hide reds";
    state.millis+=1000;
    state.grey_alpha=255;
    state.red_alpha=0;
    state.draw_grey_dipoles=true;
    states.add(state);
    
    state=new QuantumState(state);
    state.name="Done hiding reds";
    state.millis+=1000;
    state.draw_red_dipoles=false;
    states.add(state);
        
    state=add_excitation(state,0.5,0.5,false);    
    state=add_a_decay(state,real_T1,real_T2,0,1,time_for_relaxation);

    //Show T1 weighting in the extreme
    state=new QuantumState(state);
    state.name="Show reds only again";
    state.millis+=1000;
    state.grey_alpha=0;
    state.red_alpha=255;
    state.draw_red_dipoles=true;
    states.add(state);
    
    state=new QuantumState(state);
    state.name="Show reds only again2";
    state.millis+=2000;
    state.draw_grey_dipoles=false;
    states.add(state);
    
    state=add_excitation(state,0.5,0.5,false);
    state=add_a_decay(state,MAX_FLOAT,real_T2,0.5,1,time_for_relaxation);
    
    state=new QuantumState(state);
    state.name="Add opposites";
    state.millis+=0;
    state.sum_vector_alpha=255;
    states.add(state);
    state=new QuantumState(state);
    state.name="Sum alpha fade";
    state.millis+=500;
    state.sum_vector_alpha=0;
    states.add(state);
    
    state=add_excitation(state,0.5,0.5,true);
    state=add_a_decay(state,MAX_FLOAT,real_T2,0.5,1,time_for_relaxation);

    state=new QuantumState(state);
    state.name="End hold";
    state.millis+=5000;
    state.T2=1;
    states.add(state);
  }
  
  QuantumState add_excitation(QuantumState startstate, float magnitude, float final_T1, boolean show_red_opposites)
  {
    QuantumState state=new QuantumState(startstate);
    state.name="Get hidden";
    state.millis+=100;
    state.hide_alpha=1.0;
    states.add(state);

    state=new QuantumState(state);
    state.name="Excitation start";
    state.millis+=100;
    state.excitation_magnitude=magnitude;
    states.add(state);

    state=new QuantumState(state);
    state.name="Excitation stop1";
    state.millis+=5000;
    state.T1=final_T1;
    state.T2=0;
    states.add(state);

    state=new QuantumState(state);
    state.name="Excitation stop2";
    state.millis+=100;
    state.excitation_magnitude=0;
    state.show_red_opposites=show_red_opposites;
    states.add(state);
    
    state=new QuantumState(state);
    state.name="Undo hidden";
    state.millis+=100;
    state.excitation_magnitude=0;
    state.hide_alpha=0.0;
    states.add(state);
    
    return state;
  }
  QuantumState add_a_decay(QuantumState startstate, float real_T1, float real_T2, float final_T1_val, float final_T2_val, int time_for_relaxation)
  {
    QuantumState state=new QuantumState(startstate);
    
    int starttime= state.millis;
    float startT1=state.T1;
    float startT2=state.T2;
    
    int decaypoints=10;
    for (int n=0; n<=decaypoints; n++)
    {
      state=new QuantumState(state);
      state.name="Decay " + n;
      state.millis=starttime+n*time_for_relaxation/decaypoints;
      state.T1=exp(-(float)(state.millis-starttime)/real_T1)*startT1;
      state.T2=1-((1-startT2)*exp(-(float)(state.millis-starttime)/real_T2));
      states.add(state);
    }
    
    state=new QuantumState(state);
    state.name="T1 relaxed in magnet, done";
    state.millis=starttime+time_for_relaxation;
    state.T1=final_T1_val;
    state.T2=final_T2_val;
    states.add(state);
    
    return state;
  }
  float get_xz_angle(int thismillis)
  {
    return 2*PI*(1-exp(-(float)thismillis/20000));
  }
  QuantumState currentstate(int thismillis)
  {    
    while (states.size()>1 && thismillis>states.get(1).millis) {
      states.remove(0);
      println("Starting state " + states.get(0).name);
    }
    if (states.size()>1)
    {
      float along;
      switch(states.get(0).interp_type)
      {
      case linear:
        along= TimeInterpolation.linear(thismillis, states.get(0).millis, states.get(1).millis);
        break;
      case sinusoidal:
        along= TimeInterpolation.sinusoidal(thismillis, states.get(0).millis, states.get(1).millis);
        break;
      default:
        along= TimeInterpolation.sinusoidal(thismillis, states.get(0).millis, states.get(1).millis);
        break;
      }
      //println("Interpolating." + along+ ","+states.get(n).millis + ","+states.get(n+1).millis+","+thismillis);        
      QuantumState retval=new QuantumState(states.get(0), states.get(1), along);
      retval.millis=thismillis;
      return retval;
    } else {
      return states.get(0);
    }
  }
  boolean finished(int thismillis)
  {
    return thismillis>states.get(states.size()-1).millis;
  }
}

class SpinsScene
{
  Spins sp=new Spins();
  PGraphics rendertarget;
  ArrayList<SpinsState> states=new ArrayList<SpinsState>();
  SpinsScene()
  {
    //rendertarget=createGraphics(1280, 720, P3D);
  }
  void initialize(PVector translation, PVector size)
  {
    states.clear();
    rendertarget=createGraphics((int)size.x, (int)size.y, P3D);
    println(size.x +","+ size.y);
    SpinsState s=new SpinsState("Start", 0);
    s.panel_position=translation;
    s.panel_size=new PVector(size.x, size.y);
    //rotation is set to default by SpinsState initialization
    s.y_angle=0;
    s.xz_angle=0;
    s.T2_variation_magnitude=0.0;
    s.interp_type=InterpolationType.linear;
    states.add(s);
  }
  boolean finished(int thismillis)
  {
    return thismillis>states.get(states.size()-1).millis;
  }
  SpinsState currentstate(int thismillis)
  {
    while (states.size()>1 && thismillis>states.get(1).millis) {
      states.remove(0);
      //println("Removed an old state");
    }
    if (states.size()>1)
    {
      float along;
      switch(states.get(0).interp_type)
      {
      case linear:
        along= TimeInterpolation.linear(thismillis, states.get(0).millis, states.get(1).millis);
        break;
      case sinusoidal:
        along= TimeInterpolation.sinusoidal(thismillis, states.get(0).millis, states.get(1).millis);
        break;
      default:
        along= TimeInterpolation.sinusoidal(thismillis, states.get(0).millis, states.get(1).millis);
        break;
      }
      //println("Interpolating." + along+ ","+states.get(n).millis + ","+states.get(n+1).millis+","+thismillis);        
      SpinsState retval=new SpinsState(states.get(0), states.get(1), along);
      retval.millis=thismillis;
      return retval;
    } else {
      return states.get(0);
    }
  }
  void draw(PGraphics maintarget, SpinsState state)
  {
    //Terrible for framerate
    //rendertarget.width=(int)current.panel_size.x;
    //rendertarget.height=(int)current.panel_size.y;

    maintarget.noFill();
    maintarget.stroke(0);

    rendertarget.ortho();
    rendertarget.beginDraw(); //only to be done by the top level
    rendertarget.camera(0, 0, (rendertarget.height/2.0) / tan(PI*30.0 / 180.0), 0, 0, 0, 0, 1, 0);
    sp.draw(rendertarget, state);
    rendertarget.endDraw();
    //scale(state.panel_size.x/(float)rendertarget.width,state.panel_size.y/(float)rendertarget.height);
    //float scale=state.scale(rendertarget);
    float x=state.panel_position.x+(state.panel_size.x-rendertarget.width)/2;
    float y=state.panel_position.y+(state.panel_size.y-rendertarget.height)/2;
    //x=state.panel_position.x;
    //y=state.panel_position.y;
    //println("X change = " + (state.panel_size.x-rendertarget.width*scale));
    //println("Y change = " + (state.panel_size.y-rendertarget.height*scale));

    maintarget.image(rendertarget, x, y);
    //scale(1,1,1);
    maintarget.hint(DISABLE_DEPTH_TEST);
    maintarget.noFill();
    maintarget.stroke(0);
    maintarget.rect(state.panel_position.x, state.panel_position.y, state.panel_size.x, state.panel_size.y);
    //stroke(color(0, 0, 0, 255));
    //fill(color(0, 0, 0, 255));
    //textAlign(CENTER, TOP);
    //text("Scanner", state.panel_position.x+state.panel_size.x/10, state.panel_position.y+state.panel_size.y/20);
    maintarget.hint(ENABLE_DEPTH_TEST);
  }
  void draw(PGraphics maintarget, int thismillis)
  {
    SpinsState current=currentstate(thismillis);
    this.draw(maintarget, current);
  }
  void draw(PGraphics maintarget, int thismillis, PVector newposition, float precession_angle)
  {
    SpinsState current=currentstate(thismillis);
    current.panel_position=newposition;
    current.displayed_precession_angle=precession_angle;
    this.draw(maintarget, current);
  }
}

class ScannerScene
{
  Scanner s;
  PGraphics rendertarget;
  ArrayList<ScannerState> states=new ArrayList<ScannerState>();
  ScannerState currentstate(int thismillis)
  {
    while (states.size()>1 && thismillis>states.get(1).millis) {
      states.remove(0);
      //println("Removed an old state");
    }
    if (states.size()>1)
    {
      float along;
      switch(states.get(0).interp_type)
      {
      case linear:
        along= TimeInterpolation.linear(thismillis, states.get(0).millis, states.get(1).millis);
        break;
      case sinusoidal:
        along= TimeInterpolation.sinusoidal(thismillis, states.get(0).millis, states.get(1).millis);
        break;
      default:
        along= TimeInterpolation.sinusoidal(thismillis, states.get(0).millis, states.get(1).millis);
        break;
      }
      //println("Interpolating." + along+ ","+states.get(n).millis + ","+states.get(n+1).millis+","+thismillis);        
      ScannerState retval=new ScannerState(states.get(0), states.get(1), along);
      retval.millis=thismillis;
      currentname=states.get(0).name;
      nextname=states.get(1).name;
      currenttime=states.get(0).millis;
      nexttime=states.get(1).millis;
      return retval;
    } else {
      nextname="None.";
      nexttime=0;
      return states.get(0);
    }
  }
  ScannerScene()
  {
    s=new Scanner();
    rendertarget=createGraphics(fullresx, fullresy, P3D);
  }

  int movetime=750;
  int coilchangetime=500;

  void initialize(PVector translation, PVector size)
  {
    ScannerState s=new ScannerState("Initialization", 0, this.s);
    s.panel_position=translation;
    s.panel_size=new PVector(size.x, size.y);
    states.add(s);
  }
  void add_coil_action(int startmillis, int durationmillis, CoilGroup group)
  {
    add_coil_action(startmillis, durationmillis, group, 1.0);
  }
  void add_coil_action(int startmillis, int durationmillis, CoilGroup group, float mag)
  {
    //println("Getting previous state.  States:" + states.size());
    ScannerState adjusted_state=new ScannerState(states.get(states.size()-1));
    //println("Initialized newstate.");
    adjusted_state.millis=startmillis-coilchangetime-movetime;
    states.add(new ScannerState(adjusted_state)); //Keep the name, translation, scale from the prior states

    adjusted_state.name=group + " 0";
    adjusted_state.millis=startmillis-coilchangetime;
    adjusted_state.set_rotation_by_coilgroup(group);
    adjusted_state.set_coils(CoilGroup.freq, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.phase, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.slice, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.RF, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.signal, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.primary, 0, 0, 0);
    adjusted_state.set_inside_arrows(group, true);
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 1";
    adjusted_state.millis=startmillis;
    adjusted_state.set_coils(group, 1, mag, 0);
    adjusted_state.interp_type=InterpolationType.linear;
    states.add(new ScannerState(adjusted_state));

    float phasechange=2*PI/1000*durationmillis;
    adjusted_state.name=group + " 2";
    adjusted_state.millis=startmillis+durationmillis;
    adjusted_state.set_coils(group, 1, mag, phasechange);
    adjusted_state.interp_type=InterpolationType.sinusoidal;
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 3";
    adjusted_state.millis=startmillis+durationmillis+coilchangetime;
    adjusted_state.set_coils(group, 0, 0, phasechange);
    states.add(new ScannerState(adjusted_state));
  }
  void add_freqandsignal(int millis_freqgrad_on, int millis_signal_on, int millis_signal_off, int millis_freqgrad_off, float signalmag, float prec_rate)
  {
    //println("Getting previous state.  States:" + states.size());
    ScannerState adjusted_state=new ScannerState(states.get(states.size()-1));
    //println("Initialized newstate.");
    String group="Frequency Gradient and Signal";
    adjusted_state.millis=millis_freqgrad_on-coilchangetime-movetime;
    states.add(new ScannerState(adjusted_state)); //Keep the name, translation, scale from the prior states

    adjusted_state.name=group + " 0";
    adjusted_state.millis=millis_freqgrad_on-coilchangetime;
    adjusted_state.set_rotation_by_coilgroup(CoilGroup.freq);
    adjusted_state.set_coils(CoilGroup.freq, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.phase, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.slice, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.RF, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.signal, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.primary, 0, 0, 0);
    adjusted_state.set_inside_arrows(CoilGroup.freq, true);
    adjusted_state.interp_type=InterpolationType.sinusoidal;
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 1";
    adjusted_state.millis=millis_freqgrad_on;
    adjusted_state.set_coils(CoilGroup.freq, 1, 1, 0);
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 2";
    adjusted_state.millis=millis_freqgrad_on+coilchangetime;
    adjusted_state.set_rotation_by_coilgroup(CoilGroup.signal);
    adjusted_state.set_coils(CoilGroup.signal, 0, 0, 0);
    states.add(new ScannerState(adjusted_state));

    float phasechange=prec_rate*(millis_signal_off-millis_signal_on);  
    adjusted_state.name=group + " 3";
    adjusted_state.millis=millis_signal_on;
    adjusted_state.set_coils(CoilGroup.signal, 1, 0, 0);
    adjusted_state.set_inside_arrows(CoilGroup.signal, true);
    adjusted_state.interp_type=InterpolationType.linear;
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 4";
    adjusted_state.millis=(millis_signal_on+millis_signal_off)/2;
    adjusted_state.set_coils(CoilGroup.signal, 1, signalmag, phasechange/2.0);   
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 5";
    adjusted_state.millis=millis_signal_off;
    adjusted_state.set_coils(CoilGroup.signal, 1, 0, phasechange);
    adjusted_state.interp_type=InterpolationType.sinusoidal;
    adjusted_state.set_inside_arrows(CoilGroup.signal, false);
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 6";
    adjusted_state.millis=millis_signal_off+coilchangetime;
    adjusted_state.set_rotation_by_coilgroup(CoilGroup.freq);
    adjusted_state.set_coils(CoilGroup.signal, 0, 0, phasechange);
    adjusted_state.set_inside_arrows(CoilGroup.signal, false);
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 7";
    adjusted_state.millis=millis_freqgrad_off+coilchangetime;
    adjusted_state.set_coils(CoilGroup.signal, 0, 0, phasechange);
    adjusted_state.set_coils(CoilGroup.freq, 0, 0, 0);
    adjusted_state.set_inside_arrows(CoilGroup.freq, false);

    states.add(new ScannerState(adjusted_state));
  }

  void add_SSandRF(int millis_SSgrad_on, int millis_RF_on, int millis_RF_off, int millis_SSgrad_off, float prec_rate)
  {
    //println("Getting previous state.  States:" + states.size());
    ScannerState adjusted_state=new ScannerState(states.get(states.size()-1));
    //println("Initialized newstate.");
    String group="Frequency Gradient and Signal";
    adjusted_state.millis=millis_SSgrad_on-coilchangetime-movetime;
    states.add(new ScannerState(adjusted_state)); //Keep the name, translation, scale from the prior states

    adjusted_state.name=group + " 0";
    adjusted_state.millis=millis_SSgrad_on-coilchangetime;
    adjusted_state.set_rotation_by_coilgroup(CoilGroup.slice);
    adjusted_state.set_coils(CoilGroup.freq, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.phase, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.slice, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.RF, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.signal, 0, 0, 0);
    adjusted_state.set_coils(CoilGroup.primary, 0, 0, 0);
    adjusted_state.set_inside_arrows(CoilGroup.slice, true);
    adjusted_state.interp_type=InterpolationType.sinusoidal;
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 1";
    adjusted_state.millis=millis_SSgrad_on;
    adjusted_state.set_coils(CoilGroup.slice, 1, 1, 0);
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 2";
    adjusted_state.millis=millis_SSgrad_on+coilchangetime;
    //adjusted_state.set_rotation_by_coilgroup(CoilGroup.RF);
    adjusted_state.set_coils(CoilGroup.RF, 0, 0, 0);
    states.add(new ScannerState(adjusted_state));

    float phasechange=prec_rate*(millis_RF_off-millis_RF_on);  
    adjusted_state.name=group + " 3";
    adjusted_state.millis=millis_RF_on;
    adjusted_state.set_coils(CoilGroup.RF, 1, 0, 0);
    adjusted_state.set_inside_arrows(CoilGroup.RF, true);
    adjusted_state.interp_type=InterpolationType.linear;
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 4";
    adjusted_state.millis=(millis_RF_on+millis_RF_off)/2;
    adjusted_state.set_coils(CoilGroup.RF, 1, 1, phasechange/2.0);   
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 5";
    adjusted_state.millis=millis_RF_off;
    adjusted_state.set_coils(CoilGroup.RF, 1, 0, phasechange);
    adjusted_state.interp_type=InterpolationType.sinusoidal;
    adjusted_state.set_inside_arrows(CoilGroup.RF, false);
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 6";
    adjusted_state.millis=millis_RF_off+coilchangetime;
    //adjusted_state.set_rotation_by_coilgroup(CoilGroup.slice);
    adjusted_state.set_coils(CoilGroup.RF, 0, 0, phasechange);
    adjusted_state.set_inside_arrows(CoilGroup.RF, false);
    states.add(new ScannerState(adjusted_state));

    adjusted_state.name=group + " 7";
    adjusted_state.millis=millis_SSgrad_off+coilchangetime;
    adjusted_state.set_coils(CoilGroup.RF, 0, 0, phasechange);
    adjusted_state.set_coils(CoilGroup.slice, 0, 0, 0);
    adjusted_state.set_inside_arrows(CoilGroup.slice, false);

    states.add(new ScannerState(adjusted_state));
  }

  void add_test(ScannerScene scene, int startmillis, int durationmillis)
  {
    ScannerState start;
    ScannerState finish;

    start=new ScannerState("Start", startmillis, this.s);
    finish=new ScannerState("Finish", durationmillis, this.s);

    float xchange=100;
    float ychange=200;

    start.panel_position=new PVector(0, 0);
    //finish.panel_position=new PVector(0,0);
    finish.panel_position=new PVector(xchange, ychange);

    start.rotation=new PVector(0, 0, 0);
    finish.rotation=new PVector(PI/2, PI, 0);
    //start.rotation=finish.rotation;

    start.panel_size=new PVector(rendertarget.width, rendertarget.height);
    finish.panel_size=new PVector(rendertarget.width-xchange*1.5, rendertarget.height-ychange*2);
    //start.scale=finish.scale;

    start.set_coils(CoilGroup.freq, 1, 0.5, 0);
    start.set_coils(CoilGroup.phase, 1, 0.25, 0);
    start.set_coils(CoilGroup.slice, 1, 1.0, 0);
    start.set_coils(CoilGroup.RF, 1, 0.25, 0);
    start.set_coils(CoilGroup.signal, 1, -0.25, 0);
    start.set_coils(CoilGroup.primary, 0, 1, 0);

    finish.set_coils(CoilGroup.freq, 1, -0.5, 0);
    finish.set_coils(CoilGroup.phase, 0, -0.25, 0);
    finish.set_coils(CoilGroup.slice, 0, -1.0, 0);
    finish.set_coils(CoilGroup.RF, 0, -0.25, 0);
    finish.set_coils(CoilGroup.signal, 0, 1, 0);
    finish.set_coils(CoilGroup.primary, 1, -1, 0);

    scene.states.add(start);
    scene.states.add(finish);
  }
  boolean finished(int thismillis)
  {
    return thismillis>states.get(states.size()-1).millis;
  }
  String currentname="";
  int currenttime=0;
  String nextname="";
  int nexttime=0;
  void draw(PGraphics maintarget, int thismillis)
  {
    ScannerState current=currentstate(thismillis);

    //Terrible for framerate
    //rendertarget.width=(int)current.panel_size.x;
    //rendertarget.height=(int)current.panel_size.y;

    rendertarget.beginDraw(); //only to be done by the top level
    rendertarget.camera(0, 0, (rendertarget.height/2.0) / tan(PI*30.0 / 180.0), 0, 0, 0, 0, 1, 0);
    s.draw(rendertarget, current);
    rendertarget.endDraw();
    //scale(current.panel_size.x/(float)rendertarget.width,current.panel_size.y/(float)rendertarget.height);
    //float scale=current.scale(rendertarget);
    float x=current.panel_position.x+(current.panel_size.x-rendertarget.width)/2;
    float y=current.panel_position.y+(current.panel_size.y-rendertarget.height)/2;
    //x=current.panel_position.x;
    //y=current.panel_position.y;
    //println("X change = " + (current.panel_size.x-rendertarget.width*scale));
    //println("Y change = " + (current.panel_size.y-rendertarget.height*scale));
    maintarget.image(rendertarget, x, y);
    //scale(1,1,1);

    maintarget.hint(DISABLE_DEPTH_TEST);
    maintarget.noFill();
    maintarget.stroke(0);
    maintarget.rect(current.panel_position.x, current.panel_position.y, current.panel_size.x, current.panel_size.y);
    //stroke(color(0, 0, 0, 255));
    //fill(color(0, 0, 0, 255));
    //textAlign(CENTER, TOP);
    //text("Scanner", current.panel_position.x+current.panel_size.x/10, current.panel_position.y+current.panel_size.y/20);
    maintarget.hint(ENABLE_DEPTH_TEST);
  }
}