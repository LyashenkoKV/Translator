//
//  ViewController.swift
//  Translator
//
//  Created by Konstantin Lyashenko on 07.09.2023.
//

import UIKit

class TranslatorViewController: UIViewController {
    
    @IBOutlet weak var sourceLanguageButton: UIButton!
    @IBOutlet weak var targetLanguageButton: UIButton!
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var outputTextView: UITextView!
    
    var translatorManager = TranslatorManager()
    
    var sourceLanguage: String?
    var targetLanguage: String?
    var languageDict: [String: String] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        translatorManager.delegate = self
    }
    
    func pushViewController(name: String, tag: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let selectLanguageViewController = storyboard
            .instantiateViewController(withIdentifier: "SelectLanguageViewControllerIdentifier") as? SelectLanguageViewController {
            selectLanguageViewController.navigationTitle = name
            selectLanguageViewController.delegate = self
            selectLanguageViewController.tag = tag
            self.navigationController?.pushViewController(selectLanguageViewController, animated: true)
        }
    }
    @IBAction func translateButtonAction(_ sender: UIButton) {
        guard let sourceLang = languageDict[sourceLanguage ?? "nil"] else { return }
        guard let targetLang = languageDict[targetLanguage ?? "nil"] else { return }
        
        print(sourceLang)
        print(targetLang)
        
        translatorManager.postRequest(source: sourceLang,
                                      target: targetLang,
                                      text: inputTextView.text
        )
        progressView.progress = 0.0
    }
    
    @IBAction func sourceLanguageButtonAction(_ sender: UIButton) {
        pushViewController(name: "Translate from:", tag: 0)
    }
    @IBAction func swapButtonAction(_ sender: UIButton) {
        sourceLanguageButton.titleLabel?.text = targetLanguage
        targetLanguageButton.titleLabel?.text = sourceLanguage
        let lang = sourceLanguage
        sourceLanguage = targetLanguage
        targetLanguage = lang
        inputTextView.text = outputTextView.text
    }
    @IBAction func targetLanguageButtonAction(_ sender: UIButton) {
        pushViewController(name: "Translate to:", tag: 1)
    }
}

extension TranslatorViewController: TranslaterManagerDelegate {
    func didUpdateText(_ languageModel: TranslatorModel) {
        outputTextView.text = languageModel.translatedText
    }
    
    func translationProgressUpdated(_ progress: Float) {
        DispatchQueue.main.async {
            self.progressView.progress = progress
        }
    }
}

extension TranslatorViewController: LanguageSelectionDelegate {
    func didSelectSource(language: String?) {
        sourceLanguageButton.setTitle(language, for: .normal)
        sourceLanguage = language
    }
    func didSelectTarget(language: String?) {
        targetLanguageButton.setTitle(language, for: .normal)
        targetLanguage = language
    }
    func language(dictionary: [String : String]) {
        languageDict = dictionary
    }
}
