package org.cis1200.minesweeper;

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.BufferedReader;
import java.util.NoSuchElementException;

/**
 * FileLineIterator provides a useful wrapper around Java's provided
 * BufferedReader and provides practice with implementing an Iterator. Your
 * solution should not read the entire file into memory at once, instead reading
 * a line whenever the next() method is called.
 * <p>
 * Note: Any IOExceptions thrown by readers should be caught and handled
 * properly. Do not use the ready() method from BufferedReader.
 */
public class FileToCellArray {

    // Add the fields needed to implement your FileLineIterator
    BufferedReader reader;
    int c;

    /**
     * Creates a FileLineIterator for the reader. Fill out the constructor so
     * that a user can instantiate a FileLineIterator. Feel free to create and
     * instantiate any variables that your implementation requires here. See
     * recitation and lecture notes for guidance.
     * <p>
     * If an IOException is thrown by the BufferedReader, then hasNext should
     * return false.
     * <p>
     * The only method that should be called on BufferedReader is readLine() and
     * close(). You cannot call any other methods.
     *
     * @param reader - A reader to be turned to an Iterator
     * @throws IllegalArgumentException if reader is null
     */
    public FileToCellArray(BufferedReader reader) {
        // Complete this constructor.
        if (reader == null) {
            throw new IllegalArgumentException();
        }

        this.reader = reader;
        c = 0;

        skipWhiteSpace();

    }

    /**
     * Creates a FileLineIterator from a provided filePath by creating a
     * FileReader and BufferedReader for the file.
     * <p>
     * DO NOT MODIFY THIS METHOD.
     *
     * @param filePath - a string representing the file
     * @throws IllegalArgumentException if filePath is null or if the file
     *                                  doesn't exist
     */
    public FileToCellArray(String filePath) {
        this(fileToReader(filePath));
    }

    /**
     * Takes in a filename and creates a BufferedReader.
     * See Java's documentation for Buf  feredReader to learn how to construct one
     * given a path to a file.
     *
     * @param filePath - the path to the CSV file to be turned to a
     *                 BufferedReader
     * @return a BufferedReader of the provided file contents
     * @throws IllegalArgumentException if filePath is null or if the file
     *                                  doesn't exist
     */
    public static BufferedReader fileToReader(String filePath) {
        FileReader fr;
        if (filePath == null) {
            throw new IllegalArgumentException();
        }
        try {
            fr = new FileReader(filePath);
        } catch (FileNotFoundException e) {
            throw new IllegalArgumentException();
        }
        BufferedReader br = new BufferedReader(fr);

        return br; // Complete this method.

    }

    /**
     * Returns true if there are lines left to read in the file, and false
     * otherwise.
     * <p>
     * If there are no more lines left, this method attempts to close the
     * BufferedReader. In case of an IOException during the closing process,
     * an error message is printed to the console indicating the issue.
     *
     * @return a boolean indicating whether the FileLineIterator can produce
     *         another line from the file
     */

    public boolean hasNext() {
        return c != -1; // Complete this method.
    }

    /**
     * Returns the next line from the file, or throws a NoSuchElementException
     * if there are no more strings left to return (i.e. hasNext() is false).
     * <p>
     * This method also advances the iterator in preparation for another
     * invocation. If an IOException is thrown during a next() call, your
     * iterator should make note of this such that future calls of hasNext()
     * will return false and future calls of next() will throw a
     * NoSuchElementException
     *
     * @return the next cell displayed by the file, null if the next line is not
     * representative of a cell
     * @throws java.util.NoSuchElementException if there is no more data in the
     *                                          file
     */

    public String nextLine() {
        if (!hasNext()) {
            throw new NoSuchElementException();
        }

        String nextLine = "";


        try {
            while (c != (int) '\n' && c != -1) {
                nextLine += (char) c;
                c = reader.read();

            }

            if (c == -1) {
                reader.close();
            }


        } catch (IOException e) {
            c = -1;
            throw new NoSuchElementException();
        }

        skipWhiteSpace();
        return nextLine;
    }

    public Cell next() {
        // Complete this method.
        if (!hasNext()) {
            throw new NoSuchElementException();
        }

        Cell cell;
        String nextLine = "";


        try {
            while (c != (int) '\n' && c != -1) {
                nextLine += (char) c;
                c = reader.read();

            }

            if (c == -1) {
                reader.close();
            }

            String[] values = nextLine.split(", ");
            int vl = values.length;

            if (vl < 1 || Integer.parseInt(values[0]) > 8) {
                return null;
            }
            cell = new Cell(Integer.parseInt(values[0]));

            if (vl > 1) {
                if (Integer.parseInt(values[1]) > 0) {
                    cell.leftClick();
                }

                if (vl > 2) {
                    if (Integer.parseInt(values[2]) > 0) {
                        cell.rightClick();
                    }
                }
            }


        } catch (IOException e) {
            c = -1;
            return null;
        } catch (NumberFormatException e) {
            return null;
        }

        skipWhiteSpace();
        return cell;
    }

    private void skipWhiteSpace() {
        try {
            c = reader.read();
            while (c == (int) '\n' || c == ' ') {
                c = reader.read();
            }
        } catch (IOException e) {
            c = -1;
        }

    }

    public Cell[][] createArray() {
        Cell[][] cells;
        int length = 0;
        if (hasNext()) {
            try {
                length = Integer.parseInt(nextLine());
            } catch (NumberFormatException e) {
                return null;
            }

            cells = new Cell[length][length];
        } else {
            return null;
        }

        for (int r = 0; r < length; r++) {
            for (int c = 0; c < length; c++) {
                if (hasNext()) {
                    cells[r][c] = next();
                } else {
                    return null;
                }
            }
        }

        return cells;
    }

}

