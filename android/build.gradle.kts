allprojects {
    repositories {
        // 官方仓库
        google()
        mavenCentral()
        
        // 优先使用国内镜像源提高速度
        maven { 
            url = uri("https://maven.aliyun.com/repository/google")
        }
        maven { 
            url = uri("https://maven.aliyun.com/repository/public")
        }
        maven { 
            url = uri("https://maven.aliyun.com/repository/gradle-plugin")
        }
        
        // JitPack（如有需要的第三方库）
        maven { url = uri("https://jitpack.io") }
    }
}

// ============================================================
// 🔑 为所有子项目配置namespace（AGP 8.4兼容方式）
// ============================================================
subprojects {
    apply(plugin = "com.android.library")
    
    configure<com.android.build.gradle.LibraryExtension> {
        namespace = "com.uyghurtranslator.${project.name.replace("-", "_")}"
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
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
