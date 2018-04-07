ArrayList<SpacesState> f_spacesscene;
ArrayList<MatrixEntry> f_matrixchanges;
int matrix_size=20;
float max_amplitude;

void build_Fourier_spaces1(int interval, boolean demo_instruments)
{
  build_Fourier_spaces1(interval, demo_instruments, 5.0);
}
void build_Fourier_spaces1(int interval, boolean demo_instruments, float oscillation_magnitude)
{  
  spaces=new Encoding_Spaces();
  spaces.set_matrix_size(matrix_size, matrix_size); //x is frequency, y is phase

  spaces.phase_oscillation_magnitude=oscillation_magnitude;
  spaces.frequency_oscillation_magnitude=oscillation_magnitude;

  f_spacesscene=new ArrayList<SpacesState>();
  f_matrixchanges=new ArrayList<MatrixEntry>();

  SpacesState state=new SpacesState(0);
  state.freq=0;
  state.phase=0;
  state.result_amplitude=max_amplitude;

  f_spacesscene.add(state);

  int demo_interval=interval*10;
  int time=0;

  for (int n=0; n<matrix_size/2; n++)
  {
    for (int m=0; m<=n; m++)
    { 
      add_a_spaces_state(n, m, time, interval);
      time+=interval;

      if (demo_instruments)
      {
        add_instrument_demo(n, m, time, demo_interval);      
        time+=demo_interval;
      }

      add_a_spaces_state(-n-1, -m-1, time, interval);
      time+=interval;

      add_a_spaces_state(n, -m-1, time, interval);
      time+=interval;

      add_a_spaces_state(-n-1, m, time, interval);
      time+=interval;

      if (m!=n)
      {
        add_a_spaces_state(m, n, time, interval);
        time+=interval;
        add_a_spaces_state(-m-1, -n-1, time, interval);
        time+=interval;
        add_a_spaces_state(m, -n-1, time, interval);
        time+=interval;
        add_a_spaces_state(-m-1, n, time, interval);
        time+=interval;
      }
    }
  }
  state=new SpacesState(time+interval);
  state.freq=0;
  state.phase=0;//matrix_size/2;
  state.result_amplitude=max_amplitude;
  f_spacesscene.add(state);
  state=new SpacesState(state);
  state.time=time+interval*10;
  f_spacesscene.add(state);
}

void build_Fourier_spaces2(int interval)
{
  spaces=new Encoding_Spaces();
  spaces.set_matrix_size(matrix_size, matrix_size); //x is frequency, y is phase

  spaces.phase_oscillation_magnitude=matrix_size/2;
  spaces.frequency_oscillation_magnitude=matrix_size/2;

  f_spacesscene=new ArrayList<SpacesState>();
  f_matrixchanges=new ArrayList<MatrixEntry>();

  SpacesState state=new SpacesState(0);
  state.freq=0;
  state.phase=0;
  state.result_amplitude=max_amplitude;

  f_spacesscene.add(state);

  float time=0;

  for (int n=matrix_size/2-1; n>=0; n--)
  {
    int points_this_loop=4*(2*n+1);
    float newinterval=(float)interval/(float)points_this_loop;
    if (n<matrix_size/2/10)
    {
      newinterval*=2;
    }
    if (n<matrix_size/2/5)
    {
      newinterval*=1.5;
    }
    println("This interval = " + newinterval);
    for (int m=-n; m<=n; m++)
    { 
      add_a_spaces_state(n, m, time, newinterval);
      time+=newinterval;
    }
    println("Time="+time);
    for (int m=-n+1; m<=n; m++)
    { 
      add_a_spaces_state(-m, n, time, newinterval);
      time+=newinterval;
    }
    println("Time="+time);
    for (int m=-n; m<=n+1; m++)
    { 
      add_a_spaces_state(-n-1, -m, time, newinterval);
      time+=newinterval;
    }
    println("Time="+time);
    for (int m=-n; m<=n; m++)
    { 
      add_a_spaces_state(m, -n-1, time, newinterval);
      time+=newinterval;
    }
    println("Time="+time);
  }
  state=new SpacesState((int)(time+interval));
  state.freq=0;
  state.phase=0;//matrix_size/2;
  state.result_amplitude=max_amplitude;
  f_spacesscene.add(state);
  state=new SpacesState(state);
  state.time=(int)(time+interval*10);
  f_spacesscene.add(state);
}

SpacesState get_a_spaces_state(int n, int m, int time)
{
  float x=(float)(n+0.5)/(float)(matrix_size-1.0)*2.0;
  float y=-0.5-(float)m;///(float)matrix_size;

  SpacesState state=new SpacesState(time);
  state.result_phase=0;
  state.result_amplitude=max_amplitude;
  state.freq=x;
  state.phase=y;

  return state;
}

void add_a_spaces_state(int n, int m, float time, float interval)
{
  //x is -1 to 1, where -1 and +1 are in the middle of the squares
  //y is 0 to matrix_size, where 0 and matrixzsize are at the edges (right? no, looks like edges)

  SpacesState state=get_a_spaces_state(n, m, (int)(time+interval/4.0));  
  f_spacesscene.add(state);
  state=new SpacesState(state);
  state.time=(int)(time+interval);
  f_spacesscene.add(state);

  MatrixEntry me;
  me=new MatrixEntry();
  me.time=(int)(time+interval/4.0);
  me.x=n+matrix_size/2;
  me.y=m+matrix_size/2;
  me.freq=state.freq;
  me.phase=state.phase;
  me.val=true;
  me.c=color(0, 0, 255, 255);
  f_matrixchanges.add(me);
}

void add_instrument_demo(int n, int m, int time, int interval)
{
  SpacesState state=get_a_spaces_state(n, m, time);
  state.result_phase=0;
  state.result_amplitude=max_amplitude;
  f_spacesscene.add(state);

  time+=interval/2.0;

  state=new SpacesState(state);
  state.time=time;
  state.result_phase=2*PI;
  f_spacesscene.add(state);
  state=new SpacesState(state);
  state.result_phase=0;
  f_spacesscene.add(state);

  time+=interval/4.0;

  state=new SpacesState(state);
  state.time=time;
  state.result_amplitude=0;
  f_spacesscene.add(state);

  time+=interval/4.0;

  state=new SpacesState(state);
  state.time=time;
  state.result_amplitude=max_amplitude;
  f_spacesscene.add(state);
}

Phase_and_Amp instruments;
Fourier f;
void setup_Fourier1()
{    
  x1=finaltarget.width/3;
  x2=finaltarget.width*2/3;

  int ymargin=finaltarget.height/10;
  y1=(finaltarget.height-x1)/2;
  y2=finaltarget.height-y1;
  y1-=ymargin;
  y2-=ymargin;

  max_amplitude=1.0;

  build_Fourier_spaces1(500, true, 5);

  PVector es_pos=new PVector(0, y1);
  PVector es_size=new PVector(x2, y2-y1);
  spaces.set_dimensions(es_pos, es_size);
  spaces.set_matrix_size(matrix_size, matrix_size);
  f=new Fourier(finaltarget.width/3, y2-y1);

  PVector instruments_size=new PVector((finaltarget.height-y2)*2, finaltarget.height-y2);
  PVector instruments_pos=new PVector(finaltarget.width/2.0-instruments_size.x/2.0, y2);

  instruments=new Phase_and_Amp(instruments_pos, instruments_size, max_amplitude);
}

void draw_Fourier1(int thismillis)
{

  SpacesState current;
  while (f_spacesscene.size()>=2 && f_spacesscene.get(1).time<thismillis)
  {
    f_spacesscene.remove(0);
  }
  if (f_spacesscene.size()>=2)
  {
    float lerp=((float)(thismillis-f_spacesscene.get(0).time))/((float)(f_spacesscene.get(1).time-f_spacesscene.get(0).time));
    current=new SpacesState(f_spacesscene.get(0), f_spacesscene.get(1), lerp);
  } else
  {
    current=f_spacesscene.get(0);
    if (thismillis>current.time) {
      exit();
    }
  }

  while (f_matrixchanges.size()>0 && f_matrixchanges.get(0).time<=thismillis)
  {
    spaces.ks.change_matrix_value(f_matrixchanges.get(0));
    f_matrixchanges.remove(0);
  }

  println(current.result_amplitude);

  spaces.update(current.freq, current.phase, 0);
  f.set(spaces.frequency_oscillations, spaces.phase_oscillations, current.result_amplitude, current.result_phase);
  //f.set(spaces.frequency_oscillations, spaces.phase_oscillations, max_amplitude, current.result_phase);

  finaltarget.beginDraw();
  spaces.draw(finaltarget);
  finaltarget.image(f.i, x2, y1);
  instruments.draw(finaltarget, current.result_phase, current.result_amplitude*max_amplitude);
  finaltarget.endDraw();
}

PImage starting_image;
PImage picture_to_show;
PImage reconstructed_image;
void setup_Fourier2()
{


  y1=finaltarget.width/3;
  y2=finaltarget.height-y1;

  x1=y1;
  int middlerowheight=y2-y1;

  starting_image=loadImage(photodir);
  starting_image.loadPixels();
  starting_image.resize(x1, y1);

  max_amplitude=starting_image.width*starting_image.height;

  picture_to_show=createImage(starting_image.width, starting_image.height, RGB);
  reconstructed_image=createImage(starting_image.width, starting_image.height, RGB);
  pixel_integral=new double[starting_image.width*starting_image.height];

  println(starting_image.width + ", " + starting_image.height);
  println(picture_to_show.width + ", " + picture_to_show.height);

  matrix_size=x1;
  //matrix_size=100;

  starting_image.filter(GRAY);

  int interval=(int)(60000.0/(matrix_size/2.0));
  //int interval=5000;

  println("Interval="+interval);
  build_Fourier_spaces2(interval);

  PVector es_pos=new PVector(0, 0);
  PVector es_size=new PVector(y1*2, y1);
  spaces.set_dimensions(es_pos, es_size);
  spaces.set_matrix_size(matrix_size, matrix_size);
  f=new Fourier(y1, y1);
  f.size=new PVector();
  f.size.y=y2;
  f.size.x=(y2*f.i.width/f.i.height);
  f.position=new PVector();
  f.position.x=(finaltarget.width-f.size.x)/2.0;
  f.position.y=y1;

  PVector instruments_size=new PVector(y2*2, y2);
  PVector instruments_pos=new PVector(finaltarget.width/2.0-instruments_size.x, y1);

  instruments=new Phase_and_Amp(instruments_pos, instruments_size, max_amplitude);
}

float scaled_amplitude(float amplitude)
{
  float retval;
  //retval=log(amplitude+1)/log(2.0);
  //retval=amplitude;
  retval=pow(amplitude, 0.35);
  return retval;
}

SpacesState preservedstate=new SpacesState(0);
void draw_Fourier2(int thismillis)
{
  boolean skipupdate=false;
  SpacesState current;
  while (f_spacesscene.size()>=2 && f_spacesscene.get(1).time<thismillis)
  {
    f_spacesscene.remove(0);
  }
  if (f_spacesscene.size()>=2)
  {
    float lerp=((float)(thismillis-f_spacesscene.get(0).time))/((float)(f_spacesscene.get(1).time-f_spacesscene.get(0).time));
    current=new SpacesState(f_spacesscene.get(0), f_spacesscene.get(1), lerp);
  } else
  {
    current=f_spacesscene.get(0);
    if (thismillis>current.time) {
      //skipupdate=true;
      println("Finished.");
      exit();
    }
  }

  if (!skipupdate)
  {
    //finaltarget.loadPixels();
    picture_to_show.loadPixels();
    reconstructed_image.loadPixels();

    while (f_matrixchanges.size()>0 && f_matrixchanges.get(0).time<=thismillis)
    {
      println("Matrix changes @ " + millis());
      spaces.update(f_matrixchanges.get(0).freq, f_matrixchanges.get(0).phase, preservedstate.result_phase);
      update_image_to_show(spaces.frequency_oscillations, spaces.phase_oscillations, preservedstate);
      float s=scaled_amplitude(preservedstate.result_amplitude);
      if (s>spaces.ks.max_matrixcolor_intensity) {
        spaces.ks.max_matrixcolor_intensity=s;
      }

      f.set(spaces.frequency_oscillations, spaces.phase_oscillations, s, preservedstate.result_phase);
      f_matrixchanges.get(0).c=color(s*255);
      spaces.ks.change_matrix_value(f_matrixchanges.get(0));
      f_matrixchanges.remove(0);
    }

    picture_to_show.updatePixels();
    reconstructed_image.updatePixels();
  }
  //spaces.update(current.freq, current.phase, current.result_phase);

  //f.set(spaces.frequency_oscillations, spaces.phase_oscillations, preservedstate.result_amplitude, preservedstate.result_phase);

  //finaltarget.background(0);
  finaltarget.background(25,0,25);
  spaces.draw_kspace(finaltarget,false,true);

  //instruments.draw(finaltarget, preservedstate.result_phase, max_amplitude*preservedstate.result_amplitude);

  finaltarget.image(picture_to_show, 0, 0);
  finaltarget.noFill();
  finaltarget.stroke(255);
  finaltarget.rect(f.position.x, f.position.y, f.size.x, f.size.y);
  finaltarget.image(f.i, f.position.x, f.position.y, f.size.x, f.size.y);
  finaltarget.image(reconstructed_image, y1*2, 0);

}

double pixel_integral[];

void update_image_to_show(float x_oscillations, float y_oscillations, SpacesState current)
{  

  float real_integral=0;
  float imaginary_integral=0;
  for (int y=0; y<picture_to_show.height; y++)
  {
    int y_index_contribution=y*picture_to_show.width;
    float y_comp_angle=2*PI*((float)y-(float)(picture_to_show.height-1)/2.0)/(float)(picture_to_show.height-1)*y_oscillations;
    for (int x=0; x<picture_to_show.width; x++)
    {
      float x_comp_angle=2*PI*((float)x-(float)(picture_to_show.width-1)/2.0)/(float)(picture_to_show.width-1)*x_oscillations;

      color source_color=starting_image.pixels[y_index_contribution+x];
      float r=source_color >> 16 & 0xFF;
      float g=source_color >> 8 & 0xFF;
      float b=source_color & 0xFF;
      float grey=(r+g+b)/3.0/255.0;

      color phase_color = phase_to_color(x_comp_angle+y_comp_angle);
      float pr=phase_color >> 16 & 0xFF;
      float pg=phase_color >> 8 & 0xFF;
      float pb=phase_color & 0xFF;

      color final_color=color(pr*grey, pg*grey, pb*grey);

      real_integral+=grey*cos(x_comp_angle+y_comp_angle);
      imaginary_integral+=grey*sin(x_comp_angle+y_comp_angle);

      picture_to_show.pixels[y_index_contribution+x]=final_color;
    }
  }


  current.result_amplitude=pow(pow(real_integral, 2)+pow(imaginary_integral, 2), 0.5)/max_amplitude;
  //println(pow(pow(real_integral, 2)+pow(imaginary_integral, 2), 0.5) + ", " + max_amplitude);
  //println(current.result_amplitude+","+current.result_phase);
  current.result_phase=-atan2(imaginary_integral, real_integral); //(opposite,adjacent)


  double max_pixel=0;
  double min_pixel=0;
  double avg_pixel=0;

  //boolean initialize=true;

  for (int y=0; y<picture_to_show.height; y++)
  {
    int y_index_contribution=y*picture_to_show.width;
    float y_comp_angle=2*PI*((float)y-(float)(picture_to_show.height-1)/2.0)/(float)(picture_to_show.height-1)*y_oscillations;
    for (int x=0; x<picture_to_show.width; x++)
    {
      float x_comp_angle=2*PI*((float)x-(float)(picture_to_show.width-1)/2.0)/(float)(picture_to_show.width-1)*x_oscillations;

      double value=current.result_amplitude*(cos(x_comp_angle+y_comp_angle+current.result_phase)+1)/2.0;

      pixel_integral[y_index_contribution+x]+=value;
      avg_pixel+=pixel_integral[y_index_contribution+x];
      /*
      if (initialize)
       {
       max_pixel=pixel_integral[y_index_contribution+x];
       min_pixel=pixel_integral[y_index_contribution+x];
       initialize=false;
       } else
       {
       avg_pixel+=pixel_integral[y_index_contribution+x];
       if (pixel_integral[y_index_contribution+x]>max_pixel) {
       max_pixel=pixel_integral[y_index_contribution+x];
       }
       if (pixel_integral[y_index_contribution+x]<min_pixel)
       {
       min_pixel=pixel_integral[y_index_contribution+x];
       }
       }
       */
    }
  }

  double pixel_std_dev=0;
  avg_pixel=avg_pixel/pixel_integral.length;
  for (int n=0; n<pixel_integral.length; n++)
  {
    pixel_std_dev+=pow((float)(avg_pixel-pixel_integral[n]), 2);
  }
  pixel_std_dev=pow((float)(pixel_std_dev)/(float)(pixel_integral.length), 0.5);

  min_pixel=avg_pixel-pixel_std_dev*2.0;
  max_pixel=avg_pixel+pixel_std_dev*2.0;

  for (int n=0; n<pixel_integral.length; n++)
  {
    float val=(float)((pixel_integral[n]-min_pixel)/(max_pixel-min_pixel));
    if (val>1.0) {
      val=1.0;
    } else if (val<0.0) {
      val=0.0;
    }
    val*=255;
    reconstructed_image.pixels[n]=color(val, val, val);
  }
}