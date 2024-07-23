plugins {
    kotlin("jvm") version "2.0.0"
    antlr
    application
}

group = "org.morj"
version = "0.1-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    // src/main
    implementation("io.github.oshai:kotlin-logging-jvm:5.1.0")
    implementation("ch.qos.logback:logback-classic:1.4.5")
    antlr("org.antlr:antlr4:4.12.0")
    implementation("com.github.ajalt.mordant:mordant:2.7.1")

    // src/test
    testImplementation(kotlin("test"))
}

// JVM toolchain
kotlin {
    jvmToolchain(17)
}

// Tests
tasks.test {
    useJUnitPlatform { excludeTags("LexerSources"); excludeTags("ParserSources") }
}

tasks.register("testSanity", Test::class) {
    group = "verification"
    useJUnitPlatform { includeTags("Sanity") }
}

tasks.register("testLexerSources", Test::class) {
    group = "verification"
    useJUnitPlatform { includeTags("LexerSources") }
    inputs.dir("morj-test-src/lexer-valid")
    inputs.dir("morj-test-src/lexer-invalid")
}

tasks.register("testParserSources", Test::class) {
    group = "verification"
    useJUnitPlatform { includeTags("ParserSources") }
    inputs.dir("morj-test-src/parser-valid")
    inputs.dir("morj-test-src/parser-invalid")
}

// Tasks
val antlrGeneratedSrcDirectory = File("${layout.buildDirectory.get()}/generated-src/antlr/main")
val antlrOutputDirectory = antlrGeneratedSrcDirectory.resolve("org/morj/antlr")

tasks.register("createAntlrDirectories") {
    group = "antlr"
    doLast {
        if (!antlrOutputDirectory.exists()) antlrOutputDirectory.mkdirs()
    }
}

tasks.register<Exec>("formatGrammarFiles") {
    group = "antlr"
    description = "Formats the ANTLR grammar files"
    commandLine("sh", "-c", "antlr-format --config config/antlr-formatter.json -v src/main/antlr/*.g4")
}

tasks.generateGrammarSource {
    group = "antlr"
    dependsOn("createAntlrDirectories")
    dependsOn("formatGrammarFiles")
    arguments.addAll(listOf("-package", "org.morj.antlr", "-visitor", "-long-messages"))
    outputDirectory = antlrOutputDirectory
}

tasks.compileKotlin {
    dependsOn("generateGrammarSource")
}

// Application
application {
    mainClass.set("org.morj.MainKt")
}

// Antlr generated sources
sourceSets["main"].java.srcDirs.add(antlrGeneratedSrcDirectory)
