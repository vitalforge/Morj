package org.morj

import io.github.oshai.kotlinlogging.KotlinLogging
import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import org.morj.antlr.MorjLexerWrapper
import org.morj.antlr.MorjParser
import org.morj.antlr.TreeUtils
import java.util.*


object Project {
    private val logger = KotlinLogging.logger { }

    fun init() {
        logger.info { "Starting Morj" }
        val source: String =
            """
            it
            """.trimIndent()
        val charStream = CharStreams.fromStream(source.byteInputStream())
        val tokenStream = CommonTokenStream(MorjLexerWrapper(charStream))
        val parser = MorjParser(tokenStream)
        val tree = parser.morjFile()
        val ruleNamesList = Arrays.asList(*parser.ruleNames)
        logger.info { "\n" + TreeUtils.toPrettyTree(tree, ruleNamesList) }
    }
}