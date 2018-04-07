void setup_ScannerParts()
{
  scene_scanner=new ScannerScene();

  scene_scanner.initialize(new PVector(0, 0), new PVector(fullresx, fullresy));

  int n=6000;
  int d=8000;
  int m=d-2000;

  scene_scanner.add_coil_action(n, m, CoilGroup.primary);

  n+=d;
  scene_scanner.add_coil_action(n, m, CoilGroup.freq);
  n+=d;
  scene_scanner.add_coil_action(n, m, CoilGroup.phase);
  n+=d;
  scene_scanner.add_coil_action(n, m, CoilGroup.slice);

  n+=d;
  d=12000;
  m=d-2000;
  scene_scanner.add_coil_action(n, m, CoilGroup.RF);
  n+=d;
  scene_scanner.add_coil_action(n, m, CoilGroup.signal);
}
void draw_ScannerParts(int thismillis)
{
  if (scene_scanner.finished(thismillis)) {
    exit();
  }
  scene_scanner.draw(finaltarget, thismillis);
}

void setup_All()
{
  scene_scanner=new ScannerScene();
  scene_spins=new SpinsScene();
  diagram=new SPD();
  spaces=new Encoding_Spaces();

  x1=finaltarget.width/2+100;
  y1=finaltarget.height/2;
  x2=finaltarget.width*3/4;

  diagram.set_dimensions(0, x2, y1, finaltarget.height);

  scene_scanner.initialize(new PVector(x1, 0), new PVector(finaltarget.width-x1, finaltarget.height-y1));
  scene_spins.initialize(new PVector(x2, y1), new PVector(finaltarget.width-x2, finaltarget.height-y1));

  fsebuilder=new FSE_builder(scene_scanner, diagram, spaces);
  fsebuilder.initialize(TR, TE, grad_steps, freq_steps);
  //println("Updating diagram.");

  //diagram.build_FSE();
  //diagram.build();
  //println("Building scanner scene.");

  PVector es_pos=new PVector(0, 0);
  PVector es_size=new PVector(x1, y1);
  spaces.set_dimensions(es_pos, es_size);
}

void draw_All(int thismillis)
{  
  if (fsebuilder.sequence.finished(thismillis))
  {
    exit();
  }

  //println("Drawing scene.");
  scene_scanner.draw(finaltarget, thismillis);

  //hint(DISABLE_DEPTH_TEST);
  //println("Updating diagram.");
  fsebuilder.update_diagram(thismillis);
  //println("Drawing diagram.");

  diagram.draw_FSE(finaltarget, thismillis); //need to draw this second. the Scanner scene will cause depth-test problems for fill otherwise.

  //hint(ENABLE_DEPTH_TEST);
  //println("Drawing EncodingSpaces");

  //println("Updating spaces");
  fsebuilder.update_spaces(thismillis);
  //println("Drawing spaces");

  spaces.draw(finaltarget);

  //println("Drawing scene_spins1");

  scene_spins.draw(finaltarget, thismillis);
}

int x1;
int y1; 
int x2;
int y2;
void setup_FSEspinsonly()
{
  scene_scanner=new ScannerScene();
  scene_spins=new SpinsScene();
  diagram=new SPD();
  spaces=new Encoding_Spaces();

  println(finaltarget.width + "," + finaltarget.height);
  x1=finaltarget.width/3;
  y1=finaltarget.height/2;
  x2=finaltarget.width/3*2;

  diagram.set_dimensions(0, finaltarget.width, y1, finaltarget.height-20);

  scene_scanner.initialize(new PVector(x2, 0), new PVector(finaltarget.width-x2, y1));

  scene_spins.initialize(new PVector(0, 0), new PVector(x1, finaltarget.height-y1));

  fsebuilder=new FSE_builder(scene_scanner, diagram, spaces);
  fsebuilder.initialize(TR, TE, grad_steps, freq_steps);
}

void draw_FSEspinsonly(int thismillis)
{
  if (fsebuilder.sequence.finished(thismillis))
  {
    exit();
  }
  scene_scanner.draw(finaltarget, thismillis);
  fsebuilder.update_diagram(thismillis);
  diagram.draw_FSE(finaltarget, thismillis); //need to draw this second. the Scanner scene will cause depth-test problems for fill otherwise.
  scene_spins.draw(finaltarget, thismillis);  
  scene_spins.draw(finaltarget, thismillis, new PVector(x1, 0), calc_precession_angle(thismillis));
}

void setup_FSEspacesonly()
{
  scene_scanner=new ScannerScene();
  scene_spins=new SpinsScene();
  diagram=new SPD();
  spaces=new Encoding_Spaces();

  x1=finaltarget.width/4;
  y1=finaltarget.height/2;
  x2=-5;

  diagram.set_dimensions(0, finaltarget.width, y1, finaltarget.height-20);

  scene_scanner.initialize(new PVector(x1*3, 0), new PVector(x1, y1));

  fsebuilder=new FSE_builder(scene_scanner, diagram, spaces);
  fsebuilder.initialize(TR, TE, grad_steps, freq_steps);

  PVector es_pos=new PVector(0, 0);
  PVector es_size=new PVector(x1*2+x2, y1);
  spaces.set_dimensions(es_pos, es_size);
}

void draw_FSEspacesonly(int thismillis)
{
  if (fsebuilder.sequence.finished(thismillis))
  {
    exit();
  }
  scene_scanner.draw(finaltarget, thismillis);
  fsebuilder.update_diagram(thismillis);
  diagram.draw_FSE(finaltarget, thismillis); //need to draw this second. the Scanner scene will cause depth-test problems for fill otherwise.
  fsebuilder.update_spaces(thismillis);
  spaces.draw(finaltarget);
  spaces.draw_realspace_precession(finaltarget, new PVector(x1*2+x2, 0), calc_precession_angle(thismillis), fsebuilder.sequence.precessing(thismillis));
}

Quantum q;

PGraphics rendertarget;
QuantumScene qs;
void setup_Quantum()
{
  rendertarget=createGraphics((int)(finaltarget.width/2), (int)(finaltarget.height), P3D);
  //rendertarget=createGraphics((int)(finaltarget.width), (int)(finaltarget.height), P3D);

  q=new Quantum();
    
  qs=new QuantumScene();
}

void draw_Quantum(int thismillis)
{
  if(qs.finished(thismillis)){exit();}
  
  QuantumState quantum_state=qs.currentstate(thismillis);
  quantum_state.displayed_precession_angle=precession_rate*thismillis;
  
  rendertarget.ortho();
  rendertarget.camera(0, 0, (rendertarget.height/2.0) / tan(PI*30.0 / 180.0), 0, 0, 0, 0, 1, 0);

  QuantumState tempstate=new QuantumState(quantum_state);
  tempstate.draw_energy_rings=true;
  tempstate.draw_sum_vector=false;
  finaltarget.beginDraw();
  rendertarget.beginDraw(); //only to be done by the top level
  q.draw(rendertarget, tempstate);
  rendertarget.endDraw();
  finaltarget.image(rendertarget, 0, 0);
  finaltarget.endDraw();
  
  finaltarget.beginDraw();
  int alpha=(int)(quantum_state.hide_alpha*255);
  finaltarget.fill(255,255,255,alpha);
  finaltarget.noStroke();
  finaltarget.rect(0,0,finaltarget.width/2,finaltarget.height);
  
  finaltarget.stroke(0,0,0,alpha);
  finaltarget.fill(0,0,0,alpha);
  finaltarget.textAlign(CENTER, CENTER);
  finaltarget.textSize(rendertarget.height/1.5);
  finaltarget.text("?", rendertarget.width/2,rendertarget.height/2);
  finaltarget.endDraw();
  
  tempstate=new QuantumState(quantum_state);
  tempstate.draw_energy_rings=false;
  tempstate.draw_grey_dipoles=false;
  tempstate.draw_red_dipoles=false;
  finaltarget.beginDraw();
  rendertarget.beginDraw();
  q.draw(rendertarget, tempstate);
  rendertarget.endDraw();
  finaltarget.image(rendertarget, finaltarget.width/2, 0);
  finaltarget.endDraw();
}

float calc_precession_angle(int thismillis)
{
  int usedmillis=thismillis;
  while (usedmillis>fsebuilder.sequence.TR) {
    usedmillis-=fsebuilder.sequence.TR;
  }
  usedmillis-=fsebuilder.sequence.lead_time;
  return (float)(precession_rate*usedmillis);
}