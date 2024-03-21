import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import './domain/model/document_model.dart';
import './domain/model/log_model.dart';

class IdwallSdk {
  static const MethodChannel _channel = MethodChannel('idwall_sdk');

  static const BasicMessageChannel _eventChannel =
      BasicMessageChannel<dynamic>('idwall_sdk_events', JSONMessageCodec());

/* ------------------------------- Initialize ------------------------------- */

  static Future<dynamic> initialize(String authKey) {
    return _channel.invokeMethod<dynamic>('initialize', authKey);
  }

  static Future<dynamic> initializeWithLoggingLevel(
      String authKey, IdwallLoggingLevel loggingLevel) {
    return _channel.invokeMethod<dynamic>(
      'initializeWithLoggingLevel',
      [authKey, describeEnum(loggingLevel)],
    );
  }

  static Future<dynamic> setupPublic(List<String> publicKeyHash) {
    return _channel.invokeMethod<dynamic>('setupPublicKey', publicKeyHash);
  }

  static void setIdwallEventsHandler(
      Future<dynamic> Function(dynamic)? eventHandler) {
    _eventChannel.setMessageHandler(eventHandler);
  }

  /* -------------------------------- Dev Mode -------------------------------- */

  static Future<dynamic> enableDevMode(bool enabled) {
    return _channel.invokeMethod<dynamic>('enableDevMode', enabled);
  }

  /* -------------------------------- Fallback -------------------------------- */

  static Future<dynamic> enableLivenessFallback(bool enabled) {
    return _channel.invokeMethod<dynamic>('enableLivenessFallback', enabled);
  }

  /* -------------------------------- Tutorial -------------------------------- */

  static Future<dynamic> showTutorialBeforeDocumentCapture(bool showTutorial) {
    return _channel.invokeMethod<dynamic>(
      'showTutorialBeforeDocumentCapture',
      showTutorial,
    );
  }

  static Future<dynamic> showTutorialBeforeLiveness(bool showTutorial) {
    return _channel.invokeMethod<dynamic>(
      'showTutorialBeforeLiveness',
      showTutorial,
    );
  }

/* ------------------------------ Complete Flow ----------------------------- */

  static Future<String?> startLiveness() {
    return _channel.invokeMethod<String?>('startLiveness');
  }

  static Future<String?> startFlow(
      IdwallFlowType flowType,
      List<IdwallDocumentType> documentTypes,
      List<IdwallDocumentOption> documentOptions) async {
    final documentTypesString =
        documentTypes.map((docType) => describeEnum(docType)).toList();

    final documentOptionsString =
        documentOptions.map((docOption) => describeEnum(docOption)).toList();

    return await _channel.invokeMethod<String?>('startFlow', [
      describeEnum(flowType),
      documentTypesString,
      documentOptionsString,
    ]);
  }

/* ----------------------------- Individual flow ---------------------------- */

  static Future<bool?> requestLiveness() {
    return _channel.invokeMethod<bool?>('requestLiveness');
  }

  static Future<bool?> requestDocument(IdwallDocumentType documentType,
      IdwallDocumentSide documentSide, IdwallDocumentOption documentOption) {
    return _channel.invokeMethod<bool?>(
      'requestDocument',
      [
        describeEnum(documentType),
        describeEnum(documentSide),
        describeEnum(documentOption)
      ],
    );
  }

/* ------------------------------- Send method ------------------------------ */

  static Future<String?> sendData(IdwallSendType sendType) {
    return _channel.invokeMethod<String?>(
      'sendData',
      describeEnum(sendType),
    );
  }
}
