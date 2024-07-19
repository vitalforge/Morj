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

    // src/test
    testImplementation(kotlin("test"))
}

// JVM toolchain
kotlin {
    jvmToolchain(17)
}

// Tasks
tasks.test {
    useJUnitPlatform()
}

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
    commandLine("antlr-format", "--config", "config/antlr-formatter.json", "-v", "src/main/antlr/*.g4")
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
