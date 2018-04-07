class RF_label
{
  String text;
  PVector pos;
}
class SPD
{
  ArrayList<RF_label> rflabels=new ArrayList<RF_label>();
  String labels[];
  curve curves[];
  float chart_left;
  float chart_right;
  float chart_top;
  float chart_bottom;
  float curve_left;
  float text_x;
  float textmargin=10;

  float time_left;
  float time_right;
  float start_time;
  float TE;
  float TR;
  int TR_count;
  int grad_steps;

  SPD()
  {
    curves=new curve[5];
    curves[0]=new curve(curvetype.line); //RF
    curves[1]=new curve(curvetype.bar); //grad_slice
    curves[2]=new curve(curvetype.bar); //grad_phase
    curves[3]=new curve(curvetype.bar); //grad_freq
    curves[4]=new curve(curvetype.line); //signal
    labels=new String[6];
    labels[0]="RF";
    labels[1]="Slice Select Gradient";
    labels[2]="Phase Gradient";
    labels[3]="Frequency Gradient";
    labels[4]="Signal";
    labels[5]="Time";
  }
  void set_dimensions(float left, float right, float top, float bottom)
  {
    chart_left=left;
    chart_right=right;
    chart_top=top;
    chart_bottom=bottom;
    curve_left=chart_left+textWidth(labels[1])+textmargin;
    text_x=(chart_left+curve_left)/2;
  }
  void build()
  {
    for (int n=0; n<5; n++)
    {
      curves[n].set_screen(curve_left, chart_right, get_curve_top(n), get_curve_top(n+1));
      curves[n].set_extrema(0, 60000, -1.0, 1.0);
      //Need to set points...
      PVector points[]=new PVector[5];
      points[0]=new PVector(0, 0);
      points[1]=new PVector(10000, -0.5);
      points[2]=new PVector(30000, 1);
      points[3]=new PVector(35000, -1);
      points[4]=new PVector(60000, 0.5);
      curves[n].set_points(points);
    }

    time_left=0;
    time_right=60000;
    TE=15000;
    start_time=0;
    curves[4].set_points(radio_wave(15000, 3000, 1.0));
    curves[0].set_points(radio_wave_half(30000, 6000, 1.0));
  }
  
  PVector[] radio_wave(float time, float delta_time, float magnitude)
  {
    int points=51; //use an odd number so there's a middle...
    int wave_oscillations=10;
    PVector[] retval=new PVector[points];
    for (int n=0; n<points; n++)
    {
      float thistime=time+delta_time*((float)n/(float)(points-1)-0.5);
      float pseudo_x=(thistime-time)/delta_time;
      float thisval=cos(pseudo_x*(wave_oscillations*PI));
      thisval*=((cos(pseudo_x*2*PI)+1)/2);
      thisval*=magnitude;
      retval[n]=new PVector(thistime, thisval);
      //println(retval[n] + "," + delta_time + "," + n + "," + points + "," + (n/(points-1)-1/2));
    }
    return retval;
  }
  PVector[] radio_wave_half(float time, float delta_time, float magnitude)
  {
    delta_time=delta_time/2;
    int points=51; //use an odd number so there's a middle...
    int wave_oscillations=10;
    PVector[] retval=new PVector[points];
    for (int n=0; n<points; n++)
    {
      float thistime=time+delta_time*((float)n/(float)(points-1));
      float pseudo_x=(thistime-time)/delta_time;
      float thisval=cos(pseudo_x*(wave_oscillations*PI));
      thisval*=((cos(pseudo_x*PI)+1)/2);
      thisval*=magnitude;
      retval[n]=new PVector(thistime, thisval);
      //println(retval[n] + "," + delta_time + "," + n + "," + points + "," + (n/(points-1)-1/2));
    }
    return retval;
  }
  float get_curve_top(int curve)
  {
    return chart_top+(chart_bottom-chart_top)/6*curve; //use 6, 5 curves and 1 x-axis labels
  }
  float get_curve_middle(int curve)
  {
    return (get_curve_top(curve)+get_curve_bottom(curve))/2;
  }
  float get_curve_bottom(int curve)
  {
    return get_curve_top(curve+1);
  }
  float time_to_x(float time)
  {
    return curve_left+(chart_right-curve_left)/(time_right-time_left)*(time-time_left);
  }
  void draw_x_axis(PGraphics rendertarget)
  {
    rendertarget.stroke(0); //time is black
    rendertarget.fill(0); // time is black
    rendertarget.textAlign(CENTER, TOP);
    float middle=get_curve_middle(5);
    rendertarget.line(curve_left, middle, chart_right, middle);
    //println("Start time1 = " + start_time);
    if (start_time<time_left) {
      start_time=time_left;
    }
    //println("Start time2 = " + start_time);
    //Zero Label
    rendertarget.text("0", time_to_x(start_time), middle+1);
    //TE Labels
    for (float t=start_time+TE; t<time_right; t+=TE)
    {
      rendertarget.text("TE", time_to_x(t), middle+1);
    }

    //TE/2 Labels
    for (float t=start_time+TE/2.0; t<time_right; t+=TE)
    {
      rendertarget.text("TE/2", time_to_x(t), middle+1);
    }
  }
  void draw(PGraphics rendertarget, int thismillis)
  {
    for (int n=0; n<5; n++)
    {
      //println("Drawing curve " + n);
      curves[n].draw(rendertarget);
      rendertarget.stroke(curves[n].get_color());
      rendertarget.fill(curves[n].get_color());
      rendertarget.textAlign(RIGHT, CENTER);
      rendertarget.text(labels[n], curve_left-textmargin/2, get_curve_middle(n));
    }
    //println("Drawing x axis");
    draw_x_axis(rendertarget);
    float timex=time_to_x(thismillis);
    //println("Timex="+timex);
    rendertarget.line(timex, chart_top, timex, chart_bottom);
    for (int n=0; n<rflabels.size(); n++)
    {
      rendertarget.stroke(curves[0].get_color());
      rendertarget.fill(curves[0].get_color());
      rendertarget.textAlign(LEFT, CENTER);
      rendertarget.text(rflabels.get(n).text, rflabels.get(n).pos.x, rflabels.get(n).pos.y);
    }
  }
  void draw_FSE(PGraphics rendertarget,int thismillis)
  {
    //println(thismillis);
    //println(time_right);
    draw(rendertarget,thismillis);
  }
}

enum curvetype
{
  bar, 
    line;
}
class curve
{
  color c;
  float curve_left;
  float curve_right;
  float curve_top;
  float curve_bottom;
  float y_min=0;
  float y_max=1;
  float x_min=0;
  float x_max=1;
  PVector points[]=new PVector[0];
  PVector screenpoints[];
  float screen_y_zero=0;
  curvetype type;
  curve(curvetype t)
  {
    type=t;
  }
  void calc()
  {
    screenpoints=new PVector[points.length];
    for (int n=0; n<points.length; n++)
    {
      screenpoints[n]=curve_to_screen(points[n]);
    }
    screen_y_zero=(curve_bottom+curve_top)/2;
  }
  PVector curve_to_screen(PVector curvepoint)
  {
    PVector retval =new PVector();
    retval.x=curve_left+(curve_right-curve_left)/(x_max-x_min)*(curvepoint.x-x_min);
    retval.y=curve_bottom+(curve_top-curve_bottom)/(y_max-y_min)*(curvepoint.y-y_min);
    return retval;
  }
  void set_color(color c)
  {
    this.c=c;
  }
  color get_color()
  {
    return c;
  }
  void set_screen(float left, float right, float top, float bottom)
  {
    curve_left=left;
    curve_right=right;
    curve_top=top;
    curve_bottom=bottom;
    calc();
  }
  void set_extrema(float xmin, float xmax, float ymin, float ymax)
  {
    x_max=xmax;
    x_min=xmin;
    y_max=ymax;
    y_min= ymin;
    if (x_max==x_min) {
      x_max+=Float.MIN_VALUE;
    }
    if (y_max==y_min) {
      y_max+=Float.MIN_VALUE;
    }
  }
  void set_points(PVector[] points)
  {
    this.points=points;
    calc();
  }
  void add_points(PVector[] newpoints)
  {
    ArrayList<PVector> p=new ArrayList<PVector>();
    if (this.points.length==0) {
      this.points = new PVector[1];
      this.points[0]=new PVector();
    }
    for (int n=0; n<this.points.length; n++)
    {
      p.add(this.points[n]);
    }
    for (int n=0; n<newpoints.length; n++)
    {
      p.add(newpoints[n]);
    }
    this.points=p.toArray(this.points);
    calc();
  }
  void draw(PGraphics rendertarget)
  {
    switch(type)
    {
    case bar:
      for (int n=0; n<screenpoints.length-1; n++)
      {
        rendertarget.stroke(c);
        rendertarget.fill(c);
        rendertarget.quad(screenpoints[n].x, screen_y_zero, screenpoints[n].x, screenpoints[n].y, screenpoints[n+1].x, screenpoints[n].y, screenpoints[n+1].x, screen_y_zero);
        //quad(screenpoints[n].x, screenpoints[n].y, screenpoints[n].x, screen_y_zero, screenpoints[n+1].x, screen_y_zero, screenpoints[n+1].x, screenpoints[n].y);
      }
      break;
    case line:
      for (int n=0; n<screenpoints.length-1; n++)
      {
        rendertarget.noFill();
        rendertarget.stroke(c);
        rendertarget.line(screenpoints[n].x, screenpoints[n].y, screenpoints[n+1].x, screenpoints[n+1].y);
      }
      break;
    }
  }
}