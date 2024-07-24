package org.morj

import io.github.oshai.kotlinlogging.KotlinLogging
import org.morj.antlr.*
import org.morj.ast.TreeUtils.toPrettyTree

object Project {
    private val logger = KotlinLogging.logger { }

    fun init() {
        logger.info { "Starting Morj" }
        val source: String =
            """
            @'inRaund( onGround )
            """.trimIndent()

        // Lexer
        val charStream = MorjCharStream(source)
        val tokenStream = MorjTokenStream(MorjLexerWrapper(charStream))

        // Parser
        val parser = MorjParser(tokenStream)
        parser.overrideErrorListeners(MorjErrorListener())
        parser.overrideParseListeners(MorjParseListener())

        val tree = parser.morjFile()
        logger.info { "\n" + parser.toPrettyTree(tree) }
    }
}