allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// ============================================================================
// AGP 8.0+ PATCH: Purani libraries (jaise disk_space) ka namespace fix karne ke liye
// ============================================================================
subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.library")) {
            extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
                if (namespace == null) {
                    // Agar manifest ka package nahi utha pa raha, toh fallback name set karein
                    namespace = if (project.group.toString().isNotEmpty()) project.group.toString() else "com.fallback.${project.name.replace(":", "")}"
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
