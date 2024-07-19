package org.morj.ast

import org.antlr.v4.runtime.Parser
import org.antlr.v4.runtime.ParserRuleContext
import org.antlr.v4.runtime.tree.TerminalNode
import org.antlr.v4.runtime.tree.Tree
import org.antlr.v4.runtime.tree.Trees
import kotlin.reflect.KProperty1
import kotlin.reflect.full.declaredMemberProperties

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
        val properties = t::class.declaredMemberProperties
            .filter { it.name.first().isUpperCase() }
        if (t.isRedundant(properties)) return redundantNodeToPretty(t, properties)
        if (properties.isEmpty()) return propertylessNodeToPretty(t)
        return complexNodeToPretty(t, properties)
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

    private fun Parser.redundantNodeToPretty(t: Tree, properties: List<KProperty1<out Tree, *>>): String {
        val buffer = if (properties.map { it.name }.contains("BUFFER")) {
            properties.first { it.name == "BUFFER" }.getter.call(t)
        } else {
            t.getChild(0)
        }
        return anyToPretty(buffer)
    }

    private fun Parser.propertylessNodeToPretty(t: Tree): String {
        val children = (0..<t.childCount).map(t::getChild)
        return """<${Trees.getNodeText(t, ruleNames.toList())}> {
${children.joinToString("$Eol$") { anyToPretty(it) }.tab()}
}"""  // .trimIndent() will break the code
    }

    private fun Parser.complexNodeToPretty(t: Tree, properties: List<KProperty1<out Tree, *>>): String {
        return """<${Trees.getNodeText(t, ruleNames.toList())}> {
${properties.map { it.name to it.getter.call(t) }.joinToString(Eol) { (k, v) -> "$k: ${anyToPretty(v)}" }.tab()}
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

    // Checking redundant rules
    private val excludeRules = setOf<Int>()

    private fun Tree.isRedundant(properties: List<KProperty1<out Tree, *>>): Boolean {
        val ruleIndex = (this as ParserRuleContext).ruleIndex
        if (ruleIndex in excludeRules) return false
        // Special cases
        if
            return properties.isEmpty() || properties.map { it.name }.contains("BUFFER")
    }

}