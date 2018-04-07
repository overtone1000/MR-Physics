ScannerScene scene_scanner;
SpinsScene scene_spins;
Encoding_Spaces spaces;
SPD diagram;
FSE_builder fsebuilder;

float stretch=1.2;
float TE=18000*stretch;
float TR=62000*stretch;
int grad_steps=18; //Make sure it's half is divisible by the number of echoes per repeat and is even.
int freq_steps=18; //Just make it square.

float precession_rate;

String savedir="";

int filecount=0;

enum Shows
{
  FSE_all, 
    FSE_spinsonly, 
    FSE_spacesonly, 
    Scanner_Demo, 
    Quantum, 
    Fourier1, 
    Fourier2;
}

float speed_modification=1;
int starttime_modification=0;

//30000 is right before the first excitation

boolean render_to_video=true;

Shows thisshow=Shows.Quantum;

PGraphics finaltarget;

int fullresx;
int fullresy;

String photodir="";

color signcolor=color(0);

void setup() {
  String savesubdir="Quantum2";
  if (File.separator.equals("\\"))
  {
    println("Windows detected.");
    photodir="E:\\Dropbox\\mylan2.jpg";
    savedir="E:\\MRI_Physics_2\\"+savesubdir+"\\";
  } else if (File.separator.equals("/"))
  {
    println("Linux detected.");
    photodir="/home/tyler/Dropbox/mylan2.jpg";
    savedir="/home/tyler/Videos/processing_output/"+savesubdir+"/";
  }
  else{
   println("OS not detected.");
   println("File separator is " + File.separator);
   println("Should be \\ for Windows and / for Linux.");
   exit();
  }

  File dir = new File(savedir);
  if (!dir.exists()) {
    dir.mkdir();
  }
  filecount=dir.list().length;

  frame_index=filecount; //set the frame index based on number of files already present to resume rendering where it left off

  //size(320, 180, P3D);//testing
  //size(640, 360, P3D);//testing  
  //size(1280, 720, P3D);//testing
  //fullresx=this.width;
  //fullresy=this.height;
  
  size(1920, 1080, P3D);//render to video
  fullresx=1920;
  fullresy=1080;
  
  println(this.width);
  println(this.height);

  finaltarget=createGraphics(fullresx, fullresy, P3D);

  precession_rate=2*PI/200;
  switch(thisshow)
  {
  case Scanner_Demo:
    {
      setup_ScannerParts();
      break;
    }
  case FSE_all:
    {
      setup_All();
      break;
    }
  case FSE_spinsonly:
    {
      precession_rate=2*PI/1250; //good for watching precessing spins
      setup_FSEspinsonly();
      break;
    }
  case FSE_spacesonly:
    {
      precession_rate=2*PI/300;
      setup_FSEspacesonly();
      break;
    }
  case Quantum:
    {
      precession_rate=2*PI/2500;
      setup_Quantum();
      break;
    }
  case Fourier1:
    {
      setup_Fourier1();
      break;
    }
  case Fourier2:
    {
      signcolor=color(255,255,255,255);
      LoadFromFile();
      setup_Fourier2();
      break;
    }
  }
}

boolean initialized=false;
int startup_time;

void draw() {

  background(255);

  //println("Drawing.");
  System.gc();

  if (!initialized)
  {
    initialized=true;
    startup_time=millis();
  }

  int thismillis;
  if (render_to_video)
  {
    thismillis=thismillis_video();
  } else
  {
    thismillis = millis()-startup_time+(int)(starttime_modification/speed_modification);

    thismillis=(int)(speed_modification*thismillis);
  }
  //spd_panel.set(1.0);

  finaltarget.beginDraw();

  finaltarget.background(255);
  finaltarget.camera();
  //finaltarget.camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);

  finaltarget.fill(0);
  //finaltarget.rect(finaltarget.width/4,finaltarget.height/4,finaltarget.width/2,finaltarget.height/2);

  switch(thisshow)
  {
  case Scanner_Demo:
    {
      draw_ScannerParts(thismillis);
      break;
    }
  case FSE_all:
    {
      draw_All(thismillis);
      break;
    }
  case FSE_spinsonly:
    {
      draw_FSEspinsonly(thismillis);
      break;
    }
  case FSE_spacesonly:
    {
      draw_FSEspacesonly(thismillis);
      break;
    }
  case Quantum:
    {
      draw_Quantum(thismillis);
      break;
    }
  case Fourier1:
    {
      draw_Fourier1(thismillis);
      break;
    }
  case Fourier2:
    {
      draw_Fourier2(thismillis);
      break;
    }
  }  

  signature(signcolor);

  finaltarget.endDraw();

  if (render_to_video)
  {
    String filename;
    filename=str(frame_index)+".png";
    while (filename.length()<12) {
      filename="0"+filename;
    }
    filename=savedir+filename;
    finaltarget.save(filename);
    if (thisshow==Shows.Fourier2)
    {
      SaveToFile();
    }
    image(finaltarget, 0, 0, width, height);
    testing_info(thismillis);
  } else
  {
    image(finaltarget, 0, 0, width, height);
    testing_info(thismillis);
  }
}

int frame_index=0;
int framerate=60;
int thismillis_video()
{
  int retval=1000*frame_index/framerate;
  frame_index++;
  //println("Frame " + frame + ", Millis " + retval);
  return retval;
}

void signature(color c)
{
  finaltarget.noLights();

  finaltarget.hint(DISABLE_DEPTH_TEST);

  c=color(c);
  
  finaltarget.stroke(c);
  finaltarget.fill(c);
  finaltarget.textAlign(RIGHT, BOTTOM);

  finaltarget.text("Tyler Moore, 2017", finaltarget.width-3, finaltarget.height-3);
  
  finaltarget.hint(ENABLE_DEPTH_TEST);
}

void testing_info(int thismillis)
{
  //Don't draw to finaltarget, draw straight to screen to avoid saving testing info to rendered videos

  String lines[]=new String[5];
  lines[0]="Frame rate = " + frameRate;
  lines[1]="";
  lines[2]="";
  if (scene_scanner!=null) {
    lines[1]="Current stage = " + scene_scanner.currentname + " (starts @ " + scene_scanner.currenttime + ")";
    lines[2]="Next stage = " + scene_scanner.nextname + " (starts @ " + scene_scanner.nexttime + ")";
  }
  lines[3]="Time = " + thismillis;
  lines[4]="";
  noLights();

  hint(DISABLE_DEPTH_TEST);
  fill(255, 255, 255, 220);
  stroke(0);
  rect(0, 0, 400, 100);

  stroke(color(0, 0, 0, 255));
  fill(color(0, 0, 0, 255));
  textAlign(LEFT, TOP);
  float sumy=0;
  for (String s : lines)
  {
    text(s, 0, sumy);
    sumy+=textAscent()+textDescent()+1;
  }
  noFill();
  stroke(0);
  rect(0, sumy, 100, textAscent()+textDescent());
  fill(0);
  stroke(0);
  if (scene_scanner!=null) {
    rect(0, sumy, lerp(0, 100, (float)(thismillis-scene_scanner.currenttime)/(float)(scene_scanner.nexttime-scene_scanner.currenttime)), textAscent()+textDescent());
  }
  hint(ENABLE_DEPTH_TEST);
}