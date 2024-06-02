package org.cis1200.minesweeper;

public class Cell {

    public static final int BOMB = -1;
    private int num;
    private boolean revealed;
    private boolean flagged;

    public Cell() {
        revealed = false;
        flagged = false;
        num = 0;
    }

    public Cell(int num) {
        if (num < 0) {
            this.num = BOMB;
        }
        revealed = false;
        flagged = false;
        this.num = num;
    }

    public boolean rightClick() {
        flagged = !flagged;
        return flagged;
    }

    public void leftClick() {
        revealed = true;
    }

    public int getNum() {
        return num;
    }

    public boolean isFlagged() {
        return flagged;
    }

    public boolean isRevealed() {
        return revealed;
    }

    public int setNum(int n) {
        if (n < 0) {
            num = BOMB;
        }

        num = n;
        return num;
    }

}
