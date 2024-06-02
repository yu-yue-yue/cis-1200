package org.cis1200.minesweeper;

/**
 * CIS 120 HW09 - TicTacToe Demo
 * (c) University of Pennsylvania
 * Created by Bayley Tuch, Sabrina Green, and Nicolas Corona in Fall 2020.
 */

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * This class is a model for TicTacToe.
 * 
 * This game adheres to a Model-View-Controller design framework.
 * This framework is very effective for turn-based games. We
 * STRONGLY recommend you review these lecture slides, starting at
 * slide 8, for more details on Model-View-Controller:
 * https://www.seas.upenn.edu/~cis120/current/files/slides/lec36.pdf
 * 
 * This model is completely independent of the view and controller.
 * This is in keeping with the concept of modularity! We can play
 * the whole game from start to finish without ever drawing anything
 * on a screen or instantiating a Java Swing object.
 * 
 * Run this file to see the main method play a game of TicTacToe,
 * visualized with Strings printed to the console.
 */
public class Minesweeper {

    public final static int SMALL = 8;
    public final static int MEDIUM = 18;
    public final static int LARGE = 25;
    private Cell[][] board;
    private int numFlags;

    private int numBombs;
    private boolean gameOver;
    private Set<Cell> land;

    private int size;

    /**
     * Constructor sets up a game of minesweeper as a square
     * with the given dimension.
     */
    public Minesweeper(int n) {
        reset(n);
    }

    /**
     * Constructor sets of the game of minesweeper with the pre-written cell array,
     * storing the array as the board, and filling the other fields accordingly.
     * @param cells the cell array that will be defined as the board
     */
    public Minesweeper(Cell[][] cells) {
        board = Arrays.copyOf(cells, cells.length);
        size = cells.length;
        gameOver = false;
        land = new HashSet<>();
        numFlags = 0;
        numBombs = 0;
        for (int r = 0; r < cells.length; r++) {
            for (int c = 0; c < cells.length; c++) {
                if (board[r][c].isFlagged()) {
                    numFlags++;
                } else if (board[r][c].getNum() > -1 && !board[r][c].isRevealed()) {
                    land.add(board[r][c]);
                }

                if (board[r][c].getNum() == Cell.BOMB) {
                    numBombs++;
                }
            }
        }
    }

    /**
     * playTurn allows players to play a turn, performing an action on the
     * cell determined by the r, c location of the click.
     * Does the leftClick method if the
     * user leftClicked, and the rightClick method otherwise.
     *
     * @param r    row to play in
     * @param c    column to play in
     * @param left whether the click was a left click or not (if false, it was a
     *             right click)
     */
    public void playTurn(int r, int c, boolean left) {
        if (left) {
            leftClick(r, c);
        } else {
            rightClick(r, c);
        }
    }

    public int getNumBombs() {
        return numBombs;
    }

    public int getNumFlags() {
        return numFlags;
    }

    public int getSize() {
        return size;
    }

    /**
     * checkWinner checks whether the game has reached a win condition.
     *
     * @return false if the board still has unearthed land, true otherwise.
     */
    public boolean checkWinner() {
        return (land.isEmpty() && board[0][0] != null);
    }

    /**
     * checkWinner checks whether the game has reached a losing condition.
     *
     * @return true if a bomb is revealed, false otherwise .
     */
    public boolean gameOver() {
        return gameOver;
    }


    /**
     * reset (re-)sets the game state to start a new game.
     * sets the board to the given size (size)
     * and the number of flags to a corresponding amount
     */
    public void reset(int size) {
        this.numBombs = (int) ((size * size) / 7.0);
        this.size = size;
        board = new Cell[size][size];
        gameOver = false;
        land = new HashSet<>();
        numFlags = 0;
    }


    /**
     * populates the board with bombs such that there are the requisite number of
     * bombs.
     * sets the other cells to be plain tiles with undecided numbers.
     * randomly assigns cell values to be bombs; if the value is within the bounding
     * box centered
     * at the cell given by row, col, it chooses a new number. if the value is
     * already a bomb, it also
     * chooses a new number.
     *
     * this function also has two algorithms that help to set bombs so they are
     * relatively close to one
     * another and far from the players initial click (demonstrated by row, col)
     * 
     * @param row the row number of the clicked square
     * @param col the column number of the clicked square
     */
    public void populateBoard(int row, int col) {

        for (int i = 0; i < numBombs; i++) {
            int r = (int) (Math.random() * board.length);
            int c = (int) (Math.random() * board.length);
            int lastR;
            int lastC;
            int norm = Math.max(
                    Math.abs((int) (Math.random() * (row - r))),
                    Math.abs((int) (Math.random() * (col - c)))
            );
            double adjust = 0;
            while (board[r][c] != null || norm < 1 || adjust > 2.0) {
                lastR = r;
                lastC = c;
                r = (int) (Math.random() * board.length);
                c = (int) (Math.random() * board.length);

                norm = Math.max(
                        Math.abs((int) (Math.random() * (row - r))),
                        Math.abs((int) (Math.random() * (col - c)))
                );

                adjust = Math.sqrt(
                        Math.pow(Math.random() * (lastR - r), 2) +
                                Math.pow(Math.random() * (lastC - c), 2)
                );

            }

            board[r][c] = new Cell(-1);
        }

        for (int r = 0; r < board.length; r++) {
            for (int c = 0; c < board[r].length; c++) {
                if (board[r][c] == null) {
                    board[r][c] = new Cell(bombsInArea(r, c));
                    land.add(board[r][c]);
                }
            }
        }

    }

    /**
     * a private helper method to calculate the number of bombs in the area around a
     * piece
     * of land
     * 
     * @param row the row of the land to calculate
     * @param col the col of the land to calculate
     * @return the number of bombs in the area
     */
    private int bombsInArea(int row, int col) {
        int bombs = 0;
        for (int r = Math.max(0, row - 1); r < Math.min(row + 2, board.length); r++) {
            for (int c = Math.max(0, col - 1); c < Math.min(col + 2, board.length); c++) {
                if (board[r][c] != null && board[r][c].getNum() == Cell.BOMB) {
                    bombs++;
                }
            }
        }

        return bombs;
    }

    /**
     * actions taken when a user right-clicks on a cell. it flags the cell, unless
     * the
     * land has already been revealed, in which case it does nothing
     * 
     * @param row horizontal coordinate of the land clicked by the user
     * @param col vertical coordinate of the land clicked by the user
     */
    public void rightClick(int row, int col) {
        if (board[row][col].isRevealed()) {
            return;
        }

        if (board[row][col].rightClick()) {
            numFlags++;
        } else {
            numFlags--;
        }

    }

    /**
     * actions taken when a user left-clicks on a cell. if the cell is flagged, it
     * does nothing.
     * if the cell is a piece of land with a non-zero number of bombs around it,
     * leftClick simply reveals that piece of land.
     * if the cell is a piece of land with zero bombs around it,
     * leftClick also reveals the pieces of land within its bounding box by
     * recursively
     * leftClicking those pieces also.
     * if the cell is a bomb, the game ends.
     * 
     * @param row horizontal coordinate of the land clicked by the user
     * @param col vertical coordinate of the land clicked by the user
     */
    public void leftClick(int row, int col) {
        Cell cell = board[row][col];
        if (cell.isFlagged() || cell.isRevealed()) {
            return;
        }

        cell.leftClick();
        if (cell.getNum() == Cell.BOMB) {
            gameOver = true;
            return;
        }

        land.remove(cell);

        if (cell.getNum() == 0) {
            for (int r = Math.max(0, row - 1); r < Math.min(row + 2, board.length); r++) {
                for (int c = Math.max(0, col - 1); c < Math.min(col + 2, board.length); c++) {
                    leftClick(r, c);
                }
            }
        }
    }

    /**
     * returns the cell at given coordinates on the board
     * 
     * @param r the horizontal coordinate
     * @param c the vertical coordinate
     * @return the cell at the given location
     */
    public Cell getCell(int r, int c) {
        return board[r][c];
    }

    /**
     * This main method illustrates how the model is completely independent of
     * the view and controller. We can play the game from start to finish
     * without ever creating a Java Swing object.
     *
     * This is modularity in action, and modularity is the bedrock of the
     * Model-View-Controller design framework.
     *
     * Run this file to see the output of this method in your console.
     */
    public static void main(String[] args) {
//        Minesweeper t = new Minesweeper(MEDIUM);
//        t.populateBoard(2, 2);
//        for (Cell[] row : t.board) {
//            for (Cell c : row) {
//                if (c.getNum() == -1) {
//                    System.out.print("B ");
//                } else {
//                    System.out.print(c.getNum() + " ");
//                }
//            }
//            System.out.println();
//        }
//
//        t.leftClick(2, 2);
//        System.out.println();
//
//        for (Cell[] row : t.board) {
//            for (Cell c : row) {
//                if (c.isRevealed()) {
//                    System.out.print(c.getNum() + " ");
//                } else {
//                    System.out.print("+ ");
//                }
//            }
//            System.out.println();
//        }

    }

}
