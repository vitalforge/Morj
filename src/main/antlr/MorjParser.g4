// $antlr-format alignTrailingComments true, columnLimit 150, minEmptyLines 1, maxEmptyLinesToKeep 1, reflowComments false, useTab false
// $antlr-format allowShortRulesOnASingleLine false, allowShortBlocksOnASingleLine true, alignSemicolons hanging, alignColons hanging

parser grammar MorjParser;

options {
    tokenVocab = MorjLexer;
}

morjFile
    : HashBangLine? LineTerminator* (literalConstant LineTerminator?)* EOF
    ;

/// Expressions
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
    | LessThanOrEqual
    | GreaterThan
    | GreaterThanOrEqual
    | Equal
    | NotEqual
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

// Arithmetic
additiveExpression
    : multiplicativeExpression (additiveOperator LineTerminator* multiplicativeExpression)*
    ;

additiveOperator
    : Plus
    | Minus
    ;

// Atoms
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
    : DoubleQuoteStringStart (DoubleQuoteStringText | lineStringExpression)* DoubleQuoteStringEnd
    ;

lineStringExpression
    : DoubleQuoteStringExprStart LineTerminator* expression LineTerminator* DoubleQuoteStringExprEnd multiLineStringLiteral
    :
    ;