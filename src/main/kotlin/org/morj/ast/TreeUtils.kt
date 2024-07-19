package org.morj.ast

import org.antlr.v4.runtime.Parser
import org.antlr.v4.runtime.ParserRuleContext
import org.antlr.v4.runtime.tree.TerminalNode
import org.antlr.v4.runtime.tree.Tree
import org.antlr.v4.runtime.tree.Trees
import org.morj.antlr.MorjParser

object TreeUtils {
    private val Eol: String = System.lineSeparator()
    private const val Indent = "  "

    fun Parser.toPrettyTree(t: Tree): String {
        if (t is TerminalNode)
            return "`${
                Trees.getNodeText(t, ruleNames.toList()).oneLine()
            }` - ${vocabulary.getSymbolicName(t.symbol.type)}"
        if (t.childCount == 0)
            return "<${Trees.getNodeText(t, ruleNames.toList())}>"
        if (t.isRedundant()) return toPrettyTree(t.getChild(0))
        val children = (0..<t.childCount).map(t::getChild)
        return """<${Trees.getNodeText(t, ruleNames.toList())}> {
${children.joinToString("$Eol$") { toPrettyTree(it) }.tab()}
}"""
    }

    // String Utils
    private fun String.tab(): String {
        return this.lines().joinToString(Eol) { "$Indent$it" }
    }

    private fun String.oneLine(): String {
        // replace newlines
        return Regex("\\r?\\n").replace(this, "<NL>")
    }

    // These are always hidden
    private val reduntantRules = setOf(
        MorjParser.RULE_literalConstant
    )

    private fun Tree.isRedundant(): Boolean {
        if (childCount != 1) return false
        val ruleIndex = (this as? ParserRuleContext)?.ruleIndex ?: throw IllegalArgumentException()
        return ruleIndex in reduntantRules
    }
}