allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // ============================================================================
    // KOTLIN VERSION FORCING: Purani libraries ka purana Kotlin plugin upgrade karna
    // ============================================================================
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
// MERGED SUBPROJECTS BLOCK: Build dir, evaluation, namespace patch, aur classpath forcing
// ============================================================================
subprojects {
    // 1. Build directory set karna
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // 2. Evaluation depend on app
    project.evaluationDependsOn(":app")

    // 3. Subprojects ke andar bhi buildscript ki dependencies ko force upgrade karna
    buildscript {
        configurations.all {
            resolutionStrategy {
                force("org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.22")
            }
        }
    }

    // 4. AGP 8.0+ safe namespace inject patch
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
