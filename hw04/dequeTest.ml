(*****************************************************************************)
(* PROBLEM 7: WRITING TEST CASES                                             *)
(*****************************************************************************)

;; open Assert
;; open Deque

(* `DequeTest` is used to test the deque implementation from deque.ml.

   Read through the module, then write your test cases in the space
   provided below.  Your TAs will be grading the completeness of your
   tests.  *)

;; print_endline ("\n--- Running tests for Deque ---")

(* Here is a test to help get you started. *)

let test () : bool =
  is_empty (create ())
;; run_test "is_empty: call on empty returns true" test


(* Now, it's your turn...

   Make sure to comprehensively test all the other functions you
   implemented in deque.ml. It will probably be helpful to have the
   files deque.ml/mli open as you work.

   We provide many test cases for you; your job here is to finish writing
   tests for `remove_head`, `remove_tail`, `delete_last`, `delete_first`, and
   `reverse`.

   Your TAs will be manually grading the completeness of your test cases.

   Note: Remember the difference between structural and reference
   equality; think about why you shouldn't be directly comparing
   deques with the '=' of structural equality. *)

(* ---------- Write your own test cases below. ---------- *)

(* INSERT_HEAD TESTS *)
let test () : bool =
  let d = create () in
  insert_head 1 d;
  valid d && peek_head d = 1 && peek_tail d = 1
;; run_test "insert_head into empty" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 2 d;
  valid d && peek_head d = 2 && peek_tail d = 1
;; run_test "insert_head into singleton" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 2 d;
  insert_head 3 d;
  valid d && peek_head d = 3 && peek_tail d = 1
;; run_test "insert_head into non-empty, multi-element" test

(* INSERT_TAIL TESTS *)
let test () : bool =
  let d = create () in
  insert_tail 1 d;
  valid d && peek_head d = 1 && peek_tail d = 1
;; run_test "insert_tail into empty" test

let test () : bool =
  let d = create () in
  insert_tail 1 d;
  insert_tail 2 d;
  valid d && peek_head d = 1 && peek_tail d = 2
;; run_test "insert_tail into singleton" test

let test () : bool =
  let d = create () in
  insert_tail 1 d;
  insert_tail 2 d;
  insert_tail 3 d;
  valid d && peek_head d = 1 && peek_tail d = 3
;; run_test "insert_tail into non-empty, multi-element" test

(* TO_LIST TESTS *)
let test () : bool =
  to_list (create ()) = []
;; run_test "to_list empty" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  to_list d = [1]
;; run_test "to_list singleton" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 2 d;
  insert_head 3 d;
  to_list d = [3; 2; 1]
;; run_test "to_list multiple elements" test

(* REMOVE_HEAD *)

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 2 d;
  remove_head d = 2 && to_list d = [1]
;; run_test "remove_head multiple" test

let test () : bool =
  let d = create () in
  insert_tail 1 d;
  insert_tail 2 d;
  remove_head d = 1 && to_list d = [2]
;; run_test "remove_head inserted with tail" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  remove_head d = 1 && is_empty d
;; run_test "remove_head singleton" test

let test () : bool =
  let d = create () in
  remove_head d = 1 && is_empty d
;; run_failing_test "remove_head empty" test

let test () : bool =
  let d = create () in
  let x = 1 in
  insert_head x d;
  insert_head 1 d;
  insert_head x d;
  remove_head d = x && to_list d = [1; x]
;; run_test "remove_head duplicates" test


(* REMOVE_TAIL *)
let test () : bool =
  let d = create () in
  insert_tail 1 d;
  remove_tail d = 1 && is_empty d
;; run_test "remove_tail singleton" 

let test () : bool =
  let d = create () in
  remove_head d = 1 && is_empty d
;; run_failing_test "remove_tail empty" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 2 d;
  insert_head 3 d;
  insert_head 4 d;
  remove_tail d = 1 && to_list d = [4; 3; 2]
;; run_test "remove_tail multiple" test

let test () : bool =
  let d = create () in
  let x = 1 in
  insert_head x d;
  insert_head 1 d;
  insert_head x d;
  remove_tail d = x && to_list d = [1; x]
;; run_test "remove_tail duplicates" test

let test () : bool =
  let d = create () in
  insert_tail 1 d;
  remove_tail d = 1 && is_empty d
;; run_test "remove_tail singleton"


(* DELETE_LAST *)
let test () : bool =
  let d = create () in
  delete_last 1 d;
  to_list d = []
;; run_test "delete_last empty"

let test () : bool =
  let d = create () in
  insert_head 1 d;
  delete_last 1 d;
  to_list d = []
;; run_test "delete_last singleton"

let test () : bool =
  let d = create () in
  let x = 1 in
  insert_head x d;
  delete_last 1 d;
  to_list d = []
;; run_test "delete_last structural equality"

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 2 d;
  delete_last 1 d;
  to_list d = [2]
;; run_test "delete_last one instance"

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 1 d;
  insert_head 1 d;
  insert_head 2 d;
  insert_head 1 d;
  delete_last 1 d;
  to_list d = [1; 2; 1; 1]
;; run_test "delete_last multiple instances"

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 1 d;
  insert_head 1 d;
  insert_head 2 d;
  insert_head 1 d;
  delete_last 3 d;
  to_list d = [1; 2; 1; 1; 1]
;; run_test "delete_last multiple no instances"

(* DELETE_FIRST *)

let test () : bool =
  let d = create () in
  insert_tail 1 d;
  remove_tail d = 1
;; run_test "remove_tail singleton" 

let test () : bool =
  let d = create () in
  remove_head d = 1 && is_empty d
;; run_failing_test "remove_tail empty" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 2 d;
  remove_tail d = 1 && to_list d = [2]
;; run_test "remove_tail multiple" test

let test () : bool =
  let d = create () in
  let x = 1 in
  insert_head x d;
  insert_head 1 d;
  insert_head x d;
  remove_tail d = x && to_list d = [1; x]
;; run_test "remove_tail duplicates" test

let test () : bool =
  let d = create () in
  insert_tail 1 d;
  insert_tail 2 d;
  remove_tail d = 2 && to_list d = [1]
;; run_test "remove_tail inserted with tail" test


(* DELETE_FIRST *)
let test () : bool =
  let d = create () in
  delete_first 1 d;
  to_list d = []
;; run_test "delete_first empty" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  delete_first 1 d;
  to_list d = []
;; run_test "delete_first singleton" test

let test () : bool =
  let d = create () in
  let x = 1 in
  insert_head x d;
  delete_first 1 d;
  to_list d = []
;; run_test "delete_first structural equality" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 2 d;
  delete_first 1 d;
  to_list d = [2]
;; run_test "delete_first one instance" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 1 d;
  insert_head 1 d;
  insert_head 2 d;
  insert_head 1 d;
  delete_first 1 d;
  to_list d = [2; 1; 1; 1]
;; run_test "delete_first multiple instances" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 1 d;
  insert_head 1 d;
  insert_head 2 d;
  insert_head 1 d;
  delete_first 3 d;
  to_list d = [1; 2; 1; 1; 1]
;; run_test "delete_first multiple no instances" test

(* DELETE_LAST *)
let test () : bool =
  let d = create () in
  delete_last 1 d;
  to_list d = []
;; run_test "delete_last empty" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  delete_last 1 d;
  to_list d = []
;; run_test "delete_last singleton" test

let test () : bool =
  let d = create () in
  let x = 1 in
  insert_head x d;  
  delete_last  1 d;
  to_list d = []
;; run_test "delete_last structural equality" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 2 d;
  delete_last 1 d;
  to_list d = [2]
;; run_test "delete_last one instance" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 1 d;
  insert_head 1 d;
  insert_head 2 d;
  insert_head 1 d;
  delete_last 1 d;
  to_list d = [1; 2; 1; 1]
;; run_test "delete_last multiple instances" test

let test () : bool =
  let d = create () in
  insert_head 1 d;
  insert_head 1 d;
  insert_head 1 d;
  insert_head 2 d;
  insert_head 1 d;
  delete_last 3 d;
  to_list d = [1; 2; 1; 1; 1]
;; run_test "delete_last multiple no instances" test


(* REVERSE *)

let test () : bool = 
  let d = create () in 
  reverse d;
  to_list d = []
;; run_test "reverse empty" test

let test () : bool = 
  let d = create () in 
  insert_head 1 d;
  reverse d;
  to_list d = [1]
;; run_test "reverse singleton" test

let test () : bool = 
  let d = create () in 
  insert_head 1 d;
  insert_head 2 d;
  reverse d;
  to_list d = [1; 2]
;; run_test "reverse two" test

let test () : bool = 
  let d = create () in 
  insert_head 1 d;
  insert_head 2 d;
  insert_head 3 d;
  insert_head 4 d;
  reverse d;
  to_list d = [1; 2; 3; 4]
;; run_test "reverse many" test

let test () : bool = 
  let d = create () in 
  let x = 1 in
  insert_head 1 d;
  insert_head x d;
  reverse d;
  to_list d = [1; x]
;; run_test "reverse structural equality" test


(* ---------- Write your own test cases above. ---------- *)
