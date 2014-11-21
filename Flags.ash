
#define GREENLEAF_FAVOR_COMPLETE 5

// quest complete codes
struct Flags {

  short Chapter; // Current chapter of the game

  // Generic Flags
  bool FlanaginnRented;
  bool UpperLibraryDoorUnlocked;
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

import Flags flags;
