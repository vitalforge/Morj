// $antlr-format alignTrailingComments true, columnLimit 150, minEmptyLines 1, maxEmptyLinesToKeep 1, reflowComments false, useTab false
// $antlr-format allowShortRulesOnASingleLine false, allowShortBlocksOnASingleLine true, alignSemicolons hanging, alignColons hanging

parser grammar MorjParser;

options {
    tokenVocab = MorjLexer;
    superClass = MorjParserBase;
}

@header { import static org.morj.antlr.MorjLexer.*; }

morjFile
    : HashBangLine? lineTerminators (expression LineTerminator?)* EOF
    ;

// Line terminators
lineTerminators
    : LineTerminator*
    ;

// Type
type
    : functionType
    | parenthesizedType
    | userType
    ;

userType
    : simpleUserType (lineTerminators Dot lineTerminators simpleUserType)*
    ;

simpleUserType
    : simpleIdentifier (lineTerminators typeArguments)?
    ;

parenthesizedType
    : OpenParen lineTerminators type lineTerminators CloseParen
    ;

functionType
    : (receiverType lineTerminators Dot lineTerminators)? functionTypeParameters lineTerminators Arrow lineTerminators type
    ;

receiverType
    : parenthesizedType
    | userType
    ;

functionTypeParameters
    : OpenParen lineTerminators (
        (parameter | type) (lineTerminators Comma lineTerminators (parameter | type))*
    )? (lineTerminators Comma)? lineTerminators CloseParen
    ;

parameter
    : simpleIdentifier lineTerminators Colon lineTerminators type
    ;

// Expression
expression
    : disjunction
    ;

disjunction
    : conjuction (lineTerminators Or lineTerminators conjuction)*
    ;

conjuction
    : comparison (lineTerminators And lineTerminators comparison)*
    ;

comparison
    : infixOperation (comparisonOperator lineTerminators infixOperation)*
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
    : infixFunctionCall (infixOperator lineTerminators infixFunctionCall)*
    ;

infixOperator
    : In
    | Is
    ;

// Infix functions
infixFunctionCall
    : rangeExpression (simpleIdentifier lineTerminators rangeExpression)*
    ;

// Range
rangeExpression
    : additiveExpression (rangeOperator lineTerminators additiveExpression)*
    ;

rangeOperator
    : Range
    | RangeUntil
    ;

// Arithmetic: Binary
additiveExpression
    : multiplicativeExpression (additiveOperator lineTerminators multiplicativeExpression)*
    ;

additiveOperator
    : Plus
    | Minus
    ;

multiplicativeExpression
    : prefixUnaryExpression (multiplicativeOperator lineTerminators prefixUnaryExpression)*
    ;

multiplicativeOperator
    : Multiply
    | Divide
    | Modulus
    ;

// Arithmetic: Unary Prefix
prefixUnaryExpression
    : prefixUnaryOperator* postfixUnaryExpression
    ;

prefixUnaryOperator
    : PlusPlus
    | MinusMinus
    | Plus
    | Minus
    ;

// Arithmetic: Unary Postfix
postfixUnaryExpression
    : primaryExpression postfixUnarySuffix*
    | targetSelector navigationSuffix*
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
    : LessThan lineTerminators type (lineTerminators Comma lineTerminators type)* (
        lineTerminators Comma
    )? lineTerminators GreaterThan
    ;

callSuffix
    : typeArguments? valueArguments
    ;

indexSuffix
    : OpenBracket lineTerminators expression lineTerminators CloseBracket
    ;

navigationSuffix
    : memberAccessOperator lineTerminators simpleIdentifier
    ;

memberAccessOperator
    : Dot
    ;

// Arguments
valueArguments
    : OpenParen lineTerminators (
        valueArgument (lineTerminators Comma lineTerminators valueArgument)* (
            lineTerminators Comma
        )? lineTerminators
    )? CloseParen
    ;

valueArgument
    : (simpleIdentifier lineTerminators Assign lineTerminators | Ellipsis lineTerminators)? expression
    ;

// Primary expressions
primaryExpression
    : parenthesizedExpression
    | simpleIdentifier
    | literalConstant
    | stringLiteral
    ;

parenthesizedExpression
    : OpenParen lineTerminators expression lineTerminators CloseParen
    ;

literalConstant
    : BooleanLiteral
    | NoneLiteral
    | CharacterLiteral
    // Numerics
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
    : StringOpenBrace lineTerminators expression lineTerminators CloseBrace
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
    : StringOpenBrace lineTerminators expression lineTerminators CloseBrace
    ;

// Identifiers
simpleIdentifier
    : Identifier
    /* Soft keywords */
    | Get
    | Set
    | Field
    | TargetSelectorVariable
    ;

identifier
    : simpleIdentifier (lineTerminators Dot simpleIdentifier)*
    ;

// Target selector
targetSelector
    locals[Boolean typeUsed = false, Boolean tagUsed = false, Boolean argsUsed = false, Boolean parentsUsed = false]
    : At targetSelectorVariable (
        lineTerminators targetSelectorSuffix[$typeUsed, $tagUsed, $argsUsed, $parentsUsed]
    )* lineTerminators
    | At (
        lineTerminators targetSelectorSuffix[$typeUsed, $tagUsed, $argsUsed, $parentsUsed]
    )+ lineTerminators
    ;

targetSelectorVariable
    : TargetSelectorVariable
    ;

targetSelectorSuffix[Boolean typeUsed, Boolean tagUsed, Boolean argsUsed, Boolean parentsUsed]
    : {!$typeUsed}? Colon lineTerminators {this.PushMode(MinecraftMode);} m_targetSelectorType {this.PopMode();}    # targetSelectorSuffixType
    | {!$tagUsed}? Apostrophe lineTerminators {this.PushMode(MinecraftMode);} m_targetSelectorTag {this.PopMode();} # targetSelectorSuffixTag
    | {!$argsUsed}? targetSelectorArguments                                                                         # targetSelectorSuffixArgs
    | {!$parentsUsed}? targetSelectorParents                                                                        # targetSelectorSuffixParents
    ;

//    | OpenParen lineTerminators (
//        expression (lineTerminators Comma lineTerminators expression)* (lineTerminators Comma)? lineTerminators
//    )? CloseParen

targetSelectorArguments
    : OpenBracket lineTerminators {this.PushMode(MinecraftMode);} (
        m_targetSelectorArgumentValuePair {this.PopMode();} (
            lineTerminators Comma lineTerminators {this.PushMode(MinecraftMode);} m_targetSelectorArgumentValuePair {this.PopMode();}
        )* (lineTerminators Comma)? lineTerminators {this.PushMode(MinecraftMode);}
    )? {this.PopMode();} CloseBracket
    ;

targetSelectorParents
    : OpenParen lineTerminators (
        targetSelectorParent (lineTerminators Comma lineTerminators targetSelectorParent)* (
            lineTerminators Comma
        )? lineTerminators
    )? CloseParen
    ;

targetSelectorParent
    : identifier
    ;

//
// Section: Minecraft
//

// Argument Types
// https://minecraft.fandom.com/wiki/Argument_types
m_entity
    : m_name
    | m_targetSelector
    | m_uuid
    ;

// Name
// - contains only `0-9`, `A-Z`, `a-z`, `_`, `-`, `.` and `+`
m_name
    : M_Name
    | M_NameLikeUUID
    | M_NameLikeDoublePrefixed
    | M_NameLikeFloat
    | M_NameLikeDouble
    | M_NameLikeDecimal
    | M_NameLikeHexadecimal
    | m_namespace
    // Letters
    | M_UpperLetterA
    | M_UpperLetterB
    | M_UpperLetterC
    | M_UpperLetterD
    | M_UpperLetterE
    | M_UpperLetterF
    | M_UpperLetterG
    | M_UpperLetterH
    | M_UpperLetterI
    | M_UpperLetterJ
    | M_UpperLetterK
    | M_UpperLetterL
    | M_UpperLetterM
    | M_UpperLetterN
    | M_UpperLetterO
    | M_UpperLetterP
    | M_UpperLetterQ
    | M_UpperLetterR
    | M_UpperLetterS
    | M_UpperLetterT
    | M_UpperLetterU
    | M_UpperLetterV
    | M_UpperLetterW
    | M_UpperLetterX
    | M_UpperLetterY
    | M_UpperLetterZ
    ;

// Scoreboard
// https://minecraft.fandom.com/wiki/Scoreboard
m_scoreboardTag
    : m_name
    ;

// Target selectors
// https://minecraft.fandom.com/wiki/Target_selectors
m_targetSelector
    : M_At m_targetSelectorVariable m_targetSelectorArgumentValuePairs
    ;

m_targetSelectorVariable
    : M_LowerLetterP
    | M_LowerLetterR
    | M_LowerLetterA
    | M_LowerLetterE
    | M_LowerLetterS
    ;

m_targetSelectorArgumentValuePairs
    : M_OpenBracket lineTerminators (
        m_targetSelectorArgumentValuePair (
            lineTerminators M_Comma lineTerminators m_targetSelectorArgumentValuePair
        )* (lineTerminators M_Comma)? lineTerminators
    )? M_CloseBracket
    ;

m_targetSelectorArgumentValuePair
    : m_targetSelectorArgument lineTerminators M_Assign lineTerminators m_targetSelectorValue
    ;

m_targetSelectorArgument
    : m_namespace
    ;

m_targetSelectorValue
    : M_Exclamation? m_targetSelectorValuePrimary
    ;

m_targetSelectorValuePrimary
    : nbtTag
    | m_tag
    | m_resourceLocation
    | m_scoreboardTag
    ;

m_targetSelectorType
    : M_Exclamation? m_targetSelectorTypePrimary
    ;

m_targetSelectorTypePrimary
    : m_resourceLocation
    | m_tag
    ;

m_targetSelectorTag
    : M_Exclamation? m_targetSelectorTagPrimary
    ;

m_targetSelectorTagPrimary
    : m_scoreboardTag
    ;

// Raw JSON text format
// https://minecraft.fandom.com/wiki/Raw_JSON_text_format
m_rawJsonText
    : m_jsonString
    | m_jsonBoolean
    | m_jsonNumber
    | m_jsonArray
    | m_jsonObject
    ;

m_jsonString
    : M_DoubleQuotedString
    ;

m_jsonBoolean
    : M_True
    | M_False
    ;

m_jsonNumber
    : M_Decimal
    | M_Double
    ;

m_jsonArray
    : M_OpenBracket lineTerminators (
        m_jsonArrayElement (lineTerminators M_Comma lineTerminators m_jsonArrayElement)* (
            lineTerminators M_Comma
        )? lineTerminators
    )? M_CloseBracket
    ;

m_jsonArrayElement
    : m_rawJsonText
    ;

m_jsonObject
    : M_OpenBrace lineTerminators (
        m_jsonObjectItem (lineTerminators M_Comma lineTerminators m_jsonObjectItem)* (
            lineTerminators M_Comma
        )? lineTerminators
    )? M_CloseBrace
    ;

m_jsonObjectItem
    : m_jsonObjectKey lineTerminators M_Colon lineTerminators m_jsonObjectValue
    ;

m_jsonObjectKey
    : m_doubleQuotedStringLiteral
    ;

m_jsonObjectValue
    : m_rawJsonText
    ;

// Universally Unique Identifier
// https://minecraft.fandom.com/wiki/Universally_unique_identifier
m_uuid
    : M_UUID
    | M_Hexadecimal
    | M_Decimal
    ;

// Tag
// https://minecraft.fandom.com/wiki/Tag
m_tag
    : M_Hashtag m_resourceLocation
    ;

// Resource Location
// https://minecraft.fandom.com/wiki/Resource_location
m_resourceLocation
    : m_namespace lineTerminators M_Colon lineTerminators m_namespace (
        lineTerminators M_Slash lineTerminators m_namespace
    )*
    | m_namespace
    ;

m_namespace
    : M_Namespace
    | M_NamespaceLikeUUID
    | M_NamespaceLikeDoublePrefixed
    | M_NamespaceLikeFloat
    | M_NamespaceLikeDouble
    | M_NamespaceLikeDecimal
    | M_NamespaceLikeHexadecimal
    | M_UUID
    | M_DoublePrefixed
    | M_Float
    | M_Double
    | M_Decimal
    | M_Hexadecimal
    | M_True
    | M_False
    // Letters
    | M_LowerLetterA
    | M_LowerLetterB
    | M_LowerLetterC
    | M_LowerLetterD
    | M_LowerLetterE
    | M_LowerLetterF
    | M_LowerLetterG
    | M_LowerLetterH
    | M_LowerLetterI
    | M_LowerLetterJ
    | M_LowerLetterK
    | M_LowerLetterL
    | M_LowerLetterM
    | M_LowerLetterN
    | M_LowerLetterO
    | M_LowerLetterP
    | M_LowerLetterQ
    | M_LowerLetterR
    | M_LowerLetterS
    | M_LowerLetterT
    | M_LowerLetterU
    | M_LowerLetterV
    | M_LowerLetterW
    | M_LowerLetterX
    | M_LowerLetterY
    | M_LowerLetterZ
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
    ;

nbtByteTag
    : M_Decimal (M_LowerLetterB | M_UpperLetterB)
    ;

nbtBooleanTag
    : M_True
    | M_False
    ;

nbtShortTag
    : M_Decimal (M_LowerLetterS | M_UpperLetterS)
    ;

nbtIntTag
    : M_Decimal
    ;

nbtLongTag
    : M_Decimal (M_LowerLetterL | M_UpperLetterL)
    ;

nbtFloatTag
    : M_Float
    ;

nbtDoubleTag
    : M_Double
    | M_DoublePrefixed
    ;

nbtStringTag
    : m_doubleQuotedStringLiteral
    ;

nbtListTag
    : M_OpenBracket lineTerminators (
        nbtListTagElement (lineTerminators M_Comma lineTerminators nbtListTagElement)* (
            lineTerminators M_Comma
        )? lineTerminators
    )? M_CloseBracket
    ;

nbtListTagElement
    : nbtTag
    ;

nbtCompoundTag
    : M_OpenBrace lineTerminators (
        nbtCompoundTagItem (lineTerminators M_Comma lineTerminators nbtCompoundTagItem)* (
            lineTerminators M_Comma
        )? lineTerminators
    )? M_CloseBrace
    ;

nbtCompoundTagItem
    : nbtCompoundKey lineTerminators Colon lineTerminators nbtCompoundValue
    ;

nbtCompoundKey
    : m_name
    | m_stringLiteral
    ;

nbtCompoundValue
    : nbtTag
    ;

nbtByteArray
    : M_OpenBracket lineTerminators M_UpperLetterB lineTerminators M_SemiColon lineTerminators (
        nbtByteArrayElement (lineTerminators M_Comma lineTerminators nbtByteArrayElement)* (
            lineTerminators Comma
        )? lineTerminators
    )? M_CloseBracket
    ;

nbtByteArrayElement
    : nbtByteTag
    ;

nbtIntArray
    : M_OpenBracket lineTerminators M_UpperLetterI lineTerminators M_SemiColon lineTerminators (
        nbtIntArrayElement (lineTerminators M_Comma lineTerminators nbtIntArrayElement)* (
            lineTerminators M_Comma
        )? lineTerminators
    )? M_CloseBracket
    ;

nbtIntArrayElement
    : nbtIntTag
    ;

nbtLongArray
    : M_OpenBracket lineTerminators M_UpperLetterL lineTerminators M_SemiColon lineTerminators (
        nbtLongArrayElement (lineTerminators M_Comma lineTerminators nbtLongArrayElement)* (
            lineTerminators M_Comma
        )? lineTerminators
    )? M_CloseBracket
    ;

nbtLongArrayElement
    : nbtLongTag
    ;

// Literals
m_stringLiteral
    : m_doubleQuotedStringLiteral
    | m_singleQuotedStringLiteral
    ;

m_doubleQuotedStringLiteral
    : M_DoubleQuotedString
    ;

m_singleQuotedStringLiteral
    : M_SingleQuotedString
    ;