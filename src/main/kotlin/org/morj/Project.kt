package org.morj

import io.github.oshai.kotlinlogging.KotlinLogging
import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import org.morj.antlr.MorjLexerWrapper
import org.morj.antlr.MorjParser
import org.morj.ast.TreeUtils.toPrettyTree

object Project {
    private val logger = KotlinLogging.logger { }

    fun init() {
        logger.info { "Starting Morj" }
        val source: String =
            """
            @(e):zombie'anchored[nbt={"sus": [I; 313, 15]}]
            """.trimIndent()
        val charStream = CharStreams.fromStream(source.byteInputStream())
        val tokenStream = CommonTokenStream(MorjLexerWrapper(charStream))
        val parser = MorjParser(tokenStream)
        val tree = parser.morjFile()
        logger.info { "\n" + parser.toPrettyTree(tree) }
    }
}