// import org.gradle.api.tasks.Delete

// This line overrides Flutter’s expected build path — REMOVE or COMMENT IT OUT
// subprojects {
//     layout.buildDirectory.set(rootProject.layout.buildDirectory.dir(name))
//     evaluationDependsOn(":app")
// }

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

tasks.register<Delete>("clean") {
    delete(layout.buildDirectory.get())
}
