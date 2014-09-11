// Main header script - this will be included into every script in
// the game (local and global). Do not place functions here; rather,
// place import definitions and #define names here to be used by all
// scripts.

import function CompleteGreenleafFavor();

/* GUI SCRIPT IMPORTS - These imports allow modularization of GUI functions */
/* SpellsGUI Script Functions - A modularization initiative */
import function spellPoint_Click();
import function spellOK_Click();

/* InventoryGUI Script Functions - A modularization initiative */
import function invDown_Click();
import function invOK_Click();
import function invSelect_Click();
import function invUp_Click();

/* IconbarGUI Script Functions - A modularization initiative */
import function iconWalk_Click();
import function iconLook_Click();
import function iconInteract_Click();
import function iconTalk_Click();
import function iconStar_Click();
import function iconMagic_Click();
import function iconCurInv_Click();
import function iconInv_Click();
import function options_Click();

/* OptionsGUI Script Functions - A modularization initiative */
import function saveGame_Click();
import function loadGame_Click();
import function restartGame_Click();
import function quitGame_Click();
import function return_Click();
import function gameSpeedSlider_Change();
import function sliderVolume_Change();
import function sliderDetail_Change();
/* These appear to be from an old implementation of the Options GUI
import function iconSave_Click();
import function iconLoad_Click();
import function iconExit_Click();
import function iconAbout_Click();
*/

/* CombatGUI Script Functions - A modularization initiative */
import function thrust_Click();
import function slash_Click();
import function slice_Click();
import function dodge_Click();
import function block_Click();
import function runAway_Click();
import function flame_Click();

/* CharacterSheetGUI Script Functions - A modularization initiative */
import function addStr_Click();
import function addInt_Click();
import function addAgi_Click();
import function addVit_Click();
import function addLuck_Click();
import function addMagic_Click();
import function addWeaponUse_Click();
import function addParry_Click();
import function addDodge_Click();
import function addThrow_Click();
import function addClimb_Click();
import function addStealth_Click();
import function addLock_Click();
import function subStr_Click();
import function subInt_Click();
import function subAgi_Click();
import function subVit_Click();
import function subLuck_Click();
import function subMagic_Click();
import function subWeaponUse_Click();
import function subParry_Click();
import function subDodge_Click();
import function subThrow_Click();
import function subClimb_Click();
import function subStealth_Click();
import function subLock_Click();
import function back_Click();
import function start_Click();
import function reroll_Click();

/* SubMenuGUI Script Functions - A modularization initiative */
import function viewCharSheet_Click();
import function subClose_Click();
import function time_Click();
import function sneak_Click();
import function run_Click();
import function rest10mins_Click();
import function rest30mins_Click();
import function rest60mins_Click();
import function restCancel_Click();
import function rest_Click();
import function restSleep_Click();

/* NameSelectGUI Script Functions - A modularization initiative */
import function nameCancel_Click();
import function nameOK_Click();

/* GameOverGUI Script Functions - A modularization initiative */
import function gQuit_Click();
import function gRestart_Click();
import function gRestore_Click();
import function gTryAgain_Click();

/* ShortcutsGUI Script Functions - A modularization initiative */
import function warpDF_Click();
import function warpTower_Click();
import function warpGreenleaf_Click();
import function warpAlbion_Click();
import function warpCaves_Click();
import function warpClose_Click();
import function cutEStatue_Click();
import function startBerryDuel_Click();

/* JobBoardGUI Script Functions - A modularization initiative */
import function jobBoardClose_Click();
import function jobPoster1_Click();

/* BookGUI Script Functions - A modularization initiative */
import function bookClose_Click();
import function bookLeft_Click();
import function bookRight_Click();
import function riddleOK_Click();

