// Script header for module 'GameData'
#define INTARRAY_SIZE 20

#define FIGHTER 1
#define MAGE 2
#define THIEF 3

// Scene flag values
#define SCENE_TYPE_EXTERIOR  0
#define SCENE_TYPE_N_FOREST  1
#define SCENE_TYPE_ROAD  2
#define SCENE_TYPE_FIELD   3
#define SCENE_TYPE_DARKFOREST   4
#define SCENE_TYPE_INTERIOR  5
#define SCENE_TYPE_TOWN      6
#define SCENE_TYPE_CAVE      7

// define hero class types
#define CLASS_FIGHTER 1
#define CLASS_MAGE 2
#define CLASS_THIEF 3
#define CLASS_UNKNOWN 4

// define hero status modes
#define STATUS_HEALTHY  	 0
#define STATUS_SLEEPY   	 1
#define STATUS_HUNGRY	     2
#define STATUS_OVERBURDONED  3
#define STATUS_POISONED		 4
// other possible status modes:
// sick, drunk, euphoric, angry

// status time information
#define STATUS_INTERVAL 90000
#define STATUS_LastUpdate 0

// Damage Type Constants
#define DMG_PHYSICAL  0
#define DMG_MAGICAL  1
#define DMG_FIRE  2
#define DMG_COLD  3

// Creature Type Constants
#define CRT_HUMANOID  0 // { Rogue, Hobgoblin, Formori, Termoidien, Aruthredd }
#define CRT_UNDEAD    1 // { Shadowmage, Cait Sith }
#define CRT_BEAST     2 // { Stalkers, Boggles, Torbbe, Drake, Tethra
#define CRT_GOLEM     3 // { Clay Golem, Wood Golem }

#define FLAMEDART_MP 0
#define FETCH_MP 0
#define TRIGGER_MP 0

#define GREENLEAF_FAVOR_COMPLETE 5

#define MAX_AVAILABLE_RIDDLES 15

enum TimerType
{
  Timer_Combat = 1, 
  Timer_FollowChar, 
  Timer_Health, 
  Timer_Stamina, 
  Timer_Magic, 
  Timer_Generic, 
  Timer_Daytime = 10, 
  Timer_FollowCharRooms1, 
  Timer_FollowCharRooms2, 
  Timer_FollowCharRooms3, 
  Timer_FollowCharRooms4, 
  Timer_FollowCharRooms5, 
  Timer_FollowCharRooms6
};

struct TimeData { 
	int ticksSinceLastState;
  int TicksPerState;
  int TimeState;
  int Day;
  
  // my new code
  int ticks;
};

// quest complete codes
struct Flags {
  
		short Chapter; // Current chapter of the game

		// Generic Flags
		bool FlanaginnRented;
		
		bool VisitedDarkForest;
		
		bool VisitedForestFirstTime;
		
		bool HadEloiaDream;
		bool AmbushCutScene;
		
		// -- Chapter 1 Quest Related Flags --
		
		short IntroFight;
		bool SeenCh1JobBoard;
		
		// Perfect Name Quest
		short GolemName;
		bool ShownBentSwordToRonBars;
		bool AlbionGateFixed;

		// Finding the Duke
		short DukeRescue;
		bool SeenSymbols;
		bool AskedGolemAboutSymbols;
		bool KnowOfRemanBook;
		
		bool KilledGuardGolem;
		bool litCaveTorch;
		
		// Sidhe Meeting #1
		
		bool MetMharryon1;
		
		//  -- Chapter 2 Quest Related Flags -- 
		short MobOccuring;
		
		short DolmenQuest;
		bool BloodSealVersion;
		
		short GreenleafFavor;
		short NiallDuel;
		bool hadStatueCutscene;
		short StatueCutSceneSequence;
		
		bool CanSeeInDarkForest;
		short AngusNote;
		short ShadowMageApproaching;
		
		bool SeenDarkSymbol;
		
		short TowerQuest;
		short TowerRiddles;
		
		short DisturbedFernin;
		short DayTheMagicShopReopens;
		
		short RumorsMarvin;

		//short ConalLovesGreenleaf;
		
		//short QstLlewellaHealing;

		//short FoxRescue;

		//short HeroRescue; // Saved by Kara/Greenleaf?

		short FlanaganDebt;
		short FlanaganSum;
		short FlanaganDebtLlewella;
		short FlanaganDebtSigurd;
		short FlanaganDebtThaen;
		short FlanaganRoom;
		
		short LostSpellbook;
		short FamilyBroach;
		short LostLibraryBook;
		short Ingredients;
		short DeirdreSong;

		
		short HeroWantToFixMcWeirdWall;	 // McWeird Wall Quest
		short McWeirdWall;

		//short SheekarIll;		// 
		//short SheekarIllTC;		// Time Count: Hero has 3 days after talking with maren to help Sheekar or she dies
		
		short HeroRescueNiall;	// dlgniall

		short HeroRescued;

		short RogueCaptive;		// initialized in dlgthaen
		//RogueCaptiveDay; 	// initialized in dlgthaen, make sure the quest doesn't last too long.
		//short QstRoguesCaptiveMcWeird;

		//short GlithThiefSign; // dlggilth

		// Tell Veran about these topics only once
		//short VeranBrooch;
		//short VeranAruthredd;
		//short VeranEscapedRogue;

		// Chapter 2 --------------

		short FerninClaySignatures;
		short TethraSuggestRemenBookLibrary;
		short ColletteTiara;
		short CatacombsUnlocked;
		short RemenCaptRing;
		short BelenusBuyStatue;
		short BelenusBuyCandles;
		short BelenusBuyWoodenBox;
		short BelenusBuyLiquid;
		short GiveRonBarsGift;
		short GiveTethraRemenAmulet;
		short GiveTethraNullWater;
		short GiveTethraBlade;
		short Lorichol;
		short Sidhestone;
		short SerlaiInitiation;
		
		// Scene-dependant Flags --

		short advguild21logbook;
		
		short beenInBIHouse1;
		short BIHouse1_TakenSilverBox;
		short BIHouse1_OpenedChest;
		short BIHouse1_TakenBracelets;
		short BIHouse1_FoundFireplaceSilver;
		short Forest166_HighLuckCoin;  //The high luck coin quest

		short armor_graveyd100;

		// Chapter 3 Quest Related Flags --

		short VeranBet;
		
		// Dialog Related Flags --
		
		bool ThaenIntroduced;
		bool AskedThaenAboutLibrary;
		
		short DlgAngus;
		short DlgBand; 		// Seen the band?
		short DlgBelenus;
		short DlgBryanCos;	// Number of times (0,1, or 2) player has talked to Bryan Cos
		short DlgClothiers;
		short DlgCollette;
		short DlgConal;
		short DlgDuke;
		short DlgDeirdre;
		short DlgEvonne;	// Talked to Evonne?
		short DlgFlanagan;
		short DlgFernin;
		short DlgFerninCh2;
		short DlgGewitter;
		short DlgGlith;
		short DlgGreenleaf;	// The first encounter is from Saved by Greenleaf quest
		short DlgHywell;
    short DlgJulian;
		short DlgKara;
		short DlgKilian;
		short DlgLlewella;
		short DlgMaren;
		short DlgMarvin;
		short DlgMcWeird;
		short DlgMharyon;     // When this is 1, you will be in Underhill
		short DlgNiall;
		short DlgOldSailor;
		short DlgPierre;
		short DlgPipawulf;
		short DlgRemenCapt;
		short DlgRowena;
		short DlgSheekar;
		short DlgTethra;
		short DlgSigurd;
		short DlgVeran;
    
    import function Init();
};

struct RiddleData {
  String riddle[6];
  String answer[4];

};

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


import float min(float a, float b);
import float max(float a, float b);

import function InitializeClasses();

import function SaveGame();
import function LoadGame();
import function ExitGame();
import function GameOverDialog(String header, String message);

import bool checkmoney(short s, short g);
import bool herobuy(short s, short g);
import bool PurchaseItem(InventoryItem* i, String msg);
import function heroCollapse();

import function SetRunningMode(short mode);
import function SetSneakingMode(short mode);
import int GetModeView();

import function DisableModeGUI();
import function EnableModeGUI();
import function recallCursorModes();
import int SetBarGraphic(float i);
import int SetBarGraphic2(float i);
import function UpdateCombatLabels();
import function UpdateTopBarLabels();

import bool IsCharacterWithinRoomBounds(Character *c);
import short getEuclideanDistance(short startx, short starty, short endx, short endy);
import bool IsCharacterFacing(Character *from, Character *to);


import int maxInt(int a, int b);
import int minInt(int a, int b);

import int floor(float a);
import int ceil(float a);

import int abs(int a);

import function HandleShadows();

import HeroData heroinfo;
import HeroData fighterData;
import HeroData mageData;
import HeroData thiefData;


import TimeData timeinfo;
import Flags flags;

import short allocate;

import bool northexit;
import bool eastexit;
import bool westexit;
import bool southexit;

import bool hasNorthExit();
import bool hasSouthExit();
import bool hasWestExit();
import bool hasEastExit();

import bool runningMode;
import bool sneakingMode;

import float alertLevel; // thief only
import float regionNoise; // thief only

import short heroPrevX;
import short heroPrevY;

import short riddle_selection[5];
import short riddleCorrect;
import RiddleData riddles[MAX_AVAILABLE_RIDDLES];


import function InitializeRiddles();
import bool AskRiddle(short r);