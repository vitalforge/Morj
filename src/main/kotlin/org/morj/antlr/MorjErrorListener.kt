package org.morj.antlr

import org.antlr.v4.runtime.ConsoleErrorListener
import org.antlr.v4.runtime.RecognitionException
import org.antlr.v4.runtime.Recognizer
import org.antlr.v4.runtime.Token

class MorjErrorListener : ConsoleErrorListener() {
    override fun syntaxError(
        recognizer: Recognizer<*, *>?,
        offendingSymbol: Any?,
        line: Int,
        charPositionInLine: Int,
        msg: String?,
        e: RecognitionException?
    ) {
        val parser = recognizer as? MorjParser ?: throw IllegalArgumentException("Expected MorjLexerWrapper")
        val token = offendingSymbol as? Token ?: return super.syntaxError(
            recognizer, offendingSymbol, line, charPositionInLine, msg, e
        )
        val sourceCode = parser.sourceCode

        val expectedTokens = parser.expectedTokens.toList()
        val tokenNames = parser.vocabulary
        val expectedRules = expectedTokens.map { tokenNames.getDisplayName(it) }

        val lines = sourceCode.lines()
        val startLine = maxOf(1, line - 3)
        val endLine = minOf(lines.size, line + 1)
        val lineNumberWidth = endLine.toString().length

        val stringBuilder = StringBuilder()
        (startLine..endLine).map { lineNum ->
            val lineContent = lines.getOrNull(lineNum - 1) ?: ""
            val lineNumberStr = lineNum.toString().padStart(lineNumberWidth)
            stringBuilder.appendLine("$lineNumberStr | $lineContent")
            if (lineNum == line) {
                val pointerOffset = lineNumberWidth + 3 + charPositionInLine
                val textLength = if (token.type == Token.EOF) 1 else token.text?.length ?: 1
                val pointer = " ".repeat(pointerOffset) + "^".repeat(textLength)
                stringBuilder.append(pointer)
            }
        }

        val errorMessage = buildString {
            appendLine("Error at line $line:${charPositionInLine + 1}")
            appendLine(stringBuilder.toString())
            appendLine("Unexpected ${tokenNames.getSymbolicName(token.type)}: '${token.text}'")
            append("Expected one of: ${expectedRules.joinToString(", ")}")
        }

        System.err.println(errorMessage)
    }
}