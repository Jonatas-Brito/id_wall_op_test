package co.idwall.sdk_bridge_flutter

import co.idwall.toolkit.InputType
import co.idwall.toolkit.core.log.LoggingLevel
import co.idwall.toolkit.flow.core.Doc
import co.idwall.toolkit.flow.core.DocumentSide
import co.idwall.toolkit.flow.core.Flow
import co.idwall.toolkit.flow.core.SendType

fun convertToLoggingLevel(loggingLevel: String): LoggingLevel? {
    return when (loggingLevel) {
        "minimal" -> LoggingLevel.MINIMAL
        "regular" -> LoggingLevel.REGULAR
        "verbose" -> LoggingLevel.VERBOSE
        else -> null
    }
}

fun convertToDocType(documentType: String): Doc? {
    return when (documentType) {
        "cnh" -> Doc.CNH
        "crlv" -> Doc.CRLV
        "rg" -> Doc.RG
        "rne" -> Doc.RNE
        "crnm" -> Doc.CRNM
        else -> null
    }
}
fun convertToDocSide(documentSide: String): DocumentSide? {
    return when (documentSide) {
        "front" -> DocumentSide.FRONT
        "back" -> DocumentSide.BACK
        else -> null
    }
}

fun convertToInputType(inputType: String): InputType? {
    return when (inputType) {
        "printed" -> InputType.PRINTED
        "digital" -> InputType.DIGITAL
        else -> null
    }
}

fun convertToFlowType(flowType: String): Flow? {
    return when (flowType) {
        "complete" -> Flow.COMPLETE
        "liveness" -> Flow.LIVENESS
        "document" -> Flow.DOC
        else -> null
    }
}

fun convertToSendType(sendType: String): SendType? {
    return when (sendType) {
        "all" -> SendType.ALL
        "liveness" -> SendType.LIVENESS
        "document" -> SendType.DOCUMENT
        else -> null
    }
}