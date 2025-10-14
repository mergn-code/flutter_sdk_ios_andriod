package com.mergn.flutter_plugin

import android.app.AlertDialog
import android.app.Application
import android.content.Context
import android.util.Log
import com.mergn.insights.classes.AttributeManager
import com.mergn.insights.classes.EventManager
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** FlutterPlugin */
class FlutterPluginMergn : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    // The MethodChannel that will be used for communication between Flutter and native Android.
    private lateinit var channel: MethodChannel
    private lateinit var applicationContext: Context
    private lateinit var context: Context
    private lateinit var application: Application

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "InitializeSdk" -> {
                    com.mergn.insights.classes.MergnSDK.Companion.initialize(application)
                    result.success("Successfully Initialized")
                }
                "registerAPI" -> {
                    val apiKey = call.argument<String>("apiKey")
                    val eventManager = EventManager()
                    eventManager.registerApiKey(apiKey.toString(), applicationContext)
                    result.success("Registered Successfully")
                }
                "sendEvent" -> {
                    val eventManager = EventManager()
                    val eventName = call.argument<String>("eventName")!!
                    val eventProperties = call.argument<Map<String, String>>("eventProperties")!!
                    eventManager.sendEvent(eventName, eventProperties, context, applicationContext)
                    // Optionally, you can show a dialog (wrapped in exception handling if needed)
                    // showDialog()
                    result.success(null)
                }
                "sendAttribute" -> {
                    val attributeManager = AttributeManager()
                    val attributeName = call.argument<String>("attributeName")!!
                    val attributeValue = call.argument<String>("attributeValue")!!
                    attributeManager.sendAttribute(context, attributeName, attributeValue)
                    result.success(null)
                }
                "login" -> {
                    val eventManager = EventManager()
                    val email = call.argument<String>("email")!!
                    eventManager.login(email, context)
                    result.success(null)
                }
                "fcm_token" -> {
                    val eventManager = EventManager()
                    val token = call.argument<String>("token")!!
                    eventManager.firebaseToken(token, context)
                    result.success(null)
                }
                "getPlatformVersion" -> {
                    result.success("Android ${android.os.Build.VERSION.RELEASE}")
                }
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            // Log the exception and send an error response back to Flutter.
            Log.e("FlutterPluginMergn", "Error handling method call ${call.method}", e)
            result.error("EXCEPTION", e.message, null)
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        try {
            channel = MethodChannel(binding.binaryMessenger, "flutter_plugin")
            channel.setMethodCallHandler(this)
            application = binding.applicationContext as Application
            applicationContext = binding.applicationContext
            Log.d("FlutterPluginMergn", "onAttachedToEngine")
        } catch (e: Exception) {
            Log.e("FlutterPluginMergn", "Error in onAttachedToEngine", e)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        try {
            channel.setMethodCallHandler(null)
            Log.d("FlutterPluginMergn", "onDetachedFromEngine")
        } catch (e: Exception) {
            Log.e("FlutterPluginMergn", "Error in onDetachedFromEngine", e)
        }
    }

    private fun showDialog() {
        try {
            AlertDialog.Builder(context)
                .setTitle("Native Dialog")
                .setMessage("This is a native Android dialog opened from Flutter.")
                .setPositiveButton("OK") { dialog, _ -> dialog.dismiss() }
                .setNegativeButton("Cancel") { dialog, _ -> dialog.dismiss() }
                .show()
        } catch (e: Exception) {
            Log.e("FlutterPluginMergn", "Error showing dialog", e)
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        try {
            context = binding.activity
            application = binding.activity.application
            // Initialize the SDK when attached to an activity.
            com.mergn.insights.classes.MergnSDK.Companion.initialize(application)
            Log.d("FlutterPluginMergn", "onAttachedToActivity")
        } catch (e: Exception) {
            Log.e("FlutterPluginMergn", "Error in onAttachedToActivity", e)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        try {
            context = applicationContext
            Log.d("FlutterPluginMergn", "onDetachedFromActivityForConfigChanges")
        } catch (e: Exception) {
            Log.e("FlutterPluginMergn", "Error in onDetachedFromActivityForConfigChanges", e)
        }
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        try {
            context = binding.activity
            application = binding.activity.application
            Log.d("FlutterPluginMergn", "onReattachedToActivityForConfigChanges")
        } catch (e: Exception) {
            Log.e("FlutterPluginMergn", "Error in onReattachedToActivityForConfigChanges", e)
        }
    }

    override fun onDetachedFromActivity() {
        try {
            context = applicationContext
            Log.d("FlutterPluginMergn", "onDetachedFromActivity")
        } catch (e: Exception) {
            Log.e("FlutterPluginMergn", "Error in onDetachedFromActivity", e)
        }
    }
}
