class Phase_and_Amp
{
  dipole_2D phase_arrow;
  PVector position;
  PVector size;
  PVector dipolecenter;
  float max_amp;
  float smallerdimension;
  PGraphics colorcircle;
  Phase_and_Amp(PVector position, PVector size, float maximum_amplitude)
  {   
    this.position=position;
    this.size=size;
    this.max_amp=maximum_amplitude;

    smallerdimension=size.y/2.0;
    dipolecenter=new PVector(position.x+size.x/4, position.y+size.y/2);
    phase_arrow=new dipole_2D(smallerdimension/20.0);
    phase_arrow.length=smallerdimension;
    phase_arrow.set_position(dipolecenter);
    
    colorcircle=createGraphics((int)size.x/2,(int)size.y,P3D);
    colorcircle.beginDraw();
    colorcircle.background(255);
    colorcircle.beginShape(TRIANGLE_FAN);
    colorcircle.vertex(colorcircle.width/2, colorcircle.height/2);
    int points=360;
    colorcircle.noStroke();
    for (int n=0; n<=points; n++)
    {
      float circleangle=2.0*PI*(float)n/(float)points;
      color c=phase_to_color(circleangle);
      colorcircle.fill(c);
      colorcircle.vertex(colorcircle.width/2+sin(circleangle)*colorcircle.width/2,colorcircle.height/2-cos(circleangle)*colorcircle.height/2);
    }
    colorcircle.endShape();
    colorcircle.endDraw();
  }
  void draw(PGraphics rendertarget, float phase, float amplitude)
  {
    rendertarget.stroke(color(0, 0, 0, 255));
    rendertarget.fill(phase_to_color(phase));

    PVector center=dipolecenter;
    
    rendertarget.image(colorcircle,position.x,position.y);
        
    rendertarget.noStroke();
    rendertarget.fill(phase_to_color(phase));
    rendertarget.ellipse(center.x, center.y, smallerdimension, smallerdimension);

    rendertarget.fill(color(0, 0, 0, 255));
    phase_arrow.angle=phase;
    phase_arrow.draw(rendertarget);

    rendertarget.fill(color(0));
    finaltarget.textAlign(RIGHT, CENTER);
    //rendertarget.text(nf(phase/PI, 1, 2) + "π", position.x-size.x/10.0, position.y+size.y/2.0);
    rendertarget.text(nf(phase/PI, 1, 2) + "π", position.x+size.x/12, position.y+size.y*9/10);
    finaltarget.textAlign(RIGHT, CENTER);
    //rendertarget.text((int)(amplitude/max_amplitude*100.0) + "%", position.x+size.x+size.x/10.0, position.y+size.y/2.0);
    rendertarget.text((int)(amplitude/max_amplitude*100.0) + "%", position.x+size.x+size.x/5.0, position.y+size.y*9/10);
    //rendertarget.text((nf(amplitude/max_amplitude*100.0,3,2)) + "%", position.x+size.x/2.0+size.x/12, position.y+size.y*9/10);
    float h=size.y*amplitude/max_amp;
    float x_left=position.x+size.x/2.0+size.x/10.0;
    float x_right=position.x+size.x-size.x/10.0;
    rendertarget.rect(x_left, position.y+size.y-h, (x_right-x_left), h, smallerdimension/20.0, smallerdimension/20.0, 0, 0);
  }
}

color phase_to_color(float phase)
  {
    int cols[]=new int[3];
    for (int n=0; n<=2; n++)
    {
      cols[n]=(int)(255*(cos(phase-(n+1)*2.0*PI/3.0)+1.0)/2.0);
    }
    return color(cols[0], cols[1], cols[2], 255);
  }