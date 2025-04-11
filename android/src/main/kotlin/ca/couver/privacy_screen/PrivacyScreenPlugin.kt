package ca.couver.privacy_screen

import android.app.Activity
import android.content.Context
import android.view.WindowManager.LayoutParams
import androidx.annotation.NonNull
import androidx.lifecycle.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** PrivacyScreenPlugin */
class PrivacyScreenPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, DefaultLifecycleObserver {

    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private lateinit var context: Context
    private var autoLockAfterSeconds: Number = -1
    private var timeEnteredBackground: Long = 0

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "channel.couver.privacy_screen")
        channel.setMethodCallHandler(this)
        this.context = flutterPluginBinding.applicationContext
        ProcessLifecycleOwner.get().lifecycle.addObserver(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "updateConfig" -> {
                activity?.window?.let { window ->
                    if (call.argument<Boolean>("enableSecureAndroid") == true) {
                        window.addFlags(LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(LayoutParams.FLAG_SECURE)
                    }
                }
                autoLockAfterSeconds = call.argument<Number>("autoLockAfterSecondsAndroid") ?: -1
                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        ProcessLifecycleOwner.get().lifecycle.removeObserver(this)
    }

    // DefaultLifecycleObserver

    private fun judgeLock() {
        if (autoLockAfterSeconds.toLong() >= 0 &&
            timeEnteredBackground > 0 &&
            (System.currentTimeMillis() - timeEnteredBackground) / 1000 > autoLockAfterSeconds.toLong()
        ) {
            channel.invokeMethod("lock", null)
        }
        timeEnteredBackground = 0
    }

    override fun onResume(owner: LifecycleOwner) {
        channel.invokeMethod("onLifeCycle", "onResume")
        judgeLock()
        super.onResume(owner)
    }

    override fun onDestroy(owner: LifecycleOwner) {
        channel.invokeMethod("onLifeCycle", "onDestroy")
        super.onDestroy(owner)
    }

    override fun onPause(owner: LifecycleOwner) {
        channel.invokeMethod("onLifeCycle", "onPause")
        timeEnteredBackground = System.currentTimeMillis()
        super.onPause(owner)
    }

    override fun onStop(owner: LifecycleOwner) {
        channel.invokeMethod("onLifeCycle", "onStop")
        super.onStop(owner)
    }

    override fun onStart(owner: LifecycleOwner) {
        channel.invokeMethod("onLifeCycle", "onStart")
        super.onStart(owner)
    }

    override fun onCreate(owner: LifecycleOwner) {
        channel.invokeMethod("onLifeCycle", "onCreate")
        super.onCreate(owner)
    }

    // ActivityAware

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        this.activity = null
    }
}