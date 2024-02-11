type token =
  | IDENTIFIER of string
  | KEYWORD of string
  | BOOLEAN of bool
  | ARITH_OP of string
  | INT_CONST of int
  | COMPARISON_OP of string
  | STRING_CONST of string
  | PAREN of char
  | COMMA ;;

let is_letter c = (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c = '\'';;

let is_digit c = c >= '0' && c <= '9' ;;

let is_bool c = (c = "true") || (c = "false") ;;

let starts_with_char_or_underscore s =
  match String.length s with
  | 0 -> false
  | _ -> 
    let first_char = String.get s 0 in
    first_char = '_' || (first_char >= 'a' && first_char <= 'z') ;;


let is_identifier s =
  let rec is_valid_char = function
    | c when (c >= 'a' && c <= 'z') || (c>='A' && c<= 'Z') || (c >= '0' && c <= '9') || c = '\'' || c = '_' -> true
    | _ -> false
  in
  let rec check_chars = function
    | [] -> true
    | c :: cs -> is_valid_char c && check_chars cs
  in
  starts_with_char_or_underscore s && check_chars (List.of_seq (String.to_seq s)) ;;


let is_keyword = function
| "if" | "else" | "then" | "pair" | "fst" | "snd" | "and" | "or" -> true
| _ -> false ;;

(* correct this , traverse the string and find out if it is correct identifier or no. *)

let rec is_valid_identifier_char = function
  | c when is_letter c || is_digit c || c = '\'' || c = '_' -> true
  | _ -> false

let rec tokenize input =
  let rec consume_word acc = function
    | c :: cs when is_valid_identifier_char c ->
      consume_word (acc ^ Char.escaped c) cs
    | cs -> ( acc, cs)
  in
  let rec consume_number acc = function
    | c :: cs when is_digit c -> consume_number (acc ^ Char.escaped c) cs
    | cs -> (int_of_string acc, cs)
  in
  match input with
  | [] -> []
  | c :: cs when is_letter c ->
    let (word, rest) = consume_word(Char.escaped c) cs in
    if word = "true" || word = "false" then
      BOOLEAN (word = "true") :: tokenize rest
    else if is_keyword word  then
      KEYWORD word :: tokenize rest
    else if is_identifier word = true then
      IDENTIFIER word :: tokenize rest
    else
      failwith "my error"
  | c :: cs when is_digit c ->
    let (number, rest) = consume_number (Char.escaped c) cs in
    INT_CONST number :: tokenize rest
  | '+' :: cs -> ARITH_OP "+" :: tokenize cs
  | '-' :: cs -> ARITH_OP "-" :: tokenize cs
  | '*' :: cs -> ARITH_OP "*" :: tokenize cs
  | '/' :: cs -> ARITH_OP "/" :: tokenize cs
  | '=' :: cs -> COMPARISON_OP "=" :: tokenize cs
  | '<' :: '=' :: cs -> COMPARISON_OP "<=" :: tokenize cs
  | '>' :: '=' :: cs -> COMPARISON_OP ">=" :: tokenize cs
  | '<' :: cs -> COMPARISON_OP "<" :: tokenize cs
  | '>' :: cs -> COMPARISON_OP ">" :: tokenize cs
  | '(' :: cs -> PAREN '(' :: tokenize cs
  | ')' :: cs -> PAREN ')' :: tokenize cs
  | ',' :: cs -> COMMA :: tokenize cs
  | '"' :: cs ->
    let rec consume_string acc = function
      | '"' :: rest -> (acc, rest)
      | c :: rest -> consume_string (acc ^ Char.escaped c) rest
      | [] -> failwith "Unterminated string literal"
    in
    let (str, rest) = consume_string "" cs in
    STRING_CONST str :: tokenize rest
  | ' ' :: cs | '\n' :: cs | '\t' :: cs -> tokenize cs
  | _ -> failwith "Unexpected character"

let tokenize_input input =
  tokenize (List.of_seq (String.to_seq input))


(* correct this so that arithmetic operations dont show plus *)

let print_token = function
  | IDENTIFIER s -> Printf.printf "'%s': identifier \n" s
  | KEYWORD s -> Printf.printf "'%s': keyword \n" s
  | BOOLEAN b -> Printf.printf "'%b': boolean \n" b
  | ARITH_OP op ->
    begin
      match op with
      | "+" -> Printf.printf "'%s': arithmetic operator (PLUS) \n" op
      | "-" -> Printf.printf "'%s': arithmetic operator (SUB) \n" op
      | "*" -> Printf.printf "'%s': arithmetic operator (MUL) \n" op
      | "/" -> Printf.printf "'%s': arithmetic operator (DIV) \n" op
      | _ -> failwith "Invalid arithmetic operator"
    end
  | INT_CONST n -> Printf.printf "'%d': constant \n" n
  | COMPARISON_OP op -> Printf.printf "'%s': comparison operator \n" op
  | STRING_CONST s -> Printf.printf "'%s': string constant \n" s
  | PAREN c -> Printf.printf "'%c': parenthesis \n" c
  | COMMA -> Printf.printf "',': comma \n";;

(* Example usage *)
let input = "if x1 + 42 * (y2 - 3) = true then \"result\" else x1 pair"
let tokens = tokenize_input input
let () = List.iter print_token tokens;;

(* let a = is_identifier "_alid_Stri'ng";; *)
(* Printf.printf "My boolean value is: %b\n" a;; *)


print_newline();;
