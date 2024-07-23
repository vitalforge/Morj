package org.morj.ast

import com.github.ajalt.mordant.rendering.TextColors.*
import com.github.ajalt.mordant.rendering.TextStyle
import com.github.ajalt.mordant.terminal.Terminal
import org.antlr.v4.runtime.Parser
import org.antlr.v4.runtime.tree.ErrorNode
import org.antlr.v4.runtime.tree.TerminalNode
import org.antlr.v4.runtime.tree.Tree
import org.antlr.v4.runtime.tree.Trees
import org.morj.antlr.MorjParser.AdditiveExpressionContext
import org.morj.antlr.MorjParser.ComparisonContext
import org.morj.antlr.MorjParser.ConjuctionContext
import org.morj.antlr.MorjParser.DisjunctionContext
import org.morj.antlr.MorjParser.InfixFunctionCallContext
import org.morj.antlr.MorjParser.InfixOperationContext
import org.morj.antlr.MorjParser.LiteralConstantContext
import org.morj.antlr.MorjParser.MultiplicativeExpressionContext
import org.morj.antlr.MorjParser.PostfixUnaryExpressionContext
import org.morj.antlr.MorjParser.PrefixUnaryExpressionContext
import org.morj.antlr.MorjParser.PrimaryExpressionContext
import org.morj.antlr.MorjParser.RangeExpressionContext
import org.morj.antlr.MorjParser.SimpleIdentifierContext

@Suppress("unused", "MemberVisibilityCanBePrivate")
object TreeUtils {
    private val terminal = Terminal()
    private val noColor = TextStyle()
    private val Eol: String = System.lineSeparator()
    private const val Indent = "  "

    // Pretty print methods
    @Suppress("UNCHECKED_CAST")
    private fun Parser.anyToPretty(a: Any?, colorful: Boolean = true): String {
        a ?: return nullToPretty(colorful)
        if (a is List<*>) return toPrettyTrees(a as List<Tree>, colorful)
        if (a is Tree) return toPrettyTree(a, colorful)
        throw IllegalArgumentException("Unsupported type: $a")
    }

    fun Parser.toPrettyTrees(l: List<Tree>?, colorful: Boolean = true): String {
        l ?: return nullToPretty(colorful)
        if (l.isEmpty()) return emptyListToPretty(colorful)
        return complexListToPretty(l, colorful)
    }

    fun Parser.toPrettyTree(t: Tree?, colorful: Boolean = true): String {
        t ?: return nullToPretty(colorful)
        if (t is ErrorNode) return errorNodeToPretty(t, colorful)
        if (t is TerminalNode) return terminalToPretty(t, colorful)
        if (t.childCount == 0) return emptyNodeToPretty(t, colorful)
        possiblySpecialNodeToPretty(t, colorful)?.let { return it }
        return complexNodeToPretty(t, colorful)
    }

    @Suppress("UnusedReceiverParameter")
    private fun Parser.nullToPretty(colorful: Boolean = true): String {
        val color = if (colorful) brightRed on black else noColor
        return terminal.render(color("null"))
    }

    private fun Parser.errorNodeToPretty(t: ErrorNode, colorful: Boolean = true): String {
        val color = if (colorful) brightRed.bg else noColor
        return terminal.render(color("! ${terminalToPretty(t, false)} !"))
    }

    @Suppress("UnusedReceiverParameter", "UNUSED_PARAMETER")
    private fun Parser.emptyListToPretty(colorful: Boolean = true): String {
        return "[]"
    }

    private fun Parser.complexListToPretty(l: List<Tree>, colorful: Boolean = true): String {
        return buildString {
            appendLine("[")
            l.forEach { appendLine(anyToPretty(it, colorful).tab()) }
            append("]")
        }
    }

    private fun Parser.terminalToPretty(t: TerminalNode, colorful: Boolean = true): String {
        val color = if (colorful) brightMagenta on black else noColor
        return terminal.render(
            color(
                "`${
                    Trees.getNodeText(t, ruleNames.toList()).oneLine()
                }` - ${vocabulary.getSymbolicName(t.symbol.type)}"
            )
        )
    }

    @Suppress("UNUSED_PARAMETER")
    private fun Parser.emptyNodeToPretty(t: Tree, colorful: Boolean = true): String {
        return "<${Trees.getNodeText(t, ruleNames.toList())}>"
    }

    private fun Parser.possiblySpecialNodeToPretty(t: Tree, colorful: Boolean = true): String? {
        when (t) {
            is DisjunctionContext, is ConjuctionContext, is ComparisonContext,
            is InfixOperationContext, is InfixFunctionCallContext, is RangeExpressionContext,
            is AdditiveExpressionContext, is MultiplicativeExpressionContext,
            is PrefixUnaryExpressionContext, is PostfixUnaryExpressionContext,
            is PrimaryExpressionContext, is LiteralConstantContext,
            is SimpleIdentifierContext
            -> if (t.childCount == 1) return anyToPretty(t.getChild(0), colorful)
        }
        return null
    }

    private fun Parser.complexNodeToPretty(t: Tree, colorful: Boolean = true): String {
        val color = if (colorful) blue else noColor
        val children = (0..<t.childCount).map(t::getChild)
        return buildString {
            appendLine(terminal.render(color("<${Trees.getNodeText(t, ruleNames.toList())}>")) + " {")
            children.forEach { appendLine(anyToPretty(it, colorful).tab()) }
            append("}")
        }
    }

    // String utils
    private fun String.tab(): String {
        return this.lines().joinToString(Eol) { "$Indent$it" }
    }

    private fun String.oneLine(): String {
        // replace newlines
        return Regex("\\r?\\n").replace(this, "<NL>")
    }
}