package co.idwall.sdk_bridge_flutter

import android.app.Activity
import android.content.Intent
import androidx.annotation.NonNull
import co.idwall.sdk.document.DocumentRequest
import co.idwall.sdk.liveness.LivenessRequest
import co.idwall.sdk.metrics.events.IdwallEvent
import co.idwall.sdk.metrics.events.IdwallEventsHandler
import co.idwall.toolkit.IDwallToolkit
import co.idwall.toolkit.InputType
import co.idwall.toolkit.core.RequestResponse
import co.idwall.toolkit.flow.core.Doc
import co.idwall.toolkit.flow.core.DocumentSide
import co.idwall.toolkit.flow.core.Flow
import co.idwall.toolkit.flow.core.SendType
import co.idwall.sdk.flow.FlowRequest
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener
import io.flutter.plugin.common.PluginRegistry.Registrar

import org.json.JSONObject

/** IdwallSdkFlutterPlugin */
public class IdwallSdkFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, ActivityResultListener {

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventsChannel: BasicMessageChannel<Any>
    private var currentActivity: Activity? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var currentResult: Result? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.flutterEngine.dartExecutor, "idwall_sdk")
        channel.setMethodCallHandler(this)

        eventsChannel = BasicMessageChannel(flutterPluginBinding.flutterEngine.dartExecutor, "idwall_sdk_events", JSONMessageCodec.INSTANCE)
    }

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    private companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "idwall_sdk")
            channel.setMethodCallHandler(IdwallSdkFlutterPlugin())
        }
        const val BRIDGE_NAME = "bridge - flutter";
        const val BRIDGE_VERSION = "3.3.1"
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        this.currentResult = result
        when (call.method) {
            "initialize" -> initialize(call.arguments as String)
            "initializeWithLoggingLevel" -> {
                val args = call.arguments as List<*>
                initializeWithLoggingLevel(args[0] as String, args[1] as String)
            }
            "setupPublicKey" -> result.success(null)
            "enableLivenessFallback" -> enableLivenessFallback(call.arguments as Boolean)
            "startLiveness" -> startLiveness()
            "startFlow" -> {
                val args = call.arguments as List<*>
                val flowType = convertToFlowType(args[0] as String);
                val documentTypes = (args[1] as List<String>).toDocList()
                val documentOptions =(args[2] as List<String>).toInputTypeList()

                startFlow(flowType, documentTypes, documentOptions)
            }
            "requestLiveness" -> requestLiveness()
            "requestDocument" -> {
                val args = call.arguments as List<*>
                val docType = convertToDocType(args[0] as String)
                val docSide = convertToDocSide(args[1] as String)
                val inputType = convertToInputType(args[2] as String)

                requestDocument(docType, docSide, inputType)
            }
            "showTutorialBeforeDocumentCapture" -> showTutorialBeforeDocumentCapture(call.arguments as Boolean)
            "showTutorialBeforeLiveness" -> showTutorialBeforeLiveness(call.arguments as Boolean)
            "sendData" -> {
                val sendType = convertToSendType(call.arguments as String)
                sendData(sendType)
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (resultCode == FlowRequest.SUCCESS_RESULT_CODE && requestCode == IDwallToolkit.IDWALL_REQUEST) {
            if (data?.extras?.containsKey(IDwallToolkit.TOKEN) == true) {
                try {
                    data.getStringExtra(IDwallToolkit.TOKEN)?.let { token ->
                        currentResult?.success(token)
                        return true
                    }
                    currentResult?.error("-1", "Error while creating token", null)
                } catch (e: Exception) {
                    e.printStackTrace()
                    currentResult?.error("-1", "Error while receiving token", null)
                }
            } else {
                currentResult?.error("-1", "Flow cancelled by user", null)
            }
        } else if (resultCode == LivenessRequest.SUCCESS_RESULT_CODE || resultCode == DocumentRequest.SUCCESS_RESULT_CODE) {
            currentResult?.success(true)
        } else {
            currentResult?.error("-1", "Flow cancelled by user", null)
        }
        this.activityBinding?.removeActivityResultListener(this)
        return true
    }

    fun initialize(authKey: String) {
        IDwallToolkit.getInstance().init(currentActivity?.application, authKey)
        configEventsHandler()
        currentResult?.success(null)

        //Technical metrics
        IDwallToolkit.getInstance().setSdkTypeMetric(BRIDGE_NAME)
        IDwallToolkit.getInstance().setBridgeVersion(BRIDGE_VERSION)
    }

    fun initializeWithLoggingLevel(authKey: String, loggingLevel: String = "") {
        val nativeLoggingLevel = convertToLoggingLevel(loggingLevel)

        if (nativeLoggingLevel == null) {
            currentResult?.error("-1", "Unsupported logging level.", null)
            return
        }

        IDwallToolkit.getInstance().init(currentActivity?.application, authKey, nativeLoggingLevel)
        configEventsHandler()
        currentResult?.success(null)
    }

    fun enableLivenessFallback(enabled: Boolean) {
        IDwallToolkit.getInstance().enableLivenessFallback(enabled)
        currentResult?.success(null)
    }

    fun showTutorialBeforeDocumentCapture(showTutorial: Boolean) {
        IDwallToolkit.getInstance().showTutorialBeforeDocumentCapture(showTutorial)
        currentResult?.success(null)
    }

    fun showTutorialBeforeLiveness(showTutorial: Boolean) {
        IDwallToolkit.getInstance().showTutorialBeforeLiveness(showTutorial)
        currentResult?.success(null)
    }

    private fun configEventsHandler() {
        IDwallToolkit.getInstance().setEventsHandler(object : IdwallEventsHandler {
            override fun onEvent(event: IdwallEvent) {
                currentActivity?.runOnUiThread {
                    val idwallEvent = JSONObject()
                    idwallEvent.put("name", event.name)
                    val propMap = JSONObject()
                    for (prop in event.properties) {
                        propMap.put(prop.key, prop.value)
                    }
                    idwallEvent.put("properties", propMap)
                    eventsChannel.send(idwallEvent)
                }
            }
        })
    }

    fun startLiveness() {
        if (currentActivity != null) {
            this.activityBinding?.addActivityResultListener(this)
            IDwallToolkit.getInstance().startFlow(currentActivity, Flow.LIVENESS)
        } else {
            currentResult?.error("-1", "No activity found.", null)
        }
    }

    fun startFlow(flowType: Flow?, documentTypes: List<Doc>, documentOptions: List<InputType>) {

        if (currentActivity != null) {
            this.activityBinding?.addActivityResultListener(this)
            IDwallToolkit.getInstance().startFlow(
                currentActivity,
                flowType,
                documentTypes,
                documentOptions
            )
        } else {
            currentResult?.error("-1", "No activity found.", null)
        }
    }

    fun requestLiveness() {
        if (currentActivity != null) {
            this.activityBinding?.addActivityResultListener(this)
            IDwallToolkit.getInstance().requestLiveness(currentActivity)
        } else {
            currentResult?.error("-1", "No activity found.", null)
        }
    }

    fun requestDocument(documentType: Doc?, documentSide: DocumentSide?, inputType: InputType?) {
        if (currentActivity != null) {
            this.activityBinding?.addActivityResultListener(this)
            IDwallToolkit.getInstance().requestDocument(
                currentActivity,
                documentType,
                inputType,
                documentSide
            )
        } else {
            currentResult?.error("-1", "No activity found.", null)
        }
    }

    fun sendData(sendType: SendType?) {
        IDwallToolkit.getInstance().send(object : RequestResponse {
            override fun onSuccess(token: String?) {
                currentResult?.success(token)
            }

            override fun onFailure(error: String?) {
                currentResult?.error("-1", error, null)
            }

            override fun onProgress(progress: Float) {
            }

        }, sendType)
    }

    override fun onDetachedFromActivity() {
        this.activityBinding?.removeActivityResultListener(this)
        this.currentActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.currentActivity = binding.activity
        this.activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }
}
