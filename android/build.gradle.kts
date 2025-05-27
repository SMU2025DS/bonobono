import org.gradle.api.tasks.Delete
import org.gradle.api.file.Directory

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ 루트 프로젝트의 빌드 디렉토리를 변경
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

// ✅ 서브 프로젝트들의 빌드 디렉토리도 설정
subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// ✅ 의존성 설정
subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ clean task 정의
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
