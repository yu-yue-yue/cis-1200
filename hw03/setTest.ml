(******************************************************************************)
(* PROBLEM 5: WRITING TEST CASES                                              *)
(******************************************************************************)

(* The module `SetTest` defined below is a reuseable component that we'll use
   to test other modules that conform to the `SET` interface. When `SetTest`
   is instantiated with a particular set implementation, it will run all of
   its test cases against the set type defined in that implementation.  This
   means that the _same_ tests can be used for both the OrderedListSet and
   BSTSet implementations -- this makes sense because all implementations of
   `SET` should behave the same!

   Read through the module, then write your test cases in the space provided
   below. Make sure NOT to test for structural equality with sets.  Instead,
   use the equals function specified in the interface.  Your TAs will be
   grading the completeness of your tests. *)

module SetTest (SetImpl: SetInterface.SET) = struct
  ;; open SetImpl

  (* We first redefine the `run_test` and `run_failing_test` functions so that
     they prepend the name of the set we're testing to the test description. *)

  let run_test desc = Assert.run_test (debug_name ^ ": " ^ desc)
  let run_failing_test desc = Assert.run_failing_test (debug_name ^ ": " ^ desc)

  ;; print_endline ("\n--- Running tests for " ^ debug_name ^ " ---")

  (* Here are a couple of test cases to help get you started... *)

  let test () : bool =
    is_empty empty
  ;; run_test "is_empty: call on empty returns true" test

  (* Note that some tests in this test module (such as the one below) may not
     pass until all the functions they depend on are implemented. For
     instance, the test below will fail for sets whose `set_of_list` function
     is not yet implemented (even if `is_empty` is correct).  This is fine:
     the goal here is just to record all the tests that we expect will pass
     when we get around to implementing everything later. *)

   

  (* This is another case where the test won't pass since the "equals"
     function hasn't been implemented yet. We would like you to complete
     this test to confirm your understanding on "=" vs "equals". What should
     you use for this test to pass? *)
   
   let test() : bool = 
      (* Uncomment the two lines below *)
      let s1 = add 1 (add 2 empty) in 
      let s2 = set_of_list [2; 1] in 
      equals s1 s2
   ;; run_test "make two sets equal" test


(* Now, it's your turn! Make sure to comprehensively test all the other
   functions defined in the `SET` interface. It will probably be helpful to
   have the file `setInterface.ml` open as you work.  Your tests should stress
   the abstract properties of what it means to be a set, as well as the
   relationships among the operations provided by the SET interface.

   One thing to be careful of: your tests should not use `=` to compare sets:
   use the `equals` function instead.

   We strongly advise you to write tests for the functions in the order they
   appear in the interface. Write tests for all of the functions here before
   you start implementing. After the tests are written, you should be able to
   implement the functions one at a time in the same order and see your tests
   incrementally pass.

   Your TAs will be manually grading the completeness of your test cases. *)

  (* ---------- Write your own test cases below. ---------- *)

  let test () : bool =
    not (is_empty (add 3 empty))
  ;; run_test "is_empty: call on non-empty returns false" test
 
   let test () : bool =
    let s = empty in
    list_of_set s = []
  ;; run_test "list of set: empty set" test

   let test () : bool =
    let s = add 2 empty in
    list_of_set s = [2]
  ;; run_test "list of set/add: singleton" test

  let test () : bool =
    let s = add 3 (add 2 empty) in
    list_of_set s = [2;3]
  ;; run_test "list of set/add: multiple" test

  let test () : bool =
    let s = add 2 (add 3 (add 2 empty)) in
    list_of_set s = [2;3]
  ;; run_test "list of set/add: duplicates" test

  let test () : bool =
    let s = remove 3 empty in
    list_of_set s = []
  ;; run_test "remove: not in set" test 

   let test () : bool =
    let s = remove 2 (add 2 empty) in
    list_of_set s = []
  ;; run_test "list of set/remove: singleton" test

  let test () : bool =
    let s = remove 3 (add 3 (add 2 empty)) in
    list_of_set s = [2]
  ;; run_test "list of set/remove: multiple" test

  let test () : bool =
    let s = remove 2 (add 2 (add 3 (add 2 empty))) in
    list_of_set s = [3]
  ;; run_test "list of set/remove: duplicates" test

  let ex_set = add 1 (add 2 (add 3 empty))
 
  let test () : bool =
    member 2 ex_set
  ;; run_test "member: in set" test

  let test () : bool =
    not (member 5 ex_set)
  ;; run_test "member: not in set" test

  let test () : bool = 
    size ex_set = 3
  ;; run_test "size: multiple"

  let test () : bool = 
    size (add 2 (add 2 empty)) = 1
  ;; run_test "size: singleton"

  let test () : bool = 
    size empty = 0
  ;; run_test "size: empty"

  let test () : bool = 
    equals empty empty
  ;; run_test "equals: empty"

  let test () : bool = 
    not (equals (add 2 empty) empty)
  ;; run_test "equals: empty and non-empty false"

  let test () : bool = 
    not (equals (add 1 (add 2 empty)) (add 3 (add 2 empty)))
  ;; run_test "equals: overlap false"

  let test () : bool = 
    equals ex_set ex_set
  ;; run_test "equals: true"
  
  let test () : bool = 
    let ex_other = add 3 (add 1 (add 2 (add 3 empty))) in
    equals ex_set ex_other 
  ;; run_test "equals: duplicates true"

  let test () : bool = 
    equals (set_of_list []) empty 
  ;; run_test "set of list: empty"

  let test () : bool = 
    equals (set_of_list [1]) (add 1 empty) 
  ;; run_test "set of list: singleton"

  let test () : bool = 
    equals(set_of_list [3;2;1]) ex_set
  ;; run_test "set of list: descending order"

  let test () : bool = 
    equals(set_of_list [3;2;1;2;3;1;1]) ex_set
  ;; run_test "set of list: duplicates"
  

  (* ---------- Write your own test cases above. ---------- *)

end

(* The rest of the file instantiates the above tests so they are
   executed for both OrderedListSet and BSTSet.  Don't modify anything
   below this comment. *)

module TestOrderedListSet = SetTest(ListSet.OrderedListSet)
;; print_newline ()

module TestBSTSet = SetTest(TreeSet.BSTSet)
;; print_newline ()
