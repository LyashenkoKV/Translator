//
//  TranslatorModel.swift
//  Translator
//
//  Created by Konstantin Lyashenko on 08.09.2023.
//

import Foundation

struct TranslatorModel {
    struct DetectedSourceLanguage {
        var code: String?
        var name: String?
    }
    var detectedSourceLanguage: DetectedSourceLanguage?
    var translatedText: String?
    var status: String?
}
