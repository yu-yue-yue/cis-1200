(** The "Graphics Context" component of the GUI library. *)

(** A graphics context represents a region of the window to which
   widgets will be drawn.

   The drawing primitives in this module are all relative to the
   graphics context. This means that when a widget needs to draw on
   the screen, it need not know its absolute position. The graphics
   context is responsible for translating the relative positions
   passed into the drawing routines into absolute positions on the
   screen.

   The graphics context also includes other information for basic
   drawing (such as the current pen color.)

   Note that this module defines a persistent (immutable) data
   structure. The operations here use a given graphics context to
   create a new one with the specified characteristics. They do not
   modify their arguments. *)

(* (We use the module name Graphics in this module to refer to a "shim
   module" that connects to either the native or the javascript
   graphics.  You do not need to understand the details of how this
   works.) *)
 
module Graphics = G

(****************)
(**   Colors    *)
(****************)

(** A type for colors *)
type color = {r:int; g:int; b:int}

let black   : color = {r=0;  g=0;  b=0}
let white   : color = {r=255;g=255;b=255}
let red     : color = {r=255;g=0;  b=0}
let green   : color = {r=0;  g=255;b=0}
let blue    : color = {r=0;  g=0;  b=255}
let yellow  : color = {r=255;g=255;b=0}
let cyan    : color = {r=0;  g=255;b=255}
let magenta : color = {r=255;g=0;  b=255}

let thick : int = 10

let thin : int = 1


(*******************************)
(**    Basic Gctx operations   *)
(*******************************)

(** The main type of graphics contexts. Note that none of the
   components are mutable. (TODO: You will need to modify this type
   definition when you get to Task 5.) *)
type gctx = {
  x: int;         (** offset from (0,0) in local coordinates *)
  y: int;
  color: color; (** the current pen color *)
  thick : bool  (** is the current pen thick*)
  }    

(* Internal helper to set the text size *)
let set_text_size (text_size: int) (font: string) : unit =
  if Graphics.js_mode then Graphics.set_font font;
  Graphics.set_text_size text_size

let clear_graph () =
  Graphics.clear_graph ();
  set_text_size 20 @@
    if Graphics.js_mode then "Source Sans Pro, Roboto, sans-serif" else ""

(* Has the graphics window been opened already? *)
let graphics_opened = {contents = false}

(** Open the graphics window (but only do it once) *)
let open_graphics () =
  if not graphics_opened.contents then
    begin
      graphics_opened.contents <- true;
      Graphics.open_graphics' ();
      clear_graph ()
    end

(** The top-level graphics context *)
(* TODO: you will need to modify this variable when you get to Task 5. *)
let top_level : gctx =
  { x = 0;
    y = 0;
    color = black;
    thick = false;
    }

(** Shift the gctx by (dx,dy).  Used by widgets to translate (shift
   the origin of) a graphics context to obtain an appropriate graphics
   context for their children. *)
let translate (g: gctx) ((dx, dy): int * int) : gctx =
  { g with x = g.x + dx; y = g.y + dy }

(** Produce a new Gctx.t with a different pen color *)
let with_color (g: gctx) (c: color) : gctx =
  { g with color = c }

(** Produce a new Gctx.t with a different line thickness *)
let with_thickness (g: gctx) (b: bool) : gctx =
  { g with thick = b }


(** Set the OCaml graphics library's internal state according to the
   Gctx settings. This sets the pen's color and thickness. *)
(* TODO: You will need to modify this definition for Task 5. *)
let set_graphics_state (gc: gctx) : unit =
  let c = gc.color in
  let t = gc.thick in
  Graphics.set_color (Graphics.rgb c.r c.g c.b);
  if t then Graphics.set_line_width thick else Graphics.set_line_width thin 

(************************************)
(*    Coordinate Transformations    *)
(************************************)

(* The default width and height of the graphics window that OCaml opens.   *)

let graphics_size_x () =
  if graphics_opened.contents then Graphics.size_x () else 640
let graphics_size_y () =
  if graphics_opened.contents then Graphics.size_y () else 480

(* A main purpose of the graphics context is to provide mapping between
   widget-local coordinates and the ocaml coordinates of the graphics
   library. Part of that translation comes from the offset stored in the
   graphics context itself. The translation needs to know where the widget
   is on the screen. The other part of the translation is the y axis flip.
   The OCaml library puts (0,0) at the bottom left corner of the window.
   We'd like our GUI library to put (0,0) at the top left corner and
   increase the y-coordinate as we go *down* the screen. *)

(** A widget-relative position *)
type position = int * int

(* The next two functions translate between the coordinate system we
   are using for the widget library and the native coordinates of the
   Graphics module.  Remember to ALWAYS call these functions before
   passing widget-local points to the Graphics module or
   vice-versa. *)

(** Convert widget-local coordinates (x,y) to OCaml graphics
    coordinates, relative to the graphics context. *)
let ocaml_coords (g: gctx) ((x, y): position) : (int * int) =
  (g.x + x, graphics_size_y () - 1 - (g.y + y))

(** Convert OCaml Graphics coordinates (x,y) to widget-local graphics
    coordinates, relative to the graphics context *)
let local_coords (g: gctx) ((x, y): int * int) : position =
  (x - g.x, (graphics_size_y () - 1 - y) - g.y)


(*****************)
(**    Drawing   *)
(*****************)

(** A width and height, paired together. *)
type dimension = int * int

(* Each of these functions takes inputs in widget-local coordinates,
   converts them to OCaml coordinates, and then draws the appropriate
   shape.                                                                  *)

(** Draw a line between the two specified positions *)
let draw_line (g: gctx) (p1: position) (p2: position) : unit =
  set_graphics_state g;
  let (x1, y1) = ocaml_coords g p1 in
  let (x2, y2) = ocaml_coords g p2 in
  Graphics.moveto x1 y1;
  Graphics.lineto x2 y2

(** Display text at the given position *)
let draw_string (g: gctx) (p: position) (s: string) : unit =
  set_graphics_state g;
  let (_, height) = Graphics.text_size s in
  let (x, y) = ocaml_coords g p in
  (* Web browser font rendering bounding box adjusment *)
  let fudge = if Graphics.js_mode then 3 else 0 in
  (* subtract: working with Ocaml coordinates *)
  Graphics.moveto x (y - height + fudge);
  Graphics.draw_string s

(** Display a rectangle with upper-left corner at position
    with the specified dimension. Remember that Graphics.draw_rect
    draws from the bottom-left by default, so you'll have to account
    for this. *)
(* TODO: you will need to make this function actually draw a
   rectangle for Task 0.                                     *)
let draw_rect (g: gctx) (p1: position) ((w, h): dimension) : unit =
  set_graphics_state g;
  let (x, y) = ocaml_coords g p1 in 
  Graphics.draw_rect x (y - h) w h 

(** Display a filled rectangle with upper-left corner at positions
    with the specified dimension. *)
let fill_rect (g: gctx) (p1: position) ((w, h): dimension) : unit =
  set_graphics_state g;
  let (x, y) = ocaml_coords g p1 in
  Graphics.fill_rect x (y - h) w h

(** Draw an ellipse at the given position with the given radii *)
(* TODO: you will need to make this function actually draw an
   ellipse for Task 0.  *)
let draw_ellipse (g: gctx) (p: position) (rx: int) (ry: int) : unit =
  set_graphics_state g;
  let (x, y) = ocaml_coords g p in
  Graphics.draw_ellipse x y rx ry 

(** Draw a point **)
let draw_point (g: gctx) (p: position) : unit =
  set_graphics_state g;
  let (x, y)  = ocaml_coords g p in 
  Graphics.plot x y  

(** Draw a list of points **)
let draw_points (g: gctx) (p: position list) : unit = 
  List.iter (draw_point g) p  

(** Calculates the size of a text when rendered. *)
let text_size (text: string) : dimension =
  
(* This function calculates the size of the text string.  If the
    graphics window is opened, then it uses the "real" text size.
    Otherwise, it assumes a font size of 10x15 pixels.
  *)
  if graphics_opened.contents then
    let (w,h) = Graphics.text_size text in
    (w+1, h)  (* Web browser font widths seem to be smaller than desirable *)
  else (10 * String.length text, 15)

(* TODO: You will need to add several "wrapped" versions of ocaml graphics *)
(* functions here for Tasks 3, 5 and 6 *)


(************************)
(**     Handling   *)
(************************)

(* This part of the module adapts OCaml's native event handling to
   something that more closely resembles that found in Java. *)

(** Types of events that could occur *)
type event_type =
  | KeyPress of char    (* Key pressed on the keyboard.      *)
  | MouseDown           (* Mouse button pressed.             *)
  | MouseUp             (* Mouse button released.            *)
  | MouseMove           (* Mouse moved with the button up.   *)
  | MouseDrag           (* Mouse moved with the button down. *)

let string_of_event_type (et : event_type) : string =
  begin match et with
    | KeyPress k -> "KeyPress at " ^ (String.make 1 k)
    | MouseDrag  -> "MouseDrag"
    | MouseMove  -> "MouseMove"
    | MouseUp    -> "MouseUp"
    | MouseDown  -> "MouseDown"
  end

(** An event records its type and the widget-local position of
    the mouse when the event occurred. *)
type event = event_type * position

(** Accessor for the type of an event. *)
let event_type (e: event) : event_type =
  fst e

(** Accessor for the OCaml Graphics coordinates of an event. *)
let event_pos (e: event) (g : gctx) : position =
  local_coords g (snd e)

(** Convert an event to a string *)
let string_of_event ((ty, (x, y)): event) : string =
  (string_of_event_type ty) ^ " at "
     ^ (string_of_int x) ^ ","
     ^ (string_of_int y)

(** Make an event by hand for testing. *)
let make_test_event (et : event_type) ((x, y) : position) =
  (et, (x, graphics_size_y () - y))
