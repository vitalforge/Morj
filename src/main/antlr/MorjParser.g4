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

disjunction
    : conjuction (LineTerminator* Or LineTerminator* conjuction)*
    ;

conjuction
    : comparison (LineTerminator* And LineTerminator* comparison)*
    ;

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
    : (simpleIdentifier LineTerminator* Assign LineTerminator* | Ellipsis)? expression
    ;

// Primary expressions
primaryExpression
    : parenthesizedExpression
    | simpleIdentifier
    | targetSelector
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
    : StringOpenBrace LineTerminator* expression LineTerminator* CloseBrace
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
    : StringOpenBrace LineTerminator* expression LineTerminator* CloseBrace
    ;

// Identifiers
simpleIdentifier
    : Identifier
    /* Soft keywords */
    | Get
    | Set
    | Field
/* Minecraft keywords */
    | LetterD
    | LetterS
    | LetterUppercaseB
    | LetterLowercaseB
    | LetterUppercaseL
    | LetterLowercaseL
    | LetterUppercaseI
    ;

identifier
    : simpleIdentifier (LineTerminator* Dot simpleIdentifier)*
    ;

// Minecraft syntax:

// Argument Types
// https://minecraft.fandom.com/wiki/Argument_types
entity
    : targetSelector
    | uuid
    ;

// Scoreboard
// https://minecraft.fandom.com/wiki/Scoreboard
scoreboardTag
    : identifier
    | stringLiteral
/* Minecraft Mode */
    ;

// Target selectors
// https://minecraft.fandom.com/wiki/Target_selectors
targetSelector
    : At targetSelectorVariable (Colon LineTerminator* targetSelectorType)? (
        Apostrophe LineTerminator* scoreboardTag
    )? targetSelectorArguments?
    /* Minecraft Mode */
    ;

targetSelectorVariable
    : identifier
    /* Expressions */
    | parenthesizedExpression
/* Minecraft Mode */
    ;

targetSelectorType
    : resourceLocation // entity ID
    | tag              // entity type tag
    /* Expressions */
    | parenthesizedExpression
/* Minecraft Mode */
    ;

targetSelectorArguments
    : OpenBracket LineTerminator* (
        targetSelectorArgument (LineTerminator* Comma LineTerminator* valueArgument)* (
            LineTerminator* Comma
        )? LineTerminator*
    )? CloseBracket
    /* Minecraft Mode */
    ;

targetSelectorArgument
    : (targetSelectorKey LineTerminator* Assign LineTerminator* | Ellipsis) targetSelectorValue
    ;

targetSelectorKey
    : identifier
    /* Expression */
    | parenthesizedExpression
/* Minecraft Mode */
    ;

// TODO: Extend selector values
targetSelectorValue
    : nbtTag
    | resourceLocation
    /* Expression */
    | parenthesizedExpression
    ;

// Universally Unique Identifier
// https://minecraft.fandom.com/wiki/Universally_unique_identifier
uuid
    : {false}? // TODO: Minecraft Mode
    | stringLiteral
/* Minecraft Mode */
    ;

// Resource Location
resourceLocation
    : (resourceLocationNamespace Colon)? resourceLocationPath
    /* Minecraft Mode */
    ;

resourceLocationNamespace
    : identifier (Divide identifier)*
    /* Minecraft Mode */
    ;

resourceLocationPath
    : identifier
    /* Minecraft Mode */
    ;

// Tag
// https://minecraft.fandom.com/wiki/Tag
tag
    : Hashtag resourceLocation
    /* Minecraft Mode */
    ;

// NBT format
// https://minecraft.fandom.com/wiki/NBT_format
nbtTag
    : nbtByteTag
    | nbtBooleanTag
    | nbtShortTag
    | nbtIntTag
    | nbtLongTag
    | nbtFloatTag
    | nbtDoubleTag
    | nbtStringTag
    | nbtListTag
    | nbtCompoundTag
    | nbtByteArray
    | nbtIntArray
    | nbtLongArray
/* Minecraft Mode */
    ;

nbtByteTag
    : Minus? DecIntegerLiteral (LetterUppercaseB | LetterLowercaseB)
    /* Minecraft Mode */
    ;

nbtBooleanTag
    : BooleanLiteral
    /* Minecraft Mode */
    ;

nbtShortTag
    : Minus? DecIntegerLiteral LetterS
    /* Minecraft Mode */
    ;

nbtIntTag
    : DecIntegerLiteral
    /* Minecraft Mode */
    ;

nbtLongTag
    : DecIntegerLiteral (LetterUppercaseL | LetterLowercaseL)
    /* Minecraft Mode */
    ;

nbtFloatTag
    : FloatLiteral
    /* Minecraft Mode */
    ;

nbtDoubleTag
    : DoubleLiteral LetterD?
    /* Minecraft Mode */
    ;

nbtStringTag
    : stringLiteral
    /* Minecraft Mode */
    ;

nbtListTag
    : OpenBracket LineTerminator* (
        nbtListTagElement (LineTerminator* Comma LineTerminator* nbtListTagElement)* (
            LineTerminator* Comma
        )? LineTerminator*
    )? CloseBracket
    /* Minecraft Mode */
    ;

nbtListTagElement
    : nbtTag
    /* Expression */
    | parenthesizedExpression
/* Minecraft Mode */
    ;

nbtCompoundTag
    : OpenBrace LineTerminator* (
        nbtCompoundTagItem (LineTerminator* Comma LineTerminator* nbtCompoundTagItem)* (
            LineTerminator* Comma
        )? LineTerminator*
    )? CloseBrace
    /* Minecraft Mode */
    ;

nbtCompoundTagItem
    : nbtCompoundKey LineTerminator* Colon LineTerminator* nbtCompoundValue
    ;

nbtCompoundKey
    : identifier
    | stringLiteral
/* Expression */
    | parenthesizedExpression
/* Minecraft Mode */
    ;

nbtCompoundValue
    : nbtTag
    /* Expression */
    | parenthesizedExpression
/* Minecraft Mode */
    ;

nbtByteArray
    : OpenBracket LineTerminator* LetterUppercaseB SemiColon (
        nbtByteArrayElement (LineTerminator* Comma LineTerminator* nbtByteArrayElement)* (
            LineTerminator* Comma
        )? LineTerminator*
    )? CloseBracket
    /* Minecraft Mode */
    ;

nbtByteArrayElement
    : nbtByteTag
    /* Expression */
    | parenthesizedExpression
/* Minecraft Mode */
    ;

nbtIntArray
    : OpenBracket LineTerminator* LetterUppercaseI SemiColon (
        nbtIntArrayElement (LineTerminator* Comma LineTerminator* nbtIntArrayElement)* (
            LineTerminator* Comma
        )? LineTerminator*
    )? CloseBracket
    /* Minecraft Mode */
    ;

nbtIntArrayElement
    : nbtIntTag
    /* Expression */
    | parenthesizedExpression
/* Minecraft Mode */
    ;

nbtLongArray
    : OpenBracket LineTerminator* LetterUppercaseL SemiColon (
        nbtLongArrayElement (LineTerminator* Comma LineTerminator* nbtLongArrayElement)* (
            LineTerminator* Comma
        )? LineTerminator*
    )? CloseBracket
    /* Minecraft Mode */
    ;

nbtLongArrayElement
    : nbtLongTag
    /* Expression */
    | parenthesizedExpression
/* Minecraft Mode */
    ;