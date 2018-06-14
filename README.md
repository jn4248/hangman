# hangman
Simple hangman game written in ruby (no gui)

This is a classic game of Hangman...but without the cute stick-figure pictures hanging from a tree.  You will be shown how many letters are in the mystery word, and then asked to guess the missing letters. Your are given a certain number of 'misses' (at present moment: 6, the same number of symbols that make up the traditional hanging stick-figure).  Guess the word before making so many losses, and you win...but make as many misses before guessing the word, and you lose.

After each round, you'll have the option to continue playing more rounds, and see the current tallied score of rounds won/lost.

The word is selected from a library of many thousands of words, in a separate file, so there is a large variety, and any game is very likely to feature all unique words.  However, the words are randomly selected from those words that are between 5 and 12 characters long (inclusive).
