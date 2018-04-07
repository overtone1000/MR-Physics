void setup()
{
  size(1920, 1080,P3D);
  PImage i;
  PGraphics g=createGraphics(1,1,P3D);
  String savedir="E:\\MRI_Physics_2\\Fourier3";
  String outdir="E:\\MRI_Physics_2\\Fourier3_signed";
  String[] files=(new File(savedir)).list();
  for(int n=0;n<files.length;n++)
  {
    String ss=files[n].substring(files[n].indexOf(".")+1,files[n].indexOf(".")+4);
     if(ss.equals("png"))
     {
       println("Processing " + files[n]);
       i=loadImage(savedir + "\\" + files[n]);
       if(g.height!=i.height || g.width!=i.width)
       {
         println("Resizing graphics object.");
         g=createGraphics(i.width,i.height,P3D);
       }
       g.beginDraw();
       g.image(i,0,0);
       signature(g);
       g.endDraw();
       
       g.save(outdir + "\\" + files[n]);
       println("Saving to " + files[n]);
     }
     else
     {
      println("Skipping " + files[n]); 
     }
  }
}

void signature(PGraphics finaltarget)
{
  finaltarget.noLights();

  finaltarget.hint(DISABLE_DEPTH_TEST);

  finaltarget.stroke(color(255));
  finaltarget.fill(color(255));
  finaltarget.textAlign(RIGHT, BOTTOM);

  finaltarget.text("Tyler Moore, 2017", finaltarget.width-3, finaltarget.height-3);
  finaltarget.hint(ENABLE_DEPTH_TEST);
}