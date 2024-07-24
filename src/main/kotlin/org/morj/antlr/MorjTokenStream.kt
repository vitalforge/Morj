package org.morj.antlr

import io.github.oshai.kotlinlogging.KotlinLogging
import org.antlr.v4.runtime.CommonTokenStream
import org.antlr.v4.runtime.Lexer
import org.antlr.v4.runtime.TokenSource

@Suppress("MemberVisibilityCanBePrivate")
class MorjTokenStream(tokenSource: TokenSource) : CommonTokenStream(tokenSource) {
    private val logger = KotlinLogging.logger { }

    // Properties
    internal val morjLexer = tokenSource as MorjLexer
    internal val morjCharStream = morjLexer.morjCharStream
    internal val sourceCode: String = morjLexer.sourceCode

    // Used after switching lexer mode
    fun reproduceToken() {
        val pointerToken = get(p)
        tokenSource.inputStream.seek(pointerToken.startIndex)
        (tokenSource as Lexer).line = pointerToken.line
        (tokenSource as Lexer).charPositionInLine = pointerToken.charPositionInLine
        // Removing tokens
        val tokenAmount = tokens.size
        repeat(tokenAmount - p) {
            val currentToken = tokens.last()
            logger.debug { "Removing token                Type! ${MorjParser.VOCABULARY.getSymbolicName(currentToken.type)}" }
            tokens.removeLast()
        }
        // Adding tokens
        repeat(tokenAmount - p) {
            (tokenSource as Lexer)._hitEOF = false  // In case of EOF
            val newToken = morjLexer.nextToken()
            tokens.add(newToken)
        }
    }
}