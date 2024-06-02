=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=
CIS 1200 Game Project README
PennKey: _______
=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=:=

===================
=: Core Concepts :=
===================

- List the four core concepts, the features they implement, and why each feature
  is an appropriate use of the concept. Incorporate the feedback you got after
  submitting your proposal.

  1. 2D Array: My board is modeled with a 2D array of Cells. Each Cell stores
  an integer value (for bombs, -1, for all others, the number of bombs in the
  surrounding area), a flagged boolean (true if flagged), a revealed boolean
  (true if revealed), and contains a left-click method that toggles the flagged
  boolean (if not revealed), and a right-click method that reveals the square
  (if unflagged).

  2. Recursion: The board only populates the array after the user clicks. It always
  places a 0 at the user's first click. For all 0 cells that are revealed, the game
  recursively left-clicks all its surrounding cells. This saves the user time and is
  an integral part of the minesweeper-playing experience.

  3. File I/O: The board stores each cell as a line in a text file (with different
  integers representing the different values) and reads in these lines to populate the
  board when a valid game state has been saved.

  4. Collections: I have a set that is initially populated with all unrevealed, non-
  bomb cells. As the player plays the game, revealing a non-bomb cell removes it
  from the set. When the set is empty (provided the game has already started),
  the player has won.

===============================
=: File Structure Screenshot :=
===============================
- Include a screenshot of your project's file structure. This should include
  all of the files in your project, and the folders they are in. You can
  upload this screenshot in your homework submission to gradescope, named 
  "file_structure.png".

=========================
=: Your Implementation :=
=========================

- Provide an overview of each of the classes in your code, and what their
  function is in the overall game.
  Cell: creates a cell object.
    Each Cell stores an integer value (for bombs, -1, for all others,
    the number of bombs in the surrounding area), a flagged boolean
    (true if flagged), a revealed boolean (true if revealed),
    and contains a left-click method that toggles the flagged
    boolean (if not revealed), and a right-click method that reveals the square
    (if unflagged).

  Minesweeper: creates a minesweeper setup.
     Minesweepers can either be constructed with an int, which determines the size
     of the minesweeper, and randomly populates it upon the user's first click
     or a Cell Array, which creates a Minesweeper with corresponding
     cells.

     It stores the game as an array of cells. It stores the game's "win state"
     as a set of cells. This is a set because the same cell shouldn't be able to be
     added twice. Revealing a piece of land removes it from the set.
     We also don't have to worry about adding cells back to the set (and thus
     having structural equality) because revealing a cell is not reversible. When the
     set is empty, the game has been won. It also stores the number of flags, the
     number of bombs, the size of the array, and whether the game is over (lost),
     as private integers. Finally, it has three static integer values that store
     the size of a small, medium, and large board.

     The populateBoard method first calculates how many bombs should be on the board
     based on the size of the board and a pre-determined density. It then
     assigns bombs to random(ish) locations on the board
     (making sure the clicked location is relatively bomb-free) and then uses
     the bombsInArea method to fill the other cells with their respective numerical
     values. It also adds all unearthed land (non-bombs) to a set, which maintains
     the game state.

     The private helper bombsInArea method calculates how many bombs are in the cells
     surrounding a given r, c value.

     The RightClick method calls the rightClick method of the given cell if the cell
     is not already revealed. It increases the number of flags on the board by 1 if the
     cell was not flagged, and decreases it by 1 if it was previously flagged.

     The LeftClick method only works if the cell at r, c is not flagged or revealed.
     If it is a bomb, the game ends.
     If it is not a bomb, then the cell is revealed and, if it is zero, the surrounding
     cells are also recursively left-clicked.


  GameBoard: stores the array of cells that make up the GameBoard.
    The initialize method attempts to read the text file and create a GameBoard
    with a cell array, but if it is unsuccessful, it defaults to an integer.

    The writeGameState method writes the cell array into a text file, first
    writing the size of the gameBoard on its own line, and then writing
    each cell as a line, where the first value in the line is the cells' int
    and the next value is 1 if the cell is revealed, 0 otherwise. The final value
    in the line is 1 if the cell is flagged, 0 otherwise.

    The paintComponent draws each cell as a square (size determined by board size and
    the screen size):
    - flagged squares are red
    - revealed squares have their number on them
    - all other squares are light or dark grey based on their parity.
    If the game reaches a losing state, it says "boom" on the screen and you "die".
    If the game reaches a win state, the bombs become light pink (flowers) and the
    safe squares become green (grass).

  FileToCellArray is an iterator that reads in a file given by the FilePath and
  converts it into a cell array. It does this in parts.
  It converts the filepath into a BufferedReader (fileToReader) and then has both
  hasNext(), nextLine(), and next() methods.
  The nextLine() method merely reads the next line of a file and returns it as a
  string. The next() method converts the next line of the file into a cell.
  If the next() method finds that the next line does not match the formatting of a
  cell written to text, it will return null.

  The private helper method skipWhiteSpace accounts for spaces and extra lines that
  may occur.

  Finally, createArray reads in the first line as an integer and sets it to the length
  of the array (if the first line is not an integer, it returns null).
  Then, all succeeding lines are read using next() and turned into cells, which
  are then added to an array.

  RunMinesweeper sets up all of the elements required to display the game using Swing,
  including the GameBoard, the instructions button (which opens and closes a panel
  that displays the instructions in text), a status panel, and other buttons that
  can create new games with small, medium, and large sizes.



- Were there any significant stumbling blocks while you were implementing your
  game (related to your design, or otherwise)?

  The biggest issue for me was making the bombs properly distributed across the
  board when initially populating it. I knew I had to make the first click be
  a safe, 0 square, but I didn't realize I would also have to sort of "algorithmically"
  distribute the bombs in general. If the bombs are evenly, randomly, distributed,
  the gameplay is sort of poor because most of the squares will have < 3 as their
  number. The density required with even distribution to make the game relatively
  interesting would be too high, and then the difficulty would skyrocket. So I had
  to create a method of distributing the bombs that was still random, but
  1. bombs are less likely to be placed very near the initial click
  2. bombs are more likely to be placed close to other bombs
  without sacrificing the relatively random distribution.

  I also went back and forth on whether I wanted to use subtyping (making
  bombs a different class than land, but having both implement a clickable interface)
  which was my initial plan, but then I finally decided that it was an unnecessary
  hassle to do that, and kept them both as the same class.

- Evaluate your design. Is there a good separation of functionality? How well is
  private state encapsulated? What would you refactor, if given the chance?

  Um, I think that it's pretty good? I think that the writing of the cells and the
  file I/O stuff could've been a little bit better. As is, it's kind of "dirty", I
  guess? I would maybe make it less intimately linked with the GameBoard. But overall,
  I think I did a pretty good job making stuff encapsulated. I would've liked to make
  the size of the board customizable (that was sort of my initial intent) but that
  seemed hard.



========================
=: External Resources :=
========================

- Cite any external resources (images, tutorials, etc.) that you may have used 
  while implementing your game.
