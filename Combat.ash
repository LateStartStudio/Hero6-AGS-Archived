// Script header for module 'Combat'

import function GenericMonsterUse(Character *m);
import function killAllMonsters();

import function setZapLevel(short z);
import function setAggressiveness(int a);
import bool isMovementEnabled();
import bool setMovementMode(bool set);

import function setCombatDeathMode(bool g);
import short GetNEnemies();
import short DecreaseMonsterHealth(Character* monst, short h);

import function HeroAttack(short attacktype);
import function HeroBlock(short attacktype);

import function initCombatModule();
import function InitCombat();
import function initCombatRoom();
import function InitializeGrid();
import function onEnterRoom_updCombat(short room);
import function updateCombat();

import function runCCombat();
import bool isHeroInCombat();
import bool isHeroDefeated();
import function StopMonsterChasingAll();

import function SpawnEnemyCoords(int enemyType,  short x, short y);
import int SpawnEnemyCoords2(int enemyType, short x, short y);
import function RegisterEnemy(Character *echar, int enemyType);

import bool GridMoveUp(int i);
import bool GridMoveDown(int i);
import bool GridMoveLeft(int i);
import bool GridMoveRight(int i);

import function HeroGridMoveUp();
import function HeroGridMoveDown();
import function HeroGridMoveLeft();
import function HeroGridMoveRight();

//import Character *combatmonster;
//import short monsterIsDead;
//import short enemyHP;


// a combat enemy
struct Enemy { 

	short id;	
	short type;
	String name;	
	Character* echar;

	// boolean states
	bool dead;
	bool searched;
	
	// speed
	short walkSpeed;
	short anmSpeed;
	
	// Hit Frames
	
	short hitFrame1; // hit frame for attack1 - COMPULSORY
	short hitFrame2;
	short hitFrame3;

	// grid pos
	short gridX;
	short gridY;

	// sounds
	short gruntwav;
	short diewav;
	short hitmewav;

	// todo - check if these are needed
	//short combatfunc = ClayGolemCombat,
	//short lookfunc = "StalkerLook",
	//short usefunc = "GenericMonsterUse",
	//short itemdrop;

	// stats
	short hp;
	short mhp;
	short mp;
	short mmp;
	short str;
	short agi;
	short dodge;
	short luck;
	short weaponuse;
	
	// views
	short anmWalk;
	short anmAttack1;
	short anmAttack2;
	short anmAttack3;
	short anmDeath;
	short anmFlinch;
	short anmIdle;
	short anmBlock;
  short anmShoot;

	// monster-only stats
	short mindmg;
	short maxdmg;
	short dmgtype;
	short armor;
	short magicarmor;
	short firearmor;
	short coldarmor;
	
	// money
	short gold;
	short silver;
	
	// currently disabled
	/*
	short itemdrop;
	short magicarmor;
	short firearmor;
	short coldarmor;
	*/
		
	// functions
	import bool isAttacking();
	import bool isBlocking(); 
	import bool isFlinching();
	import function faceHero();
	import short calcHitProb();
	import short calcDamage();
	import short calcDodge();
	import short InflictDamageToHero();
	import short InflictDamageFromHero();
	import function Attack();
	import function Defend();
	import function BeIdle();
	import function Die();
	import function Flinch();
	import function ReactAttack();
  import function shootHero();
	import function updateAI();
	import function updCCombat();
	import function updFCombat();
	import function updFollowHero();
	import function updFollowHeroNewRoom();
	import function genericUse();

};
