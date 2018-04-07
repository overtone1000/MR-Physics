class Encoding_Spaces
{
  Real_Space_2D rs=new Real_Space_2D();
  K_Space_2D ks=new K_Space_2D();

  int matrix_size_x;
  int matrix_size_y;

  PVector position;
  PVector size;

  Encoding_Spaces()
  {
    int dipoles=10;
    rs.set_dipole_counts(dipoles, dipoles);
  }

  void set_dimensions(PVector position, PVector size)
  {
    this.position=position.copy();
    this.size=size.copy();
    rs.set_position(position.x, position.y);
    rs.set_dimension(size.x/2.0, size.y);
    ks.set_position(position.x+size.x/2.0, position.y);
    ks.set_dimension(size.x/2.0, size.y);
  }

  void set_matrix_size(int matrix_size_x, int matrix_size_y)
  {
    this.matrix_size_x=matrix_size_x;
    this.matrix_size_y=matrix_size_y;
    ks.set_matrix_size(matrix_size_x, matrix_size_y);
  }

  float frequency_oscillations;
  float phase_oscillations;
  float frequency_oscillation_magnitude=5;
  float phase_oscillation_magnitude=5;

  float freq;
  float phase;
  float all_precession;
  void update(float freq, float phase, float all_precession)
  {
    //supply freq as a float from -1 to 1
    //supply phase as an int from -matrix_size_y/2 to +matrix_size_y/2
    //all_precession is just an angle 
    this.freq=freq;
    this.phase=phase;
    this.all_precession=all_precession;

    frequency_oscillations=-(frequency_oscillation_magnitude*freq);
    //frequency_oscillations=0;
    phase_oscillations=phase_oscillation_magnitude*phase/((float)matrix_size_y/2.0);
    //phase_oscillations=0;
  }

  void draw(PGraphics maintarget)
  {
    rs.set_precession(frequency_oscillations, phase_oscillations, all_precession);

    if (thisshow==Shows.Fourier1)
    {
      rs.draw(maintarget,true);
    } else
    {
      rs.draw(maintarget,false);
    }

    if (thisshow==Shows.Fourier2)
    {
      draw_kspace(maintarget, false, true);
    } else
    {
      draw_kspace(maintarget, true, false);
    }

    maintarget.hint(DISABLE_DEPTH_TEST);
    maintarget.noFill();
    maintarget.stroke(0);
    maintarget.rect(position.x, position.y, size.x, size.y);
    //stroke(color(0, 0, 0, 255));
    //fill(color(0, 0, 0, 255));
    //textAlign(CENTER, TOP);
    //text("Scanner", current.panel_position.x+current.panel_size.x/10, current.panel_position.y+current.panel_size.y/20);
    maintarget.hint(ENABLE_DEPTH_TEST);
  }

  void draw_kspace(PGraphics maintarget, boolean show_minor_lines, boolean scale_color)
  {
    //k_space_freq and k_space_phase are floats from 0 to matrix_size-1;
    float k_space_freq=freq*((float)(matrix_size_x-1))/2.0+(float)(matrix_size_x-1)/2.0;
    float k_space_phase=(float)matrix_size_y/2.0-phase-0.5;
    //println("freq = " + freq);
    //println("phase = " + phase);
    //println("k_space_freq = " + k_space_freq);
    //println("k_space_phase = " + k_space_phase);
    ks.set_k_space_location(k_space_freq, k_space_phase);
    ks.draw(maintarget, show_minor_lines, scale_color);
  }

  void draw_realspace_precession(PGraphics maintarget, PVector newposition, float precession_angle, boolean precessing)
  {
    PVector oldpos=rs.position.copy();
    rs.set_position(newposition.x, newposition.y);

    if (precessing)
    {   
      rs.set_precession(frequency_oscillations, phase_oscillations, precession_angle);
    }
    rs.draw(maintarget,true);

    rs.set_position(oldpos.x, oldpos.y);
  }
}