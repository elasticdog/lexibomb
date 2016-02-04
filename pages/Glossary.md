Glossary
========

## Anchor square

A square that is adjacent to a tile previously played on the board. Every play
(subsequent to the first play) must place a tile on an anchor square.

## Bomb square

A randomly-placed penalty square that causes a play to score no points. All
squares adjacent to a bomb square have an increased bonus.

## Bingo

A bonus gained by using all seven tiles from player's rack in one play.

## Blank

A tile with no letter on it; the player who places it on the board gets to
choose which letter it will represent.

## Board

A grid of squares onto which players play tiles to make words.

## Bonus

Some squares give you bonus scores: double or triple letter or word scores.

## Cross word

A word formed in the other direction from a play. For example, a play forms
a word in the across direction, and in doing so, places a letter that extends
a word in the down direction. This new extended cross word must be in the
word list.

## Direction

Every play must be in either the ACROSS or DOWN direction.

## Game

Players take turns making plays until one player has no more tiles. After
making a play, the player's rack is replenished with tiles until the player has
7 tiles or until the bag of tiles is empty.

## Letter bonus

The letter bonus is 2 when a tile is first placed on a double letter square and
3 when first placed on a triple letter square; it is 1 for a tile already on
the board, or for a new tile played on a non-letter-bonus square.

## Letter score

The letter score is the value of the letter on the tile times the letter bonus
score.

The letter score for a blank tile is always zero.

## Play

A play consists of placing some tiles on the board to form a continuous string
of letters in one direction (across or down), such that only valid words are
formed, and such that one of the tiles is placed on an anchor square.

## Prefix

A string of zero or more letters that starts some word in the word list. Not
a concept that has to do with the rules of the game; it will be important in
the algorithm to finds valid plays.

## Rack

A collection of up to seven tiles that a player may use to make words.

## Rack leave

The collection of tiles left on a player's rack after making a play.

## Score

The points awarded for a play, consisting of the sum of the word scores for
each word made (the main word and possibly any cross words), plus a bingo bonus
if all seven letters are used.

## Square

A location on the board; a square can hold one tile.

## Tile

A letter (or a blank) that can be played on the board to form words.

## Word

A string of letters. Words in the word list are all uppercase.

## Word bonus

The word bonus starts at 1, and is multiplied by 2 for each double word square
and 3 for each triple word square covered by a tile on this play. If a tile is
played on a bomb square, the word bonus is 0 (i.e., no points are earned for
the play).

## Word list

A set of all legal words.

## Word score

The word score is the sum of the letter scores for each tile (either placed by
the player or already on the board but part of the word) times the word bonus
score.
