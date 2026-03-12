package com.cjsdnwls7738.arrowescape

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Android 15 (SDK 35) 이상에서 앱이 전체 화면으로 올바르게 표시되도록 설정합니다.
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }
}
