// Script header for module 'DialogBox'
//
// Author: Andrew MacCormack (SSH)
//   Please use the PM function on the AGS forums to contact
//   me about problems with this module
// 
// Abstract: Provides a a function to display a GUI with OK/Cancel options 
//           and return 1/0 respectively when a button is clicked.
// Dependencies:
//
//   AGS 2.71 or later
//   gDialogbox GUE imported to game
//
// Functions:
//
//	function DialogBox(String caption);
//		This opens the dialog and sets the label to the string specified. It waits
//    for a button to be pushed and then returns 1 for "OK" and 0 for "Cancel"
//
// Configuration:
//
// 	The gDialogbox GUI is hardcoded as the one to be used, as are the script names
//  of the gui controls inside the GUI. One can edit the module to change these, 
//  but that probably isn't necessary. You can change the included GUI around as
//  much as is liked, but if you just have text on the buttons rather than images,
//  the buttons will not be seen to be "pushed" when the mouse is clicked.
//
// Example:
//
//		if (Game.GetSaveSlotDescription(n)!=null &&
//        DialogBox("Overwrite saved game?")) {
//      SaveGameSlot(n, description);
//    }
//
// Caveats:
//
//   Forces the "When GUIs disabled are unchanged" option during run
//
// Revision History:
//
//  1 Jun 06: v1.0  First release of DialogBox module
//  2 Jun 06: v1.1  Fixed it to actually work with 2.71 and got pointer done better
//
// Licence:
//
//   DialogBox AGS script module
//   Copyright (C) 2006 Andrew MacCormack
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to 
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in 
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
// THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
// DEALINGS IN THE SOFTWARE.

import function DialogBox(String caption);
