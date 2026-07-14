allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory path configuration (Jaise aapke workflows me structured hai)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    // 1. Subproject level par build directory set karna
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    // 2. Evaluation depend on app module
    project.evaluationDependsOn(":app")

    // 3. AGP 8.0+ safe namespace inject patch
    // (Yeh check abhi bhi zaroori hai agar koi doosra minor package fallback namespace miss kare)
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
