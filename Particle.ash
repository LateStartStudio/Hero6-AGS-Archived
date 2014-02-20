// Script header for module 'Akumayo's Particle Engine'
struct Particles {
  int lifespan;
  bool alive;
  int speed;
  int trans;
  int fadeout;
  int Y_Gravity;
  int X_Gravity;
  int sprite;
  int x_pos;
  int y_pos;
  int grav_resistance;
};

import function Remove_All_Particles();
import function Edit_Particle_Values(int min_speed,int max_speed,int min_trans,int max_trans, int trans_fadeout, int fadeout_resistance,int x_grav,int y_grav,int grav_resistance_min, int grav_resistance_max,int spriteslot_min,int spriteslot_max);
import function Single_Emit_Particles(int particle_x,int particle_y, int life_min,int life_max, int amount_to_emit);
import function Particle_Removal_Boundries(int removal_x_min, int removal_x_max, int removal_y_min, int removal_y_max);
import function Toggle_Particle_Deviation(int deviate_on_x_axis, int deviate_on_y_axis);
import function Continuous_Emit_Particles_Go(int particle_x, int particle_y, int life_min, int life_max, int amount_on_screen);
import function Continuous_Emit_Particles_Stop();