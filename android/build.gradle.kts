allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    if (project.name != "app") {
        project.evaluationDependsOn(":app")
        if (project.state.executed) {
            val android = project.extensions.findByName("android")
            if (android != null) {
                for (m in android.javaClass.methods) {
                    if ((m.name == "setCompileSdkVersion" || m.name == "compileSdkVersion" || m.name == "setCompileSdk")
                        && m.parameterCount == 1
                        && (m.parameterTypes[0] == java.lang.Integer.TYPE || m.parameterTypes[0] == java.lang.Integer::class.java)) {
                        try {
                            m.invoke(android, 36)
                        } catch (_: Throwable) {}
                    }
                }
            }
        } else {
            afterEvaluate {
                val android = project.extensions.findByName("android") ?: return@afterEvaluate
                for (m in android.javaClass.methods) {
                    if ((m.name == "setCompileSdkVersion" || m.name == "compileSdkVersion" || m.name == "setCompileSdk")
                        && m.parameterCount == 1
                        && (m.parameterTypes[0] == java.lang.Integer.TYPE || m.parameterTypes[0] == java.lang.Integer::class.java)) {
                        try {
                            m.invoke(android, 36)
                        } catch (_: Throwable) {}
                    }
                }
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
