package org.morj.antlr

class MorjParseListener : MorjParserBaseListener() {
    override fun exitTargetSelectorSuffixType(ctx: MorjParser.TargetSelectorSuffixTypeContext?) {
        ctx ?: throw IllegalStateException()
        val targetSelectorContext = ctx.parent as MorjParser.TargetSelectorContext
        targetSelectorContext.typeUsed = true
    }

    override fun exitTargetSelectorSuffixTag(ctx: MorjParser.TargetSelectorSuffixTagContext?) {
        ctx ?: throw IllegalStateException()
        val targetSelectorContext = ctx.parent as MorjParser.TargetSelectorContext
        targetSelectorContext.tagUsed = true
    }

    override fun exitTargetSelectorSuffixArgs(ctx: MorjParser.TargetSelectorSuffixArgsContext?) {
        ctx ?: throw IllegalStateException()
        val targetSelectorContext = ctx.parent as MorjParser.TargetSelectorContext
        targetSelectorContext.argsUsed = true
    }

    override fun exitTargetSelectorSuffixParents(ctx: MorjParser.TargetSelectorSuffixParentsContext?) {
        ctx ?: throw IllegalStateException()
        val targetSelectorContext = ctx.parent as MorjParser.TargetSelectorContext
        targetSelectorContext.parentsUsed = true
    }
}
