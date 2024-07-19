package org.morj.ast

import org.antlr.v4.runtime.Parser
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
import org.morj.antlr.MorjParser.PrefixUnaryOperatorContext
import org.morj.antlr.MorjParser.PrimaryExpressionContext
import org.morj.antlr.MorjParser.RangeExpressionContext
import org.morj.antlr.MorjParser.SimpleIdentifierContext

@Suppress("unused", "MemberVisibilityCanBePrivate")
object TreeUtils {
    private val Eol: String = System.lineSeparator()
    private const val Indent = "  "

    // Pretty print methods
    @Suppress("UNCHECKED_CAST")
    private fun Parser.anyToPretty(a: Any?): String {
        a ?: return nullToPretty()
        if (a is List<*>) return toPrettyTrees(a as List<Tree>)
        if (a is Tree) return toPrettyTree(a)
        throw IllegalArgumentException("Unsupported type: $a")
    }

    fun Parser.toPrettyTrees(l: List<Tree>?): String {
        l ?: return nullToPretty()
        if (l.isEmpty()) return emptyListToPretty()
        return complexListToPretty(l)
    }

    fun Parser.toPrettyTree(t: Tree?): String {
        t ?: return nullToPretty()
        if (t is TerminalNode) return terminalToPretty(t)
        if (t.childCount == 0) return emptyNodeToPretty(t)
        possiblySpecialNodeToPretty(t)?.let { return it }
        return complexNodeToPretty(t)
    }

    @Suppress("UnusedReceiverParameter")
    private fun Parser.nullToPretty(): String {
        return "null"
    }

    @Suppress("UnusedReceiverParameter")
    private fun Parser.emptyListToPretty(): String {
        return "[]"
    }

    private fun Parser.complexListToPretty(l: List<Tree>): String {
        return """[
${l.joinToString(",$Eol") { anyToPretty(it) }}
]"""  // .trimIndent() will break the code
    }

    private fun Parser.terminalToPretty(t: TerminalNode): String {
        return "`${
            Trees.getNodeText(t, ruleNames.toList()).oneLine()
        }` - ${vocabulary.getSymbolicName(t.symbol.type)}"
    }

    private fun Parser.emptyNodeToPretty(t: Tree): String {
        return "<${Trees.getNodeText(t, ruleNames.toList())}>"
    }

    private fun Parser.possiblySpecialNodeToPretty(t: Tree): String? {
        when (t) {
            is DisjunctionContext, is ConjuctionContext, is ComparisonContext,
            is InfixOperationContext, is InfixFunctionCallContext, is RangeExpressionContext,
            is AdditiveExpressionContext, is MultiplicativeExpressionContext,
            is PrefixUnaryExpressionContext, is PostfixUnaryExpressionContext,
            is PrimaryExpressionContext, is LiteralConstantContext,
            is SimpleIdentifierContext
            -> if (t.childCount == 1) return anyToPretty(t.getChild(0))
        }
        return null
    }

    private fun Parser.complexNodeToPretty(t: Tree): String {
        val children = (0..<t.childCount).map(t::getChild)
        return """<${Trees.getNodeText(t, ruleNames.toList())}> {
${children.joinToString("$Eol$") { anyToPretty(it) }.tab()}
}"""  // .trimIndent() will break the code
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