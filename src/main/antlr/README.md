# Morj Grammar

Grammar is written using ANTLR 4. It's heavily inspired by these grammars:

- [Jetbrains' Kotlin](https://github.com/Kotlin/kotlin-spec/tree/release/grammar/src/main/antlr)
- [ANTLR's Kotlin](https://github.com/antlr/grammars-v4/tree/7d6622d23d67fa7ff77091bbd055bd70ce53049b/kotlin/kotlin)
- [JavaScript](https://github.com/antlr/grammars-v4/tree/7d6622d23d67fa7ff77091bbd055bd70ce53049b/javascript/javascript)

> If you're using Intellij IDEA, there is a well known issue that ANTLR v4 plugin will try to
> create unnecessary folder `gen`, to avoid this look at
> this [issue](https://github.com/antlr/intellij-plugin-v4/issues/491).
> You can specify generated source directory in external directory (/tmp/antlr4-gen in my case).

## Building the grammar

The most convenient way is to use Gradle task: `gradle generateGrammarSource` (in `antlr` group),
which automatically formats the grammar and builds it in `build/generated-src/antlr/main` directory,
but if you want to format it manually, use `gradle formatGrammarFiles`.

Generated sources are used via `sourceSets` in [build.gradle.kts](../../../build.gradle.kts),
and are located in `org.morj.antlr` package.

## Lexer specification

Complex logic is implemented in [MorjLexerBase.kt](../kotlin/org/morj/antlr/MorjLexerBase.kt), any other
logic is implemented in [MorjLexer.g4](MorjLexer.g4).

### Notes

1. There are few rules which are not used directly in parser (e.g. `IdentifierOrSoftKeyword`), they
   are usually override by upper rules, but can be used explicitly (for syntax highlighters), since
   lexer grammar can be used not only by compilers.
2. Numbers are not allowed to contain zero in the beginning.
3. Strings support unicode escape sequences.
4. Comments are put into `HIDDEN` channel, this is planned to be used in the future.
5. Line continuation works only outside of strings.

## Parser specification

Parser is implemented in [MorjParser.g4](MorjParser.g4), all utils related to Abstract Syntax Tree
are located in [ast directory](../kotlin/org/morj/ast).

In order to
distinguish [Rule Element Labels](https://codeberg.org/UniGrammar/antlr4/src/branch/tool_refactoring/doc/parser-rules.md#rule-element-labels)
by pretty printer from other rule elements, they should start with uppercase letter, e.g.:
`MorjFile: UppercaseRuleElementLabel = rule`. This is because rule elements except labels can't start with uppercase.

There is [a list of best practices for ANTLR parsers](https://tomassetti.me/best-practices-for-antlr-parsers/).

## Printing Tokens and AST

Tokens are printed using [MorjLexerWrapper.kt](../kotlin/org/morj/antlr/MorjLexerWrapper.kt),
and AST is printed using custom [TreeUtils.kt](../kotlin/org/morj/ast/TreeUtils.kt).

> Additional information about pretty printer can be found [here](https://github.com/vitalforge/Morj/issues/1).

### AST pretty printer

Parser grammar consists of terminals and rules. Each terminal is printed using next format: `` `Text` - Type ``.

Rules can be printed in the following ways:

[//]: # (TODO: add example)
