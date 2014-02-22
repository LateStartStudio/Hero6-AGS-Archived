AGSScriptModule    Edmundo Ruiz, Tzach Shabtay Module can be used to create programatic in-betweens (tweens) for AGS objects. These animations can be blocking, non blocking, or loop them, and it has acceleration/deceleration timing functions. Tween 1.5 ��  // Main script for module 'Tween'

_TweenObject _tweens[MAX_TWEENS]; // Stores all the tweens in the game
int _longestTweenDuration = 0;

///////////////////////////////////////////////////////////////////////////////
// Utility Functions
///////////////////////////////////////////////////////////////////////////////

#ifdef DEBUG
function _AssertTrue(bool statement, String errorMessage) {
  if (!statement) {
    AbortGame(errorMessage);
  }
}
#endif

/**
 * Gets red value from color integer
 * @param color in AGS-style integer color value
 * @return integer with red value
 */
int GetRFromColor(int color) {
  float floatColor = IntToFloat(color);
  int result = FloatToInt(floatColor / 2048.0) * 8;

  return result;
}

/**
 * Gets green value from color integer
 * @param color in AGS-style integer color value
 * @return integer with green value
 */
int GetGFromColor(int color) {
  float floatColor = IntToFloat(color);
  int result = FloatToInt(( floatColor - IntToFloat(FloatToInt(floatColor / 2048.0) * 2048)) / 64.0) * 8;
  
  return result;
}

/**
 * Gets blue value from color integer
 * @param color in AGS-style integer color value
 * @return integer with blue value
 */
int GetBFromColor(int color) {
  float floatColor = IntToFloat(color);
  
  float withoutR = floatColor - IntToFloat(FloatToInt(floatColor / 2048.0) * 2048);
  int withoutRInt = FloatToInt(withoutR);
  
  float withoutG = withoutR - IntToFloat(FloatToInt(withoutR / 64.0) * 64);
  int withoutGInt = FloatToInt(withoutG);
  
  int result = withoutGInt * 8;

  if (result > 255) {
    result = (withoutGInt - 31) * 8 - 1;
  }

  return result;
}

#ifdef AGS_SUPPORTS_IFVER
#ifver 3.0
#define GET_COLOR_FROM_RGB Game.GetColorFromRGB
#endif
#endif

#ifndef GET_COLOR_FROM_RGB
/**
 * Equivalent to AGS 3.0+ function Game.GetColorFromRGB,
 * it gets the AGS Colour Number for the specified RGB color.
 * @param red red color value (from 0 to 255)
 * @param green green color value (from 0 to 255)
 * @param blue blue color value (from 0 to 255)
 * @return integer with the equivalent AGS Colour Number
 */
int GetColorFromRGB(int red, int green, int blue) {
  int r32 = red / 8;
  int g64 = green / 4;
  int b32 = blue / 8;

  return (2048 * r32) + (32 * g64) + b32;
}
#define GET_COLOR_FROM_RGB GetColorFromRGB
#endif

/*
 * Workaround for the following AGS issues with the new audio system:
 * 1. http://www.bigbluecup.com/yabb/index.php?topic=42186.0
 * 2. http://www.bigbluecup.com/yabb/index.php?topic=45071.0
 */
bool ShouldLeaveAudioAlone(AudioChannel *channel) {
  return (channel == null || Game.SkippingCutscene);
}

/**
 * Converts seconds to AGS "loops"
 *
 * @params seconds the number of seconds
 * @return integer value with the number of loops equivalent to that second
 */
int SecondsToLoops(float seconds) {
  return FloatToInt(IntToFloat(GetGameSpeed()) * seconds, eRoundNearest);
}

function WaitSeconds(float seconds) {
  Wait(SecondsToLoops(seconds));
}

function WaitForTweensToStop() {
  if (_longestTweenDuration > 0) {
    Wait(_longestTweenDuration);
  }
}

int _GetTweenRemainingDuration(int index) {
  return _tweens[index].duration - _tweens[index].frameCount;
}

function _CheckIfIsLongestTween(int index) {
  int remainingDuration = _GetTweenRemainingDuration(index);
  
  if (_tweens[index].style != eReverseRepeatTween &&
      _tweens[index].style != eRepeatTween &&
     remainingDuration > _longestTweenDuration) {     
    _longestTweenDuration = remainingDuration;
  }
}

float GetDistance(int fromX, int fromY, int toX, int toY) {
  return Maths.Sqrt(
    Maths.RaiseToPower(IntToFloat(toX - fromX), 2.0) + 
    Maths.RaiseToPower(IntToFloat(toY - fromX), 2.0)
  );
}

float SpeedToSeconds(float speed, int fromX, int fromY, int toX, int toY) {
  return GetDistance(fromX, fromY, toX, toY) / speed;
}

/**
 * Linear Interpolation
 *
 * @param from is the start value
 * @param to is the final value
 * @param amount is from 0.0 to 1.0, how far along in the lerp it is
 * @return integer value with the current value
 */
int Lerp(int from, int to, float amount) {
  return FloatToInt(IntToFloat(from) + IntToFloat(to - from) * amount, eRoundUp);
}

/**
 * Limits an int between a min and max values
 */
int ClampInt(int value, int min, int max) {
  if (value > max) return max;
  else if (value < min) return min;
  
  return value;
}

float _ComputeTiming(int currentTime, int duration, TweenTiming timingType) {
  float timing = IntToFloat(currentTime) / IntToFloat(duration);

  if (timingType != eLinearTween) {
    float timing2 = Maths.RaiseToPower(timing, 2.0);

    if (timingType == eEaseInTween) {
      timing = ((3.0 * timing2) - (timing2 * timing)) * 0.5;
    }
    else if (timingType == eEaseOutTween) {
      timing = ((3.0 * timing) - (timing2 * timing)) * 0.5;
    }
    else if (timingType == eEaseInEaseOutTween) {
      timing = (3.0 * timing2) - (2.0 * timing * timing2);
    }
  }

  return timing;
}

///////////////////////////////////////////////////////////////////////////////
// Tween Internal Step
///////////////////////////////////////////////////////////////////////////////

/**
 * Where the magic happens, the tween gets updated here.
 * @param amount is from 0.0 to 1.0
 */
function _TweenObject::step(float amount) {
  // GUI step
  if (this.type == _eTweenGUIPosition) {
    gui[this.refID].SetPosition(Lerp(this.fromX, this.toX, amount), Lerp(this.fromY, this.toY, amount));
  }
  if (this.type == _eTweenGUISize) {
    gui[this.refID].SetSize(Lerp(this.fromX, this.toX, amount), Lerp(this.fromY, this.toY, amount));
  }
  else if (this.type == _eTweenGUITransparency) {
    // Workaround for Popup Modal GUIs. If the scripter is fading this in, then make it vsible.
    GUI* refGUI = gui[this.refID];
    if (this.frameCount == 0 && refGUI.Visible == false && refGUI.Transparency == 100) {
      refGUI.Visible = true;
    }

    refGUI.Transparency = Lerp(this.fromX, this.toX, amount);

    // Workaround for Popup Modal GUIs. If the scripter is fading this out, then make it invisble.
    if (this.frameCount == this.duration && refGUI.Visible == true && refGUI.Transparency == 100) {
      refGUI.Visible = false;
    }
  }
  else if (this.type == _eTweenGUIZOrder) {
    gui[this.refID].ZOrder = Lerp(this.fromX, this.toX, amount);
  }
  // OBJECT step
  else if (this.type == _eTweenObjectPosition) {
    object[this.refID].SetPosition(Lerp(this.fromX, this.toX, amount), Lerp(this.fromY, this.toY, amount));
  }
  else if (this.type == _eTweenObjectTransparency) {
    Object *objectRef = object[this.refID];
    if (this.frameCount == 0 && objectRef.Visible == false && objectRef.Transparency == 100) {
      objectRef.Visible = true;
    }

    objectRef.Transparency = Lerp(this.fromX, this.toX, amount);

    if (this.frameCount == this.duration && objectRef.Visible == true && objectRef.Transparency == 100) {
      objectRef.Visible = false;
    }
  }
  // CHARACTER step
  else if (this.type == _eTweenCharacterPosition) {
    character[this.refID].x = Lerp(this.fromX, this.toX, amount);
    character[this.refID].y = Lerp(this.fromY, this.toY, amount);
  }
  else if (this.type == _eTweenCharacterScaling) {
    character[this.refID].Scaling = Lerp(this.fromX, this.toX, amount);
  }
  else if (this.type == _eTweenCharacterTransparency) {
    character[this.refID].Transparency = Lerp(this.fromX, this.toX, amount);
  }
  else if (this.type == _eTweenCharacterAnimationSpeed) {
    character[this.refID].AnimationSpeed = Lerp(this.fromX, this.toX, amount);
  }
  // REGION step
  else if (this.type == _eTweenRegionLightLevel) {
    region[this.refID].LightLevel = Lerp(this.fromX, this.toX, amount);
  }
  else if (this.type == _eTweenRegionTintR) {
    int saturation = region[this.refID].TintSaturation;
    if (saturation < 0) saturation = 0;
    region[this.refID].Tint(Lerp(this.fromX, this.toX, amount), region[this.refID].TintGreen, region[this.refID].TintBlue, saturation);
  }
  else if (this.type == _eTweenRegionTintG) {
    int saturation = region[this.refID].TintSaturation;
    if (saturation < 0) saturation = 0;
    region[this.refID].Tint(region[this.refID].TintRed, Lerp(this.fromX, this.toX, amount), region[this.refID].TintBlue, saturation);
  }
  else if (this.type == _eTweenRegionTintB) {
    int saturation = region[this.refID].TintSaturation;
    if (saturation < 0) saturation = 0;
    region[this.refID].Tint(region[this.refID].TintRed, region[this.refID].TintGreen, Lerp(this.fromX, this.toX, amount), saturation);
  }
  else if (this.type == _eTweenRegionTintAmount) {
    int saturation = Lerp(this.fromX, this.toX, amount);
    if (saturation < 0) saturation = 0;
    region[this.refID].Tint(region[this.refID].TintRed, region[this.refID].TintGreen, region[this.refID].TintBlue, saturation);
  }
  // GUICONTROL step
  else if (this.type == _eTweenGUIControlPosition) {
    this.guiControlRef.SetPosition(Lerp(this.fromX, this.toX, amount), Lerp(this.fromY, this.toY, amount));
  }
  else if (this.type == _eTweenGUIControlSize) {
    this.guiControlRef.SetSize(Lerp(this.fromX, this.toX, amount), Lerp(this.fromY, this.toY, amount));
  }
  // LABEL step
  else if (this.type == _eTweenLabelColorR) {
    this.guiControlRef.AsLabel.TextColor = GET_COLOR_FROM_RGB(Lerp(this.fromX, this.toX, amount), GetGFromColor(this.guiControlRef.AsLabel.TextColor), GetBFromColor(this.guiControlRef.AsLabel.TextColor));
  }
  else if (this.type == _eTweenLabelColorG) {
    this.guiControlRef.AsLabel.TextColor = GET_COLOR_FROM_RGB(GetRFromColor(this.guiControlRef.AsLabel.TextColor), Lerp(this.fromX, this.toX, amount), GetBFromColor(this.guiControlRef.AsLabel.TextColor));
  }
  else if (this.type == _eTweenLabelColorB) {
    this.guiControlRef.AsLabel.TextColor = GET_COLOR_FROM_RGB(GetRFromColor(this.guiControlRef.AsLabel.TextColor), GetGFromColor(this.guiControlRef.AsLabel.TextColor), Lerp(this.fromX, this.toX, amount));
  }
  // BUTTON step
  else if (this.type == _eTweenButtonColorR) {
    this.guiControlRef.AsButton.TextColor = GET_COLOR_FROM_RGB(Lerp(this.fromX, this.toX, amount), GetGFromColor(this.guiControlRef.AsButton.TextColor), GetBFromColor(this.guiControlRef.AsButton.TextColor));
  }
  else if (this.type == _eTweenButtonColorG) {
    this.guiControlRef.AsButton.TextColor = GET_COLOR_FROM_RGB(GetRFromColor(this.guiControlRef.AsButton.TextColor), Lerp(this.fromX, this.toX, amount), GetBFromColor(this.guiControlRef.AsButton.TextColor));
  }
  else if (this.type == _eTweenButtonColorB) {
    this.guiControlRef.AsButton.TextColor = GET_COLOR_FROM_RGB(GetRFromColor(this.guiControlRef.AsButton.TextColor), GetGFromColor(this.guiControlRef.AsButton.TextColor), Lerp(this.fromX, this.toX, amount));
  }
  // TEXTBOX step
#ifdef AGS_SUPPORTS_IFVER
#ifver 3.1
  else if (this.type == _eTweenTextBoxColorR) {
    this.guiControlRef.AsTextBox.TextColor = GET_COLOR_FROM_RGB(Lerp(this.fromX, this.toX, amount), GetGFromColor(this.guiControlRef.AsTextBox.TextColor), GetBFromColor(this.guiControlRef.AsTextBox.TextColor));
  }
  else if (this.type == _eTweenTextBoxColorG) {
    this.guiControlRef.AsTextBox.TextColor = GET_COLOR_FROM_RGB(GetRFromColor(this.guiControlRef.AsTextBox.TextColor), Lerp(this.fromX, this.toX, amount), GetBFromColor(this.guiControlRef.AsTextBox.TextColor));
  }
  else if (this.type == _eTweenTextBoxColorB) {
    this.guiControlRef.AsTextBox.TextColor = GET_COLOR_FROM_RGB(GetRFromColor(this.guiControlRef.AsTextBox.TextColor), GetGFromColor(this.guiControlRef.AsTextBox.TextColor), Lerp(this.fromX, this.toX, amount));
  }
#endif
#endif
  // LISTBOX step
  else if (this.type == _eTweenListBoxSelectedItem) {
    this.guiControlRef.AsListBox.SelectedIndex = Lerp(this.fromX, this.toX, amount);
  }
  else if (this.type == _eTweenListBoxTopItem) {
    this.guiControlRef.AsListBox.TopItem = Lerp(this.fromX, this.toX, amount);
  }
  // SLIDER step
  else if (this.type == _eTweenSliderValue) {
    this.guiControlRef.AsSlider.Value =  Lerp(this.fromX, this.toX, amount);
  }
#ifdef AGS_SUPPORTS_IFVER
#ifver 3.1
  else if (this.type == _eTweenSliderHandleOffset) {
    this.guiControlRef.AsSlider.HandleOffset = Lerp(this.fromX, this.toX, amount);
  }
#endif
#endif
  // INVWINDOW step
  else if (this.type == _eTweenInvWindowTopItem) {
    this.guiControlRef.AsInvWindow.TopItem = Lerp(this.fromX, this.toX, amount);
  }
  // MISC step
  else if (this.type == _eTweenViewportX) {
    SetViewport(Lerp(this.fromX, this.toX, amount), GetViewportY());
  }
  else if (this.type == _eTweenViewportY) {
    SetViewport(GetViewportX(), Lerp(this.fromY, this.toY, amount));
  }
  else if (this.type == _eTweenViewportXY) {
    SetViewport(Lerp(this.fromX, this.toX, amount), Lerp(this.fromY, this.toY, amount));
  }
  else if (this.type == _eTweenGamma) {
    System.Gamma = Lerp(this.fromX, this.toX, amount);
  }
  else if (this.type == _eTweenShakeScreen) {
    ShakeScreenBackground(Lerp(this.fromX, this.toX, amount), Lerp(this.fromY, this.toY, amount), 1);
  }
  else if (this.type == _eTweenAreaScaling) {
    SetAreaScaling(this.refID, Lerp(this.fromX, this.toX, amount), Lerp(this.fromY, this.toY, amount));
  }
  // AUDIO step
  else if (this.type == _eTweenSpeechVolume) {
    SetSpeechVolume(Lerp(this.fromX, this.toX, amount));
  }
  // Pre AGS 3.2 strict audio
#ifndef STRICT_AUDIO
  else if (this.type == _eTweenMusicMasterVolume) {
    SetMusicMasterVolume(Lerp(this.fromX, this.toX, amount));
  }
  else if (this.type == _eTweenDigitalMasterVolume) {
    SetDigitalMasterVolume(Lerp(this.fromX, this.toX, amount));
  }
  else if (this.type == _eTweenSoundVolume) {
    SetSoundVolume(Lerp(this.fromX, this.toX, amount));
  }
  else if (this.type == _eTweenChannelVolume) {
    SetChannelVolume(this.refID, Lerp(this.fromX, this.toX, amount));
  }
#endif
  // AGS 3.2+ strict audio
#ifdef STRICT_AUDIO
  else if (this.type == _eTweenSystemVolume) {
    System.Volume = Lerp(this.fromX, this.toX, amount);
  }
  else if (this.type == _eTweenAudioChannelVolume) {
    AudioChannel* channel = System.AudioChannels[this.refID];
    if (ShouldLeaveAudioAlone(channel)) return;
    channel.Volume = Lerp(this.fromX, this.toX, amount);
  }
  else if (this.type == _eTweenAudioChannelRoomLocation) {
    AudioChannel* channel = System.AudioChannels[this.refID];
    if (ShouldLeaveAudioAlone(channel)) return;
    channel.SetRoomLocation(Lerp(this.fromX, this.toX, amount), Lerp(this.fromY, this.toY, amount));
  }
  else if (this.type == _eTweenAudioChannelPanning) {
    AudioChannel* channel = System.AudioChannels[this.refID];
    if (ShouldLeaveAudioAlone(channel)) return;
    channel.Panning = Lerp(this.fromX, this.toX, amount);
  }
#endif
}

/**
 * Resets and stops all the tweens
 */
function _CleanupTweens() {
  short i = 0;

  while (i < MAX_TWEENS) {
    if (_tweens[i].duration != -1) {
      _tweens[i].step(0.0);
      _tweens[i].duration = -1;
    }

    i++;
  }
}

///////////////////////////////////////////////////////////////////////////////
// AGS Events
///////////////////////////////////////////////////////////////////////////////

function game_start() {
  // Initialize all the internal tween data on game start
  short i = 0;
  while (i < MAX_TWEENS) {
    _tweens[i].duration = -1;
    i++;
  }
}

function repeatedly_execute_always() {
  // Steps through every active tween
  short i = 0;

  _longestTweenDuration = 0;
  while (i < MAX_TWEENS) {
    if (_tweens[i].duration > 0) {
      // Compute the amount based on the timing type
      float amount = _ComputeTiming(
        _tweens[i].frameCount,
        _tweens[i].duration,
        _tweens[i].timing
        );

      // Update the tween
      _tweens[i].step(amount);
      _tweens[i].frameCount++;

      // Repeat tween if needed
      if (_tweens[i].frameCount > _tweens[i].duration) {
        if (_tweens[i].style == eRepeatTween) {
          _tweens[i].frameCount = 0;
        }
        else if (_tweens[i].style == eReverseRepeatTween) {
          short fromX = _tweens[i].toX;
          short fromY = _tweens[i].toY;

          _tweens[i].toX = _tweens[i].fromX;
          _tweens[i].toY = _tweens[i].fromY;
          _tweens[i].fromX = fromX;
          _tweens[i].fromY = fromY;
          
          // Reverse the timing function if needed.
          if (_tweens[i].timing == eEaseOutTween) {
            _tweens[i].timing = eEaseInTween;
          }
          else if (_tweens[i].timing == eEaseInTween) {
            _tweens[i].timing = eEaseOutTween;
          }

          _tweens[i].frameCount = 0;
        }
        else {
          _tweens[i].duration = -1;
        }
      }
      else {
        _CheckIfIsLongestTween(i);
      }
    }

    i++;
  }
}

function on_event(EventType event, int data) {
  if (event == eEventLeaveRoom) {
    // If the player leaves the room, reset and stop tweens
    _CleanupTweens();
  }
}

///////////////////////////////////////////////////////////////////////////////
// Tween Construction
///////////////////////////////////////////////////////////////////////////////

/*
 * Finds and returns an available tween spot
 *
 * @return integer index in the _tweens array that is available.
 */
int _GetAvailableTweenSpot() {
  short i = 0;
  short spot = -1;

  // Pretty simple linear search for an available spot
  while (i < MAX_TWEENS && spot == -1) {
    if (_tweens[i].duration == -1) {
      spot = i;
    }

    i++;
  }

#ifdef DEBUG
  // Let the scripter know that tweens are maxed out, but ignore it completely in the non-debug version.
  _AssertTrue(spot >= 0, String.Format("Cannot create new tween because the Tween module is currently playing %d tween(s), which is the maximum. You can increase this max number on the Tween module script header.", MAX_TWEENS));
#endif

  return spot;
}

// Internal
// Creates and starts a new tween
int _StartTween(_TweenType type, float seconds, short toX, short toY, short fromX, short fromY,
  _TweenReferenceType refType, int refID, GUIControl* guiControlRef, TweenTiming timing, TweenStyle style) {
  
  short index = _GetAvailableTweenSpot();
  
#ifdef DEBUG
  // Make sure the index is good. This should not happen to scripters ever.
  _AssertTrue(index >= 0 && index < MAX_TWEENS, "Cannot create Tween. Invalid index!");
#endif

  _tweens[index].type = type;
  _tweens[index].toX = toX;
  _tweens[index].toY = toY;
  _tweens[index].fromX = fromX;
  _tweens[index].fromY = fromY;
  _tweens[index].refType = refType;
  _tweens[index].refID = refID;
  _tweens[index].guiControlRef = guiControlRef;
  _tweens[index].duration = SecondsToLoops(seconds);
  _tweens[index].frameCount = 0;
  _tweens[index].timing = timing;
  _tweens[index].style = style;
  
  _CheckIfIsLongestTween(index);

  if (_tweens[index].style == eBlockTween) {
    Wait(_tweens[index].duration + 1);
  }
  else {
    return _tweens[index].duration + 1;
  }

  return 1;
}

// Internal
// Tween "constructors"
int _StartGUITween(_TweenType type, float seconds, short toX, short toY, short fromX, short fromY,
    GUI* guiRef, TweenTiming timing, TweenStyle style) {
  return _StartTween(type, seconds, toX, toY, fromX, fromY, _eTweenReferenceGUI, guiRef.ID, null, timing, style);
}
int _StartGUITweenBySpeed(_TweenType type, float speed, short toX, short toY, short fromX, short fromY,
    GUI* guiRef, TweenTiming timing, TweenStyle style) {
  return _StartGUITween(type, SpeedToSeconds(speed, fromX, fromY, toX, toY), toX, toY, fromX, fromY, guiRef, timing, style);
}

int _StartObjectTween(_TweenType type, float seconds, short toX, short toY, short fromX, short fromY,
    Object* objectRef, TweenTiming timing, TweenStyle style) {
  return _StartTween(type, seconds, toX, toY, fromX, fromY, _eTweenReferenceObject, objectRef.ID, null, timing, style);
}
int _StartObjectTweenBySpeed(_TweenType type, float speed, short toX, short toY, short fromX, short fromY,
    Object* objectRef, TweenTiming timing, TweenStyle style) {
  return _StartObjectTween(type, SpeedToSeconds(speed, fromX, fromY, toX, toY), toX, toY, fromX, fromY, objectRef, timing, style);
}

int _StartCharacterTween(_TweenType type, float seconds, short toX, short toY, short fromX, short fromY,
    Character* characterRef, TweenTiming timing, TweenStyle style) {
  return _StartTween(type, seconds, toX, toY, fromX, fromY, _eTweenReferenceCharacter, characterRef.ID, null, timing, style);
}
int _StartCharacterTweenBySpeed(_TweenType type, float speed, short toX, short toY, short fromX, short fromY,
    Character* characterRef, TweenTiming timing, TweenStyle style) {
  return _StartCharacterTween(type, SpeedToSeconds(speed, fromX, fromY, toX, toY), toX, toY, fromX, fromY, characterRef, timing, style);
}

int _StartRegionTween(_TweenType type, float seconds, short toX, short toY, short fromX, short fromY,
    Region* regionRef, TweenTiming timing, TweenStyle style) {
  return _StartTween(type, seconds, toX, toY, fromX, fromY, _eTweenReferenceRegion, regionRef.ID, null, timing, style);
}

int _StartGUIControlTween(_TweenType type, float seconds, short toX, short toY, short fromX, short fromY,
    GUIControl* guiControlRef, TweenTiming timing, TweenStyle style) {
  return _StartTween(type, seconds, toX, toY, fromX, fromY, _eTweenReferenceGUIControl, 0, guiControlRef, timing, style);
}
int _StartGUIControlTweenBySpeed(_TweenType type, float speed, short toX, short toY, short fromX, short fromY,
    GUIControl* guiControlRef, TweenTiming timing, TweenStyle style) {
  return _StartGUIControlTween(type, SpeedToSeconds(speed, fromX, fromY, toX, toY), toX, toY, fromX, fromY, guiControlRef, timing, style);
}

int _StartMiscTween(_TweenType type, float seconds, short toX, short toY, short fromX, short fromY, int id,
    TweenTiming timing, TweenStyle style) {
  return _StartTween(type, seconds, toX, toY, fromX, fromY, _eTweenReferenceMisc, id, null, timing, style);
}
int _StartMiscTweenBySpeed(_TweenType type, float speed, short toX, short toY, short fromX, short fromY, int id,
    TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(type, SpeedToSeconds(speed, fromX, fromY, toX, toY), toX, toY, fromX, fromY, id, timing, style);
}

///////////////////////////////////////////////////////////////////////////////
// Public Tween Functions
///////////////////////////////////////////////////////////////////////////////

// GUI Tweens
int TweenGUIPosition(GUI* guiRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return _StartGUITween(_eTweenGUIPosition, seconds, toX, toY, guiRef.X, guiRef.Y, guiRef, timing, style);
}
int TweenGUIPositionBySpeed(GUI* guiRef, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return _StartGUITweenBySpeed(_eTweenGUIPosition, speed, toX, toY, guiRef.X, guiRef.Y, guiRef, timing, style);
}
int TweenGUIZOrder(GUI* guiRef, float seconds, short toZOrder, TweenTiming timing, TweenStyle style) {
  return _StartGUITween(_eTweenGUIZOrder, seconds, toZOrder, 0, guiRef.ZOrder, 0, guiRef, timing, style);
}
int TweenGUITransparency(GUI* guiRef, float seconds, short toTransparency, TweenTiming timing, TweenStyle style) {
  return _StartGUITween(_eTweenGUITransparency, seconds, toTransparency, 0, guiRef.Transparency, 0, guiRef, timing, style);
}
int TweenGUISize(GUI* guiRef, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return _StartGUITween(_eTweenGUISize, seconds, toWidth, toHeight, guiRef.Width, guiRef.Height, guiRef, timing, style);
}

// OBJECT Tweens
int TweenObjectPosition(Object* objectRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return _StartObjectTween(_eTweenObjectPosition, seconds, toX, toY, objectRef.X, objectRef.Y, objectRef, timing, style);
}
int TweenObjectPositionBySpeed(Object* objectRef, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return _StartObjectTweenBySpeed(_eTweenObjectPosition, speed, toX, toY, objectRef.X, objectRef.Y, objectRef, timing, style);
}
int TweenObjectTransparency(Object* objectRef, float seconds, short toTransparency, TweenTiming timing, TweenStyle style) {
  return _StartObjectTween(_eTweenObjectTransparency, seconds, toTransparency, 0, objectRef.Transparency, 0, objectRef, timing, style);
}
int TweenObjectImage(Object* objectRef, Object* tmpObjectRef, float seconds, short toSprite, TweenTiming timing, TweenStyle style) {
  tmpObjectRef.Graphic = objectRef.Graphic;
  tmpObjectRef.SetPosition(objectRef.X, objectRef.Y);
  tmpObjectRef.Transparency = 0;
  tmpObjectRef.Visible = true;

  objectRef.Transparency = 100;
  objectRef.Graphic = toSprite;

  if (style == eBlockTween) {
    TweenObjectTransparency(tmpObjectRef, seconds, 100, timing, eNoBlockTween);
  }
  else {
    TweenObjectTransparency(tmpObjectRef, seconds, 100, timing, style);
  }
  
  return TweenObjectTransparency(objectRef, seconds, 0, timing, style);
}

// CHARACTER Tweens
int TweenCharacterPosition(Character* characterRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return _StartCharacterTween(_eTweenCharacterPosition, seconds, toX, toY, characterRef.x, characterRef.y, characterRef, timing, style);
}
int TweenCharacterPositionBySpeed(Character* characterRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return _StartCharacterTweenBySpeed(_eTweenCharacterPosition, seconds, toX, toY, characterRef.x, characterRef.y, characterRef, timing, style);
}
int TweenCharacterScaling(Character* characterRef, float seconds, short toScaling, TweenTiming timing, TweenStyle style) {
  if (!characterRef.ManualScaling) {
    characterRef.ManualScaling = true;
  }
  return _StartCharacterTween(_eTweenCharacterScaling, seconds, toScaling, 0, characterRef.Scaling, 0, characterRef, timing, style);
}
int TweenCharacterTransparency(Character* characterRef, float seconds, short toTransparency, TweenTiming timing, TweenStyle style) {
  return _StartCharacterTween(_eTweenCharacterTransparency, seconds, toTransparency, 0, characterRef.Transparency, 0, characterRef, timing, style);
}
int TweenCharacterAnimationSpeed(Character* characterRef, float seconds, short toAnimationSpeed, TweenTiming timing, TweenStyle style) {
  return _StartCharacterTween(_eTweenCharacterAnimationSpeed, seconds, toAnimationSpeed, 0, characterRef.AnimationSpeed, 0, characterRef, timing, style);
}

// REGION Tweens
int TweenRegionLightLevel(Region* regionRef, float seconds, short toLightLevel, TweenTiming timing, TweenStyle style) {
  return _StartRegionTween(_eTweenRegionLightLevel, seconds, toLightLevel, 0, regionRef.LightLevel, 0, regionRef, timing, style);
}
int TweenRegionTintR(Region* regionRef, float seconds, short toR, TweenTiming timing, TweenStyle style) {
  return _StartRegionTween(_eTweenRegionTintR, seconds, toR, 0, regionRef.TintRed, 0, regionRef, timing, style);
}
int TweenRegionTintG(Region* regionRef, float seconds, short toG, TweenTiming timing, TweenStyle style) {
  return _StartRegionTween(_eTweenRegionTintG, seconds, toG, 0, regionRef.TintGreen, 0, regionRef, timing, style);
}
int TweenRegionTintB(Region* regionRef, float seconds, short toB, TweenTiming timing, TweenStyle style) {
  return _StartRegionTween(_eTweenRegionTintB, seconds, toB, 0, regionRef.TintBlue, 0, regionRef, timing, style);
}
int TweenRegionTintAmount(Region* regionRef, float seconds, short toAmount, TweenTiming timing, TweenStyle style) {
  return _StartRegionTween(_eTweenRegionTintAmount, seconds, toAmount, 0, regionRef.TintSaturation, 0, regionRef, timing, style);
}
int TweenRegionTintBlackAndWhite(Region* regionRef, float seconds, TweenTiming timing, TweenStyle style) {
  if (style == eBlockTween) {
    TweenRegionTintR(regionRef, seconds, 255, timing, eNoBlockTween);
    TweenRegionTintG(regionRef, seconds, 255, timing, eNoBlockTween);
    TweenRegionTintB(regionRef, seconds, 255, timing, eNoBlockTween);
  }
  else {
    TweenRegionTintR(regionRef, seconds, 255, timing, style);
    TweenRegionTintG(regionRef, seconds, 255, timing, style);
    TweenRegionTintB(regionRef, seconds, 255, timing, style);
  }
  return TweenRegionTintAmount(regionRef, seconds, 100, timing, style);
}

// GUIControl Tweens
int TweenGUIControlPosition(GUIControl* guiControlRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return _StartGUIControlTween(_eTweenGUIControlPosition, seconds, toX, toY, guiControlRef.X, guiControlRef.Y, guiControlRef, timing, style);
}
int TweenGUIControlPositionBySpeed(GUIControl* guiControlRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return _StartGUIControlTweenBySpeed(_eTweenGUIControlPosition, seconds, toX, toY, guiControlRef.X, guiControlRef.Y, guiControlRef, timing, style);
}
int TweenGUIControlSize(GUIControl* guiControlRef, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return _StartGUIControlTween(_eTweenGUIControlSize, seconds, toWidth, toHeight, guiControlRef.Width, guiControlRef.Height, guiControlRef, timing, style);
}

#ifndef TWEEN_1_2_LEGACY_FUNCTIONS_DISABLED
// Legacy GUI Control Specific Functions (Deprecated after Tween 1.2)
int TweenLabelPosition(Label* labelRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(labelRef, seconds, toX, toY, timing, style);
}
int TweenLabelSize(Label* labelRef, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(labelRef, seconds, toWidth, toHeight, timing, style);
}

int TweenButtonPosition(Button* buttonRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(buttonRef, seconds, toX, toY, timing, style);
}
int TweenButtonSize(Button* buttonRef, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(buttonRef, seconds, toWidth, toHeight, timing, style);
}

int TweenTextBoxPosition(TextBox* textBoxRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(textBoxRef, seconds, toX, toY, timing, style);
}
int TweenTextBoxSize(TextBox* textBoxRef, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(textBoxRef, seconds, toWidth, toHeight, timing, style);
}

int TweenListBoxPosition(ListBox* listBoxRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(listBoxRef, seconds, toX, toY, timing, style);
}
int TweenListBoxSize(ListBox* listBoxRef, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(listBoxRef, seconds, toWidth, toHeight, timing, style);
}
int TweenSliderPosition(Slider* sliderRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(sliderRef, seconds, toX, toY, timing, style);
}
int TweenSliderSize(Slider* sliderRef, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(sliderRef, seconds, toWidth, toHeight, timing, style);
}

int TweenInvWindowPosition(InvWindow* invWindowRef, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(invWindowRef, seconds, toX, toY, timing, style);
}
#endif

// LABEL Tweens
int TweenLabelColorR(Label* labelRef, float seconds, short toR, TweenTiming timing, TweenStyle style) {
  int fromR = GetRFromColor(labelRef.TextColor);
  return _StartGUIControlTween(_eTweenLabelColorR, seconds, toR, 0, fromR, 0, labelRef, timing, style);
}

int TweenLabelColorG(Label* labelRef, float seconds, short toG, TweenTiming timing, TweenStyle style) {
  int fromG = GetGFromColor(labelRef.TextColor);
  return _StartGUIControlTween(_eTweenLabelColorG, seconds, toG, 0, fromG, 0, labelRef, timing, style);
}
int TweenLabelColorB(Label* labelRef, float seconds, short toB, TweenTiming timing, TweenStyle style) {
  int fromB = GetBFromColor(labelRef.TextColor);
  return _StartGUIControlTween(_eTweenLabelColorB, seconds, toB, 0, fromB, 0, labelRef, timing, style);
}

// BUTTON Tweens
int TweenButtonColorR(Button* buttonRef, float seconds, short toR, TweenTiming timing, TweenStyle style) {
  int fromR = GetRFromColor(buttonRef.TextColor);
  return _StartGUIControlTween(_eTweenButtonColorR, seconds, toR, 0, fromR, 0, buttonRef, timing, style);
}
int TweenButtonColorG(Button* buttonRef, float seconds, short toG, TweenTiming timing, TweenStyle style) {
  int fromG = GetGFromColor(buttonRef.TextColor);
  return _StartGUIControlTween(_eTweenButtonColorG, seconds, toG, 0, fromG, 0, buttonRef, timing, style);
}
int TweenButtonColorB(Button* buttonRef, float seconds, short toB, TweenTiming timing, TweenStyle style) {
  int fromB = GetBFromColor(buttonRef.TextColor);
  return _StartGUIControlTween(_eTweenButtonColorB, seconds, toB, 0, fromB, 0, buttonRef, timing, style);
}

// LIST BOX Tweens
int TweenListBoxSelectedItem(ListBox* listBoxRef, float seconds, short toSelectedItem, TweenTiming timing, TweenStyle style) {
  return _StartGUIControlTween(_eTweenListBoxSelectedItem, seconds, toSelectedItem, 0, listBoxRef.SelectedIndex, 0, listBoxRef, timing, style);
}
int TweenListBoxTopItem(ListBox* listBoxRef, float seconds, short toTopItem, TweenTiming timing, TweenStyle style) {
  return _StartGUIControlTween(_eTweenListBoxTopItem, seconds, toTopItem, 0, listBoxRef.TopItem, 0, listBoxRef, timing, style);
}

// SLIDER Tweens
int TweenSliderValue(Slider* sliderRef, float seconds, short toValue, TweenTiming timing, TweenStyle style) {
  return _StartGUIControlTween(_eTweenSliderValue, seconds, toValue, 0, sliderRef.Value, 0, sliderRef, timing, style);
}

// INVWINDOW Tweens
int TweenInvWindowSize(InvWindow* invWindowRef, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(invWindowRef, seconds, toWidth, toHeight, timing, style);
}
int TweenInvWindowTopItem(InvWindow* invWindowRef, float seconds, short toTopItem, TweenTiming timing, TweenStyle style) {
  return _StartGUIControlTween(_eTweenInvWindowTopItem, seconds, toTopItem, 0, invWindowRef.TopItem, 0, invWindowRef, timing, style);
}

// MISC Tweens
int TweenViewportX(float seconds, short toX, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenViewportX, seconds, toX, 0, GetViewportX(), 0, 0, timing, style);
}
int TweenViewportY(float seconds, short toY, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenViewportY, seconds, 0, toY, 0, GetViewportY(), 0, timing, style);
}
int TweenViewportXBySpeed(float speed, short toX, TweenTiming timing, TweenStyle style) {
  return _StartMiscTweenBySpeed(_eTweenViewportX, speed, toX, 0, GetViewportX(), 0, 0, timing, style);
}
int TweenViewportYBySpeed(float speed, short toY, TweenTiming timing, TweenStyle style) {
  return _StartMiscTweenBySpeed(_eTweenViewportY, speed, 0, toY, 0, GetViewportY(), 0, timing, style);
}
int TweenViewportPosition(float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenViewportXY, seconds, toX, toY, GetViewportX(), GetViewportY(), 0, timing, style);
}
int TweenViewportPositionBySpeed(float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return _StartMiscTweenBySpeed(_eTweenViewportXY, speed, toX, toY, GetViewportX(), GetViewportY(), 0, timing, style);
}
int TweenGamma(float seconds, short toGamma, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenGamma, seconds, toGamma, 0, System.Gamma, 0, 0, timing, style);
}
int TweenShakeScreen(float seconds, short fromDelay, short toDelay, short fromAmount, short toAmount, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenShakeScreen, seconds,  toDelay, toAmount, fromDelay, fromAmount, 0, timing, style);
}
int TweenAreaScaling(float seconds, int area, short fromMin, short toMin, short fromMax, short toMax, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenAreaScaling, seconds, toMin, toMax, fromMin, fromMax, area, timing, style);
}

// AUDIO Tweens
int TweenSpeechVolume(float seconds, short fromVolume, short toVolume, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenSpeechVolume, seconds, toVolume, 0, fromVolume, 0, 0, timing, style);
}
#ifndef STRICT_AUDIO
// Pre 3.2 Strict Audio Tweens
int TweenMusicMasterVolume(float seconds, short fromVolume, short toVolume, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenMusicMasterVolume, seconds, toVolume, 0, fromVolume, 0, 0, timing, style);
}
int TweenDigitalMasterVolume(float seconds, short fromVolume, short toVolume, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenDigitalMasterVolume, seconds, toVolume, 0, fromVolume, 0, 0, timing, style);
}
int TweenSoundVolume(float seconds, short fromVolume, short toVolume, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenSoundVolume, seconds, toVolume, 0, fromVolume, 0, 0, timing, style);
}
int TweenChannelVolume(float seconds, int channel, short fromVolume, short toVolume, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenChannelVolume, seconds, toVolume, 0, fromVolume, 0, channel, timing, style);
}
#endif

///////////////////////////////////////////////////////////////////////////////
// Tween Stoppers
///////////////////////////////////////////////////////////////////////////////

/**
  * Stops a tween
  *
  * @param index which tween in the _tweens array to stop
  * @param result how to stop the tween:
  *   ePauseTween will leave it as it is
  *   eFinishTween will carry it to the end
  *   eResetTween will bring it back to where it was
  */
function _StopTween(short index, TweenStopResult result) {
  if (_tweens[index].duration != -1) {
    if (result == eFinishTween) {
      _tweens[index].step(1.0);
    }
    else if (result == eResetTween) {
      _tweens[index].step(0.0);
    }
    
    _tweens[index].duration = -1;
  }
}

// Internal Function, stops all tweens for a particular ags object
function _StopTweens(_TweenReferenceType refType, int refID, TweenStopResult result) {
  short i = 0;
  while (i < MAX_TWEENS) {
    if (_tweens[i].refType == refType && _tweens[i].refID == refID) {
      _StopTween(i, result);
    }
    i++;
  }
}

// Stop (2.7 Style)
function TweenStopAllForGUI(GUI* guiRef, TweenStopResult result) {
  _StopTweens(_eTweenReferenceGUI, guiRef.ID, result);
}
function TweenStopAllForObject(Object* objectRef, TweenStopResult result) {
  _StopTweens(_eTweenReferenceObject, objectRef.ID, result);
}
function TweenStopAllForCharacter(Character* characterRef, TweenStopResult result) {
  _StopTweens(_eTweenReferenceCharacter, characterRef.ID, result);
}
function TweenStopAllForRegion(Region* regionRef, TweenStopResult result) {
  _StopTweens(_eTweenReferenceRegion, regionRef.ID, result);
}

function TweenStopAllForGUIControl(GUIControl* guiControlRef, TweenStopResult result) {
  short i = 0;
  while (i < MAX_TWEENS) {
    if (_tweens[i].guiControlRef == guiControlRef) {
      _StopTween(i, result);
    }
    i++;
  }
}

#ifndef TWEEN_1_2_LEGACY_FUNCTIONS_DISABLED
// Legacy Functions (Deprecated after Tween 1.2)
function TweenStopAllForLabel(Label* labelRef, TweenStopResult result) {
  TweenStopAllForGUIControl(labelRef, result);
}
function TweenStopAllForButton(Button* buttonRef, TweenStopResult result) {
  TweenStopAllForGUIControl(buttonRef, result);
}
function TweenStopAllForTextBox(TextBox* textBoxRef, TweenStopResult result) {
  TweenStopAllForGUIControl(textBoxRef, result);
}
function TweenStopAllForListBox(ListBox* listBoxRef, TweenStopResult result) {
  TweenStopAllForGUIControl(listBoxRef, result);
}
function TweenStopAllForSlider(Slider* sliderRef, TweenStopResult result) {
  TweenStopAllForGUIControl(sliderRef, result);
}
function TweenStopAllForInvWindow(InvWindow* invWindowRef, TweenStopResult result) {
  TweenStopAllForGUIControl(invWindowRef, result);
}
#endif

function TweenStopAll(TweenStopResult result) {
  short i = 0;
  while (i < MAX_TWEENS) {
    _StopTween(i, result);
    i++;
  }
}

///////////////////////////////////////////////////////////////////////////////
// Extender Functions (FOR AGS 3.0 OR LATER ONLY):
///////////////////////////////////////////////////////////////////////////////

#ifdef AGS_SUPPORTS_IFVER
#ifver 3.0
// Position
int TweenPosition(this GUI*, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIPosition(this, seconds, toX, toY, timing, style);
}
int TweenPosition(this Object*, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenObjectPosition(this, seconds, toX, toY, timing, style);
}
int TweenPosition(this Character*, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenCharacterPosition(this, seconds, toX, toY, timing, style);
}
int TweenPosition(this GUIControl*, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(this, seconds, toX, toY, timing, style);
}
int TweenPosition(this Label*, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(this, seconds, toX, toY, timing, style);
}
int TweenPosition(this Button*, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(this, seconds, toX, toY, timing, style);
}
int TweenPosition(this TextBox*, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(this, seconds, toX, toY, timing, style);
}
int TweenPosition(this ListBox*, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(this, seconds, toX, toY, timing, style);
}
int TweenPosition(this Slider*, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(this, seconds, toX, toY, timing, style);
}
int TweenPosition(this InvWindow*, float seconds, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPosition(this, seconds, toX, toY, timing, style);
}

// Position By Speed
int TweenPositionBySpeed(this GUI*, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIPositionBySpeed(this, speed, toX, toY, timing, style);
}
int TweenPositionBySpeed(this Object*, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenObjectPositionBySpeed(this, speed, toX, toY, timing, style);
}
int TweenPositionBySpeed(this Character*, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenCharacterPositionBySpeed(this, speed, toX, toY, timing, style);
}
int TweenPositionBySpeed(this GUIControl*, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPositionBySpeed(this, speed, toX, toY, timing, style);
}
int TweenPositionBySpeed(this Label*, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPositionBySpeed(this, speed, toX, toY, timing, style);
}
int TweenPositionBySpeed(this Button*, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPositionBySpeed(this, speed, toX, toY, timing, style);
}
int TweenPositionBySpeed(this TextBox*, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPositionBySpeed(this, speed, toX, toY, timing, style);
}
int TweenPositionBySpeed(this ListBox*, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPositionBySpeed(this, speed, toX, toY, timing, style);
}
int TweenPositionBySpeed(this Slider*, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPositionBySpeed(this, speed, toX, toY, timing, style);
}
int TweenPositionBySpeed(this InvWindow*, float speed, short toX, short toY, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlPositionBySpeed(this, speed, toX, toY, timing, style);
}

// Transparency
int TweenTransparency(this GUI*, float seconds, short toTransparency, TweenTiming timing, TweenStyle style) {
  return TweenGUITransparency(this, seconds, toTransparency, timing, style);
}
int TweenTransparency(this Object*, float seconds, short toTransparency, TweenTiming timing, TweenStyle style) {
  return TweenObjectTransparency(this, seconds, toTransparency, timing, style);
}
int TweenTransparency(this Character*, float seconds, short toTransparency, TweenTiming timing, TweenStyle style) {
  return TweenCharacterTransparency(this, seconds, toTransparency, timing, style);
}

// Size
int TweenSize(this GUI*, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUISize(this, seconds, toWidth, toHeight, timing, style);
}
int TweenSize(this GUIControl*, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(this, seconds, toWidth, toHeight, timing, style);
}
int TweenSize(this Label*, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(this, seconds, toWidth, toHeight, timing, style);
}
int TweenSize(this Button*, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(this, seconds, toWidth, toHeight, timing, style);
}
int TweenSize(this TextBox*, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(this, seconds, toWidth, toHeight, timing, style);
}
int TweenSize(this ListBox*, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(this, seconds, toWidth, toHeight, timing, style);
}
int TweenSize(this Slider*, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(this, seconds, toWidth, toHeight, timing, style);
}
int TweenSize(this InvWindow*, float seconds, short toWidth, short toHeight, TweenTiming timing, TweenStyle style) {
  return TweenGUIControlSize(this, seconds, toWidth, toHeight, timing, style);
}

// GUI Specific
int TweenZOrder(this GUI*, float seconds, short toZOrder, TweenTiming timing, TweenStyle style) {
  return TweenGUIZOrder(this, seconds, toZOrder, timing, style);
}

// Object Specific
int TweenImage(this Object*, Object* tmpObjectRef, float seconds, short toSprite, TweenTiming timing, TweenStyle style) {
  return TweenObjectImage(this, tmpObjectRef, seconds, toSprite, timing, style);
}

// Character Specific
int TweenAnimationSpeed(this Character*, float seconds, short toAnimationSpeed, TweenTiming timing, TweenStyle style) {
  return TweenCharacterAnimationSpeed(this, seconds, toAnimationSpeed, timing, style);
}
int TweenScaling(this Character*, float seconds, short toScaling, TweenTiming timing, TweenStyle style) {
  return TweenCharacterScaling(this, seconds, toScaling, timing, style);
}

// Region Specific
int TweenLightLevel(this Region*, float seconds, short toLightLevel, TweenTiming timing, TweenStyle style) {
  return TweenRegionLightLevel(this, seconds, toLightLevel, timing, style);
}
int TweenTintR(this Region*, float seconds, short toR, TweenTiming timing, TweenStyle style) {
  return TweenRegionTintR(this, seconds, toR, timing, style);
}
int TweenTintG(this Region*, float seconds, short toG, TweenTiming timing, TweenStyle style) {
  return TweenRegionTintG(this, seconds, toG, timing, style);
}
int TweenTintB(this Region*, float seconds, short toB, TweenTiming timing, TweenStyle style) {
  return TweenRegionTintB(this, seconds, toB, timing, style);
}
int TweenTintAmount(this Region*, float seconds, short toAmount, TweenTiming timing, TweenStyle style) {
  return TweenRegionTintAmount(this, seconds, toAmount, timing, style);
}
int TweenTintBlackAndWhite(this Region*, float seconds, TweenTiming timing, TweenStyle style) {
  return TweenRegionTintBlackAndWhite(this, seconds, timing, style);
}

// Label Specific
int TweenColorR(this Label*, float seconds, short toR, TweenTiming timing, TweenStyle style) {
  return TweenLabelColorR(this, seconds, toR, timing, style);
}
int TweenColorG(this Label*, float seconds, short toG, TweenTiming timing, TweenStyle style) {
  return TweenLabelColorG(this, seconds, toG, timing, style);
}
int TweenColorB(this Label*, float seconds, short toB, TweenTiming timing, TweenStyle style) {
  return TweenLabelColorB(this, seconds, toB, timing, style);
}

// Button Specific
int TweenColorR(this Button*, float seconds, short toR, TweenTiming timing, TweenStyle style) {
  return TweenButtonColorR(this, seconds, toR, timing, style);
}
int TweenColorG(this Button*, float seconds, short toG, TweenTiming timing, TweenStyle style) {
  return TweenButtonColorG(this, seconds, toG, timing, style);
}
int TweenColorB(this Button*, float seconds, short toB, TweenTiming timing, TweenStyle style) {
  return TweenButtonColorB(this, seconds, toB, timing, style);
}

// ListBox Specific
int TweenSelectedItem(this ListBox*, float seconds, short toSelectedItem, TweenTiming timing, TweenStyle style) {
  return TweenListBoxSelectedItem(this, seconds, toSelectedItem, timing, style);
}
int TweenTopItem(this ListBox*, float seconds, short toTopItem, TweenTiming timing, TweenStyle style) {
  return TweenListBoxTopItem(this, seconds, toTopItem, timing, style);
}

// InvWindow Specific
int TweenTopItem(this InvWindow*, float seconds, short toTopItem, TweenTiming timing, TweenStyle style) {
  return TweenInvWindowTopItem(this, seconds, toTopItem, timing, style);
}

// Slider Specific
int TweenValue(this Slider*, float seconds, short toValue, TweenTiming timing, TweenStyle style) {
  return TweenSliderValue(this, seconds, toValue, timing, style);
}

// Stop
function StopAllTweens(this GUI*, TweenStopResult result) {
  TweenStopAllForGUI(this, result);
}
function StopAllTweens(this Object*, TweenStopResult result) {
  TweenStopAllForObject(this, result);
}
function StopAllTweens(this Character*, TweenStopResult result) {
  TweenStopAllForCharacter(this, result);
}
function StopAllTweens(this Region*, TweenStopResult result) {
  TweenStopAllForRegion(this, result);
}
function StopAllTweens(this GUIControl*, TweenStopResult result) {
  TweenStopAllForGUIControl(this, result);
}
function StopAllTweens(this Label*, TweenStopResult result) {
  TweenStopAllForGUIControl(this, result);
}
function StopAllTweens(this Button*, TweenStopResult result) {
  TweenStopAllForGUIControl(this, result);
}
function StopAllTweens(this TextBox*, TweenStopResult result) {
  TweenStopAllForGUIControl(this, result);
}
function StopAllTweens(this ListBox*, TweenStopResult result) {
  TweenStopAllForGUIControl(this, result);
}
function StopAllTweens(this Slider*, TweenStopResult result) {
  TweenStopAllForGUIControl(this, result);
}
function StopAllTweens(this InvWindow*, TweenStopResult result) {
  TweenStopAllForGUIControl(this, result);
}
#endif
#ifver 3.1
// TextBox 3.1+ Specific
int TweenColorR(this TextBox*, float seconds, short toR, TweenTiming timing, TweenStyle style) {
  int fromR = GetRFromColor(this.TextColor);
  return _StartGUIControlTween(_eTweenTextBoxColorR, seconds, toR, 0, fromR, 0, this, timing, style);
}
int TweenColorG(this TextBox*, float seconds, short toG, TweenTiming timing, TweenStyle style) {
  int fromG = GetGFromColor(this.TextColor);
  return _StartGUIControlTween(_eTweenTextBoxColorG, seconds, toG, 0, fromG, 0, this, timing, style);
}
int TweenColorB(this TextBox*, float seconds, short toB, TweenTiming timing, TweenStyle style) {
  int fromB = GetBFromColor(this.TextColor);
  return _StartGUIControlTween(_eTweenTextBoxColorB, seconds, toB, 0, fromB, 0, this, timing, style);
}

// Slider 3.1+ Specific
int TweenHandleOffset(this Slider*, float seconds, short toHandleOffset, TweenTiming timing, TweenStyle style) {
  return _StartGUIControlTween(_eTweenSliderHandleOffset, seconds, toHandleOffset, 0, this.HandleOffset, 0, this, timing, style);
}
#endif
#ifdef STRICT_AUDIO
// 3.2+ Strict Audio Specific
int TweenSystemVolume(float seconds, short toVolume, TweenTiming timing, TweenStyle style) {
  return _StartMiscTween(_eTweenSystemVolume, seconds, ClampInt(toVolume, 0, 100), 0, System.Volume, 0, 0, timing, style);
}

int _StartAudioTween(_TweenType type, AudioChannel* audioChannelRef, float seconds, short toX, short toY, short fromX, short fromY,
    TweenTiming timing, TweenStyle style) {
  return _StartTween(type, seconds, toX, toY, fromX, fromY, _eTweenReferenceAudioChannel, audioChannelRef.ID, null, timing, style);
}
int TweenPanning(this AudioChannel*,  float seconds, short toPanning, TweenTiming timing, TweenStyle style) {
  return _StartAudioTween(_eTweenAudioChannelPanning, this, seconds, ClampInt(toPanning, -100,  100), 0, this.Panning, 0, timing, style);
}
int TweenVolume(this AudioChannel*,  float seconds, short toVolume, TweenTiming timing, TweenStyle style) {
  return _StartAudioTween(_eTweenAudioChannelVolume, this, seconds, ClampInt(toVolume, 0, 100), 0, this.Volume, 0, timing, style);
}
int TweenRoomLocation(this AudioChannel*,  float seconds, short toX, short toY, short fromX, short fromY, TweenTiming timing, TweenStyle style) {
  return _StartAudioTween(_eTweenAudioChannelRoomLocation, this, seconds, toX, toY, fromX, fromY, timing, style);
}

function StopAllTweens(this AudioChannel*, TweenStopResult result) {
  _StopTweens(_eTweenReferenceAudioChannel, this.ID, result);
}
#endif
#endif
 �u  // Script header for module 'Tween'
//
// Authors: Edmundo Ruiz (edmundito [netmonkey]) and Tzach Shabtay (tzachs)
//  Please use the messaging function in the AGS forums to contact
//  us about problems or questions.
//
// Revision History:
//  (See CHANGES.TXT for more detailed information)
//  1.5   Mar 4 2012  Added support for 3.2+ strict audio
//                    Added Position tweens by speed
//                    Various GUI Control tweens have been merged
//                    Internal module cleanup and improvements
//  1.22  Aug 14 2010 Compatible with AGS 2.72 and 3.0 again!
//  1.21  Jun 12 2010 Compatible with AGS 3.2
//  1.2   Jun 5 2010  Better control over stopping tweens
//                    Settings for default TweenTiming and TweenStyle
//  1.1   Feb 17 2010 added ~30 new tweens
//  1.0L  Jul 9 2009  added license
//  1.0   Jun 13 2009 created
//
// --------
//
// License (MIT):
//
// Copyright (c) 2009-2011 Edmundo Ruiz (http://www.edmundito.com/)
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
// --------
//
// That said, you are most welcome but not obliged to give us
// credit in your game or the AGS Games Page as such:
//
// In the Game Credits:
// Special Thanks
// Edmundo Ruiz
// Tzach Shabtay
//
// OR if you prefer something along these lines:
// Tween Module by Edmundo Ruiz and Tzach Shabtay
//
// AND/OR In the AGS Games page:
// netmonkey Tween Module
// tzachs Tween Module


///////////////////////////////////////////////////////////////////////////////
// SETTINGS - Feel free to change this for your game!
///////////////////////////////////////////////////////////////////////////////

// Max number of simultaneous tweens that this module can play
// Feel free to change this number, but the higher it is, the slower it might be
// So just increase or decrease it to however many you need.
#define MAX_TWEENS 16

// Default TweenTiming
#define DEFAULT_TweenTiming eLinearTween // All Tweens Except GUI and GUI element Tweens
#define DEFAULT_GUI_TweenTiming eLinearTween // For GUI and GUI element Tweens Only
#define DEFAULT_Audio_TweenTiming eLinearTween // For Audio Tweens Only

// Default TweenStyle
#define DEFAULT_TweenStyle eBlockTween // All Tweens Except GUI and GUI element Tweens
#define DEFAULT_GUI_TweenStyle eBlockTween // For GUI and GUI element Tweens Only
#define DEFAULT_Audio_TweenStyle eNoBlockTween // For Audio Tweens only

// Default TweenStopResult
#define DEFAULT_TweenStopResult ePauseTween // The expected behavior for stopping all tweens

// Settings for AGS 3 and ABOVE:
#ifdef AGS_SUPPORTS_IFVER
#ifver 3.0

// Comment out the following line if you would like to support AGS 2.x style Tween function calls in AGS 3.0+:
#define AGS_2_COMPATIBLE_TWEENS_DISABLED

// Comment out the following line if you want to support Tween 1.2's deprecated functions:
#define TWEEN_1_2_LEGACY_FUNCTIONS_DISABLED

#endif
#endif

///////////////////////////////////////////////////////////////////////////////
// ENUMERATIONS
///////////////////////////////////////////////////////////////////////////////

enum TweenTiming {
  eLinearTween,
  eEaseInTween,
  eEaseOutTween,
  eEaseInEaseOutTween
};

enum TweenStyle {
  eBlockTween,
  eNoBlockTween,
  eRepeatTween,
  eReverseRepeatTween,
};

enum TweenStopResult {
  ePauseTween,
  eResetTween,
  eFinishTween,
};

///////////////////////////////////////////////////////////////////////////////
// HANDY-DANDY UTILITY FUNCTIONS
///////////////////////////////////////////////////////////////////////////////

/// Converts number of seconds to number of game loops. (Part of the Tween module)
import int SecondsToLoops(float seconds);

/// Waits a number of seconds. (Part of the Tween module)
import function WaitSeconds(float seconds);

/// Gets the distance between two points. (Part of the Tween module)
import float GetDistance(int fromX, int fromY, int toX, int toY);

// Uncomment if you would like to use this function in AGS 2.72
/// Gets the AGS Colour Number for the specified RGB color. (Part of the Tween module)
//import int GetColorFromRGB(int red, int green, int blue);

///////////////////////////////////////////////////////////////////////////////
// TWEENS
///////////////////////////////////////////////////////////////////////////////

/// Stops all Tweens that are currently running.
import function TweenStopAll(TweenStopResult result=DEFAULT_TweenStopResult);

/// Waits until all non-looping Tweens are finished playing.
import function WaitForTweensToStop();

import int TweenViewportX(float seconds, short toX, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenViewportXByDistance(float speed, short toX, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenViewportY(float seconds, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenViewportYByDistance(float speed, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenViewportPosition(float seconds, short toX, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenViewportPositionByDistance(float speed, short toX, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);

import int TweenGamma(float seconds, short toGamma, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenShakeScreen(float seconds, short fromDelay, short toDelay, short fromAmount, short toAmount, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenAreaScaling(float seconds, int area, short fromMin, short toMin, short fromMax, short toMax, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);

import int TweenSpeechVolume(float seconds, short fromVolume, short toVolume, TweenTiming timing=DEFAULT_Audio_TweenTiming, TweenStyle style=DEFAULT_Audio_TweenStyle);
#ifndef STRICT_AUDIO
import int TweenMusicMasterVolume(float seconds, short fromVolume, short toVolume, TweenTiming timing=DEFAULT_Audio_TweenTiming, TweenStyle style=DEFAULT_Audio_TweenStyle);
import int TweenDigitalMasterVolume(float seconds, short fromVolume, short toVolume, TweenTiming timing=DEFAULT_Audio_TweenTiming, TweenStyle style=DEFAULT_Audio_TweenStyle);
import int TweenSoundVolume(float seconds, short fromVolume, short toVolume, TweenTiming timing=DEFAULT_Audio_TweenTiming, TweenStyle style=DEFAULT_Audio_TweenStyle);
import int TweenChannelVolume(float seconds, int channel, short fromVolume, short toVolume, TweenTiming timing=DEFAULT_Audio_TweenTiming, TweenStyle style=DEFAULT_Audio_TweenStyle);
#endif


// FOR AGS 3.0 OR LATER ONLY:
#ifdef AGS_SUPPORTS_IFVER
#ifver 3.0
import int TweenPosition(this Character*, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenPosition(this Object*, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenPosition(this GUI*, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPosition(this GUIControl*, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPosition(this Label*, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPosition(this Button*, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPosition(this TextBox*, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPosition(this ListBox*, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPosition(this Slider*, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPosition(this InvWindow*, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenPositionBySpeed(this Character*, float speed, short toX, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenPositionBySpeed(this Object*, float speed, short toX, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenPositionBySpeed(this GUI*, float speed, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPositionBySpeed(this GUIControl*, float speed, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPositionBySpeed(this Label*, float speed, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPositionBySpeed(this Button*, float speed, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPositionBySpeed(this TextBox*, float speed, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPositionBySpeed(this ListBox*, float speed, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPositionBySpeed(this Slider*, float speed, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenPositionBySpeed(this InvWindow*, float speed, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenTransparency(this GUI*, float seconds, short toTransparency, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenTransparency(this Object*, float seconds, short toTransparency, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenTransparency(this Character*, float seconds, short toTransparency, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);

import int TweenZOrder(this GUI*, float seconds, short toZOrder, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenSize(this GUI*, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenSize(this GUIControl*, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenSize(this Label*, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenSize(this Button*, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenSize(this TextBox*, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenSize(this ListBox*, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenSize(this Slider*, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenSize(this InvWindow*, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenScaling(this Character*, float seconds, short toScaling, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);

import int TweenImage(this Object*, Object* objectRef, float seconds, short toSprite, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);

import int TweenAnimationSpeed(this Character*, float seconds, short toAnimationSpeed, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);

import int TweenLightLevel(this Region*, float seconds, short toLightLevel, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenTintR(this Region*, float seconds, short toR, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenTintG(this Region*, float seconds, short toG, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenTintB(this Region*, float seconds, short toB, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenTintAmount(this Region*, float seconds, short toAmount, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenTintBlackAndWhite(this Region*, float seconds, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);

import int TweenColorR(this Label*, float seconds, short toR, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenColorG(this Label*, float seconds, short toG, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenColorB(this Label*, float seconds, short toB, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenColorR(this Button*, float seconds, short toR, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenColorG(this Button*, float seconds, short toG, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenColorB(this Button*, float seconds, short toB, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenValue(this Slider*, float seconds, short toValue, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenSelectedItem(this ListBox*, float seconds, short toSelectedItem, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenTopItem(this ListBox*, float seconds, short toTopItem, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenTopItem(this InvWindow*, float seconds, short toTopItem, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import function StopAllTweens(this GUI*, TweenStopResult result=DEFAULT_TweenStopResult);
import function StopAllTweens(this Object*, TweenStopResult result=DEFAULT_TweenStopResult);
import function StopAllTweens(this Character*, TweenStopResult result=DEFAULT_TweenStopResult);
import function StopAllTweens(this Region*, TweenStopResult result=DEFAULT_TweenStopResult);
import function StopAllTweens(this GUIControl*, TweenStopResult result=DEFAULT_TweenStopResult);
import function StopAllTweens(this Label*, TweenStopResult result=DEFAULT_TweenStopResult);
import function StopAllTweens(this Button*, TweenStopResult result=DEFAULT_TweenStopResult);
import function StopAllTweens(this TextBox*, TweenStopResult result=DEFAULT_TweenStopResult);
import function StopAllTweens(this ListBox*, TweenStopResult result=DEFAULT_TweenStopResult);
import function StopAllTweens(this Slider*, TweenStopResult result=DEFAULT_TweenStopResult);
import function StopAllTweens(this InvWindow*, TweenStopResult result=DEFAULT_TweenStopResult);
#endif
#ifver 3.1
// These apply to AGS 3.1 and above
import int TweenColorR(this TextBox*, float seconds, short toR, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenColorG(this TextBox*, float seconds, short toG, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenColorB(this TextBox*, float seconds, short toB, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenHandleOffset(this Slider*, float seconds, short toOffset, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
#endif
#ifdef STRICT_AUDIO
// These apply to AGS 3.2 and above when the Strict Audio setting is enabled
import int TweenSystemVolume(float seconds, short toVolume, TweenTiming timing=DEFAULT_Audio_TweenTiming, TweenStyle style=DEFAULT_Audio_TweenStyle);

import int TweenPanning(this AudioChannel*,  float seconds, short toPanning, TweenTiming timing=DEFAULT_Audio_TweenTiming, TweenStyle style=DEFAULT_Audio_TweenStyle);
import int TweenVolume(this AudioChannel*,  float seconds, short toVolume, TweenTiming timing=DEFAULT_Audio_TweenTiming, TweenStyle style=DEFAULT_Audio_TweenStyle);
import int TweenRoomLocation(this AudioChannel*,  float seconds, short toX, short toY, short fromX, short fromY, TweenTiming timing=DEFAULT_Audio_TweenTiming, TweenStyle style=DEFAULT_Audio_TweenStyle);
import function StopAllTweens(this AudioChannel*, TweenStopResult result=DEFAULT_TweenStopResult);
#endif
#endif


// FOR AGS 2.x AND LATER:
#ifndef AGS_2_COMPATIBLE_TWEENS_DISABLED
import int TweenGUIPosition(GUI* guiRef, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenGUIPositionByDistance(GUI* guiRef, float speed, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenGUITransparency(GUI* guiRef, float seconds, short toTransparency, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenGUISize(GUI* guiRef, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenGUIZOrder(GUI* guiRef, float seconds, short toZOrder, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import function TweenStopAllForGUI(GUI* guiRef, TweenStopResult result=DEFAULT_TweenStopResult);

import int TweenObjectPosition(Object* objectRef, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenObjectPositionByDistance(Object* objectRef, float speed, short toX, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenObjectTransparency(Object* objectRef, float seconds, short toTransparency, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenObjectImage(Object* objectRef, Object* tmpObjectRef, float seconds, short toSprite, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import function TweenStopAllForObject(Object* objectRef, TweenStopResult result=DEFAULT_TweenStopResult);

import int TweenCharacterPosition(Character* characterRef, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenCharacterPositionByDistance(Character* characterRef, float speed, short toX, short toY, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenCharacterScaling(Character* characterRef, float seconds, short toScaling, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenCharacterTransparency(Character* characterRef, float seconds, short toTransparency, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenCharacterAnimationSpeed(Character* characterRef, float seconds, short toAnimationSpeed, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import function TweenStopAllForCharacter(Character* characterRef, TweenStopResult result=DEFAULT_TweenStopResult);

import int TweenRegionLightLevel(Region* regionRef, float seconds, short toLightLevel, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenRegionTintR(Region* regionRef, float seconds, short toR, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenRegionTintG(Region* regionRef, float seconds, short toG, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenRegionTintB(Region* regionRef, float seconds, short toB, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenRegionTintAmount(Region* regionRef, float seconds, short toAmount, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import int TweenRegionTintBlackAndWhite(Region* regionRef, float seconds, TweenTiming timing=DEFAULT_TweenTiming, TweenStyle style=DEFAULT_TweenStyle);
import function TweenStopAllForRegion(Region* guiRef, TweenStopResult result=DEFAULT_TweenStopResult);

import int TweenGUIControlSize(GUIControl* guiControlRef, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenGUIControlPosition(GUIControl* guiControlRef, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenGUIControlPositionByDistance(GUIControl* guiControlRef, float speed, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import function TweenStopAllForGUIControl(GUIControl* guiControlRef, TweenStopResult result=DEFAULT_TweenStopResult);

import int TweenLabelColorR(Label* labelRef, float seconds, short toR, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenLabelColorG(Label* labelRef, float seconds, short toG, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenLabelColorB(Label* labelRef, float seconds, short toB, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenButtonColorR(Button* buttonRef, float seconds, short toR, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenButtonColorG(Button* buttonRef, float seconds, short toG, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenButtonColorB(Button* buttonRef, float seconds, short toB, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenListBoxSelectedItem(ListBox* listBoxRef, float seconds, short toSelectedItem, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenListBoxTopItem(ListBox* listBoxRef, float seconds, short toTopItem, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenSliderValue(Slider* sliderRef, float seconds, short toValue, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

import int TweenInvWindowTopItem(InvWindow* invWindowRef, float seconds, short toTopItem, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);

#ifndef TWEEN_1_2_LEGACY_FUNCTIONS_DISABLED
// These functions have been abandoned after tween 1.2
import int TweenButtonSize(Button* buttonRef, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenButtonPosition(Button* buttonRef, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenLabelSize(Label* labelRef, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenLabelPosition(Label* labelRef, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenTextBoxSize(TextBox* textBoxRef, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenTextBoxPosition(TextBox* textBoxRef, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenListBoxSize(ListBox* listBoxRef, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenListBoxPosition(ListBox* listBoxRef, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenInvWindowSize(InvWindow* invWindowRef, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenInvWindowPosition(InvWindow* invWindowRef, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenSliderSize(Slider* sliderRef, float seconds, short toWidth, short toHeight, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import int TweenSliderPosition(Slider* sliderRef, float seconds, short toX, short toY, TweenTiming timing=DEFAULT_GUI_TweenTiming, TweenStyle style=DEFAULT_GUI_TweenStyle);
import function TweenStopAllForButton(Button* guiRef, TweenStopResult result=DEFAULT_TweenStopResult);
import function TweenStopAllForLabel(Label* guiRef, TweenStopResult result=DEFAULT_TweenStopResult);
import function TweenStopAllForTextBox(TextBox* guiRef, TweenStopResult result=DEFAULT_TweenStopResult);
import function TweenStopAllForListBox(ListBox* guiRef, TweenStopResult result=DEFAULT_TweenStopResult);
import function TweenStopAllForSlider(Slider* guiRef, TweenStopResult result=DEFAULT_TweenStopResult);
import function TweenStopAllForInvWindow(InvWindow* guiRef, TweenStopResult result=DEFAULT_TweenStopResult);
#define TweenViewportXY TweenViewportPosition
#endif
#endif





///////////////////////////////////////////////////////////////////////////////
// INTENDED FOR INTERNAL USE BY THIS MODULE ONLY
///////////////////////////////////////////////////////////////////////////////
enum _TweenReferenceType {
  _eTweenReferenceGUI,
  _eTweenReferenceObject,
  _eTweenReferenceCharacter,
  _eTweenReferenceRegion,
  _eTweenReferenceGUIControl, 
  _eTweenReferenceMisc,
#ifdef STRICT_AUDIO
  _eTweenReferenceAudioChannel,
#endif
};

enum _TweenType {
  _eTweenGUIPosition,
  _eTweenGUITransparency,
  _eTweenGUISize,
  _eTweenGUIZOrder,
  _eTweenObjectPosition,
  _eTweenObjectTransparency,
  _eTweenCharacterPosition,
  _eTweenCharacterScaling,
  _eTweenCharacterTransparency,
  _eTweenCharacterAnimationSpeed,
  _eTweenRegionLightLevel,
  _eTweenRegionTintR,
  _eTweenRegionTintG,
  _eTweenRegionTintB,
  _eTweenRegionTintAmount,
  _eTweenLabelColorR,
  _eTweenLabelColorG,
  _eTweenLabelColorB,
  _eTweenGUIControlPosition, 
  _eTweenGUIControlSize,
  _eTweenButtonColorR,
  _eTweenButtonColorG,
  _eTweenButtonColorB,
  _eTweenSliderValue,
  _eTweenListBoxSelectedItem,
  _eTweenListBoxTopItem,
  _eTweenInvWindowTopItem,
  _eTweenViewportX,
  _eTweenViewportY,
  _eTweenViewportXY,
  _eTweenGamma,
  _eTweenShakeScreen,
  _eTweenAreaScaling,
  _eTweenSpeechVolume,
#ifdef AGS_SUPPORTS_IFVER
#ifver 3.1
  _eTweenTextBoxColorR,
  _eTweenTextBoxColorG,
  _eTweenTextBoxColorB,
  _eTweenSliderHandleOffset,
#endif
#endif
#ifndef STRICT_AUDIO
  _eTweenMusicMasterVolume,
  _eTweenDigitalMasterVolume,
  _eTweenSoundVolume,
  _eTweenChannelVolume,
#endif
#ifdef STRICT_AUDIO
  _eTweenSystemVolume, 
  _eTweenAudioChannelVolume,  
  _eTweenAudioChannelRoomLocation,
  _eTweenAudioChannelPanning, 
#endif
};

struct _TweenObject {
  _TweenType type;
  _TweenReferenceType refType;
  int refID;
  
  TweenTiming timing;
  TweenStyle style;

  int duration;
  int frameCount;

  short toX;
  short toY;
  short fromX;
  short fromY;
  
  GUIControl* guiControlRef;

  import function step(float amount);
};
 C�}J        ej��