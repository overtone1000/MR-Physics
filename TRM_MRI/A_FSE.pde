class Sequence_Parameters
{
  float TE;
  float TR;
  int grad_steps;
  int freq_steps;
  float gradient_time;
  int echoes_per_TR;
  float lead_time;
  int end_time;
  int total_repeats;
  void calculate()
  {
    gradient_time=TE/12;
    echoes_per_TR=floor((TR-gradient_time)/TE);
    lead_time=(float)TR/10.0;
    end_time=(int)((lead_time+TR)*((float)grad_steps/(float)echoes_per_TR));
    total_repeats=grad_steps/echoes_per_TR;
    println("End time = " + end_time);
  }
  boolean finished(int thismillis)
  {
    return thismillis>=end_time;
  }
  boolean precessing(int thismillis)
  {
    int usedmillis=thismillis;
    while(usedmillis>(TR+lead_time))
    {
     usedmillis-=TR+lead_time; 
    }
    return usedmillis>lead_time;
  }
}
class Repeat_Parameters
{
  Sequence_Parameters sequence;
  int TR_count;
  float time_left;
  float time_right;
  float start_time;
  Repeat_Parameters(Sequence_Parameters sequence)
  {
    this.sequence=sequence;
    set_TR_count(0);
  }
  void set_TR_count(int TR_count)
  {
    this.TR_count=TR_count;
    time_left=TR_count*(sequence.lead_time+sequence.TR);
    time_right=time_left+sequence.TR+sequence.lead_time;
    start_time=time_left+sequence.lead_time;
  }
  int get_grad_step(int index)
  {
    int retval;
    int stepsize=floor(index/sequence.total_repeats)+(index%(sequence.total_repeats/2))*(sequence.grad_steps/2)/sequence.echoes_per_TR;
    retval=sequence.grad_steps/2;//0 is the top, grad_steps-1 is the bottom, so start here
    if (!isEven(TR_count)) {
      retval=sequence.grad_steps/2-1;
      stepsize*=-1;
    }
    retval+=stepsize;
    //println("Input index " + index + ", output index " + retval + ", repeat count = " + TR_count + " total repeats = " + sequence.total_repeats);
    return retval;
  }
}
class Echo_Parameters
{
  Repeat_Parameters repeat;
  int echo_count;
  int this_TE_time;
  int this_TE_time_half;
  int this_TE_time_quarter;
  int this_TE_time_3quarter;
  int grad_step;
  int grad_index;
  float grad_magnitude;
  Echo_Parameters(Repeat_Parameters repeat)
  {
    this.repeat=repeat;
    set_echo_count(0);
  }
  void set_echo_count(int echo_count)
  {
    this.echo_count=echo_count;
    this_TE_time=(int)(repeat.start_time+(repeat.sequence.TE*(echo_count+1)));
    this_TE_time_half=this_TE_time-(int)(repeat.sequence.TE/2);
    this_TE_time_quarter=this_TE_time-(int)(repeat.sequence.TE/4);
    this_TE_time_3quarter=this_TE_time+(int)(repeat.sequence.TE/4);

    grad_step=repeat.TR_count*repeat.sequence.echoes_per_TR+echo_count;
    grad_index=repeat.get_grad_step(grad_step);
    grad_magnitude=lerp(1.0, -1.0, (float)grad_index/((float)repeat.sequence.grad_steps-1.0));
  }
}

class FSE_builder
{
  ScannerScene scene;
  SPD diagram;
  Encoding_Spaces spaces;
  ArrayList<SpacesState> spacesscene;
  ArrayList<MatrixEntry> matrixchanges;
  FSE_builder(ScannerScene scene, SPD diagram, Encoding_Spaces spaces)
  {
    this.scene=scene;
    this.diagram=diagram;
    this.spaces=spaces;
    spacesscene=new ArrayList<SpacesState>();
    matrixchanges=new ArrayList<MatrixEntry>();
  }

  Sequence_Parameters sequence = new Sequence_Parameters();

  void initialize(float TR, float TE, int grad_steps, int freq_steps)
  {
    sequence.TR=TR;
    sequence.TE=TE;
    sequence.grad_steps=grad_steps;
    sequence.freq_steps=freq_steps;

    diagram.TE=TE;
    diagram.TR=TR;
    diagram.grad_steps=grad_steps;

    sequence.calculate();

    build_ScannerScene();
    diagram_repeat.set_TR_count(0);
    build_diagram();
    build_spins(scene_spins);
    build_spaces(spaces);
  }

  void build_spins(SpinsScene scene)
  {
    if(scene.states.size()<=0){return;}
    SpinsState s=new SpinsState(scene.states.get(0)); //get the first state to propagage translation and size

    int grad_step_count=0;

    Repeat_Parameters repeat=new Repeat_Parameters(sequence);
    repeat.set_TR_count(0);
    Echo_Parameters echo=new Echo_Parameters(repeat);
    //println("Building spins.");
    //println("Grad steps = " + sequence.grad_steps);
    //println("Echoes_per_TR = " + sequence.echoes_per_TR);
    while (grad_step_count<sequence.grad_steps-1)
    {
      //90 degree pulse

      s=new SpinsState(s);
      s.millis=(int)repeat.start_time-(int)(sequence.gradient_time/2);
      s.excitation_magnitude=0.5;
      s.xz_angle=0;
      s.T2_variation_magnitude=0.0;
      scene.states.add(s);

      s=new SpinsState(s);
      s.millis=(int)repeat.start_time+(int)(sequence.gradient_time/2);
      s.y_angle=PI/2.0;
      s.xz_angle=0;
      s.excitation_magnitude=0;
      s.T2_variation_magnitude=1; //Leave it at 1.0 for FSE
      scene.states.add(s);

      float T1_decay_angle=PI/8.0;
      float T2_decay_angle=PI;

      for (int n=0; n<=sequence.echoes_per_TR; n++)
      {
        echo.set_echo_count(n);

        int TE_factor;
        if (n==0) {
          TE_factor=1;
        } else {
          TE_factor=2;
        }

        boolean showanotherexcitation=n<sequence.echoes_per_TR;

        //180 deg pulse
        s=new SpinsState(s);
        s.millis=echo.this_TE_time_half-(int)(sequence.gradient_time/2);
        if (showanotherexcitation) {
          s.excitation_magnitude=1;
        } else {
          s.excitation_magnitude=0;
        }
        s.y_angle-=T1_decay_angle*TE_factor;
        s.xz_angle=T2_decay_angle;
        scene.states.add(s);

        if (showanotherexcitation) //show decay (above) but not another excitation for the last echo 
        {
          s=new SpinsState(s);
          s.millis=echo.this_TE_time_half+(int)(sequence.gradient_time/2);
          s.excitation_magnitude=0;
          s.forced_xy_angle=-PI;
          scene.states.add(s);

          //Switch from forced xyangle to yangle
          s=new SpinsState(s);
          s.forced_xy_angle=0;
          s.y_angle+=PI;
          s.xz_angle=-T2_decay_angle;
          scene.states.add(s);

          T1_decay_angle*=-1; //Change the direction of the decay each time due to 180 degree pulse

          //println("Spins grad_step_count="+ grad_step_count+", time = " + s.millis + "TR_count = " + repeat.TR_count);
          grad_step_count++; //for spins, only iterate on grad_step_count if n<echoes_per_TR
        }
      }

      repeat.set_TR_count(repeat.TR_count+1);

      s=new SpinsState(s);
      s.millis=(int)repeat.time_left;
      s.xz_angle=0;
      s.y_angle+=PI/2.0;
      scene.states.add(s);

      s=new SpinsState(s);
      s.y_angle=0.0;
      scene.states.add(s);
    }
  }

  void build_spaces(Encoding_Spaces spaces)
  {
    spaces.set_matrix_size(sequence.freq_steps, sequence.grad_steps); //x is frequency, y is phase

    SpacesState state=new SpacesState(0);
    state.freq=0;
    state.phase=0;
    spacesscene.add(state);    

    //println("Building spins.");
    //println("Grad steps = " + sequence.grad_steps);
    //println("Echoes_per_TR = " + sequence.echoes_per_TR);

    Repeat_Parameters repeat=new Repeat_Parameters(sequence);
    repeat.set_TR_count(0);
    Echo_Parameters echo=new Echo_Parameters(repeat);
    int grad_step_count=0;
    while (grad_step_count<sequence.grad_steps-1)
    {

      for (int n=0; n<sequence.echoes_per_TR; n++)
      {
        if (grad_step_count>=sequence.grad_steps) {
          break;
        }

        echo.set_echo_count(n);
        //int grad_index=repeat.get_grad_step(floor(echo.grad_mag*(float)sequence.grad_steps/2.0));

        //Phase gradient
        state=new SpacesState(state);
        state.time=echo.this_TE_time_quarter-(int)(sequence.gradient_time/2);
        spacesscene.add(state);
        state=new SpacesState(state);
        state.time=echo.this_TE_time_quarter+(int)(sequence.gradient_time/2);
        //state.phase=echo.grad_mag*(float)sequence.grad_steps/2.0+0.5;
        //state.phase=(1.0+echo.grad_magnitude())/2.0*(float)sequence.grad_steps+0.5;
        state.phase=(sequence.grad_steps/2-echo.grad_index-0.5);
        //println("Created phase " + state.phase);
        spacesscene.add(state);

        //Frequency gradient before
        state=new SpacesState(state);
        state.time=echo.this_TE_time-(int)(sequence.gradient_time*1.5);
        spacesscene.add(state);
        state=new SpacesState(state);
        state.time+=(int)(sequence.gradient_time/2);
        state.freq=-1;
        spacesscene.add(state);
        //Frequency gradient during
        state=new SpacesState(state);
        state.time=echo.this_TE_time-(int)(sequence.gradient_time/2);
        state.freq=-1;
        spacesscene.add(state);

        //Matrix Entries
        for (int f=1; f<=sequence.freq_steps; f++)
        {
          MatrixEntry m=new MatrixEntry();
          m.time=(int)ceil(lerp(echo.this_TE_time-(int)(sequence.gradient_time/2), echo.this_TE_time+(int)(sequence.gradient_time/2), (float)f/float(sequence.freq_steps)));
          m.x=f-1;
          //m.y=(int)floor(sequence.grad_steps/2-state.phase);
          m.y=echo.grad_index;
          m.val=true;
          //println("Adding matrixchange entry " + m.x+ ","+m.y + "," + m.val+","+m.time);
          matrixchanges.add(m);
        }

        state=new SpacesState(state);
        state.time=echo.this_TE_time+(int)(sequence.gradient_time/2);
        state.freq=1;
        spacesscene.add(state);
        //Frequency gradient after
        state=new SpacesState(state);
        state.time=echo.this_TE_time+(int)(sequence.gradient_time*1);
        spacesscene.add(state);
        state=new SpacesState(state);
        state.time+=(int)(sequence.gradient_time/2);
        state.freq=0;
        spacesscene.add(state);

        //Rewind phase gradient
        state=new SpacesState(state);
        state.time=echo.this_TE_time_3quarter-(int)(sequence.gradient_time/2);
        spacesscene.add(state);
        state=new SpacesState(state);
        state.time=echo.this_TE_time_3quarter+(int)(sequence.gradient_time/2);
        state.phase=0;
        spacesscene.add(state);

        //println("Spaces grad_step_count="+ grad_step_count+", time = " + state.time + "TR_count = " + repeat.TR_count);
        grad_step_count++;
      }
      repeat.set_TR_count(repeat.TR_count+1);
    }
    state=new SpacesState(state);
    state.time=echo.this_TE_time_3quarter+(int)(sequence.gradient_time/2);
    state.phase=0;
    spacesscene.add(state);
  }

  void build_ScannerScene()
  {

    int grad_step_count=0;

    //println("Building spins.");
    //println("Grad steps = " + sequence.grad_steps);
    //println("Echoes_per_TR = " + sequence.echoes_per_TR);

    Repeat_Parameters repeat=new Repeat_Parameters(sequence);
    repeat.set_TR_count(0);
    Echo_Parameters echo=new Echo_Parameters(repeat);
    while (grad_step_count<sequence.grad_steps-1)
    {
      //90 degree pulse
      scene.add_SSandRF((int)repeat.start_time-(int)(sequence.gradient_time/2), (int)repeat.start_time-(int)(sequence.gradient_time/4), (int)repeat.start_time+(int)(sequence.gradient_time/4), (int)repeat.start_time+(int)(sequence.gradient_time/2),precession_rate);

      for (int n=0; n<sequence.echoes_per_TR; n++)
      {
        echo.set_echo_count(n);

        //180 deg pulse
        //scene.add_coil_action(this_TE_time_half-(int)(sequence.gradient_time/2), (int)sequence.gradient_time, CoilGroup.RF); //need to change this to a different function to include slice select
        scene.add_SSandRF(echo.this_TE_time_half-(int)(sequence.gradient_time/2), echo.this_TE_time_half-(int)(sequence.gradient_time/4), echo.this_TE_time_half+(int)(sequence.gradient_time/4), echo.this_TE_time_half+(int)(sequence.gradient_time/2),precession_rate);

        //Phase gradient
        //float grad_mag=lerp(1.0, -1.0, (float)(repeat.TR_count*sequence.echoes_per_TR+(n+1))/(float)(sequence.grad_steps));
        scene.add_coil_action(echo.this_TE_time_quarter-(int)(sequence.gradient_time/2), (int)sequence.gradient_time, CoilGroup.phase, echo.grad_magnitude);

        //Frequency gradient before
        scene.add_coil_action(echo.this_TE_time-(int)(sequence.gradient_time*1.5), (int)(sequence.gradient_time/2), CoilGroup.freq, -1);
        //Frequency gradient and signal
        float signalmag=exp(-(float)n/3.0);
        scene.add_freqandsignal(echo.this_TE_time-(int)(sequence.gradient_time/2), echo.this_TE_time-(int)(sequence.gradient_time/4), echo.this_TE_time+(int)(sequence.gradient_time/4), echo.this_TE_time+(int)(sequence.gradient_time/2), signalmag,precession_rate);
        //Frequency gradient after
        scene.add_coil_action(echo.this_TE_time+(int)(sequence.gradient_time*1), (int)(sequence.gradient_time/2), CoilGroup.freq, -1);

        //Rewind phase gradient
        scene.add_coil_action(echo.this_TE_time_3quarter-(int)(sequence.gradient_time/2), (int)sequence.gradient_time, CoilGroup.phase, -echo.grad_magnitude);

        //println("Scanner grad_step_count="+ grad_step_count+", time = " + echo.this_TE_time + "TR_count = " + repeat.TR_count);
        grad_step_count++;
      }
      repeat.set_TR_count(repeat.TR_count+1);
    }
  }

  void update_diagram(int thismillis)
  {
    //println("Checking diagram. Thismillis = " + thismillis + " and time_right = " + time_right);
    while (thismillis>=diagram.time_right)
    {
      //println("Changing TR count");
      diagram_repeat.set_TR_count(diagram_repeat.TR_count+1);
      //println("Rebuilding diagram.");
      build_diagram();
    }
  }

  void update_spaces(int thismillis)
  {
    //supply freq as a float from -1 to 1
    //supply phase as an int from -matrix_size_y/2 to +matrix_size_y/2
    //all_precession is just an angle 
    if (spacesscene.size()<2) 
    {
      spaces.update(0, 0, 0);
      return;
    }
    while (spacesscene.size()>2 && spacesscene.get(1).time<thismillis)
    {
      spacesscene.remove(0);
    }
    float prog=(float)(thismillis-spacesscene.get(0).time)/(float)(spacesscene.get(1).time-spacesscene.get(0).time);
    //println("prog="+prog);
    //println("time0="+spacesscene.get(0).time);
    //println("time1="+spacesscene.get(1).time);
    //println("thismillis="+thismillis);
    SpacesState current=new SpacesState(spacesscene.get(0), spacesscene.get(1), prog);
    spaces.update(current.freq, current.phase, 0.0);

    while (matrixchanges.size()>0 && matrixchanges.get(0).time<=thismillis)
    {
      spaces.ks.change_matrix_value(matrixchanges.get(0));
      matrixchanges.remove(0);
    }
  }

  Repeat_Parameters diagram_repeat=new Repeat_Parameters(sequence);
  void build_diagram()
  {
    diagram.rflabels.clear();

    diagram.time_left=diagram_repeat.time_left;
    diagram.start_time=diagram_repeat.start_time;
    diagram.time_right=diagram_repeat.time_right;

    diagram.curves[0].set_color(CoilGroup_Color(CoilGroup.RF)); //RF pulse is yellow
    diagram.curves[1].set_color(CoilGroup_Color(CoilGroup.slice)); //slice select (z) is blue
    diagram.curves[2].set_color(CoilGroup_Color(CoilGroup.phase)); //Phase gradient (y) is green
    diagram.curves[3].set_color(CoilGroup_Color(CoilGroup.freq)); //Freq gradient (x) is red
    diagram.curves[4].set_color(CoilGroup_Color(CoilGroup.signal)); //Signal is purple

    for (int n=0; n<5; n++)
    {
      diagram.curves[n].set_screen(diagram.curve_left, diagram.chart_right, diagram.get_curve_top(n), diagram.get_curve_top(n+1));
      diagram.curves[n].set_extrema(diagram.time_left, diagram.time_right, -1.0, 1.0);
      PVector points[]=new PVector[1];
      points[0]=new PVector(diagram.time_left, 0);
      diagram.curves[n].set_points(points);
    }

    Echo_Parameters echo=new Echo_Parameters(diagram_repeat);

    PVector points[]=new PVector[2];

    //90 degree pulse
    points=new PVector[2];
    diagram.curves[0].add_points(diagram.radio_wave(diagram.start_time, sequence.gradient_time, 0.5));
    points[0]=new PVector(diagram.start_time-sequence.gradient_time/2, 1);
    points[1]=new PVector(diagram.start_time+sequence.gradient_time/2, 0);
    diagram.curves[1].add_points(points);
    RF_label l=new RF_label();
    l.text="90";
    l.pos=(diagram.curves[0].curve_to_screen(new PVector(diagram.start_time+sequence.gradient_time/2, 0.5)));
    diagram.rflabels.add(l);
    for (int n=0; n<sequence.echoes_per_TR; n++)
    {
      echo.set_echo_count(n);
      if (echo.grad_index>=sequence.grad_steps) {
        break;
      }
      float this_TE_time=diagram.start_time+sequence.TE*(n+1);
      //Frequency gradient before
      points[0]=new PVector(this_TE_time-sequence.gradient_time*1.5, -1);
      points[1]=new PVector(this_TE_time-sequence.gradient_time, 0);
      diagram.curves[3].add_points(points);
      //Frequency gradient
      points[0]=new PVector(this_TE_time-sequence.gradient_time/2, 1);
      points[1]=new PVector(this_TE_time+sequence.gradient_time/2, 0);
      diagram.curves[3].add_points(points);      
      //Frequency gradient after
      points[0]=new PVector(this_TE_time+sequence.gradient_time, -1);
      points[1]=new PVector(this_TE_time+sequence.gradient_time*1.5, 0);
      diagram.curves[3].add_points(points);

      float signalmag=exp(-(float)n/3.0);
      //println("Signal " + n + " = " + signalmag);
      //Signal
      diagram.curves[4].add_points(diagram.radio_wave(this_TE_time, sequence.gradient_time, signalmag));

      //Phase gradient
      //float grad_mag=lerp(1.0, -1.0, (float)(diagram_repeat.TR_count*sequence.echoes_per_TR+(n+0.5))/(float)(sequence.grad_steps));

      points[0]=new PVector(this_TE_time-sequence.TE/4-sequence.gradient_time/2, echo.grad_magnitude);
      points[1]=new PVector(this_TE_time-sequence.TE/4+sequence.gradient_time/2, 0);
      diagram.curves[2].add_points(points);
      //Rewind gradient
      points[0]=new PVector(this_TE_time+sequence.TE/4-sequence.gradient_time/2, -echo.grad_magnitude);
      points[1]=new PVector(this_TE_time+sequence.TE/4+sequence.gradient_time/2, 0);
      diagram.curves[2].add_points(points);

      //180 degree pulse
      float this_TEhalf_time=this_TE_time-sequence.TE/2;
      diagram.curves[0].add_points(diagram.radio_wave(this_TEhalf_time, sequence.gradient_time, 1.0));
      l=new RF_label();
      l.text="180";
      l.pos=(diagram.curves[0].curve_to_screen(new PVector(this_TEhalf_time+sequence.gradient_time/2, 0.5)));
      diagram.rflabels.add(l);

      //Slice select gradient
      points[0]=new PVector(this_TEhalf_time-sequence.gradient_time/2, 1);
      points[1]=new PVector(this_TEhalf_time+sequence.gradient_time/2, 0);
      diagram.curves[1].add_points(points);
    }

    //Draw curves to the end.
    points=new PVector[1];
    points[0]=new PVector(diagram.time_right, 0);
    for (int n=0; n<diagram.curves.length; n++)
    {
      diagram.curves[n].add_points(points);
    }
  }
}