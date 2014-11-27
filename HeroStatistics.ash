
#define STATS_LENGTH 13

struct HeroStatistics {
  String name;
  short class;
  short gold;
  short silver;
  
  // Stats
  short currentHealthPoints;
  short maxHealthPoints;
  short currentStaminaPoints;
  short maxStaminaPoints;
  short currentMagicPoints;
  short maxMagicPoints;
  
  short stats[STATS_LENGTH];
  
  short honour;
  
  // Struct functions
  import function setHealthStaminaMagicPointsToMax();
  import function calculateMaxHealthStaminaAndMagic();
  
  import function modifyHealthPoints  (short value);
  import function modifyStaminaPoints (short value);
  import function modifyMagicPoints   (short value);
  
  import function increaseStat (int stat, short value);
  
  import function modifyHonour        (short value);
  
  import function InitializeTempValues();
};

enum Stats {
  Stats_Strength     = 0, // enum values appear to start at 1 instead of 0
  Stats_Intelligence = 1,
  Stats_Agility      = 2,
  Stats_Vitality     = 3,
  Stats_Luck         = 4,
  Stats_WeaponUse    = 5,
  Stats_Dodge        = 6,
  Stats_Magic        = 7,
  Stats_Parry        = 8,
  Stats_Throwing     = 9,
  Stats_Climbing     = 10,
  Stats_Stealth      = 11,
  Stats_LockPicking  = 12
};

import HeroStatistics heroStatistics;
