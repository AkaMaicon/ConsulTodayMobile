allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Set custom build directory for root project
val newBuildDir = rootProject.layout.projectDirectory.dir("../../build")
rootProject.buildDir = newBuildDir.asFile

subprojects {
    // Set custom build directory for subprojects
    buildDir = "${rootProject.buildDir}/$name"
}

tasks.register<Delete>("clean") {
    delete(rootProject.buildDir)
}
