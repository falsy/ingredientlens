package com.falsy.ingredientlens

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager
class MainActivity: FlutterActivity() {
    private val CHANNEL = "app/system_ui"
    private var originalFitsSystemWindows: Boolean = false
    
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        // 초기 fitsSystemWindows 상태 저장
        originalFitsSystemWindows = window.decorView.fitsSystemWindows
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "beginAdMode" -> {
                    // 광고 모드 시작 - 시스템 UI가 콘텐츠와 겹치지 않도록 설정
                    window.decorView.fitsSystemWindows = true
                    window.setDecorFitsSystemWindows(true)
                    
                    result.success(true)
                }
                "endAdMode" -> {
                    // 광고 모드 종료 - 원래 설정으로 복원
                    window.decorView.fitsSystemWindows = originalFitsSystemWindows
                    window.setDecorFitsSystemWindows(originalFitsSystemWindows)
                    
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}