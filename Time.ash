
#define LOOPS_PER_INGAME_TEN_MINUTES 400 // 40 loops occur every second. 40 * 10 seconds = 10 in game minutes per real world 10 seconds
#define MAX_AMOUNT_TICKS_ONE_INGAME_DAY 144

import function processTime();
import bool isDaytime();
import function initTimeProcessing();
import function executeSleep();
import function testTime();
