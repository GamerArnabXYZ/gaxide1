allprojects {
    repositories {
        google()
        mavenCentral()
    }
    
    // KOTLIN VERSION FORCING: Purani libraries ka plugin upgrade karne ke liye
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
// MERGED SUBPROJECTS BLOCK: Target alignment, namespace aur dependencies patch
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

    // 4. FIX: Java aur Kotlin Compiler target mismatch ko bilkul lock karna (App + Plugins)
    tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
        kotlinOptions {
            jvmTarget = "17" 
        }
    }
    
    tasks.withType<JavaCompile>().configureEach {
        sourceCompatibility = "17"
        targetCompatibility = "17"
    }

    // 5. AGP 8.0+ safe namespace inject aur App/Library compile options override
    val configureNamespace = {
        // Yeh block ab application (app) aur library (plugins) dono par apply hoga
        if (plugins.hasPlugin("com.android.library") || plugins.hasPlugin("com.android.application")) {
            extensions.findByType<com.android.build.gradle.BaseExtension>()?.apply {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
                
                // Namespace sirf plugins/libraries ke liye inject karna hai
                if (plugins.hasPlugin("com.android.library") && namespace == null) {
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
