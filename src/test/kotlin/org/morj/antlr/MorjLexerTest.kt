package org.morj.antlr

import org.antlr.v4.runtime.Token
import org.antlr.v4.runtime.CharStreams
import org.junit.jupiter.api.*
import java.nio.file.Files
import java.nio.file.Paths
import java.util.stream.Stream
import kotlin.test.Test

// https://ssricardo.github.io/2018/junit-antlr-lexer/
internal class MorjLexerTest {
    private val srcDir = Paths.get("morj-test-src")
    @Suppress("SameParameterValue")
    private fun getTokenStream(txt: String): Iterator<Token> = iterator {
        val charStream = CharStreams.fromString(txt)
        val lexer = MorjLexerWrapper(charStream)
        var token = lexer.nextToken()
        while (token.type != Token.EOF) {
            yield(token)
            token = lexer.nextToken()
        }
    }

    @Suppress("SameParameterValue")
    private fun getTokens(txt: String): List<Token> =
        getTokenStream(txt).asSequence().toList()

    // Lexer Sources
    @Tag("LexerSources")
    @TestFactory
    fun testValidSources(): Stream<DynamicTest> {
        val files = Files.list(srcDir.resolve("lexer-valid")) ?: throw Exception("No valid sources found")
        return files.map { path ->
            DynamicTest.dynamicTest("Valid: ${path.fileName}") {
                val sourceCode = Files.readString(path)
                assertDoesNotThrow { getTokens(sourceCode) }
            }
        }
    }

    @Tag("LexerSources")
    @TestFactory
    fun testInvalidSources(): Stream<DynamicTest> {
        val files = Files.list(srcDir.resolve("lexer-invalid")) ?: throw Exception("No invalid sources found")
        return files.map { path ->
            DynamicTest.dynamicTest("Invalid: ${path.fileName}") {
                val sourceCode = Files.readString(path)
                assertThrows<Exception> { getTokens(sourceCode) }
            }
        }
    }

    // Before Commit
    @Nested
    @Tag("BeforeCommit")
    inner class BeforeCommit {
        @Test
        fun `test simple input`() {
            val tokens = getTokens("foo")
            assert(tokens.size == 1)
            assert(tokens[0].type == MorjLexer.Identifier)
        }

        @Test
        fun `test empty input`() {
            assert(getTokens("").isEmpty())
        }
    }

    // Other tests
    @Test
    fun `test single line comment`() {
        val tokens = getTokens("// foo")
        assert(tokens.size == 1)
        assert(tokens[0].type == MorjLexer.SingleLineComment)
    }

    @Test
    fun `test multi line comment`() {
        val tokens = getTokens("/* foo */")
        assert(tokens.size == 1)
        assert(tokens[0].type == MorjLexer.MultiLineComment)
    }
}