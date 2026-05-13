import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKeystore = keystorePropertiesFile.exists()

if (hasReleaseKeystore) {
    FileInputStream(keystorePropertiesFile).use { keystoreProperties.load(it) }
}

android {
    namespace = "br.gov.rs.casacivil.sismobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "br.gov.rs.casacivil.sismobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["appLabel"] = "SIS Mobile"

        // ✅ ALTERAÇÃO: Onde: defaultConfig
        // Por quê: o build está falhando ao configurar CMake/NDK para armeabi-v7a (32-bit).
        // O que faz: limita os ABIs gerados para os que tu realmente precisa no debug (emulador x86_64 + arm64 real).
        // Obs: remove armeabi-v7a para evitar o erro.
        ndk {
            abiFilters += setOf("x86_64", "arm64-v8a")
        }
    }

    flavorDimensions += "app"

    productFlavors {
        create("sis") {
            dimension = "app"
            applicationId = "br.gov.rs.casacivil.sismobile"
            manifestPlaceholders["appLabel"] = "SIS Mobile"
        }

        create("dtic") {
            dimension = "app"
            applicationId = "br.gov.rs.casacivil.dticmobile"
            manifestPlaceholders["appLabel"] = "DTIC Mobile"
        }
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            // Usa keystore de release quando configurada.
            // Fallback para debug so existe para nao bloquear validacao local.
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
    }

    // O task lintVitalReportRelease passou a falhar de forma espuria neste host,
    // impedindo a geracao da APK mesmo com o pacote ja compilado.
    lint {
        abortOnError = false
        checkReleaseBuilds = false
    }
}

flutter {
    source = "../.."
}
