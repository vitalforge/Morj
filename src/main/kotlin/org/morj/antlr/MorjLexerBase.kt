package org.morj.antlr

import org.antlr.v4.runtime.CharStream
import org.antlr.v4.runtime.Lexer
import org.antlr.v4.runtime.Token

@Suppress("FunctionName", "unused", "MemberVisibilityCanBePrivate")
abstract class MorjLexerBase(input: CharStream) : Lexer(input) {
    // Properties
    internal val morjCharStream = this._input as MorjCharStream
    internal val sourceCode: String = morjCharStream.sourceCode

    // Conditions
    private var lastToken: Token? = null
    override fun nextToken(): Token {
        val token = super.nextToken()
        if (token.channel == Token.DEFAULT_CHANNEL)
            lastToken = token
        return token
    }

    // https://stackoverflow.com/questions/53504903/parse-string-antlr/53524929#53524929
    protected fun IsMissingBrace() {
        TODO("Not yet implemented")
    }

    protected fun IsStartOfFile(): Boolean {
        return lastToken == null
    }

    protected fun IsCommandPossible(): Boolean {
        // No token has been produced yet: at the start of the input,
        // no division is possible, so a command mode _is_ possible.
        val lastToken = this.lastToken ?: return true
        return when (lastToken.type) {
            MorjLexer.LineTerminator -> true
            else -> false
        }
    }
}
