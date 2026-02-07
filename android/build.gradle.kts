plugins {
    id("com.google.gms.google-services") version "4.4.4" apply false
}

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

subprojects {
    project.configurations.all {
        resolutionStrategy.eachDependency {
            // --- FIX START: Force compatible androidx.activity version ---
            if (requested.group == "androidx.activity") {
                useVersion("1.9.3")
            }

            if (requested.group == "androidx.core") {
                // ONLY apply the fix to "core" and "core-ktx"
                if (requested.name == "core" || requested.name == "core-ktx") {
                    useVersion("1.15.0")
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
