package org.morj.antlr

import io.github.oshai.kotlinlogging.KotlinLogging
import org.antlr.v4.runtime.CharStream
import org.antlr.v4.runtime.Token

class MorjLexerWrapper(input: CharStream) : MorjLexer(input) {
    private val logger = KotlinLogging.logger { }

    override fun nextToken(): Token {
        val token = super.nextToken()
        if (token.type != Token.EOF)
            logger.debug {
                "Token: ${token.text.replace("\n", "\\n").padEnd(20)}, Type: ${
                    vocabulary.getSymbolicName(
                        token.type
                    )
                }"
            }
        return token
    }
}