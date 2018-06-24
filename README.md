# hangman
Simple hangman game written in ruby (console based...no UI).

This is a classic game of Hangman...but without the cute stick-figure pictures hanging from a tree.  You will be shown how many letters are in the mystery word, and then asked to guess the missing letters. Your are given a certain number of 'misses' (at present moment: 6, the same number of symbols that make up the traditional hanging stick-figure).  Guess the word before making so many losses, and you win...but make as many misses before guessing the word, and you lose.

After each round, you'll have the option to continue playing more rounds, and see the current tallied score of rounds won/lost.

The word is selected from a library of many thousands of words, in a separate file, so there is a large variety, and any game is very likely to feature all unique words.  However, the words are randomly selected from those words that are between 5 and 12 characters long (inclusive).

The game begins by asking for the player's name, and presenting a start menu, from which the player three choices: start a new game, load a saved game, or quit the game.

At any point during a round, you may choose to either exit or save the game instead of offering a letter guess.  Both choices will exit the round immediately, while the latter saves the game before exiting.  After exiting the round, the player is prompted to play a new round or return to the start menu.

Currently, only one saved game may be kept.  Choosing to save another game will over-write any previous saved game.
