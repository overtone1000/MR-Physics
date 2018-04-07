byte[] doublearr_to_bytearr(double[] darr)
{
  byte[] barr=new byte[darr.length*8];
  for (int n=0; n<darr.length; n++)
  {
    long lng = Double.doubleToLongBits(darr[n]);
    for (int i = 0; i < 8; i++) 
    {
      barr[n*8+i] = (byte)((lng >> ((7 - i) * 8)) & 0xff);
    }
  }
  return barr;
}

double[] bytearr_to_doublearr(byte[] barr)
{
  double[] darr=new double[barr.length/8];
  for (int n=0; n<darr.length; n++)
  {
    long lng_result=0;
    for (int i=0; i<8; i++)
    {
      lng_result|=((long)barr[n*8+i] & 0xff)<<((7-i)*8);
    }
    darr[n]=Double.longBitsToDouble(lng_result);
  }
  return darr;
}

byte[] int_to_bytearr(int in)
{
  byte[] barr=new byte[4];
  for (int i = 0; i < 4; i++) 
  {
    barr[i] = (byte)((in >> ((3 - i) * 8)) & 0xff);
  }
  return barr;
}

int bytearr_to_int(byte[] barr)
{
  int in=0;
  for (int i=0; i<4; i++)
  {
    in|=((int)barr[i] & 0xff)<<((3-i)*8);
  }
  return in;
}

//Int.intToIntBits(int); //converts a integer to a byte array 

//Int.intBitsToInt(barr); //converts a byte array to an integer

String savefilename="!progress";//File.separator + "!progress";
void SaveToFile()
{
  byte[] bytes=new byte[4+pixel_integral.length*8];
  byte[] toadd;
  toadd=int_to_bytearr(frame_index);
  for (int n=0; n<toadd.length; n++)
  {
    bytes[n]=toadd[n];
  }
  toadd=doublearr_to_bytearr(pixel_integral);
  for (int n=0; n<toadd.length; n++)
  {
    bytes[n+4]=toadd[n];
  }

  saveBytes(savedir+savefilename, bytes);
}

void LoadFromFile()
{
  File f = new File(savedir+savefilename);
  if (f.exists()) {
    byte[] bytesout=loadBytes(savedir+savefilename);
    frame_index=bytearr_to_int(subset(bytesout, 0, 4));
    println("Frame index = " + frame_index);
    pixel_integral=bytearr_to_doublearr(subset(bytesout, 4, bytesout.length-4));
  }
}