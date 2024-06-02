package org.cis1200.minesweeper;

/*
 * CIS 120 HW09 - TicTacToe Demo
 * (c) University of Pennsylvania
 * Created by Bayley Tuch, Sabrina Green, and Nicolas Corona in Fall 2020.
 */

import java.awt.*;
import javax.swing.*;

/**
 * This class sets up the top-level frame and widgets for the GUI.
 * 
 * This game adheres to a Model-View-Controller design framework. This
 * framework is very effective for turn-based games. We STRONGLY
 * recommend you review these lecture slides, starting at slide 8,
 * for more details on Model-View-Controller:
 * https://www.seas.upenn.edu/~cis120/current/files/slides/lec37.pdf
 * 
 * In a Model-View-Controller framework, Game initializes the view,
 * implements a bit of controller functionality through the reset
 * button, and then instantiates a GameBoard. The GameBoard will
 * handle the rest of the game's view and controller functionality, and
 * it will instantiate a TicTacToe object to serve as the game's model.
 */
public class RunMinesweeper implements Runnable {


    public void run() {
        // NOTE: the 'final' keyword denotes immutability even for local variables.

        // Top-level frame in which game components live
        final JFrame frame = new JFrame("Minesweeper");
        frame.setLocation(100, 10);

        // Instructions frame (pop-up)
        final JFrame instructions = new JFrame("Instructions");
        instructions.setLocation(100, 10);
        final JPanel textPanel = new JPanel();
        final JTextArea text = new JTextArea(
                "Minesweeper is a game where mines are hidden in a grid of squares. \n" +
                "Safe squares have numbers telling you how many mines touch the square. \n" +
                "You can use the number clues to solve the game by opening all safe squares. \n" +
                "If you click on a mine you lose the game! \n" +
                "The first click is always safe. \n" +
                "You open squares by left-clicking and put flags by right-clicking. \n" +
                "Pressing the right mouse button again removes the flag. \n" +
                "When you open a square that does not touch any mines, it will be empty \n" +
                "and the adjacent squares will automatically open in all directions until \n " +
                "reaching squares that contain numbers.");
        text.setEditable(false);
        textPanel.add(text);
        instructions.add(textPanel, BorderLayout.CENTER);
        instructions.pack();
        instructions.setDefaultCloseOperation(
                JFrame.HIDE_ON_CLOSE);

        // Puts the window on the screen if the button is clicked, remove it if it is clicked again
        final JButton instruct = new JButton("INSTRUCTIONS");
        instruct.addActionListener(e -> instructions.setVisible(!instructions.isVisible()));

        // Status panel
        final JPanel status_panel = new JPanel();
        frame.add(status_panel, BorderLayout.SOUTH);
        final JLabel status = new JLabel("Setting up...");
        status_panel.add(status);

        // Game board
        final GameBoard board = new GameBoard(status);
        frame.add(board, BorderLayout.CENTER);

        // Reset buttons
        final JPanel control_panel = new JPanel();
        control_panel.add(instruct);
        frame.add(control_panel, BorderLayout.NORTH);

        // Note here that when we add an action listener to the reset button, we
        // define it as an anonymous inner class that is an instance of
        // ActionListener with its actionPerformed() method overridden. When the
        // button is pressed, actionPerformed() will be called.
        final JButton easy = new JButton("Easy");
        easy.addActionListener(e -> board.reset(Minesweeper.SMALL));
        control_panel.add(easy);

        final JButton medium = new JButton("Medium");
        medium.addActionListener(e -> board.reset(Minesweeper.MEDIUM));
        control_panel.add(medium);

        final JButton hard = new JButton("Hard");
        hard.addActionListener(e -> board.reset(Minesweeper.LARGE));
        control_panel.add(hard);
        // Put the frame on the screen
        frame.pack();
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setVisible(true);



        // Start the game
        board.initialize(Minesweeper.SMALL);
    }
}