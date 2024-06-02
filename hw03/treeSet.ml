;; open Assert

(******************************************************************************)
(* PROBLEM 7: BINARY SEARCH TREE SET                                          *)
(******************************************************************************)

module BSTSet : SetInterface.SET = struct

  (* We open the `Tree` module to make the type `'a tree` and the helper
     functions defined earlier available for use in this file. *)

  ;; open Tree

  (* This time, we'll use a binary tree as our set (but again, this fact is
     not exposed to anyone using our module). The binary search tree invarints
     are a good match for the behavior of a set, because BSTs do not have
     duplicate elements. *)

  type 'a set = 'a tree

  let empty : 'a set = Empty

  let is_empty (s: 'a set) : bool =
    s = empty

  let rec list_of_set (s: 'a set) : 'a list =
    begin match s with 
    | Empty -> []
    | Node(lt, n, rt) -> (list_of_set lt) @ n :: (list_of_set rt)
    end

  let add (x: 'a) (s: 'a set) : 'a set =
    insert x s

  let remove (x: 'a) (s: 'a set) : 'a set =
    delete x s

  (* We've done the next one for you, because set membership for BSTs is
     equivalent to the `lookup` function. Reusing code is good! *)

  let member (x: 'a) (s: 'a set) : bool =
    lookup x s

  (* Note that there's no `size` function in tree.ml -- you'll have to
     implement this yourself rather than reusing code. *)

  let rec size (s: 'a set) : int =
    begin match s with 
    | Empty -> 0
    | Node(lt, _, rt) -> 1 + (size lt) + (size rt)
    end 

  (* Note that two binary search trees can be equal as sets without having the
     exact same structure. The OCaml (=) operator will only return true if the
     trees look exactly the same, and _not_ if they contain the same elements
     but don't have the same exact structure. The test case below specifies
     the behavior of `equals`. *)
  
  let equals_helper (l: 'a list) (s: 'a set) : bool = 
    HigherOrder.fold (fun x acc -> member x s && acc) true l

  let equals (s: 'a set) (t: 'a set) : bool =
    (equals_helper (list_of_set s) t) && (equals_helper (list_of_set t) s)

  let test () : bool =
    let s = Node (Empty, 1, Node (Empty, 2, Empty)) in
    let t = Node (Node (Empty, 1, Empty), 2, Empty) in
    s <> t          (* not structurally equal *)
    && equals s t   (* but have same elements *)
  ;; run_test "equals: different structured trees" test


  let set_of_list (l: 'a list) : 'a set =
    HigherOrder.fold (fun x acc -> add x acc) empty l


  (* Don't modify this line: *)
  let debug_name: string = "BSTSet"
end
