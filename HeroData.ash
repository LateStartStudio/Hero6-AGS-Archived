
struct HeroData {				
			String name;
		  short class; 
      short hp;
			short mhp;
			short mp;
			short mmp;
			short sp;
			short msp;
			short gold;
			short silver;
			
			// currently equipped
			short i_armor;
			short i_weapon;
			short i_shield;
			// basic stats
			short str;
			short Int;
			short agi;
			short vit;
			short luck;
			short honor;
			short magic;
			short comm;
			// combat stats
			short weaponuse;
			short parry;
			short dodge;
			// spell experience
			short sp_exp_kincharge;
			short sp_exp_distraction;
			short sp_exp_flamedart;
			short sp_exp_forcebolt;
			short sp_exp_iceburst;
			// abilities
			short throw;
			short climb;
			short stealth;
			short lockpick;
			// status
			short status;
			short status_interval;
			short status_lastupdate;
			
			// Hunger and Thrist
			short hunger;
			short thrist;
      
      import function Init();
};

import function SetMaxHealth();
import function SetMaxStamina();
import function SetMaxMagic();
import function RefreshMaxHealthStat();
import function RefreshMaxStaminaStat();
import function RefreshMaxMagicStat();

import HeroData heroinfo;
import HeroData fighterData;
import HeroData mageData;
import HeroData thiefData;
