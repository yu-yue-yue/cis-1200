(*****************************************************************************)
(* Problem 6: Linked Queues **************************************************)
(*****************************************************************************)

;; open Assert
;; open Imp

(* This problem extends the queue example that we covered in class
   with a few additional exercises. Note that there is some new code
   here, too, that you will also need to understand in preparation for
   the rest of the assignment.  
   
   We expect all solutions to be implemented tail recursively. Note
   that this won't require any extra work if your solution is
   is the intuitive or natural solution to the question! Odds are,
   your solution is already tail recursive.
   *)

(* Here are mutable queues, as defined in class. *)

module LinkedQueue : QueueInterface.QUEUE = struct

  type 'a qnode = { v: 'a;
                    mutable next: 'a qnode option }

  type 'a queue = { mutable head: 'a qnode option;
                    mutable tail: 'a qnode option }

  (* INVARIANT:
   - q.head and q.tail are either both None, or
   - q.head and q.tail both point to Some nodes, and
       - q.tail is reachable by following 'next' pointers
         from q.head
       - q.tail's next pointer is None

   Your job will be to preserve this invariant in all of the functions
   of the queue module (unless we specifically tell you not to).  That is,
   every function can assume that any queue it is passed as an argument
   already satisfies the invariant, and it must ensure that any queue it
   returns as a result also satisfies the invariant.

   Note that this invariant implies that there are no cycles in the
   queue, meaning that you will never encounter the same node twice if
   you traverse the queue via 'next' pointers starting from the head.
   Queues that do not satisfy this invariant could have cycles -- for
   example, the two queues below.  *)

  let cyclic_queue_1 () : int queue =
    let n = { v = 1; next = None } in
    n.next <- Some n;
    { head = Some n; tail = Some n }

  let cyclic_queue_12 () : int queue =
    let n2 = { v = 2; next = None } in
    let n1 = { v = 1; next = Some n2 } in
    n2.next <- Some n2;
    { head = Some n1; tail = Some n2 }

  (* To check that a given queue is valid (i.e. that it satisfies the
     invariant) we first write a function that walks down the list
     looking for the very last element. To avoid infinite looping (on
     queues that do not satisfy the invariant), this function must
     also keep track of which nodes have been traversed and fail (by
     returning None) if a cycle is detected.

     For acyclic queues, the function find_last_node below
     returns (Some n), where n is the tail of the queue found by
     traversing next pointers from qn until it finds the last
     node (i.e., a node whose 'next' pointer is None).  If it ever
     visits a node that has already been seen (indicating a cycle), it
     instead returns None. *)

  let rec find_last_node (qn: 'a qnode) : 'a qnode option =
    let rec loop (curr: 'a qnode) (seen: 'a qnode list) : 'a qnode option =
      begin match curr.next with
      | None -> Some curr
      | Some n ->
        let rec alias : 'a qnode list -> 'a qnode option =
          begin function
          | [] -> loop n (curr :: seen)
          | h :: t -> if n == h then None else alias t
          end in
        alias seen
      end
    in loop qn []

  (* The next function, `valid`, checks whether a given queue
     satisfies the queue implementation invariant described above.

     Each of the functions defined below checks the validity of its
     arguments as an aid to debugging.  In practice, doing such costly
     validity checking every time they are called would ruin the
     performance of the queue operations, so the checks would be
     removed once the code is debugged. *)

  let valid (q: 'a queue) : bool =
    begin match q.head, q.tail with
    | None, None -> true
    | Some qh, Some qt ->
       begin match find_last_node qh with
       | Some n -> qt == n (* the tail points to the last node *)
       | None -> false
       end
    | _, _ ->  false
    end


  (******  QUEUE functions from lecture ******)

  (* Create an empty queue *)
  let create () : 'a queue =
    { head = None;
      tail = None }

  (* Determine whether a queue is empty *)
  let is_empty (q: 'a queue) : bool =
    if not (valid q) then failwith "is_empty: given invalid queue";
    q.head = None

  (* Add an element to the tail of a queue *)
  let enq (elt: 'a) (q: 'a queue) : unit =
    if not (valid q) then failwith "enq: given invalid queue";
    let newnode = Some { v = elt; next = None } in
    begin match q.tail with
    | None ->
       (* Note that the invariant tells us that q.head is also None *)
       q.head <- newnode;
       q.tail <- newnode
    | Some n ->
       n.next <- newnode;
       q.tail <- newnode
    end

  (* Remove an element from the head of the queue *)
  let deq (q: 'a queue) : 'a =
    if not (valid q) then failwith "deq: given invalid queue";
    begin match q.head with
    | None ->
       failwith "deq called on empty queue"
    | Some n ->
       q.head <- n.next;
       begin match n.next with
       | None -> q.tail <- None; n.v
       | Some _ -> n.v
       end
    end

  (* Retrieve the list of values stored in the queue, ordered from
     head to tail. *)
  let to_list (q: 'a queue) : 'a list =
    if not (valid q) then failwith "to_list: given invalid queue";
    let rec loop (no: 'a qnode option) (l: 'a list) : 'a list =
      begin match no with
      | None -> List.rev l
      | Some n -> loop n.next (n.v :: l)
      end
    in loop q.head []

  (* Get the length of a queue *)
  let length (q: 'a queue) : int =
    if not (valid q) then failwith "length: given invalid queue";
    let rec loop (no: 'a qnode option) (len: int) : int =
      begin match no with
      | None -> len
      | Some n -> loop n.next (len + 1)
      end
    in loop q.head 0

  (* Print out the contents of a queue *)
  let rec print (q: 'a queue) (string_of_element: 'a -> string) : unit =
    if not (valid q) then failwith "print: given invalid queue";
    let rec loop (no: 'a qnode option) : unit =
      begin match no with
      | None -> ()
      | Some n -> print_endline (string_of_element n.v); loop n.next
      end
    in
    print_endline "--- queue contents ---";
    loop q.head;
    print_endline "--- end of queue -----"


  (**********************************************)
  (******  QUEUE problems ***********************)

  (* Now it's your turn...

     Implement a function that converts a list [v1; v2; ...; vn] into
     a queue with v1 is at the head and vn at the tail. You should not
     use any List library functions for this.

     HINT: You may want to consider using the `iter` function you wrote
     in `imp.ml`.
   *)


  let from_list (l: 'a list) : 'a queue =
   let q = create () in
   iter (fun x -> enq x q) l;
   q


  (* For the rest of this task, do NOT use to_list to convert any
     given queues into lists.  Rather, implement the required
     functions by directly manipulating the linked representation. *)

  (* Implement a function that checks whether a given element is
     in the queue. Test queue elements for equivalence using reference
     equality (==).  (We want to use reference equality here to ensure
     that the element "elt" refers to the same item on the heap as the
     element you are looking for, and isn't simply just a copy.)
      *)

  let contains (elt: 'a) (q: 'a queue) : bool =
    if not (valid q) then failwith "contains: given invalid queue";
    let rec contains_node (qn: 'a qnode option) : bool =
      begin match qn with 
      |None -> false 
      |Some n -> (n.v == elt) || (contains_node n.next)
      end in 
    contains_node q.head 

  (* Implement a function that truncates a queue after the first
     occurrence of a specified element. (i.e. it removes all elements
     from the queue that follow the first occurrence of the given
     element.) The function should mutate the queue "in place," --
     i.e., you should not construct a new queue, but instead should
     update the pointers within the given queue.

     Remember to use reference (==) equality! *)


  let truncate (elt: 'a) (q: 'a queue) : unit =
    if not (valid q) then failwith "truncate: given invalid queue";
    if not (contains elt q) then () 
    else let rec truncate_node (qn: 'a qnode option) : unit =
      begin match qn with 
      |None -> ()
      |Some n -> if (n.v == elt) then (n.next <- None; q.tail <- Some n)
      else truncate_node n.next 
      end in 
    truncate_node q.head

  


  (* Implement a function that deletes all nodes containing the value elt
     (compare using structural equality) from the queue q. This function
     should mutate the queue in place. In place means that you should not
     construct a new queue, but instead should update the pointers within
     the given queue.

     Remember here to use structural (=) equality!

     Advice: Work out examples on paper first.

     Hints:
     - You will need to both use and maintain the queue invariants

     - Think about these cases:
         . what if the queue is empty?
         . what if the only element of the queue is the value to
           be deleted?
         . what if the first or last element of the queue
           has the value to be deleted?

     - You may want to consider adding one or more helper functions
       that traverse the queue *)

  let rec delete_helper (elt: 'a) (q: 'a queue) : unit =
    let rec traverses_nodes (qn: 'a qnode option) : unit =
      begin match qn with 
      |None -> () 
      |Some n -> 
        begin match n.next with 
        |None -> ()
        |Some nextnode -> if (nextnode.v = elt  && nextnode.next = None) then 
        (n.next <- nextnode.next; q.tail <- Some n)
        else if (nextnode.v = elt) then 
        (n.next <- nextnode.next; traverses_nodes (Some n))
        else traverses_nodes n.next
        end 
    end in 
    begin match q.head with 
    | None -> () 
    | Some n -> if (n.v = elt && n.next = None) then 
      (q.head <- None; q.tail <- None)
      else if (n.v = elt) then (q.head <- n.next; delete_helper elt q)
      else traverses_nodes q.head 
    end 
   
    
  let delete (elt: 'a) (q: 'a queue) : unit =
    if not (valid q) then failwith "delete: given invalid queue"
    else delete_helper elt q

    


  (****************************************************************)
  (**** Queue Kudos problem  **************************************)
  (****************************************************************)

  (* The given valid queue function uses a helper function named
     "contains_alias," which keeps track of seen nodes. This can use
     up a lot of memory and can get VERY inefficient when the queue is
     large.

     Fortunately, we can do better.  Your mission in this kudos
     problem, should you choose to accept it, is to determine whether
     or not a given queue has a cycle WITHOUT using `contains_alias`
     or keeping a list (or other data structure) containing all the
     nodes that have already been seen. *)

  let has_cycle (q: 'a queue) : bool =
    failwith "has_cycle: unimplemented"

  (* DO NOT MODIFY *)
  let debug_name = "LinkedQueue"

end
