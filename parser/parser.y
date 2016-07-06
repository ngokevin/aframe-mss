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
        $$['rulelist'] = $2;
      }
      return $$;
    %}
;

string_or_uri
  : STRING wempty	-> $1
  | URI wempty -> $1
;

general_list
  : general_item
    %{
  		$$ = [];
  		if ($1 !== null)
  			$$.push($1);
  	%}
  | general_list general_item
  	%{
  		$$ = $1;
  		$$.push($2);
  	%}
  |	-> null
;

general_item
  : ruleset	-> $1
  | space_cdata_list -> null
;

unary_operator
  : '-'	-> $1
  | '+'	-> $1
;

property
  : IDENT wempty -> $1
  | '*' IDENT wempty -> $1 + $2  // cwdoh.
;

ruleset
  : selector_list '{' wempty declaration_list '}' wempty		-> { "type": "style", "selector": $1, "declarations": $4 }
  ;

selector_list
  : selector									-> $1
  | selector_list ',' wempty selector			-> $1 + $2 + ' ' + $4
  ;

selector
  : simple_selector								-> $1
  | selector combinator simple_selector			-> $1 + $2 + $3
  ;

combinator
  : '+' wempty					-> $1
  | '>' wempty					-> $1
  | /* empty */					-> ""
  ;
simple_selector
  : simple_selector_atom_list whitespace					-> $1 + " "
  | element_name simple_selector_atom_list wempty		-> $1 + $2
  ;
simple_selector_atom_list
  : simple_selector_atom								-> $1
  | simple_selector_atom_list simple_selector_atom		-> $1 + $2
  |														-> ""
  ;

simple_selector_atom
  : HASH			-> $1
  | class			-> $1
  | attrib			-> $1
;

class
  : '.' IDENT		-> $1 + $2
  ;
element_name
  : IDENT			-> $1
  | '*'				-> $1
  ;
attrib
  : '[' wempty IDENT wempty ']'													-> $1 + $3 + $5
  | '[' wempty IDENT wempty attrib_operator wempty attrib_value wempty ']'		-> $1 + $3 + $5 + $6 + $7 + $9
  ;
attrib_operator
  : '='										-> $1
  | INCLUDES								-> $1
  | DASHMATCH								-> $1
  | PREFIXMATCH								-> $1
  | SUFFIXMATCH								-> $1
  | SUBSTRINGMATCH							-> $1
  ;
attrib_value
  : IDENT									-> $1
  | STRING									-> $1
  ;

declaration_list
  : declaration_parts
  	%{
  		$$ = {};
  		if ( $1 !== null ) {
        if(!$$[ $1[0] ]){
          $$[ $1[0] ] = $1[1];
        } else if(Object.prototype.toString.call($$[ $1[0] ]) === '[object Array]') {
          $$[ $1[0] ].push($1[1]);
        } else {
          $$[ $1[0] ] = [ $$[ $1[0] ], $1[1] ];
        }
  		}
  	%}
  | declaration_list declaration_parts
  	%{
  		$$ = $1;
  		if ( $2 !== null ) {
        if(!$$[ $2[0] ]){
          $$[ $2[0] ] = $2[1];
        } else if(Object.prototype.toString.call($$[ $2[0] ]) === '[object Array]') {
          $$[ $2[0] ].push($2[1]);
        } else {
          $$[ $2[0] ] = [ $$[ $2[0] ], $2[1] ];
        }
	  	}
  	%}
  ;
declaration_parts
  : declaration 		-> $1
  | ';'					-> null
  | wempty				-> null
  ;
declaration
  : property ':' wempty expr wempty					-> [ $1, $4 ]
  | property ':' wempty expr IMPORTANT_SYM wempty	-> [ $1, $4 + " !important" ]
  | /* empty */										-> null
  ;
expr
  : term									-> $1
  | expr operator term						-> $1 + $2 + $3
  | expr term								-> $1 + ' ' + $2
  ;
term
  : computable_term							-> $1
  | unary_operator computable_term			-> $1 + $2
  | string_term								-> $1
  ;
computable_term
  : NUMBER wempty							-> $1
  | PERCENTAGE wempty						-> $1
  | ANGLE wempty							-> $1
  | TIME wempty								-> $1
  | FUNCTION wempty expr ')' wempty			-> $1 + $3 + $4
  ;
string_term
  : STRING wempty							-> $1
  | IDENT wempty							-> $1
  | URI wempty								-> $1
  | UNICODERANGE wempty						-> $1
  | hexcolor	 							-> $1
  ;
operator
  : '/' wempty					-> $1
  | ',' wempty					-> $1
  | '=' wempty					-> $1
  |	/* empty */					-> ""
  ;
hexcolor
  : HASH wempty					-> $1
  ;
whitespace
  : S					-> ' '
  | whitespace S		-> ' '
  ;
wempty
  : whitespace		-> $1
  |					-> ""
  ;

space_cdata_list
  : space_cdata	-> null
  | space_cdata_list space_cdata -> null
  |
;

space_cdata
  : S	-> null
  | CDO	-> null
  | CDC	-> null
;
