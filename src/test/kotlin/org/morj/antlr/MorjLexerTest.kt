package org.morj.antlr

import org.antlr.v4.runtime.Token
import org.antlr.v4.runtime.CharStreams
import org.junit.jupiter.api.Nested
import org.junit.jupiter.api.Tag
import kotlin.test.Test

internal class MorjLexerTest {
    // https://ssricardo.github.io/2018/junit-antlr-lexer/
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