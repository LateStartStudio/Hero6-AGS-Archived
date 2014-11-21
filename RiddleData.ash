
#define MAX_AVAILABLE_RIDDLES 15

struct RiddleData {
  String riddle[6];
  String answer[4];
};

import short riddle_selection[5];
import short riddleCorrect;
import RiddleData riddles[MAX_AVAILABLE_RIDDLES];

import function InitializeRiddles();
import bool AskRiddle(short r);
