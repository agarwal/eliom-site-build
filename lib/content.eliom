[%%shared
open Lwt
open Eliom_content
open Printf
]

let column_12 x =
  let open Html.F in
  div ~a:[a_class ["row"]] [
    div ~a:[a_class ["small-12"; "columns"]]
      x
  ]

(******************************************************************************)
(** {2 Template} *)
(******************************************************************************)
let template ~title:title_str content =
  let open Html.F in
  let head =
    head
      (title @@ pcdata title_str)
      [
        meta () ~a:[a_charset "utf-8"];
        meta () ~a:[
          a_http_equiv "x-ua-compatible";
          a_content "ie=edge";
        ];
        meta () ~a:[
          a_name "viewport";
          a_content "width=device-width,initial-scale=1.0";
        ];

        css_link
          ~uri:(make_uri ~service:(Service.static_dir ())
                  ["css"; "app.css"])
          ()
        ;

        css_link
          ~uri:(make_uri ~service:(Service.static_dir ())
                  ["css"; "foundation-icons.css"])
          ()
        ;
      ]
  in
  let top_bar_left =
    div ~a:[a_class ["top-bar-left"]] [
      ul ~a:[a_class ["menu"]] [
        li [a ~service:Service.home [i ~a:[a_class ["fi-home"]] []] ()];
      ]
    ]
  in
  let top_bar_right =
    div ~a:[a_class ["top-bar-right"]] [
      ul ~a:[a_class ["menu"]] [
        li [a ~service:Service.users [pcdata "Users"] ()];
      ]
    ]
  in
  let top_bar =
    div ~a:[a_class ["top-bar"]] [top_bar_left; top_bar_right]
  in
  let footer =
    footer [
      div ~a:[a_class ["row"]] [
        div ~a:[a_class ["small-8"; "columns"]] [
          pcdata "License: ISC";
        ];
        div ~a:[a_class ["small-4"; "columns"; "text-right"]] [
          a ~service:Service.github [i ~a:[a_class ["fi-social-github"]] []] ()
        ]
      ]
    ]
  in
  let end_matter =
    [
      js_script ~uri:(make_uri ~service:Service.jquery ()) ();
      js_script ~uri:(Xml.uri_of_string "/js/app-deps.min.js") ();
      Raw.script (pcdata "$(document).foundation();");
    ]
  in
  html
    head
    (body @@ [top_bar]@content@[footer]@end_matter)

(******************************************************************************)
(** {2 Front Page} *)
(******************************************************************************)
let read_and_display_input =
  let open Eliom_content.Html.D in
  let input = input ~a:[a_input_type `Text] () in
  let onclick_handler = [%client (fun _ ->
    let v =
      Js.to_string
        (Html.To_dom.of_input ~%input)##.value
    in
    Dom_html.window##alert(Js.string ("Input value: " ^ v)))
  ]
  in
  let button =
    button
      ~a:[
        a_onclick onclick_handler;
        Unsafe.string_attrib "type" "submit";
        a_class ["button"];
      ]
      [pcdata "Read value"]
  in
  div [
    column_12 [h2 [pcdata "onclick handler"]];
    div ~a:[a_class ["row"]] [
      div ~a:[a_class ["small-4"; "columns"]] [input];
      div ~a:[a_class ["small-2"; "columns"]] [button];
      div ~a:[a_class ["small-6"; "columns"]] [];
    ]
  ]

let add_user_form (username_name, password_name) =
  let open Eliom_content.Html.D in
  [
    column_12 [h2 [pcdata "create new user"]];
    div ~a:[a_class ["row"]] [
      div ~a:[a_class ["small-6"; "columns"]] [
        div [
          pcdata "Username: ";
          Form.input ~input_type:`Text ~name:username_name Form.string;

          pcdata "Password: ";
          Form.input ~input_type:`Text ~name:password_name Form.string;

          Form.input ~input_type:`Submit ~value:"Add User" Form.string
            ~a:[a_class ["button"]; Unsafe.string_attrib "type" "submit"]
        ]
      ]
    ]
  ]

let front_page () () =
  let open Eliom_content.Html.F in
  return @@ template ~title:"Eliom Starter"
    [
      column_12 [h1 [pcdata "Demos"]];
      read_and_display_input;
      Eliom_content.Html.D.Form.post_form ~service:Service.add_user add_user_form ();
    ]

(******************************************************************************)
(** {2 Users Page} *)
(******************************************************************************)
let users () () =
  let open Eliom_content.Html.F in
  User.all_users () >|=
  List.map (fun (username,password) ->
    tr [td [pcdata username]; td [pcdata password]]
  ) >>= fun rows ->
  return @@ table
    ((tr [th [pcdata "Username"]; th [pcdata "Password"]])::rows)
  >|= fun users ->
  template ~title:"Users"
    [
      column_12 [h1 [pcdata "Users"]];
      div ~a:[a_class ["row"]] [
        div ~a:[a_class ["small-6"; "columns"]] [
          users
        ]
      ]
    ]
