// $antlr-format alignTrailingComments true, columnLimit 150, maxEmptyLinesToKeep 1, reflowComments false, useTab false
// $antlr-format allowShortRulesOnASingleLine true, allowShortBlocksOnASingleLine true, minEmptyLines 0, alignSemicolons ownLine
// $antlr-format alignColons trailing, singleLineOverrulesHangingColon true, alignLexerCommands true, alignLabels true, alignTrailers true

lexer grammar MorjLexer;

options {
    superClass = MorjLexerBase;
}

tokens {
    StringOpenBrace
}

channels {
    MorjComment
}

// Comments
HashBangLine      :                           {this.IsStartOfFile()}? '#!' ~[\r\n\u2028\u2029]*;
MultiLineComment  : '/*' .*? '*/'             -> channel(MorjComment);
SingleLineComment : '//' ~[\r\n\u2028\u2029]* -> channel(MorjComment);

// Whitespace
WhiteSpaces      : [\t\u000B\u000C\u0020\u00A0]+ -> skip;
LineTerminator   : [\r\n\u2028\u2029];
LineContinuation : '\\' LineTerminator -> skip;

// Braces
OpenBracket  : '[';
CloseBracket : ']';
OpenBrace    : '{' -> pushMode(DEFAULT_MODE);
CloseBrace   : '}' -> popMode;
OpenParen    : '(';
CloseParen   : ')';

// Base characters
SemiColon                  : ';';
Comma                      : ',';
Assign                     : '=';
QuestionMark               : '?';
Colon                      : ':';
Ellipsis                   : '...';
Range                      : '..';
RangeUntil                 : '..<';
Dot                        : '.';
PlusPlus                   : '++';
MinusMinus                 : '--';
Plus                       : '+';
Minus                      : '-';
BitNot                     : '~';
Not                        : '!';
Multiply                   : '*';
CommandStart               : '/' {this.IsCommandPossible()}? -> pushMode(CommandMode);
Divide                     : '/';
Modulus                    : '%';
Power                      : '**';
Hashtag                    : '#';
RightShiftArithmetic       : '>>';
LeftShiftArithmetic        : '<<';
LessThan                   : '<';
GreaterThan                : '>';
LessThanEquals             : '<=';
GreaterThanEquals          : '>=';
Equals                     : '==';
NotEquals                  : '!=';
BitAnd                     : '&';
BitXOr                     : '^';
BitOr                      : '|';
And                        : '&&';
Or                         : '||';
MultiplyAssign             : '*=';
DivideAssign               : '/=';
ModulusAssign              : '%=';
PlusAssign                 : '+=';
MinusAssign                : '-=';
LeftShiftArithmeticAssign  : '<<=';
RightShiftArithmeticAssign : '>>=';
BitAndAssign               : '&=';
BitXorAssign               : '^=';
BitOrAssign                : '|=';
PowerAssign                : '**=';
At                         : '@';
Arrow                      : '->';

// None Literals
NoneLiteral: 'none';

// Boolean Literals
BooleanLiteral: 'true' | 'false';

// Numeric Literals
FloatLiteral: DoubleLiteral [fF] | DecimalIntegerLiteral [fF];
DoubleLiteral:
    DecimalIntegerLiteral? '.' DecimalDigitsLiteral ExponentPart?
    | DecimalIntegerLiteral ExponentPart
;
DecIntegerLiteral    : DecimalIntegerLiteral;
HexIntegerLiteral    : '0' [xX] HexDigit ('_'? HexDigit)*;
OctalIntegerLiteral  : '0' [oO] [0-7] ('_'? [0-7])*;
BinaryIntegerLiteral : '0' [bB] [01] ('_'? [01])*;

// Keywords
Operator    : 'operator';
Constructor : 'constructor';
If          : 'if';
Else        : 'else';
Break       : 'break';
While       : 'while';
For         : 'for';
Return      : 'return';
Continue    : 'continue';
Class       : 'class';

// Reserved (May be added)
Loop      : 'loop';
In        : 'in';
Is        : 'is';
Public    : 'public';
Pub       : 'pub';
Private   : 'private';
Protected : 'protected';
Final     : 'final';
Static    : 'static';
Abstract  : 'abstract';
Override  : 'override';

// Soft keywords
Get                    : 'get';
Set                    : 'set';
Field                  : 'field';
TargetSelectorVariable : [praes];

// Identifiers
Identifier              : IdentifierStart IdentifierPart*;
IdentifierOrSoftKeyword : Identifier | Get | Set | Field;

// Strings
CharacterLiteral                : '\'' (UnicodeEscapeSequence | SingleStringCharacter) '\'';
Apostrophe                      : '\''; // For selectors
DoubleQuoteStringStart          : '"'   -> pushMode(DoubleQuoteStringMode);
MultiLineDoubleQuoteStringStart : '"""' -> pushMode(MultiLineDoubleQuoteStringMode);

// Inside strings
mode DoubleQuoteStringMode;
DoubleQuoteStringEnd         : '"' -> popMode;
DoubleQuoteStringRef         : FieldIdentifier;
DoubleQuoteStringText        : DoubleStringCharacter+ | '$'; // TODO: Dollar signs are handled by the ...
DoubleQuoteStringEscapedChar : EscapeSequence;
DoubleQuoteStringExprStart   : '${' -> type(StringOpenBrace), pushMode(DEFAULT_MODE);

mode MultiLineDoubleQuoteStringMode;
MultiLineDoubleQuoteStringEnd         : '"""' -> popMode;
MultiLineDoubleQuoteStringQuote       : '"';
MultiLineDoubleQuoteStringRef         : FieldIdentifier;
MultiLineDoubleQuoteStringText        : DoubleStringCharacter+ | '$';
MultiLineDoubleQuoteStringEscapedChar : EscapeSequence;
MutliLineDoubleQuoteStringExprStart   : '${'           -> type(StringOpenBrace), pushMode(DEFAULT_MODE);
MultiLineDoubleQuoteStringNewLine     : LineTerminator -> skip;

// Fragments: Numeric
fragment DecimalIntegerLiteral : [1-9] ('_'? [0-9])*;
fragment DecimalDigitsLiteral  : [0-9] ('_'? [0-9])*;
fragment ExponentPart          : [eE] [+-]? [0-9] ('_'? [0-9])*;
fragment HexDigit              : [0-9a-fA-F];

// Fragments: Identifier
fragment IdentifierPart  : IdentifierStart | [\p{Mn}] | [\p{Nd}] | [\p{Pc}] | '\u200C' | '\u200D';
fragment IdentifierStart : [\p{L}] | [$_];

// Fragments: String
fragment DoubleStringCharacter : ~["\\\r\n$];
fragment SingleStringCharacter : ~['\\\r\n$];
fragment EscapeSequence        : UnicodeEscapeSequence | EscapedIdentifier;
fragment UnicodeEscapeSequence : '\\u' HexDigit HexDigit HexDigit HexDigit;
fragment EscapedIdentifier     : '\\' [tbrn\\"'$];
fragment FieldIdentifier       : '$' Identifier;

//
// Section: Minecraft
//

mode CommandMode;

CommandEnd: LineTerminator -> popMode;

mode MinecraftMode;

// Whitespace
M_WhiteSpaces      : WhiteSpaces      -> skip;
M_LineTerminator   : LineTerminator   -> type(LineTerminator);
M_LineContinuation : LineContinuation -> skip;

// Letters
M_LowerLetterA : 'a';
M_LowerLetterB : 'b';
M_LowerLetterC : 'c';
M_LowerLetterD : 'd';
M_LowerLetterE : 'e';
M_LowerLetterF : 'f';
M_LowerLetterG : 'g';
M_LowerLetterH : 'h';
M_LowerLetterI : 'i';
M_LowerLetterJ : 'j';
M_LowerLetterK : 'k';
M_LowerLetterL : 'l';
M_LowerLetterM : 'm';
M_LowerLetterN : 'n';
M_LowerLetterO : 'o';
M_LowerLetterP : 'p';
M_LowerLetterQ : 'q';
M_LowerLetterR : 'r';
M_LowerLetterS : 's';
M_LowerLetterT : 't';
M_LowerLetterU : 'u';
M_LowerLetterV : 'v';
M_LowerLetterW : 'w';
M_LowerLetterX : 'x';
M_LowerLetterY : 'y';
M_LowerLetterZ : 'z';

M_UpperLetterA : 'A';
M_UpperLetterB : 'B';
M_UpperLetterC : 'C';
M_UpperLetterD : 'D';
M_UpperLetterE : 'E';
M_UpperLetterF : 'F';
M_UpperLetterG : 'G';
M_UpperLetterH : 'H';
M_UpperLetterI : 'I';
M_UpperLetterJ : 'J';
M_UpperLetterK : 'K';
M_UpperLetterL : 'L';
M_UpperLetterM : 'M';
M_UpperLetterN : 'N';
M_UpperLetterO : 'O';
M_UpperLetterP : 'P';
M_UpperLetterQ : 'Q';
M_UpperLetterR : 'R';
M_UpperLetterS : 'S';
M_UpperLetterT : 'T';
M_UpperLetterU : 'U';
M_UpperLetterV : 'V';
M_UpperLetterW : 'W';
M_UpperLetterX : 'X';
M_UpperLetterY : 'Y';
M_UpperLetterZ : 'Z';

// Operators
M_At           : '@';
M_Slash        : '/';
M_Hashtag      : '#';
M_Colon        : ':';
M_SemiColon    : ';';
M_Assign       : '=';
M_OpenBracket  : '[';
M_CloseBracket : ']';
M_OpenBrace    : '{';
M_CloseBrace   : '}';
M_Comma        : ',';
M_Exclamation  : '!';

M_True  : 'true';
M_False : 'false';

M_NamespaceLikeUUID : M_UUID [a-z_.\-] [a-z0-9_.\-]*;
M_NameLikeUUID      : M_UUID [a-zA-Z_.\-+] [a-zA-Z0-9_.\-+]*;
M_UUID              : M_HexInt '-' M_HexShort '-' M_HexShort '-' M_HexShort '-' M_HexInt M_HexShort?;

M_NamespaceLikeDoublePrefixed : M_DoublePrefixed [a-z0-9_.\-]+;
M_NameLikeDoublePrefixed      : M_DoublePrefixed [a-zA-Z0-9_.\-+]+;
M_DoublePrefixed              : M_Double 'd';

M_NamespaceLikeFloat : M_Float [a-z0-9_.\-]+;
M_NameLikeFloat      : M_Float [a-zA-Z0-9_.\-+]+;
M_Float              : (M_Double | M_Decimal) 'f';

M_NamespaceLikeDouble : M_Double [a-z.\-] [a-z0-9.\-]*;
M_NameLikeDouble      : M_Double [a-zA-Z.\-+] [a-zA-Z0-9.\-+]*;
M_Double              : '-'? [0-9]+ ('.' [0-9]+)? [eE] [+-]? [0-9]+ | '-'? [0-9]+ '.' [0-9]+;

M_NamespaceLikeDecimal : M_Decimal [a-z_.\-] [a-z0-9_.\-]*;
M_NameLikeDecimal      : M_Decimal [a-zA-Z0-9_.\-+]*;
M_Decimal              : '-'? [0-9]+;

M_NamespaceLikeHexadecimal : M_Hexadecimal [g-z_.\-] [a-z0-9_.\-]*;
M_NameLikeHexadecimal      : M_Hexadecimal [g-zG-Z_.\-+] [a-zA-Z0-9_.\-+]*;
M_Hexadecimal              : [0-9a-fA-F]+;

M_Namespace          : [a-z0-9_.\-]+;
M_Name               : [a-zA-Z0-9_.\-+]+;
M_DoubleQuotedString : '"' ([^"\r\n\\] | '\\' [tbrn\\"'/] | UnicodeEscapeSequence)* '"';
M_SingleQuotedString : '\'' ([^'\r\n\\] | '\\' [tbrn\\'"/] | UnicodeEscapeSequence)* '\'';

// Bad characters
M_BadCharacter: .;

// Fragments: Minecraft
fragment M_HexCharacter : [0-9a-fA-F];
fragment M_HexByte      : M_HexCharacter M_HexCharacter?;
fragment M_HexShort     : M_HexByte M_HexByte?;
fragment M_HexInt       : M_HexShort M_HexShort?;
fragment M_HexLong      : M_HexInt M_HexInt?;