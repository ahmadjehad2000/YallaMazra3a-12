package com.example.yalla_mazra3a

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Show the native splash immediately
        installSplashScreen()
        super.onCreate(savedInstanceState)
    }
}
