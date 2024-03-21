package co.idwall.sdk_bridge_flutter

import co.idwall.toolkit.InputType
import co.idwall.toolkit.flow.core.Doc

fun String.toDoc(): Doc {
    return when (this) {
        "rg" -> Doc.RG
        "cnh" -> Doc.CNH
        "crlv" -> Doc.CRLV
        "rne" -> Doc.RNE
        "crnm" -> Doc.CRNM
        else -> Doc.RG
    }
}

fun List<String>.toDocList(): List<Doc> {
    return this.map { it.toDoc() }
}

fun String.toInputType(): InputType {
    return when (this) {
        "printed" -> InputType.PRINTED
        "digital" -> InputType.DIGITAL
        else -> InputType.PRINTED
    }
}

fun List<String>.toInputTypeList(): List<InputType> {
    return this.map { it.toInputType() }
}
