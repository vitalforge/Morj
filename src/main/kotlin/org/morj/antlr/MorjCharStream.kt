package org.morj.antlr

import org.antlr.v4.runtime.CharStream
import org.antlr.v4.runtime.CharStreams

class MorjCharStream(
    // Properties
    internal val sourceCode: String
) : CharStream by CharStreams.fromStream(sourceCode.byteInputStream())
