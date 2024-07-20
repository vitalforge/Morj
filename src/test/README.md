# Morj Compiler Tests

This topic describes all test tasks for Morj compiler.

## Before Commit

Make sure you've added [git hooks to pre-commit](../../README.md#development).
It runs `./gradlew testBeforeCommit` before each commit, which includes all tests
tagged with `BeforeCommit` tag. These are usually very small tests to check
if compiler can handle the most basic cases.

## Lexer and Parser Sources

To reduce boilerplate code in tests, which tests whether grammar is parsed or not,
use `ParserSources` and `LexerSources` tags.

You can run `./gradlew testLexerSources` and `./gradlew testParserSources` to
run all tests tagged with `LexerSources` and `ParserSources` respectively.

Note, that `./gradlew test` excludes these tests by default.
