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
      $$ = {};
      if ($1 === null) { return; }
      var mixinName = $1.id;
      var components = $1.components;
      $$[mixinName] = components;
    %}
  | general_list general_item
    %{
      $$ = $1;
      if ($2 === null) { return; }
      var mixinName = $2.id;
      var components = $2.components;
      $$[mixinName] = components;
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
  : IDENT whitespace -> $1
;

component_name
  : IDENT whitespace -> $1
;

component_list
  : property
    %{
     // Terminal for single-prop component. Start data structure.
     var components = {};
     var property = $1;
     if (property === null) { $$ = components; return; }
     var propertyName = property[0];
     var propertyValue = property[1];

     if (!components[propertyName]) {
       components[propertyName] = propertyValue;
     } else if (components[propertyName].constructor === Array) {
       components[propertyName].push(propertyValue);
     } else {
       components[propertyName] = [components[propertyName], propertyValue];
     }
     $$ = components;
    %}
  | component_list property
    %{
     // Non-terminal for single-prop component. Update data structure.
     var components = $1;
     var property = $2;
     if (property === null) { $$ = components; return; }
     var propertyName = property[0];
     var propertyValue = property[1];

     if (!components[propertyName]) {
       components[propertyName] = propertyValue;
     } else if (components[propertyName].constructor === Array) {
       components[propertyName].push(propertyValue);
     } else {
       components[propertyName] = [components[propertyName], propertyValue];
     }
     $$ = components;
    %}
  | multi_prop_component
    %{
     // Terminal for multi-prop component. Create data structure.
     var components = {};
     var componentName = $1.component;
     var properties = $1.properties;
     if (properties === null) { $$ = components; return; }
     components[componentName] = properties;
     $$ = components;
    %}
  | component_list multi_prop_component
    %{
     // Non-terminal for multi-prop component. Create data structure.
     var components = $1;
     var componentName = $2.component;
     var properties = $2.properties;
     if (properties === null) { $$ = components; return; }
     components[componentName] = properties;
     $$ = components;
    %}
;

multi_prop_component
  : component_name wempty '{' wempty component_list '}' wempty -> {component: $1, properties: $5}
;

property
  : property_name wempty ':' wempty expr wempty ';' -> [$1, $5]
  | wempty -> null
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
