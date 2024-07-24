package org.morj.antlr

import org.antlr.v4.runtime.Token
import org.morj.antlr.MorjLexer.*
import org.junit.jupiter.api.*
import java.nio.file.Files
import java.nio.file.Paths
import java.util.stream.Stream
import kotlin.test.Test

// https://ssricardo.github.io/2018/junit-antlr-lexer/
internal class MorjLexerTest {
    private val srcDir = Paths.get("morj-test-src")

    @Suppress("SameParameterValue")
    private fun getTokenStream(txt: String, mode: Int = DEFAULT_MODE): Iterator<Token> = iterator {
        val charStream = MorjCharStream(txt)
        val lexer = MorjLexerWrapper(charStream)
        if (mode != DEFAULT_MODE) lexer.pushMode(mode)
        var token = lexer.nextToken()
        while (token.type != Token.EOF) {
            yield(token)
            token = lexer.nextToken()
        }
        if (mode != DEFAULT_MODE) lexer.popMode()
    }

    @Suppress("SameParameterValue")
    private fun getTokens(txt: String, mode: Int = DEFAULT_MODE): List<Token> =
        getTokenStream(txt, mode).asSequence().toList()

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

    @Nested
    @Tag("Sanity")
    inner class SanityTests {
        @Test
        fun `test simple input`() {
            val tokens = getTokens("foo")
            assert(tokens.size == 1)
            assert(tokens[0].type == Identifier)
        }

        @Test
        fun `test empty input`() {
            assert(getTokens("").isEmpty())
        }
    }

    // Comments
    @Test
    fun `test single line comment`() {
        val tokens = getTokens("// foo")
        assert(tokens.size == 1)
        assert(tokens[0].type == SingleLineComment)
    }

    @Test
    fun `test multi line comment`() {
        val tokens = getTokens("/* foo */")
        assert(tokens.size == 1)
        assert(tokens[0].type == MultiLineComment)
    }

    //
    // Section: Minecraft
    //

    @Nested
    @Tag("Minecraft")
    inner class MinecraftTests {
        @Test
        fun `test namespace`() {
            val tokens = getTokens("21foo.bar-you-are-sus", MinecraftMode)
            assert(tokens.size == 1)
            assert(tokens[0].type == M_NamespaceLikeFloat)
        }

        @Test
        fun `test name`() {
            val tokens = getTokens("something.sus-+Foo", MinecraftMode)
            assert(tokens.size == 1)
            assert(tokens[0].type == M_Name)
        }
    }
}