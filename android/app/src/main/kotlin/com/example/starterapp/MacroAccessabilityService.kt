// android/app/src/main/kotlin/com/example/macro_runner/MacroAccessibilityService.kt
package com.example.macro_runner

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.Context
import android.content.Intent
import android.graphics.Path
import android.graphics.PixelFormat
import android.os.Build
import android.provider.Settings
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.WindowManager
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class MacroAccessibilityService : AccessibilityService() {

    companion object {
        var instance: MacroAccessibilityService? = null
        var isServiceEnabled = false

        fun openAccessibilitySettings(context: Context) {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)
        }
    }

    private lateinit var windowManager: WindowManager
    private var overlayView: View? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        isServiceEnabled = true
    }

    override fun onDestroy() {
        super.onDestroy()
        instance = null
        isServiceEnabled = false
        removeOverlay()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}

    override fun onInterrupt() {}

    fun launchApp(packageName: String) {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        if (intent != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or 
                           Intent.FLAG_ACTIVITY_CLEAR_TOP)
            startActivity(intent)
        }
    }

    fun tapAtCoordinates(x: Float, y: Float) {
        val gestureBuilder = GestureDescription.Builder()
        val path = Path()
        path.moveTo(x, y)
        
        gestureBuilder.addStroke(
            GestureDescription.StrokeDescription(
                path, 
                0, 
                1  // Duration 1ms = tap
            )
        )
        
        dispatchGesture(gestureBuilder.build(), null, null)
    }

    fun swipe(x1: Float, y1: Float, x2: Float, y2: Float, duration: Long) {
        val gestureBuilder = GestureDescription.Builder()
        val path = Path()
        path.moveTo(x1, y1)
        path.lineTo(x2, y2)
        
        gestureBuilder.addStroke(
            GestureDescription.StrokeDescription(path, 0, duration)
        )
        
        dispatchGesture(gestureBuilder.build(), null, null)
    }

    fun inputText(text: String) {
        val root = rootInActiveWindow ?: return
        val focusedNode = findFocusedNode(root)
        
        if (focusedNode != null && focusedNode.isFocused) {
            val args = Bundle()
            args.putCharSequence(
                AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, 
                text
            )
            focusedNode.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, args)
        }
    }

    fun pressBack() {
        performGlobalAction(GLOBAL_ACTION_BACK)
    }

    fun pressHome() {
        performGlobalAction(GLOBAL_ACTION_HOME)
    }

    private fun findFocusedNode(node: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        if (node.isFocused) return node
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            val focused = findFocusedNode(child)
            if (focused != null) return focused
        }
        return null
    }

    // Optional: Coordinate overlay for testing
    fun showCoordinateOverlay() {
        removeOverlay()
        
        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_ACCESSIBILITY_OVERLAY
        } else {
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            100, 100,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
            WindowManager.LayoutParams.FLAG_NOT_TOUCHABLE or
            WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START
        
        // Position the overlay at top-left initially
        overlayView = View(this)
        overlayView?.setBackgroundColor(0x40FF0000.toInt()) // Semi-transparent red
        
        windowManager.addView(overlayView, params)
    }

    fun updateOverlayPosition(x: Int, y: Int) {
        overlayView?.let {
            val params = it.layoutParams as WindowManager.LayoutParams
            params.x = x - 50
            params.y = y - 50
            windowManager.updateViewLayout(it, params)
        }
    }

    private fun removeOverlay() {
        overlayView?.let {
            windowManager.removeView(it)
            overlayView = null
        }
    }
}
