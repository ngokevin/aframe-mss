%start stylesheet

%%

// Root grammar.
stylesheet
  : space_cdata_list general_list
    // What to export.
    %{
      $$ = {};
      // $2 respectively corresponds to output of general_list.
      if ($2) {
        $$['mixins'] = $2;
      }
      return $$;
    %}
;

string_or_uri
  : STRING wempty -> $1
  | URI wempty -> $1
;

general_list
  : general_item
    %{
    $$ = [];
    if ($1 !== null) {
     $$.push($1);
      }
   %}
  | general_list general_item
   %{
    $$ = $1;
    $$.push($2);
   %}
  | -> null
;

general_item
  : ruleset -> $1
  | space_cdata_list -> null
;

unary_operator
  : '-' -> $1
  | '+' -> $1
;

property_name
  : IDENT wempty -> $1
  | '*' IDENT wempty -> $1 + $2  // cwdoh.
;

ruleset
  : mixin_name wempty '{' wempty component_list '}' wempty -> {id: $1, components: $5}
;

mixin_name
  : IDENT whitespace -> $1 + " "
;

component_name
  : IDENT whitespace -> $1 + " "
;

component_list
  : component
   %{
    $$ = {};
    if ($1 !== null) {
      if (!$$[$1[0]]) {
        $$[$1[0]] = $1[1];
      } else if (Object.prototype.toString.call($$[$1[0]]) === '[object Array]') {
        $$[$1[0]].push($1[1]);
      } else {
        $$[$1[0]] = [$$[$1[0]], $1[1]];
      }
    }
   %}
  | component_list component
   %{
    $$ = $1;
    if ($2 !== null) {
      if (!$$[$2[0]]){
        $$[$2[0]] = $2[1];
      } else if (Object.prototype.toString.call($$[$2[0]]) === '[object Array]') {
        $$[$2[0]].push($2[1]);
      } else {
        $$[$2[0]] = [$$[$2[0]], $2[1]];
      }
    }
   %}
  | component_name wempty '{' wempty component_list '}' wempty -> {component: $1, properties: $5}
;

component
  : property -> $1
  | ';' -> null
  | wempty -> null
;

property
  : property_name wempty ':' wempty expr wempty -> [$1, $5]
  | /* empty */ -> null
;

expr
  : term -> $1
  | expr operator term -> $1 + $2 + $3
  | expr term -> $1 + ' ' + $2
;

term
  : computable_term -> $1
  | unary_operator computable_term -> $1 + $2
  | string_term -> $1
;

computable_term
  : NUMBER wempty -> $1
  | PERCENTAGE wempty -> $1
  | ANGLE wempty -> $1
  | TIME wempty -> $1
  | FUNCTION wempty expr ')' wempty -> $1 + $3 + $4
;

string_term
  : STRING wempty -> $1
  | IDENT wempty -> $1
  | URI wempty -> $1
  | UNICODERANGE wempty -> $1
  | hexcolor -> $1
;

operator
  : '/' wempty -> $1
  | ',' wempty -> $1
  | '=' wempty -> $1
  | /* empty */ -> ""
;

hexcolor
  : HASH wempty -> $1
;

whitespace
  : S -> ' '
  | whitespace S -> ' '
;

wempty
  : whitespace -> $1
  | -> ""
;

space_cdata_list
  : space_cdata -> null
  | space_cdata_list space_cdata -> null
  |
;

space_cdata
  : S -> null
  | CDO -> null
  | CDC -> null
;
