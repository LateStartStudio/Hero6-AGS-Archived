/*  Climbing related functions  */
import function resetClimbTransitions(int totalClimbPoints);
import function setTrOnlyWalkable(int transitionNum,  bool newOnlyWalkable);
import function setTrUseWalkAnim(int transitionNum,  bool newUseWalkAnim);
import function setTrBaseline(int transitionNum,  int newBaseline);


struct climbStruct  {
  int totalClimbPoints;   //Total number of points in the climb. 
  int x[30];      //X coordinate of the climb points
  int y[30];    //Y coordinate of the climb points
  int minAttemptSkill;  // If the hero's climb skill isn't at least this much, he doesn't even attempt the climb
  int minSucceedSkill;  // Climb skill + luck + random must be at least this much for the climb to succeed
  int fallCheckPoint;  //If the hero can fall from the climb, this is the climb point where the check will take place
  int fallToX;    // If the hero falls, he lands in this X coordinate
  int fallToY;    // Same as above, only Y
  short fallDamage;  //If the hero fails and falls, he will suffer this much health damage
  bool handbarClimbAnimation;   //true= use the handbar animation, false= use the normal climb animation
  bool reverseClimb;    //true= the hero will go through the climb points in reverse order, false=normal climb
  String messageSkillInsufficient;  //The message to show if the hero doesn't have enough climb skill to attempt the climb
  String messageFall;   //Message when falling (i.e. fall point is defined and climb failed)
  String messageClimbFailed;  //Message when failing to climb (i.e. no fall point and climb failed)

  
  import function setTrOnlyWalkable(int transitionNum,  bool newOnlyWalkable);
  import function setTrUseWalkAnim(int transitionNum,  bool newUseWalkAnim);
  import function setTrBaseline(int transitionNum,  int newBaseline);
  import function resetClimbTransitions(int totalClimbPoints);
  import function doClimb();
};


