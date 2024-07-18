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
