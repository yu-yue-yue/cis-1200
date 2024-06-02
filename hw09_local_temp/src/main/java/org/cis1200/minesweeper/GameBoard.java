package org.cis1200.minesweeper;

/*
 * CIS 120 HW09 - TicTacToe Demo
 * (c) University of Pennsylvania
 * Created by Bayley Tuch, Sabrina Green, and Nicolas Corona in Fall 2020.
 */

import java.awt.*;
import java.awt.event.*;
import java.awt.image.BufferedImage;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.swing.*;

/**
 * This class instantiates a TicTacToe object, which is the model for the game.
 * As the user clicks the game board, the model is updated. Whenever the model
 * is updated, the game board repaints itself and updates its status JLabel to
 * reflect the current state of the model.
 * 
 * This game adheres to a Model-View-Controller design framework. This
 * framework is very effective for turn-based games. We STRONGLY
 * recommend you review these lecture slides, starting at slide 8,
 * for more details on Model-View-Controller:
 * https://www.seas.upenn.edu/~cis120/current/files/slides/lec37.pdf
 * 
 * In a Model-View-Controller framework, GameBoard stores the model as a field
 * and acts as both the controller (with a MouseListener) and the view (with
 * its paintComponent method and the status JLabel).
 */
@SuppressWarnings("serial")
public class GameBoard extends JPanel {

    private Minesweeper ms; // model for the game
    private JLabel status; // current status text
    private final String filePath = "files/game_state.txt";

    // Game constants
    public static final int BOARD_WIDTH = 500;
    public static final int BOARD_HEIGHT = 500;

    private BufferedImage[] images = new BufferedImage[8];

    private boolean clicked;

    /**
     * Initializes the game board.
     */
    public GameBoard(JLabel statusInit) {
        // creates border around the court area, JComponent method
        setBorder(BorderFactory.createLineBorder(Color.BLACK));

        // Enable keyboard focus on the court area. When this component has the
        // keyboard focus, key events are handled by its key listener.
        setFocusable(true);

        status = statusInit; // initializes the status JLabel


        for (int i = 0; i < images.length; i++) {
            try {
                images[i] = ImageIO.read(new File("files/" + (String.valueOf(i + 1)) + ".png"));

            } catch (IOException e) {
                System.out.println("Internal Error:" + e.getMessage());
            }
        }

        /*
         * Listens for mouseclicks. Updates the model, then updates the game
         * board based off of the updated model.
         */
        addMouseListener(new MouseAdapter() {
            @Override
            public void mouseReleased(MouseEvent e) {
                Point p = e.getPoint();

                int x = p.x * ms.getSize() / BOARD_WIDTH;
                int y = p.y * ms.getSize() / BOARD_HEIGHT;

                if (!clicked) {
                    ms.populateBoard(x, y);
                    clicked = true;
                }


                // updates the model given the coordinates of the mouseclick
                ms.playTurn(x, y, SwingUtilities.isLeftMouseButton(e));

                writeGameState();
                updateStatus(); // updates the status JLabel
                repaint(); // repaints the game board
            }
        });
    }

    public void initialize(int n) {

        if (filePath != null) {
            FileToCellArray f = new FileToCellArray(filePath);
            Cell[][] cells = f.createArray();
            if (cells != null) {
                ms = new Minesweeper(cells);
                clicked = true;
                status.setText("Mining... " +
                        (ms.getNumBombs() - ms.getNumFlags()) +
                        " bombs left.");
            } else {
                ms = new Minesweeper(n);
                clicked = false;
            }
        } else {
            ms = new Minesweeper(n);
            clicked = false;
        }

    }

    /**
     * (Re-)sets the game to its initial state.
     */
    public void reset(int n) {
        ms.reset(n);
        clicked = false;
        status.setText("Searching for bombs...");
        repaint();

        // Makes sure this component has keyboard/mouse focus
        requestFocusInWindow();
    }

    /**
     * Updates the JLabel to reflect the current state of the game.
     */
    private void updateStatus() {
        if (ms.checkWinner()) {
            status.setText("You won!");
        } else if (ms.gameOver()) {
            status.setText("You blew up. Try again.");
        } else {
            status.setText(
                    "Mining... " + (ms.getNumBombs() - ms.getNumFlags()) + " bombs remaining."
            );
        }
    }

    public int numBombs() {
        return ms.getNumBombs();
    }

    /**
     * Draws the game board.
     *
     * There are many ways to draw a game board. This approach
     * will not be sufficient for most games, because it is not
     * modular. All of the logic for drawing the game board is
     * in this method, and it does not take advantage of helper
     * methods. Consider breaking up your paintComponent logic
     * into multiple methods or classes, like Mushroom of Doom.
     */
    @Override
    public void paintComponent(Graphics g) {
        super.paintComponent(g);
        Graphics2D g2d = (Graphics2D) g;
        int width = BOARD_WIDTH / ms.getSize() + 1;
        int height = BOARD_HEIGHT / ms.getSize() + 1;

        if (ms.gameOver()) {
            g2d.setColor(Color.BLACK);
            g2d.fillRect(0, 0, BOARD_WIDTH, BOARD_HEIGHT);
            g2d.setColor(Color.RED);
            g2d.drawString("BOOM.", BOARD_WIDTH / 8, BOARD_HEIGHT / 2);
            return;
        }

        if (ms.checkWinner()) {
            for (int r = 0; r < ms.getSize(); r++) {
                for (int c = 0; c < ms.getSize(); c++) {
                    Cell cell = ms.getCell(r, c);
                    int x = r * BOARD_WIDTH / ms.getSize();
                    int y = c * BOARD_HEIGHT / ms.getSize();

                    if (ms.getCell(r, c).isRevealed()) {
                        g2d.setColor(new Color(10, 100, 10));
                    } else {
                        g2d.setColor(new Color(255, 150, 170));
                    }

                    g2d.fillRect(x, y, width, height);
                    g2d.setColor(Color.BLACK);
                }
            }
            return;
        }

        if (!clicked) {
            for (int r = 0; r < ms.getSize(); r++) {
                for (int c = 0; c < ms.getSize(); c++) {
                    Cell cell = ms.getCell(r, c);
                    int x = r * BOARD_WIDTH / ms.getSize();
                    int y = c * BOARD_HEIGHT / ms.getSize();

                    if ((r + c) % 2 == 0) {
                        g2d.setColor(Color.LIGHT_GRAY);
                    } else {
                        g2d.setColor(Color.DARK_GRAY);
                    }

                    g2d.fillRect(x, y, width, height);
                }
            }
            return;

        } else {
            for (int r = 0; r < ms.getSize(); r++) {
                for (int c = 0; c < ms.getSize(); c++) {
                    Cell cell = ms.getCell(r, c);
                    int x = r * BOARD_WIDTH / ms.getSize();
                    int y = c * BOARD_HEIGHT / ms.getSize();

                    if (cell.isFlagged()) {
                        g2d.setColor(Color.RED);
                        g2d.fillRect(x, y, width, height);
                    } else if (cell.isRevealed()) {
                        g2d.setColor(
                                new Color(
                                        255 - cell.getNum() * 255 / 8,
                                        255 - cell.getNum() * 255 / 8,
                                        255
                                )
                        );
                        g2d.fillRect(x, y, width, height);
                        if (cell.getNum() != 0) {
                            int buffer = width / 8;
                            g2d.drawImage(
                                    images[cell.getNum() - 1], x + buffer, y + buffer,
                                    width - buffer, height - buffer, null
                            );
                        }
                    } else {
                        if ((r + c) % 2 == 0) {
                            g2d.setColor(Color.LIGHT_GRAY);
                        } else {
                            g2d.setColor(Color.DARK_GRAY);
                        }

                        g2d.fillRect(x, y, width, height);
                    }

                }
            }
        }

    }

    /**
     * Returns the size of the game board.
     */
    @Override
    public Dimension getPreferredSize() {
        return new Dimension(BOARD_WIDTH, BOARD_HEIGHT);
    }

    public void writeGameState() {
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter(filePath));
            int size = ms.getSize();

            bw.write(String.valueOf(size));
            bw.write("\n");

            if (ms.gameOver() || ms.checkWinner()) {
                bw.write("");
                return;
            }

            for (int r = 0; r < size; r++) {
                for (int c = 0; c < size; c++) {
                    Cell cell = ms.getCell(r, c);

                    bw.write(cell.getNum() + ", ");

                    if (cell.isRevealed()) {
                        bw.write("1, ");
                    } else {
                        bw.write("0, ");
                    }

                    if (cell.isFlagged()) {
                        bw.write("1, ");
                    } else {
                        bw.write("0, ");
                    }

                    bw.write("\n");
                }
            }
            bw.close();

        } catch (IOException exception) {
            System.out.println("System error: did not save game.");
            return;
        }
    }
}
