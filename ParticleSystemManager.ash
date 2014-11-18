//===================================================================
// *** AGS MODULE HEADER ***
//
// Module: ParticleSystemManager
//
// Author: Miguel García Díaz (Jerakeen)
//
// Copyright (C) 2009  Jerakeen
//-------------------------------------------------------------------

//===================================================================
// Dependancies:
// The following constant definitions allow the compiler to check for
// module  dependencies and to issue appropiate error messages when a
// required module is not installed. There should be a definition for
// the current version and all previous compatiable versions. 
//-------------------------------------------------------------------


// Define this module's version info
#define ParticleSystemManager_VERSION 0100
#define ParticleSystemManager_VERSION_0100

// Check for correct AGS version
#ifdef AGS_SUPPORTS_IFVER
#ifnver 3.00
#error Module ModuleName requires AGS V3.00 or above
#endif
#endif

// Check for required module/version 
//#ifndef RequiredModuleName_VERSION_0200
//#error Module ModuleName requires RequiredModuleName V2.00 or above
//#endif


//===================================================================
// Configuration:
// The following constant definitions are used to modify the behavior
// of this module.  
//-------------------------------------------------------------------
//#define ModuleName_CONFIGPARAM		10


//===================================================================
// Return Values:
// The following constant definitions represent possible return value
// of functions contained in this module. 
//-------------------------------------------------------------------
//	#define ModuleName_RETURNVAL		100


//===================================================================
// Enumerated Types:
// The following enumerated data types are defined by this module. 
//-------------------------------------------------------------------

enum enDrawType
{
  dtBackground, 
  dtOverlay, 
  dtSprite
};

enum enPosType
{
  ptPoint, 
  ptCirle, 
  ptCrown, 
  ptBox, 
  ptLine, 
  ptMousePosition
};

enum enForceType
{
  ftConstant, 
  ftRandom, 
  ftSidetoSide, 
  ftParticleDirection, 
  ftLateral, 
  ftLateralRandom
};

enum enRepeatMode
{
  rmAllways, 
  rmNumberOfTimes
};





struct ParticleSystemManager
{
	// Public Data
//  bool use_particle_system;
  int  num_systems;

 	// Private Data

	// Public Static Methods
//	import static function FunctionName();
	
  // Private Methods
//	protected import function function_name();


	// Public Methods

  // PARTICLES SYSTEM MANAGER: Create, destroy and manage particles systems
  
  import function CreateSystem (int n_particles, bool keep_track = false, enDrawType draw_type = dtBackground, int width = 0, int height = 0);
  import function DeleteLastSystem ();
  import DynamicSprite *GetSystemSprite (int system);
  import function GetSystemActiveParticles (int system);

//  protected import function update_systems ( );


  // EMITTER: Set Initial properties of the particles in a system
  
  import function emitter_creation_mode (int system, enRepeatMode rep_mode, int max_rep, int frecuency, int n_particles);
  
  import function emitter_set_position (int system, enPosType type, float p1 = 0, float p2 = 0, float p3 = 0, float p4 = 0, float p5 = 0, float p6 = 0);
  import function emitter_set_velocity (int system, int min_speed, int max_speed, int min_angle, int max_angle);
  import function emitter_set_color (int system, int min_r, int min_g, int min_b, int min_saturation, int max_r, int max_g, int max_b, int max_saturation);
  import function emitter_set_transparency (int system, int min_trans, int max_trans);
  import function emitter_set_age (int system, int min_age, int max_age);
  import function emitter_set_sprite (int system, int min_slot, int max_slot);
  import function emitter_set_scale (int system, int min_scale, int max_scale);
  

  // ACTIONS SETTING: Modifies particle's properties

  // Evolution functions
  import function action_set_color_evolution (int system, int to_r, int to_g, int to_b, int to_saturation, int frec);
  import function action_set_transparency_evolution (int system, int to_trans, int frec);
  import function action_set_scale_evolution (int system, int to_scale,  int frec);

  // Forces functions
  import function action_add_force (int system, enForceType type, float p1, float p2 = 0, float p3 = 0, float p4 = 0, float p5 = 0, float p6 = 0);
  import function action_update_force (int num_system, int num_force, enForceType type, float p1, float p2 = 0, float p3 = 0, float p4 = 0, float p5 = 0, float p6 = 0);

  import function action_set_bound_box (int system, int min_x, int min_y, int max_x, int max_y);

//  import function action_when_condition ();
};
