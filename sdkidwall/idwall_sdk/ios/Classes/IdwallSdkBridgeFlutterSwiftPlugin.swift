import Flutter
import UIKit
import IDwallToolkit

public class IdwallSdkBridgeFlutterPluginSwift: NSObject, FlutterPlugin, IDwallEventsHandler {
    static var channelMessage: FlutterBasicMessageChannel?
    private static var isCallback = false // TODO:remove this when sdk ios make support to this fix
    let BRIDGE_NAME = "bridge - Flutter"
    let BRIDGE_VERSION = "3.3.1"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "idwall_sdk", binaryMessenger: registrar.messenger())
        let instance = IdwallSdkBridgeFlutterPluginSwift()
        registrar.addMethodCallDelegate(instance, channel: channel)
        channelMessage = .init(name: "idwall_sdk_events", binaryMessenger: registrar.messenger(), codec: FlutterJSONMessageCodec.sharedInstance())
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if IdwallSdkBridgeFlutterPluginSwift.isCallback { return } // TODO:remove this when sdk ios make support to this fix
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let method = PublicMethods(rawValue: call.method) else { result(FlutterMethodNotImplemented); return }
            let args = call.arguments
            switch method {
            case .initialize:
                guard let authKey = args as? String else { result(FlutterMethodNotImplemented); return; }
                self.initialize(authkey: authKey)
                result(nil)
            case .setupPublicKey:
                guard let publicKeyHash = args as? Array<String> else { result(FlutterMethodNotImplemented); return; }
                self.setupPublicKey(publicKeysHashs: publicKeyHash)
                result(nil)
            case .initializeWithLoggingLevel:
                guard let casted = args as? Array<String>,
                      let authKey = casted.first,
                      let level = HelperFunctions.sharedInstance.asLogginLevel(any: casted.dropFirst().first) else { result(FlutterMethodNotImplemented); return; }
                self.initializeWithLoggingLevel(authkey: authKey, level: level)
                result(nil)
            case .enableDevMode:
                guard let flag = args as? Bool else { result(FlutterMethodNotImplemented); return; }
                self.enableDevMode(flag)
                result(nil)
            case .enableLivenessFallback:
                guard let flag = args as? Bool else { result(FlutterMethodNotImplemented); return; }
                self.enableLivenessFallback(flag)
                result(nil)
            case .showTutorialBeforeDocumentCapture:
                guard let flag = args as? Bool else { result(FlutterMethodNotImplemented); return; }
                self.showTutorialBeforeDocumentCapture(flag)
                result(nil)
            case .showTutorialBeforeLiveness:
                guard let flag = args as? Bool else { result(FlutterMethodNotImplemented); return; }
                self.showTutorialBeforeLiveness(flag)
                result(nil)
            case .startFlow:
               guard let casted = args as? Array<Any>,
                     let flowType = HelperFunctions.sharedInstance.asFlowType(flow: casted.first! as? String),
                     let type = casted[1] as? Array<String>,
                     let input = casted[2] as? Array<String> else { result(FlutterMethodNotImplemented); return; }
                self.startFlow(flowType: flowType, documentType: type, documentOption: input, result: result)
            case .startLiveness:
                self.startLiveness(result: result)
            case .requestLiveness:
                self.requestLiveness(result: result)
            case .requestDocument:
                guard let casted = args as? Array<String>,
                      let type = HelperFunctions.sharedInstance.asDocumentType(type: casted[0]),
                      let side = HelperFunctions.sharedInstance.asDocumentSide(side: casted[1]),
                      let input = HelperFunctions.sharedInstance.asIDDocInputType(input: casted[2]) else { result(FlutterMethodNotImplemented); return; }
                self.requestDocument(documentType: type, documentSide: side, documentOption: input, result: result)
            case .sendData:
                guard let casted = args as? String,
                      let send = HelperFunctions.sharedInstance.asSendType(send: casted) else { result(FlutterMethodNotImplemented); return; }
                self.sendData(type: send, result: result)
            }
        }
    }
    
    func initialize(authkey: String) {
        _ = IDwallToolkitSettings.sharedInstance().initWithAuthKey(authkey)
        IDwallToolkitSettings.sharedInstance().setEventHandler(self)

        //Techinical Metrics
        IDwallToolkitSettings.sharedInstance().setSdkType(BRIDGE_NAME)
        IDwallToolkitSettings.sharedInstance().setBridgeVersion(BRIDGE_VERSION)

    }
    
    func setupPublicKey(publicKeysHashs: [String]) {
        IDwallToolkitSettings.sharedInstance().setupIDWallPublicKey(publicKeysHashs)
    }
    
    func initializeWithLoggingLevel(authkey: String, level: IDLoggingLevel) {
        _ = IDwallToolkitSettings.sharedInstance().initWithAuthKey(authkey)
        IDwallToolkitSettings.sharedInstance().setLoggingLevel(level)
        IDwallToolkitSettings.sharedInstance().setEventHandler(self)

        //Techinical Metrics
        IDwallToolkitSettings.sharedInstance().setSdkType(BRIDGE_NAME)
        IDwallToolkitSettings.sharedInstance().setBridgeVersion(BRIDGE_VERSION)

    }

    func enableDevMode(_ flag: Bool) {
        IDwallToolkitSettings.sharedInstance().enableDeveloperMode(flag)
    }

    func enableLivenessFallback(_ flag: Bool) {
        IDwallToolkitSettings.sharedInstance().faceFallbackActivated(flag)
    }
    
    func showTutorialBeforeDocumentCapture(_ flag: Bool) {
        IDwallToolkitSettings.sharedInstance().setDocumentTutorialEnabled(flag)
    }
    
    func showTutorialBeforeLiveness(_ flag: Bool) {
        IDwallToolkitSettings.sharedInstance().setLivenessTutorialEnabled(flag)
    }
    
    func startLiveness(result: @escaping FlutterResult) {
        IdwallSdkBridgeFlutterPluginSwift.isCallback = true 
        IDwallToolkitManager.sharedInstance().startFlow(.Liveness) { (value, error) in
            IdwallSdkBridgeFlutterPluginSwift.isCallback = false
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
            } else if let token = value?["token"] {
                result(token)
            } else {
                result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
            }
        }
    }
    
    func startFlow(flowType: IDFlowType, documentType: Array<String>, documentOption: Array<String>, result: @escaping FlutterResult) {
        IdwallSdkBridgeFlutterPluginSwift.isCallback = true
        IDwallToolkitManager.sharedInstance().startFlow(flowType,
                                                        withDocuments: documentType,
                                                        andInputOptions: documentOption) { (value, error) in
            IdwallSdkBridgeFlutterPluginSwift.isCallback = false
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
            } else if let token = value?["token"] {
                result(token)
            } else {
                result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
            }
        }
    }
    
    func requestDocument(documentType: IDDocumentType, documentSide: IDDocSide?, documentOption: IDDocInputType, result: @escaping FlutterResult) {
        IdwallSdkBridgeFlutterPluginSwift.isCallback = true
        IDwallToolkitManager.sharedInstance().requestDocument(withDocument: documentType,
                                                              inputOption: documentOption,
                                                              documentSide: documentSide) { (value, error) in
            IdwallSdkBridgeFlutterPluginSwift.isCallback = false
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
                return
            }
            result(value)
        }
    }
    
    func requestLiveness(result: @escaping FlutterResult) {
        IdwallSdkBridgeFlutterPluginSwift.isCallback = true
        IDwallToolkitManager.sharedInstance().requestLiveness { (value, error) in
            IdwallSdkBridgeFlutterPluginSwift.isCallback = false
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
                return
            }
            result(value)
        }
    }
    
    func sendData(type: IDWallSend, result: @escaping FlutterResult) {
        IDwallToolkitManager.sharedInstance().send(type: type) { (value, error) in
            if let error = error as NSError? {
                result(FlutterError(code: "\(error.code)", message: error.localizedDescription, details: nil))
            } else if let token = value?["token"] {
                result(token)
            } else {
                result(FlutterError(code: "-1", message: "Unexpected error no token was returned", details: nil))
            }
        }
    }
    
    
    public func onEvent(_ event: IDwallEvent) {
        let msg: [String : Any] = ["name": event.name, "properties": event.properties]
        IdwallSdkBridgeFlutterPluginSwift.channelMessage?.sendMessage(msg)
    }
    
    enum PublicMethods: String {
        case initialize
        case setupPublicKey
        case initializeWithLoggingLevel

        case enableDevMode
        case enableLivenessFallback
        case showTutorialBeforeDocumentCapture
        case showTutorialBeforeLiveness
        
        case startLiveness
        case startFlow
        
        case requestLiveness
        case requestDocument
        
        case sendData
    }
}
