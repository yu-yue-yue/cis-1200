(* Homework Assignment 1: OCaml Finger Exercises! *)

(* See the web pages for instructions on how to get started using Codio. *)

(* The following command tells OCaml to use the "assert" library that
   defines the run_test command used below. *)
;; open Assert

(* The Assert library by default will run _all_ of the test cases
   associated with this program.  While debugging, you may prefer to
   have testing stop and report the first failure that is encountered;
   the command below requests this behavior.  Remove or comment out
   the line if you want to see all of the test errors at once. *)
;; stop_on_failure ()


(* NOTE: you should _not_ use any of the functions that are built into
   OCaml, especially the ones in the List module, except where they
   are explicitly allowed in the comments.  The purpose of this
   assignment is to get famil with the basics of OCaml programming, so
   we want you to explicitly write out each of these problems even
   though there is often a built-in function that would achieve the
   same result. You will not receive credit for solutions that are
   contrary to the spirit of the assignment. *)

(*************************************************************************)
(* Problem 1 (counting coins) *)

(* Your job in this problem is to calculate the smallest number of
   pennies, nickels, and dimes that can be used to add up to the given
   amount. For example, to make 7 cents, a total of 3 coins are
   needed (two pennies and a nickel). To make 99 cents, 14 coins are
   needed (9 dimes, 1 nickel, and 4 pennies).
  
   First, have a look at our tests (just below the definition of the
   coins function), make sure you understand them, and fill in TWO
   MORE tests of your own.
  
   Then come back and fill in the body of the function `coins` below
   so that it returns the right answers on all the tests. Start by
   deleting the line beginning `failwith`. *)

let rec coins (amount: int) : int =
  (amount/10) + (amount mod 10)/5 + amount mod 5


(* Here are two test cases for this problem. *)

let test () : bool =
  (coins 7) = 3
;; run_test "coins nickels and pennies" test

let test () : bool =
  (coins 99) = 14
;; run_test "coins dimes, nickels, and pennies" test

(* Here are two more test case stubs. Please edit them to produce real
   tests for the coins function.

   Note: For each of the problems in the assignment, we've provided
   some test cases like the ones above.  However, just because your
   code passes our tests does not mean that you will get full
   credit. When you submit your assignment, we will test it using
   DIFFERENT tests. To make sure that your solution is robust enough
   to pass our tests, you should think about what tests you can add to
   make sure that your program is correct.
  
   STARTING FROM HW 02, WE WILL GRADE YOU ON THE QUALITY AND ROBUSTNESS
   OF YOUR TEST CASES AS PART OF YOUR "STYLE GRADE."
  
   Please refer to the FAQ page for an explanation about test cases. *)

let test () : bool =
 (coins 54) = 9
;; run_test "coins dimes and pennies" test

let test () : bool =
 (coins 1) = 1
;; run_test "one cent" test

let test () : bool =
 (coins 10) = 1
;; run_test "dimes" test

let test () : bool =
 (coins 0) = 0
;; run_test "no coins" test


(*************************************************************************)
(* Example (printing) *)

(* Printing is a useful tool, letting you see the output of your code
   on the console. In this part, we will show you how to print in
   OCaml. *)

(* Recall that OCaml files are composed of top-level definitions,
   which begin with the `let` keyword, and commands, which begin with
   two semicolons. One useful command instructs OCaml to print
   text. *)

(* The `print_endline` function causes its string argument to appear in the
   output window (much like `System.out.println` in Java). *)

;; print_endline "~~~~~~~~~~~~~~~~~~~~~~~~~"
;; print_endline "Start of printing example"

(* Adding commands to print things can be very useful for debugging
   your assignment. For example, consider the following buggy
   function: *)

let day_after (day: string) : string =
  begin match day with
  | "Monday"    -> "Tuesday"
  | "Tuesday"   -> "Wednesday"
  | "Wednesday" -> "Thursday"
  | "Thursday"  -> "Friday"
  | "Friday"    -> "Saturday"
  | "Saturday"  -> "Sunday"
  | "Sunday"    -> "Monday"
  | _           -> failwith "not a valid day"
  end

(* The following test case for this definition fails, telling us that
   this definition definitely has a bug (since the test case matches
   our understanding of what the function is supposed to do). But
   running the program just tells us that the answer is wrong, without
   showing the actual answer. *)

let test () : bool =
  (day_after "Tuesday") = "Wednesday"
;;  print_endline ("The day after Tuesday is " ^ (day_after     "Tuesday") ^ ".")
;; run_test "day_after Tuesday" test

(* Adding a print command will let us see what the erroneous result
   actually is.

   Try moving the `print_endline` command from the line below to
   before the failing test case (so that its output is displayed
   before the test fails); then run the code again. *)

(* (After running this example, go ahead and fix the bug in the
   `day_after` function so that the test passes). *)

(* Note: If the result that you want to print is not a string, you
   need to convert it to be a string. OCaml includes two library
   functions for this conversion: `string_of_int` and `string_of_bool`.
  
   After you finish problem 1 above, uncomment the next command
   to demonstrate printing integer values. *)

 
;; print_endline ("Coins to make 99 cents is "
                  ^ (string_of_int (coins 99)))


(* Feel free to add whatever printing commands you like to this
   homework assignment. The testing and grading infrastructure will
   ignore any output that your code produces. *)

;; print_endline "End of printing example"
;; print_endline "~~~~~~~~~~~~~~~~~~~~~~~"


(*************************************************************************)
(* Problem 2 (geometry) *)

(* Street magicians often use crates as tables in their acts.  Given
   the dimensions of a crate, your job in this part is to write a function to
   find the largest surface area it can provide when used as a table.
  
   Hint: OCaml provides built-in `max` and `min` functions that take in
   two arguments and behave exactly as you might expect: `max 5 2`
   returns 5, for example.  This problem can be solved using just `max`,
   `min`, and simple arithmetic.
  
   Your function's behavior when one or more of the input side lengths
   is zero or negative is not important. Your `maximum_table_area`
   function may return any value in such cases; we will not test them.
  
   Once again, you should look at our test cases first, then add your
   own test cases, and THEN come back and implement `maximum_table_area`. *)

let rec maximum_table_area (side1: int) (side2: int) (side3: int) : int =
  (max (max (side1*side2) (side2*side3)) (side1*side3))


let test () : bool =
  (maximum_table_area 1 2 3) = 6
;; run_test "maximum_table_area three different side lengths" test

let test () : bool =
  (maximum_table_area 4 3 3) = 12
;; run_test "maximum_table_area two sides the same length" test

let test () : bool =
  (maximum_table_area 5 5 5) = 25
;; run_test "maximum_table_area all sides are the same length" test

let test () : bool =
  (maximum_table_area 1 7 3) = 21
;; run_test "maximum_table_area middle length is longest" test


(*************************************************************************)
(* Problem 3 (simulating robot movement) *)

(* Help a robot move along a (linear) track, with spaces numbered 0
   through 99, by calculating its new position when given `dir` (a
   string that will be either "forward" or "backward") and `num_moves`
   indicating a (non-negative) number of spaces.  Keep in mind that
   the robot can't move past the 0 or 99 spot, so when it reaches
   either end it stays there. *)

let rec move_robot (pos: int) (dir: string) (num_moves: int) : int =
  if (num_moves = 0) then pos 
  else if pos <  0 then 0 
  else if pos > 99 then 99 
  else if dir = "forward" then (move_robot (pos + 1) (dir) (num_moves -1)) 
  else (move_robot (pos - 1) (dir) (num_moves - 1))
;;
let test () : bool =
  (move_robot 10 "forward" 3) = 13
;; run_test "move_robot forward in bounds" test

let test () : bool =
  (move_robot 1 "backward" 4 ) = 0
;; run_test "move_robot backward out of bounds" test

let test () : bool =
 (move_robot 99 "backward" 12) = 87
;; run_test "move_robot backward in bounds" test

let test () : bool =
 (move_robot 1 "backward" 1) = 0
;; run_test "move_robot backward barely in bounds" test

let test () : bool =
 (move_robot 75 "forward" 31) = 99
;; run_test "move_robot forward out of bounds" test


(*************************************************************************)
(* Problem 4 (Philadelphia geography) *)

(* Philadelphia has a fairly logical layout: the numbered streets
   are typically one-way, and their direction is determined by their
   number and where you are in the city.
  
   Even streets go one way and odd streets the other way:
  
     East of Broad (< 14th): even go south, odd go north
     West of Broad (> 14th): even go north, odd go south
     West Philly  (>= 32nd): even go south, odd go north
     West Philly  (>= 46th): two-way
  
   There are, however, a few exceptions.
     - 1st and 14th do not actually exist as street names -- they're
       called Front and Broad. We'll ignore this and pretend they do.
     - Broad (14th), 25th, 38th, 41st, and 42nd are all two-way.
     - 24th and 59th go south.
     - 58th goes north.
  
   Write a program that returns one of four string values for each street
   number:
     - "N/A" when the street doesn't exist. We only consider 1st
       through 69th Streets.
     - "N" when the street goes north.
     - "S" when the street goes south.
     - "NS" when the street is two-way.
  
   Hints:
     - You may find the infix `mod` (modulo) function useful: for example,
       `x mod 2` evaluates to 0 if x is even and 1 otherwise.
     - Sometimes there is no simple/clever way of writing down a
       complex case analysis: you just have to write out all the cases.
  
   Welcome to Philadelphia! *)

let rec street_direction (st: int) : string =
  if ((st < 1) || (st > 69)) then "N/A"
  else if ((st = 14) || (st = 25) || 
  (st = 38) || (st = 41) || (st = 42)) then "NS" 
  else if ((st = 24) || (st = 59)) then "S"
  else if (st = 58) then "N"
  else if ((st < 14) && (st mod 2 = 0)) then "S"
  else if (st < 14) then "N"
  else if ((st < 32) && (st mod 2 = 0)) then "N"
  else if (st < 32) then "S" 
  else if (st < 46) && (st mod 2 = 0) then "S"
  else if (st < 46) then "N"
  else "NS"
;;

let test () : bool =
  (street_direction 73) = "N/A"
;; run_test "street_direction not a valid street" test

let test () : bool =
  (street_direction 14) = "NS"
;; run_test "street_direction Broad is two-way" test

let test () : bool =
  (street_direction 9) = "N"
;; run_test "street_direction 9th goes north" test

let test () : bool =
  (street_direction 18) = "N"
;; run_test "street_direction 18th goes north" test

let test () : bool =
  (street_direction 33) = "N"
;; run_test "street_direction 33st goes north" test

let test () : bool =
 (street_direction 56) = "NS"
;; run_test "street_direction 56th is two-way" test


(*************************************************************************)

(* The remaining exercises provide practice with lists and recursion.
   It is best to wait until after these topics are covered in lecture before
   tackling these problems. *)

(*************************************************************************)
(* Problem 5 (exists) *)

(* Write a function that determines whether at least one boolean value
   in its input list is true. *)

let rec exists (bools: bool list) : bool =
  begin match bools with 
  | [] -> false 
  | x :: tail -> x || exists tail 
  end 
;; 

(* (The `not` function below takes in a boolean value and returns its
   complement.) *)

let test () : bool =
  not (exists [false; false])
;; run_test "exists all false" test

let test () : bool =
  (exists [true; false; true])
;; run_test "exists multiple true" test

let test () : bool =
 (exists [true; false; false])
;; run_test "exists one true" test

let test () : bool =
 (exists [true])
;; run_test "exists all true" test


(*************************************************************************)
(* Problem 6 (join) *)

(* Write a function that takes a list of strings and "flattens" it
   into a single string. Your function should also take an additional
   argument, a separator string, which is interspersed between all of
   the strings in the list.
  
   Hint: the ^ operator concatenates two strings together. For example,
   `"a" ^ "bc"` evaluates to "abc". *)

let rec join (separator: string) (l: string list) : string =
  begin match l with 
  |[] -> ""
  |x :: [] -> x
  |x :: tail -> x^separator^(join separator tail) 
  end
;;


let test () : bool =
  (join "," ["a"; "b"; "c"]) = "a,b,c"
;; run_test "test_join nonempty separator" test

let test () : bool =
  (join "" ["a"; "b"; "c"]) =  "abc"
;; run_test "test_join empty separator" test

let test () : bool =
 (join "," ["a"]) = "a"
;; run_test "test_join list size 1" test

let test () : bool =
 (join "," []) = ""
;; run_test "test_join empty list" test


(*************************************************************************)
(* Example (printing lists) *)

;; print_endline "~~~~~~~~~~~~~~~~~~~~~~~~"
;; print_endline "Start of list printing example"

(* Once you have implemented the `join` function above, you can use it
   to print out lists of strings. This can be very useful for
   debugging the remaining tasks in this assignment, as you can print
   out the output of your functions to help you understand why your
   test cases are failing *)


;; print_endline (join "," ["a"; "b"; "c"])


(* If you would like to print a list of `int`s, you'll need a variant
   of the `join` function for this purpose. We advise that you go
   ahead and do this so that you can use this function to help debug
   the last few tasks in this homework. *)

let rec int_join (separator: string) (l: int list) : string =
  begin match l with 
  |[] -> ""
  |x :: [] -> string_of_int x
  |x :: tail -> (string_of_int x)^separator^(int_join separator tail) 
  end


;; print_endline ("[" ^ (int_join ";" [1; 2; 3]) ^ "]")


;; print_endline "End of list printing example"
;; print_endline "~~~~~~~~~~~~~~~~~~~~~~~~"

(*************************************************************************)
(* Problem 7 (append) *)

(* Write a function that takes lists l1 and l2 and returns a list
   containing all the items in l1 followed by all the items in l2.
  
   NOTE: OCaml actually already provides this function. In future
   homeworks you can use built in operator `@`, which appends l1 and l2,
   as in l1 @ l2. Do *not* use the @ operator in your solution to this
   problem. *)

let rec append (l1: string list) (l2: string list) : string list =
  begin match l1 with 
  | [] -> l2
  | x :: tail -> x :: append tail l2
  end
  ;;

let test () : bool =
  (append [] []) = []
;; run_test "append two empty lists" test

let test () : bool =
  (append ["1"; "2"] ["3"]) = ["1"; "2"; "3"]
;; run_test "append different lengths" test

let test () : bool =
 (append ["1"] []) = ["1"]
;; run_test "append an empty list" test

let test () : bool =
 (append [] ["1"]) = ["1"]
;; run_test "append to an empty list" test


(*************************************************************************)
(* Problem 8 (finding names in a list) *)

(* Write a function that checks whether a list of names contains some
   particular name. *)

let rec contains_str (l: string list) (name: string) : bool =
  begin match l with 
  | [] -> false
  | x :: tail -> (x = name || contains_str tail name)
  end
  ;;

let test () : bool =
  (contains_str ["Garnet"; "Amethyst"; "Pearl"] "Amethyst")
;; run_test "contains_str name in list once" test

let test () : bool =
  not (contains_str ["Garnet"; "Amethyst"; "Pearl"] "Steven")
;; run_test "contains_str name not in list" test

let test () : bool =
 (contains_str ["Amethyst"; "Amethyst"; "Amethyst"] "Amethyst")
;; run_test "contains_str name in list multiple times" test

let test () : bool =
 (contains_str ["Garnet"; "Amethyst"; "Pearl"] "Pearl")
;; run_test "contains_str name is last" test


(* Next, write a function that, given two lists of names, filters the
   first list so that only those that are also in the second list
   remain. That is, your function should return a list containing all
   the elements that appear in both lists, in the order that they
   appear in the first list. *)

let rec in_both (names1: string list) (names2: string list) : string list =
  begin match names1 with 
  | [] -> []
  | x :: tail -> 
    if (contains_str names2 x) then x :: in_both tail names2 
    else in_both tail names2
  end
  ;;
let test () : bool =
  (in_both ["Garnet"; "Amethyst"; "Pearl"] ["Pearl"; "Steven"]) = ["Pearl"]
;; run_test "in_both Pearl in both lists" test

let test () : bool =
  (in_both [] ["Pearl"; "Steven"]) = []
;; run_test "in_both empty name1 list" test

let test () : bool =
  (in_both ["Pearl"; "Steven"] []) = []
;; run_test "in_both empty name2 list" test

let test () : bool =
 (in_both ["Garnet"; "Amethyst"; "Pearl"] ["Pearl"; "Garnet"]) = ["Garnet"; 
 "Pearl"]
;; run_test "in_both Pearl Garnet opposite orders" test

let test () : bool =
 (in_both ["Garnet"; "Amethyst"; "Pearl"] 
 ["Pearl"; "Garnet"; "Amethyst"]) = ["Garnet"; "Amethyst"; "Pearl"]
;; run_test "in_both same names different orders" test


(*************************************************************************)
(* Problem 9 (merging lists) *)

(* Write a function that merges two input lists into a single list
   that contains all the elements from both input lists in alternating
   order: the first, third, etc. elements come from the first input
   list and the second, fourth, etc. elements come from the second
   input list.
  
   The lengths of the two lists may not be the same -- any left over
   elements should appear at the very end of the result. *)

let rec merge (l1: int list) (l2: int list) : int list =
  begin match l1 with 
  | [] -> l2
  | x :: tail -> x :: merge l2 tail 
  end
;;

let test () : bool =
  (merge [1; 3; 5; 7] [2; 4; 6; 8]) = [1; 2; 3; 4; 5; 6; 7; 8]
;; run_test "merge lists same size" test

let test () : bool =
  (merge [] [1; 2; 3]) = [1; 2; 3]
;; run_test "merge one empty list" test

let test () : bool =
 (merge [1; 3; 5; 7; 9] [2; 4; 6]) = [1; 2; 3; 4; 5; 6; 7; 9]
;; run_test "merge first list larger" test

let test () : bool =
 (merge [1; 3; 5] [2; 4; 6; 8; 10]) = [1; 2; 3; 4; 5; 6; 8; 10]
;; run_test "merge second list larger" test


(*************************************************************************)
(* Problem 10 (is_sorted) *)

(* Write a function that determines whether a given list of integers
   is SORTED -- that is, whether the elements appear in ascending
   order. 

   A sorted list may have repeated elements, so long as they are next
   to each other.  Lists containing zero or one elements are
   considered sorted. *)

let rec is_sorted (l: int list) : bool =
  begin match l with 
  | x :: y :: tail -> (x <= y) && is_sorted (y :: tail)
  | _ -> true  
  end
;;

let test () : bool =
  (is_sorted [1; 2; 3])
;; run_test "is_sorted sorted list" test

let test () : bool =
  not (is_sorted [3; 2; 1])
;; run_test "is_sorted unsorted list" test

let test () : bool =
 (is_sorted [1; 1; 1])
;; run_test "is_sorted repeated numbers" test

let test () : bool =
 (is_sorted [])
;; run_test "is_sorted empty" test

let test () : bool =
 (is_sorted [1])
;; run_test "is_sorted one" test



(*************************************************************************)
(* Problem 11 (merge_sorted) *)

(* Write a function that takes two sorted lists (in ascending order)
   and yields a merged list that is also sorted and contains all the
   elements from the two input lists. *)


let rec merge_sorted (l1: int list) (l2: int list) : int list =
  begin match l1, l2 with 
  |[], _ -> l2
  |_, [] -> l1
  | x :: tail1, y :: tail2 ->
    if (x <= y) then (x :: merge_sorted tail1 l2)
      else (y :: merge_sorted l1 tail2)
  end

;;

let test () : bool =
  (merge_sorted [2; 7] [3; 5; 11]) = [2; 3; 5; 7; 11]
;; run_test "merge_sorted lists different size" test

let test () : bool =
  (merge_sorted [1; 2; 3] [4; 5; 6]) = [1; 2; 3; 4; 5; 6]
;; run_test "merge_sorted lists same size" test

let test () : bool =
 (merge_sorted [1; 2; 3] [1; 5; 6]) = [1; 1; 2; 3; 5; 6]
;; run_test "merge_sorted repeating numbers" test

let test () : bool =
 (merge_sorted [] [1; 2; 3]) = [1; 2; 3]
;; run_test "merge_sorted empty" test


(*************************************************************************)
(* Problem 12 (sublist) *)

(* Write a function that takes two integer lists (not necessarily
   sorted) and returns true precisely when the first list is a sublist
   of the second.
  
   The first list may appear anywhere within the second, but its elements
   must appear contiguously.
  
   HINT: You should define (and test!) a helper function that you can use
   to define sublist. *)


(* given that the lists start with the same value *)
let rec start_sublist (l1: int list) (l2: int list) : bool =
  begin match l1, l2 with 
  | [], _ -> true
  | _ , [] -> false
  | x :: xs , y :: ys -> (x = y && start_sublist xs ys)
  end
;;

let rec sublist (l1: int list) (l2: int list) : bool = 
  begin match l1, l2 with 
  | [], _ -> true
  | _ , [] -> false
  | x :: xs , y :: ys -> (x = y && start_sublist xs ys) || sublist l1 ys
  end
;;
;;
(*start_sublist tests*)

let test () : bool =
  (start_sublist [] [])
;; run_test "start sublist two empty lists" test

let test () : bool =
  (start_sublist [] [1;2;3])
;; run_test "start sublist one empty list" test

let test () : bool =
  not (start_sublist [2;3] [1;2;3])
;; run_test "sublist but not start sublist" test

let test () : bool =
  not (start_sublist [2;3] [2;1;3])
;; run_test "start sublist elements are not contiguous" test

let test () : bool =
  (start_sublist [1] [1;2;3])
;; run_test "is a start sublist one element" test

let test () : bool =
  (start_sublist [1; 2] [1;2;3])
;; run_test "is a start sublist" test

(*sublist tests*)

let test () : bool =
  (sublist [] [])
;; run_test "sublist two empty lists" test

let test () : bool =
  (sublist [] [1;2;3])
;; run_test "sublist one empty list" test

let test () : bool =
  (sublist [2] [1;2;3])
;; run_test "sublist is one element" test

let test () : bool =
  (sublist [2;3] [1;2;3])
;; run_test "sublist is a sublist" test

let test () : bool =
  not (sublist [2;3] [2;1;3])
;; run_test "sublist elements are not contiguous" test


(*************************************************************************)
(* Problem 13 (rainfall) *)

(* Design and implement a function called `rainfall` that consumes a
   list of ints representing daily rainfall readings. The list may
   contain the number -999 indicating the end of the data of interest.
  
   Produce the average of the non-negative values in the list up to
   the first -999 (if any). There may be negative numbers other than
   -999 in the list, representing faulty readings; these should be
   skipped.  If you cannot compute an average, for whatever reason,
   return -1.  *)

let rec elements (readings: int list) : int = 
  begin match readings with 
  | [] -> 0
  | hd :: tail -> if hd = -999 then 0
    else if hd < 0 then elements tail
    else (elements tail) + 1
  end 
;;

let rec sum (readings: int list) : int = 
  begin match readings with 
    | [] -> 0
    | hd :: tail -> if hd = -999 then 0
      else if hd < 0 then sum tail
      else (sum tail) + hd
    end 
  ;;  

let rainfall (readings: int list) : int =
  if elements readings = 0 then -1 
  else (sum readings)/(elements readings)

(* For example, if we have readings [1; 2; 3], then the average
   rainfall is (1 + 2 + 3) / 3 = 6/3 = 2. *)
let test () : bool =
  rainfall [1; 2; 3] = 2
;; run_test "example" test

(* NOTE: for simplicity, you should only use int operations in this
   problem.  This may lead to slightly wrong answers, as integer
   division discards the fractional part of its result instead of
   rounding. *)

let test () : bool =
  rainfall [ 2; 2; 2; 2; 1] = 1
;; run_test "use integer division to calculate average" test

(* HINT: Before you implement anything, make sure that you add some
   more test cases. The two tests above do not cover all of the
   situations in the problem description. *)

let test () : bool =
 rainfall [1; 1; -3; 2] = 1
;; run_test "rainfall skipping negative numbers" test

let test () : bool =
 rainfall [1; 1; -999; 10] = 1
;; run_test "rainfall ending at -999" test

let test () : bool =
 rainfall [-1; -1; -3; -2] = -1
;; run_test "all negative numbers" test

let test () : bool =
 rainfall [] = -1
;; run_test "empty set" test


(*************************************************************************)
(* Kudos Problem (permutations) *)

(* This one is a challenge problem, worth 0 points -- "kudos only." *)

(* A PERMUTATION of a list l is a list that has the same elements as l
   but is not necessarily in the same order.

   Write a function that, given a list l, calculates ALL of the
   permutations of l (and returns them as a list). For example,

       permutations [1;2;3]

   might yield

       [[1;2;3]; [1;3;2]; [2;1;3]; [2;3;1]; [3;1;2]; [3;2;1]].

   (We say "might yield" here instead of "yields" because we haven't
   specified the order of the permutations in the list returned by
   your function.  For example, the result

       [[1;3;2]; [2;1;3]; [2;3;1]; [3;1;2]; [3;2;1]; [1;2;3]]

   would also be correct.)

   Hint: Begin by writing several  unit tests, to make sure you
   understand the problem. (Even though you may need to rewrite them
   if your answer comes out in a different order, the exercise of
   writing them first is useful.) Also, you'll probably want to break
   the problem down into one or more sub-problems, each of which can
   be solved by recursion. *)


(* Note: Do not remove or comment out this function stub, even if you
   choose not to attempt the challenge problem. Your file will not
   compile when you upload it for grading if `permutations` is
   missing. *)

let rec permutations (l: int list) : int list list =
  failwith "permutations: unimplemented"

(* Note that you will also have to think about how to TEST
   permutations, as there may be several correct solutions for each
   input. *)

(* The last thing in this file is a print statement. When you see this
   line after running your code, you will know that all of the tests
   in this file have succeeded. *)
;; print_endline "intro.ml: ran to completion"
