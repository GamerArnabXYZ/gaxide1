allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // Kotlin version plugin force upgrade
    buildscript {
        configurations.all {
            resolutionStrategy {
                force("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22")
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// ============================================================================
// MERGED SUBPROJECTS BLOCK: Zero finalized properties errors
// ============================================================================
subprojects {
    // 1. Build directory set karna
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // 2. Evaluation depend on app
    project.evaluationDependsOn(":app")

    // 3. Subprojects ke dependencies force upgrade karna
    buildscript {
        configurations.all {
            resolutionStrategy {
                force("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22")
            }
        }
    }

    // 4. FIX: Compiler task settings override bina property lock kiye
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        // Compiler args use karne se finalized variables error nahi dete
        kotlinOptions.freeCompilerArgs += listOf("-jvm-target", "17")
    }

    tasks.withType<JavaCompile>().configureEach {
        // Bina release property finalize kiye target set karne ka safe tareeka
        options.compilerArgs.addAll(listOf("--release", "17"))
    }

    // 5. AGP 8.0+ safe namespace inject patch (Sirf libraries ke liye)
    val configureNamespace = {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
                if (namespace == null) {
                    namespace = if (project.group.toString().isNotEmpty()) {
                        project.group.toString()
                    } else {
                        "com.fallback.${project.name.replace(":", "")}"
                    }
                }
            }
        }
    }

    if (state.executed) {
        configureNamespace()
    } else {
        afterEvaluate {
            configureNamespace()
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
