package org.morj.antlr

import org.antlr.v4.runtime.CharStream
import org.antlr.v4.runtime.Lexer
import org.antlr.v4.runtime.Token

@Suppress("FunctionName", "unused")
abstract class MorjLexerBase(input: CharStream) : Lexer(input) {
    private var lastToken: Token? = null

    override fun nextToken(): Token {
        val token = super.nextToken()
        if (token.channel == Token.DEFAULT_CHANNEL)
            lastToken = token
        return token
    }

    // https://stackoverflow.com/questions/53504903/parse-string-antlr/53524929#53524929
    protected fun IsMissingBrace() {
        if (_modeStack.peek() != DEFAULT_MODE) TODO("Add error message")
    }

    protected fun IsStartOfFile(): Boolean {
        return lastToken == null
    }
}