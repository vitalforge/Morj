package org.morj.antlr

import org.antlr.v4.runtime.ANTLRErrorListener
import org.antlr.v4.runtime.TokenStream
import org.antlr.v4.runtime.Parser
import org.antlr.v4.runtime.tree.ParseTreeListener

@Suppress("unused", "MemberVisibilityCanBePrivate")
abstract class MorjParserBase(input: TokenStream) : Parser(input) {
    // Properties
    internal val morjTokenStream = this._input as MorjTokenStream
    internal val morjLexer = morjTokenStream.morjLexer
    internal val morjCharStream = morjTokenStream.morjCharStream
    internal val sourceCode: String = morjTokenStream.sourceCode

    // Quality of life methods
    fun overrideErrorListeners(errorListener: ANTLRErrorListener) {
        this.removeErrorListeners()
        this.addErrorListener(errorListener)
    }

    fun overrideParseListeners(parseListener: ParseTreeListener) {
        this.removeParseListeners()
        this.addParseListener(parseListener)
    }

    // Switch mode
    fun PushMode(mode: Int) {
        morjLexer.pushMode(mode)
        morjTokenStream.reproduceToken()
    }

    fun PopMode() {
        morjLexer.popMode()
        morjTokenStream.reproduceToken()
    }
}
