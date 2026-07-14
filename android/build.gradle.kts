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
// MERGED SUBPROJECTS BLOCK: Force-Align All JVM Targets to 1.8 (No finalized errors)
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

    // 4. FIX: Kotlin compilation target ko explicitly 1.8 (Java 8) par set karna
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = "1.8"
        }
    }

    // 5. FIX: Java compilation target ko bhi explicitly 1.8 par set karna
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "1.8"
        targetCompatibility = "1.8"
    }

    // 6. AGP 8.0+ safe namespace inject patch (Sirf libraries ke liye)
    val configureNamespace = {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
                // Compile options ko bhi library level par 1.8 par override karna
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_1_8
                    targetCompatibility = JavaVersion.VERSION_1_8
                }

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
