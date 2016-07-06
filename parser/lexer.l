/* lexical scanner from W3C spec. see http://www.w3.org/TR/css3-syntax/#lexical */

h	[0-9a-fA-F]
nonascii [\200-\377]
unicode	\\{h}{1,6}[ \t\r\n\f]?
escape {unicode}|\\[ -~\200-\377]
nmstart	[a-zA-Z]|{nonascii}|{escape}
nmchar [a-zA-Z0-9-]|{nonascii}|{escape}
string1	\"([\t !#$%&(-~]|\\{nl}|\'|{nonascii}|{escape})*\"
string2	\'([\t !#$%&(-~]|\\{nl}|\"|{nonascii}|{escape})*\'

identchar	[_]|{nmchar}
ident	[-]?{nmstart}{identchar}*
name {identchar}+
num	([0-9]+(\.[0-9]+)?)|(\.[0-9]+)
string {string1}|{string2}
url	([!#$%&*-~]|{nonascii}|{escape})*
// Whitespace.
w	[ \t\r\n\f]*
// Newline.
nl \n|\r\n|\r|\f
range	\?{1,6}|{h}(\?{0,5}|{h}(\?{0,4}|{h}(\?{0,3}|{h}(\?{0,2}|{h}(\??|{h})))))

%%

[ \t\r\n\f]+ {return 'S';}
\/\*[^*]*\*+([^/][^*]*\*+)*\/	{}  // Ignore comments.

// Attribute value matching.
"<!--" {return 'CDO';}  // Comment Delimiter Open.
"-->"	{return 'CDC';}	 // Comment Delimiter Close.
"~=" {return 'INCLUDES';}
"|=" {return 'DASHMATCH';}
"^=" {return 'PREFIXMATCH';}
"$=" {return 'SUFFIXMATCH';}
"*=" {return 'SUBSTRINGMATCH';}

"url("{w}{string}{w}")"	{return 'URI';}
"url("{w}{url}{w}")" {return 'URI';}
{ident}"(" {return "FUNCTION";}

{string} {return 'STRING';}
{ident}	{return 'IDENT';}

"#"{name}	{return 'HASH';}

"@page"	{return 'PAGE_SYM';}

{num}"deg" {return 'ANGLE';}
{num}"rad" {return 'ANGLE';}
{num}"ms"	{return 'TIME';}
{num}"s" {return 'TIME';}
{num}{ident} {return 'DIMEN';}
{num}"%" {return 'PERCENTAGE';}
{num}	{return 'NUMBER';}

U\+{range} {return 'UNICODERANGE';}
U\+{h}{1,6}-{h}{1,6} {return 'UNICODERANGE';}

.	{return yytext;}
