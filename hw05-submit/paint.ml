 (** The main paint application *)

;; open Gctx
;; open Widget

(******************************************)
(**    SHAPES, MODES, and PROGRAM STATE   *)
(******************************************)

(** A location in the paint_canvas widget *)
type point = position  (* from Gctx *)

(** The shapes that are visible in the paint canvas -- these make up the
    picture that the user has drawn, as well as any other "visible" elements
    that must show up in the canvas area (e.g. a "selection rectangle"). At
    the start of the homework, the only available shape is a line.  
    The shapes available are Line, Points, and Ellipse. *)
(* TODO: You will modify this definition in Tasks 3, 4, 5 and maybe 6. *)
type shape = 
  | Line of {color: color; thick: bool; p1: point; p2: point}
  | Points of {color: color; thick: bool; points: point list}
  | Ellipse of {color: color; thick: bool; p1: point; p2: point}

(** These are the possible interaction modes that the paint program might be
    in. Some interactions require two modes. For example, the GUI might
    recognize the first mouse click as starting a line and a second mouse
    click as finishing the line.

    To start out, there are only two modes:

      - LineStartMode means the paint program is waiting for the user to make
        the first click to start a line.

      - LineEndMode means that the paint program is waiting for the user to 
        release the mouse. The point associated with this mode stores the 
        location of the user's first mouse click. It also draws a line in the 
        preview while the user is dragging. 

      - PointMode means that the paint program draws a point in the mouse's 
        location so long as the user has clicked and dragged. When the user's 
        mouse is up, the PointMode draws nothing.

      - EllipseStartMode means the paint program is waiting for the user to 
        make the first click and start an ellipse.
      
      - EllipseEndMode means the paint program is waiting for the user to 
        release the mouse. The point associated with this stores the location 
        of the user's first mouse click. This is one of the corners of the 
        ellipse. The location of release is the opposite corner. It also draws
        an ellipse in the preview while the user is dragging. *)
           
(* TODO: You will need to modify this type in Tasks 3 and 4, and maybe 6. *)
type mode = 
  | LineStartMode
  | LineEndMode of point
  | PointMode
  | EllipseStartMode
  | EllipseEndMode of point

(** The state of the paint program. *)
type state = {
  (** The sequence of all shapes drawn by the user, in order from
      least recent (the head) to most recent (the tail). *)
  shapes : shape Deque.deque;

  (** The input mode the Paint program is in. *)
  mutable mode : mode;

  (** The currently selected pen color. *)
  mutable color : color;

  (* TODO: You will need to add new state for Tasks 2, 5, and *)
  (* possibly 6 *) 
  
  (** If we are showing the preview *)
  mutable preview : shape option;

  (** The currently selected line thickness. *)
  mutable thick : bool; 
 
}

(** Initial values of the program state. *)
let paint : state = {
  shapes = Deque.create ();
  mode = LineStartMode;
  color = black;
  (* TODO: You will need to add new state for Tasks 2, 5, and maybe 6 *)
  preview = None;
  thick = false;
}



(** This function creates a graphics context with the appropriate
    pen color. *)
(* TODO: Your will need to modify this function in Task 5 *)
let with_params (g: gctx) (c: color) (t: bool) : gctx =
  let g = with_thickness (with_color g c) t in
  g


(*********************************)
(**    MAIN CANVAS REPAINTING    *)
(*********************************)

(** The paint_canvas repaint function.

    This function iterates through all the drawn shapes (in order of least
    recent to most recent so that they are layered on top of one another
    correctly) and uses the Gctx.draw_xyz functions to display them on the
    canvas.  *)

(* TODO: You will need to modify this repaint function in Tasks 2, 3,
   4, and possibly 5 or 6. For example, if the user is performing some
   operation that provides "preview" (see Task 2) the repaint function
   must also show the preview. *)
let repaint (g: gctx) : unit =
  let draw_shape (s: shape) : unit =
    begin match s with
      | Line l -> draw_line (with_params g l.color l.thick) l.p1 l.p2
      | Points ps -> draw_points (with_params g ps.color ps.thick) (ps.points)
      | Ellipse e -> 
        let center = ((fst e.p1 + fst e.p2)/2, (snd e.p1 + snd e.p2)/2) in 
        let rx = if 
          (fst e.p1 - fst center) < 0 then -1*(fst e.p1 - fst center) else 
          (fst e.p1 - fst center)
        in 
        let ry = if 
          (snd e.p1 - snd center) < 0 then -1*(snd e.p1 - snd center) else 
          (snd e.p1 - snd center) 
        in 
        draw_ellipse (with_params g e.color e.thick) center rx ry
    end in
  let draw_preview (so: shape option): unit = 
    begin match so with 
    | None -> ()
    | Some s -> draw_shape s 
    end in
  Deque.iterate draw_shape paint.shapes; 
  draw_preview paint.preview

(** Create the actual paint_canvas widget and its associated
    notifier_controller . *)
let ((paint_canvas : widget), (paint_canvas_controller : notifier_controller)) =
  canvas (600, 350) repaint


(************************************)
(**  PAINT CANVAS EVENT HANDLER     *)
(************************************)

(** The paint_action function processes all events that occur
    in the canvas region. *)
(* TODO: Tasks 2, 3, 4, 5, and 6 involve changes to paint_action. *)
let paint_action (gc:gctx) (event:event) : unit =
  let p  = event_pos event gc in  (* mouse position *)
  begin match (event_type event) with
    | MouseDown ->
       (* This case occurs when the mouse has been clicked in the
          canvas, but before the button has been released. How we
          process the event depends on the current mode of the paint
          canvas.  *)
       (* The paint_canvas was waiting for the first click of a line,
        so change it to LineEndMode, recording the starting point of
        the line. *)
      begin match paint.mode with 
      | LineStartMode -> paint.mode <- LineEndMode p
      | LineEndMode _-> ()
      | PointMode -> 
        Deque.insert_tail 
        (Points {color = paint.color; thick = paint.thick; points = [p]}) 
        paint.shapes
      | EllipseStartMode -> paint.mode <- EllipseEndMode p
      | EllipseEndMode _ -> ()
      end


    | MouseDrag ->
      (* In this case, the mouse has been clicked, and it's being dragged
         with the button down. Initially there is nothing to do, but you'll
         need to update this part for Task 2, 3, 4 and maybe 6. *)
      begin match paint.mode with 
      | PointMode -> 
        let points_list =
        begin match paint.preview with
        | Some (Points ps) -> ps.points
        | _ -> []
        end in
        paint.preview <- 
        Some (Points {color = paint.color; thick = paint.thick; 
        points = p::points_list  })
      | LineStartMode -> ()
      | LineEndMode p1 -> 
        paint.preview <- Some(Line{color = paint.color; thick = paint.thick; 
        p1 = p1; p2 = p})
      | EllipseStartMode -> ()
      | EllipseEndMode p1 -> 
        paint.preview <- Some(Ellipse{color = paint.color; thick = paint.thick; 
        p1 = p1; p2 = p})
      end  
    | MouseUp ->
      (* In this case there was a mouse button release event. TODO: Tasks 2,
         3, 4, and possibly 6 need to do something different here. *)
      begin match paint.mode with 
      | LineStartMode -> ()
      | LineEndMode p1 -> 
        Deque.insert_tail 
        (Line {color = paint.color; thick = paint.thick; 
        p1 = p1; p2 = p}) paint.shapes; 
        paint.mode <- LineStartMode ; 
        paint.preview <- None
      | PointMode -> 
        let points_list =
          begin match paint.preview with
          | Some (Points ps) -> ps.points
          | _ -> []
          end in
        Deque.insert_tail 
        (Points {color = paint.color; thick = paint.thick; 
        points = points_list}) paint.shapes;
           paint.preview <- None
      | EllipseStartMode -> ()
      | EllipseEndMode p1 -> 
        Deque.insert_tail 
        (Ellipse {color = paint.color; thick = paint.thick; 
        p1 = p1; p2 = p}) paint.shapes; 
        paint.mode <- EllipseStartMode ; 
        paint.preview <- None
      end 
    
    | _ -> ()
    (* This catches the MouseMove event (where the user moved the mouse over
       the canvas without pushing any buttons) and the KeyPress event (where
       the user typed a key when the mouse was over the canvas). *)
  end

(** Add the paint_action function as a listener to the paint_canvas *)
;; paint_canvas_controller.add_event_listener paint_action


(**************************************)
(** TOOLBARS AND PAINT PROGRAM LAYOUT *)
(**************************************)

(** This part of the program creates the other widgets for the paint
    program -- the buttons, color selectors, etc., and lays them out
    in the top - level window. *)
(* TODO: Tasks 1, 4, 5, and 6 involve adding new buttons or changing
   the layout of the Paint GUI. Initially the layout is ugly because
   we use only the hpair widget demonstrated in Lecture. Task 1 is to
   make improvements to make the layout more appealing. You may choose
   to arrange the buttons and other GUI elements of the paint program
   however you like (so long as it is easily apparent how to use the
   interface).  The sample screenshot of our solution shows one
   possible design.  Also, feel free to improve the visual components
   of the GUI; for example, our solution puts borders around the
   buttons and uses a custom "color button" that changes its
   appearance based on whether or not the color is currently
   selected. *)

(** Create the Undo button *)
let (w_undo, lc_undo, nc_undo) = button "Undo"

(** Create the Lines button *)
let (w_lines, lc_lines, nc_lines) = button "Lines"

(** Create the Points button *)
let (w_points, lc_points, nc_points) = button "Points" 

(** Create the Ellipses button *)
let (w_ellipses, lc_ellipses, nc_ellipses) = button "Ellipses"

(** Create the Line Thickness button *)
let (w_thickness, vc_thickness) = checkbox false "Thick Lines"

(** This function runs when the Undo button is clicked.
    It simply removes the last shape from the shapes deque. *)
(* TODO: You need to modify this in Task 3 and 4, and potentially 2
   (depending on your implementation). *)

let undo () : unit =
  if Deque.is_empty paint.shapes then () else
    ignore (Deque.remove_tail paint.shapes)

;; nc_undo.add_event_listener (mouseclick_listener undo)

(** Changes the mode to LineStartMode when the line button is clicked *)
let lines () : unit =
  paint.mode <- LineStartMode

;; nc_lines.add_event_listener (mouseclick_listener lines)

(** Changes the mode to PointMode when the point button is clicked *)
let points () : unit =
  paint.mode <- PointMode  

;; nc_points.add_event_listener (mouseclick_listener points) 

(** Changes the mode to EllipseStartMode when the ellipse button is clicked *)
let ellipses () : unit =
  paint.mode <- EllipseStartMode  

;; nc_ellipses.add_event_listener (mouseclick_listener ellipses) 


(** Changes the thickness, thick when is checked, thin when not clicked *)
let thickness (b: bool) : unit = 
  paint.thick <- b
;; vc_thickness.add_change_listener thickness

(** A spacer widget *)  
let spacer : widget = space (10,10) 


(** The mode toolbar, initially containing just the Undo button.
    TODO: you will need to modify this widget to add more buttons
    to the toolbar in Task 1, Tasks 5, and possibly 6. 
    Contains undo, points, line, ellipse and thickness*)
let mode_toolbar : widget = 
  hlist [border w_undo; spacer; border w_lines; spacer; border w_points;
  spacer; border w_ellipses; spacer; border w_thickness]

(* The color selection toolbar. *)
(* This toolbar contains an indicator for the currently selected color
   and some buttons for changing it. Both the indicator and the buttons
   are small square widgets built from this higher-order function. *)
(** Create a widget that displays itself as colored square with the given
    width and color specified by the [get_color] function. *)
let colored_square (width:int) (get_color:unit -> color)
  : widget * notifier_controller =
  let repaint_square (gc:gctx) =
    let c = get_color () in
    fill_rect (with_color gc c) (0, 0) (width-1, width-1) in
  canvas (width,width) repaint_square

(** Red color slider. Changes the color's red value to be proportional to the 
  slider; this is overriden by the buttons, though. The sliders do not change 
  if a color button is clicked. *)
let red_slider (size: int): widget = 
  let (rw, rc) = slider paint.color.r "R" size red in 
  let change_r (red: int) : unit = paint.color <- 
  {r = red*255/size; 
  g = paint.color.g; 
  b = paint.color.b} in
  rc.add_change_listener change_r; 
  rw

(** Green color slider. Changes the color's green value to be proportional to 
  the slider; this is overriden by the buttons, though. The sliders do not 
  change if a color button is clicked.*)
let green_slider (size: int): widget = 
  let (gw, gc) = slider paint.color.g "G" size green in 
  let change_g (green: int) : unit = paint.color <- 
  {r = paint.color.r; 
  g = green*255/size; 
  b = paint.color.b} in
  gc.add_change_listener change_g; 
  gw

(** Blue color slider. Changes the color's blue value to be proportional to the 
  slider; this is overriden by the buttons, though. The sliders do not change 
  if a color button is clicked.*)
let blue_slider (size: int): widget = 
  let (bw, bc) = slider paint.color.b "B" size blue in 
  let change_b (blue: int) : unit = paint.color <- 
  {r = paint.color.r; 
  g = paint.color.g; 
  b = blue*255/size} in
  bc.add_change_listener change_b; 
  bw

(** The color_indicator repaints itself with the currently selected
    color of the paint application. *)
let color_indicator : widget =
  let indicator,_ = colored_square 24 (fun () -> paint.color) in
  let lab, _ = label "Current Color" in
  border (hpair lab indicator)

(** color_buttons repaint themselves with whatever color they were created
    with. They are also installed with a mouseclick listener
    that changes the selected color of the paint app to their color. *)
let color_button (c: color) : widget =
  let w,nc = colored_square 10 (fun () -> c) in
  nc.add_event_listener (mouseclick_listener (fun () ->
      paint.color <- c ));
  w

(** The color selection toolbar. Contains the color indicator and
    buttons for several different colors. *)
(* TODO: Task 1 - This code contains a great deal of boilerplate.  You
     should come up with a better, more elegant, more concise solution... *)
   let color_toolbar : widget =
    let color_sliders (size: int): widget = 
      vlist [red_slider size; green_slider size; blue_slider size;] in

    let rec color_list_creator (clist: color list) (cwlist: widget list): 
    widget list = 
      begin match clist with 
      |[] -> cwlist
      |c::tail -> color_list_creator (tail) ((color_button c)::spacer::cwlist)
      end
    in 
    hlist (color_sliders 50:: spacer :: color_indicator::spacer::
    (color_list_creator [magenta; cyan; yellow; blue; green; red; white; black]
     []))

(** The top-level paint program widget: a combination of the
    mode_toolbar, the color_toolbar and the paint_canvas widgets. *)
(* TODO: Task 1 (and others) involve modifing this layout to add new
   buttons and make the layout more aesthetically appealing. *)
let paint_widget =
   vlist [paint_canvas; spacer; mode_toolbar; spacer; color_toolbar]


(**************************************)
(**      Start the application        *)
(**************************************)

(** Run the event loop to process user events. *)
;; Eventloop.run paint_widget
