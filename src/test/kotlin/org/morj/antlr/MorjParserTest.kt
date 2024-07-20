package org.morj.antlr

import org.antlr.v4.runtime.CharStreams
import org.antlr.v4.runtime.CommonTokenStream
import org.junit.jupiter.api.*
import org.morj.antlr.MorjParser.MorjFileContext
import java.nio.file.Files
import java.nio.file.Paths
import java.util.stream.Stream

// https://ssricardo.github.io/2018/junit-antlr-parser/
internal class MorjParserTest {
    private val srcDir = Paths.get("morj-test-src")
    private fun getAbstractTree(txt: String): MorjFileContext {
        val charStream = CharStreams.fromString(txt)
        val lexer = MorjLexerWrapper(charStream)
        val tokenStream = CommonTokenStream(lexer)
        val parser = MorjParser(tokenStream)
        val tree = parser.morjFile()
        return tree
    }

    // Parser Sources
    @Tag("ParserSources")
    @TestFactory
    fun testValidSources(): Stream<DynamicTest> {
        val files = Files.list(srcDir.resolve("parser-valid")) ?: throw Exception("No valid sources found")
        return files.map { path ->
            DynamicTest.dynamicTest("Valid: ${path.fileName}") {
                val sourceCode = Files.readString(path)
                assertDoesNotThrow { getAbstractTree(sourceCode) }
            }
        }
    }

    @Tag("ParserSources")
    @TestFactory
    fun testInvalidSources(): Stream<DynamicTest> {
        val files = Files.list(srcDir.resolve("parser-invalid")) ?: throw Exception("No invalid sources found")
        return files.map { path ->
            DynamicTest.dynamicTest("Invalid: ${path.fileName}") {
                val sourceCode = Files.readString(path)
                assertThrows<Exception> { getAbstractTree(sourceCode) }
            }
        }
    }

    // Before Commit
    @Nested
    @Tag("BeforeCommit")
    inner class BeforeCommit

    // Other tests
}