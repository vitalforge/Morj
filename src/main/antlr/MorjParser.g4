// $antlr-format alignTrailingComments true, columnLimit 150, minEmptyLines 1, maxEmptyLinesToKeep 1, reflowComments false, useTab false
// $antlr-format allowShortRulesOnASingleLine false, allowShortBlocksOnASingleLine true, alignSemicolons hanging, alignColons hanging

parser grammar MorjParser;

options {
    tokenVocab = MorjLexer;
}

morjFile
    : HashBangLine? LineTerminator* (expression LineTerminator?)* EOF
    ;

// Type
type
    : functionType
    | parenthesizedType
    | userType
    ;

userType
    : simpleUserType (LineTerminator* Dot LineTerminator* simpleUserType)*
    ;

simpleUserType
    : simpleIdentifier (LineTerminator* typeArguments)?
    ;

parenthesizedType
    : OpenParen LineTerminator* type LineTerminator* CloseParen
    ;

functionType
    : (receiverType LineTerminator* Dot LineTerminator*)? functionTypeParameters LineTerminator* Arrow LineTerminator* type
    ;

receiverType
    : parenthesizedType
    | userType
    ;

functionTypeParameters
    : OpenParen LineTerminator* (
        (parameter | type) (LineTerminator* Comma LineTerminator* (parameter | type))*
    )? (LineTerminator* Comma)? LineTerminator* CloseParen
    ;

parameter
    : simpleIdentifier LineTerminator* Colon LineTerminator* type
    ;

// Expression
expression
    : disjunction
    ;

// Disjunction
disjunction
    : conjuction (LineTerminator* Or LineTerminator* conjuction)*
    ;

// Conjuction
conjuction
    : comparison (LineTerminator* And LineTerminator* comparison)*
    ;

// Comparison
comparison
    : infixOperation (comparisonOperator LineTerminator* infixOperation)*
    ;

comparisonOperator
    : LessThan
    | LessThanEquals
    | GreaterThan
    | GreaterThanEquals
    | Equals
    | NotEquals
    ;

// In | Is
infixOperation
    : infixFunctionCall (infixOperator LineTerminator* infixFunctionCall)*
    ;

infixOperator
    : In
    | Is
    ;

// Infix functions
infixFunctionCall
    : rangeExpression (simpleIdentifier LineTerminator* rangeExpression)*
    ;

// Range
rangeExpression
    : additiveExpression (rangeOperator LineTerminator* additiveExpression)*
    ;

rangeOperator
    : Range
    | RangeUntil
    ;

// Arithmetic: Binary
additiveExpression
    : multiplicativeExpression (additiveOperator LineTerminator* multiplicativeExpression)*
    ;

additiveOperator
    : Plus
    | Minus
    ;

multiplicativeExpression
    : prefixUnaryExpression (multiplicativeOperator LineTerminator* prefixUnaryExpression)*
    ;

multiplicativeOperator
    : Multiply
    | Divide
    | Modulus
    ;

// Arithmetic: Unary Prefix
prefixUnaryExpression
    : prefixUnaryOperator? postfixUnaryExpression
    ;

prefixUnaryOperator
    : PlusPlus
    | MinusMinus
    | Plus
    | Minus
    ;

// Arithmetic: Unary Postfix
postfixUnaryExpression
    : primaryExpression postfixUnarySuffix?
    ;

postfixUnaryOperator
    : PlusPlus
    | MinusMinus
    ;

// Other: Unary Postfix
postfixUnarySuffix
    : postfixUnaryOperator
    | typeArguments
    | callSuffix
    | indexSuffix
    | navigationSuffix
    ;

typeArguments
    : LessThan LineTerminator* type (LineTerminator* Comma LineTerminator* type)* (
        LineTerminator* Comma
    )? LineTerminator* GreaterThan
    ;

callSuffix
    : typeArguments? valueArguments
    ;

indexSuffix
    : OpenBracket LineTerminator* expression LineTerminator* CloseBracket
    ;

navigationSuffix
    : memberAccessOperator LineTerminator* simpleIdentifier
    ;

memberAccessOperator
    : Dot
    ;

// Arguments
valueArguments
    : OpenParen LineTerminator* (
        valueArgument (LineTerminator* Comma LineTerminator* valueArgument)* (
            LineTerminator* Comma
        )? LineTerminator*
    )? CloseParen
    ;

valueArgument
    : LineTerminator* (simpleIdentifier LineTerminator* Assign LineTerminator* | Ellipsis)? expression
    ;

// Primary expressions
primaryExpression
    : parenthesizedExpression
    | simpleIdentifier
    | literalConstant
    | stringLiteral
    ;

parenthesizedExpression
    : OpenParen LineTerminator* expression LineTerminator* CloseParen
    ;

literalConstant
    : BooleanLiteral
    | NoneLiteral
    | CharacterLiteral
/* Numeric */
    | FloatLiteral
    | DoubleLiteral
    | DecIntegerLiteral
    | HexIntegerLiteral
    | OctalIntegerLiteral
    | BinaryIntegerLiteral
    ;

// Strings
stringLiteral
    : lineStringLiteral
    | multiLineStringLiteral
    ;

lineStringLiteral
    : DoubleQuoteStringStart (lineStringContent | lineStringExpression)* DoubleQuoteStringEnd
    ;

lineStringContent
    : DoubleQuoteStringText
    | DoubleQuoteStringEscapedChar
    | DoubleQuoteStringRef
    ;

lineStringExpression
    : OpenBrace LineTerminator* expression LineTerminator* CloseBrace
    ;

multiLineStringLiteral
    : MultiLineDoubleQuoteStringStart (multiLineStringContent | multiLineStringExpression)* MultiLineDoubleQuoteStringEnd
    ;

multiLineStringContent
    : MultiLineDoubleQuoteStringText
    | MultiLineDoubleQuoteStringQuote
    | MultiLineDoubleQuoteStringEscapedChar
    | MultiLineDoubleQuoteStringRef
    ;

multiLineStringExpression
    : OpenBrace LineTerminator* expression LineTerminator* CloseBrace
    ;

// Identifier
simpleIdentifier
    : Identifier
    /* Soft keywords */
    | Get
    | Set
    | Field
    ;

identifier
    : simpleIdentifier (LineTerminator* Dot simpleIdentifier)*
    ;