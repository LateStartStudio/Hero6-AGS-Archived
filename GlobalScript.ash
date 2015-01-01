// Main header script - this will be included into every script in
// the game (local and global). Do not place functions here; rather,
// place import definitions and #define names here to be used by all
// scripts.

/* INVENTORY SCRIPT IMPORTS - These imports allow modularization of Inventory functions */
import function inv_24a();
import function inv_32a();
import function inv_50a();
import function inv_58a();
import function inv_63a();
import function inv_64a();
import function inv_64b();
import function inv_68a();
import function inv_70a();
import function inv_72a();
import function inv_77a();
import function inv_78a();
import function inv_80a();
import function remenBook_Look();
import function gNote_Look();
import function torch_UseInv();
import function flint_UseInv();

/* CHARACTER SCRIPT IMPORTS - These imports allow modularization of Character functions */
import function VeranPotionResponse();
import function chr_0e();
import function chr_2a();
import function chr_9a();
import function chr_9b();
import function chr_17a();
import function chr_18a();
import function chr_18e();
import function chr_18f();
import function chr_19a();
import function chr_22a();
import function chr_23a();
import function chr_23b();
import function chr_23c();
import function chr_28a();
import function chr_28b();
import function chr_29a();
import function chr_37a();
import function chr_42a();
import function chr_52a();
import function ego_UseInv();
import function guard01_UseInv();
import function thaen_UseInv();
import function veran_UseInv();
import function belenus_UseInv();
import function fernin_UseInv();
import function glith_UseInv();
import function shadowMageDolm_UseInv();
import function ronbars_UseInv();
import function rogueMonster_UseInv();

/* GUI SCRIPT IMPORTS - These imports allow modularization of GUI functions */
/* SpellsGUI Script Functions */
import function spellPoint_Click();
import function spellOK_Click();

/* InventoryGUI Script Functions */
import function invDown_Click();
import function invOK_Click();
import function invSelect_Click();
import function invUp_Click();

/* IconbarGUI Script Functions */
import function iconWalk_Click();
import function iconLook_Click();
import function iconInteract_Click();
import function iconTalk_Click();
import function iconStar_Click();
import function iconMagic_Click();
import function iconCurInv_Click();
import function iconInv_Click();
import function options_Click();

/* OptionsGUI Script Functions */
import function saveGame_Click();
import function loadGame_Click();
import function restartGame_Click();
import function quitGame_Click();
import function return_Click();
import function gameSpeedSlider_Change();
import function sliderVolume_Change();
import function sliderDetail_Change();

/* CombatGUI Script Functions */

import function thrust_Click();
import function slash_Click();
import function slice_Click();
import function dodge_Click();
import function block_Click();
import function runAway_Click();
import function flame_Click();

/* CharacterSheetGUI Script Functions */
import function increaseStat_Click(int stat);
import function decreaseStat_Click(int stat);
import function back_Click();
import function start_Click();
import function reroll_Click();

/* SubMenuGUI Script Functions */
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

/* NameSelectGUI Script Functions */
import function nameCancel_Click();
import function nameOK_Click();

/* GameOverGUI Script Functions */
import function gQuit_Click();
import function gRestart_Click();
import function gRestore_Click();
import function gTryAgain_Click();

/* JobBoardGUI Script Functions */
import function jobBoardClose_Click();
import function jobPoster1_Click();

/* BookGUI Script Functions */
import function bookClose_Click();
import function bookLeft_Click();
import function bookRight_Click();
import function riddleOK_Click();

/* DebugUtilityGUI Script Functions */
import function agsDebug_OnClick(int command, int data);
import function heal_OnClick();
import function maxStats_OnClick();
import function adjustStats_OnClick();
import function giveGold_OnClick();
import function warpToDarkForest_OnClick();
import function warpToTower_OnClick();
import function warpToGreenleaf_OnClick();
import function warpToAlbion_OnClick();
import function warpToCaves_OnClick();
import function warpToEloiaStatue_OnClick();
import function warpToBerryDuel_OnClick();
import function dolmenA_OnClick();
import function dolmenB_OnClick();
import function chapter1Select_OnClick();
import function chapter2Select_OnClick();
import function chapter3Select_OnClick();
