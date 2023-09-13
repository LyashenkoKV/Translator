//
//  LanguageViewController.swift
//  Translator
//
//  Created by Konstantin Lyashenko on 07.09.2023.
//

import UIKit

protocol LanguageSelectionDelegate {
    func didSelectSource(language: String?)
    func didSelectTarget(language: String?)
    func language(dictionary: [String: String])
}


class SelectLanguageViewController: UIViewController {
    
    @IBOutlet weak var pickerView: UIPickerView!
    var sourceLanguages: [String] = []
    var targetLanguages: [String] = []
    
    var getLanguage = LanguageManager()
    var languageDictionary: [String: String] = [:]
    
    var navigationTitle: String?
    var tag: Int?
    
    var delegate: LanguageSelectionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = navigationTitle
        
        pickerView.delegate = self
        pickerView.dataSource = self
        getLanguage.delegate = self
        getLanguage.getRequest()
    }
    
    @IBAction func selectButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SelectLanguageViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if tag == 0 {
            return sourceLanguages.count
        } else {
            return targetLanguages.count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if tag == 0 {
            return sourceLanguages[row]
        } else {
            return targetLanguages[row]
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if tag == 0 {
            delegate?.didSelectSource(language: sourceLanguages[row])
        } else {
            delegate?.didSelectTarget(language: targetLanguages[row])
        }
    }
}
extension SelectLanguageViewController: GetLanguageProtocol {
    func getLanguage(response: [LanguageModel.Languages]) {
        sourceLanguages.removeAll()
        targetLanguages.removeAll()
        
        for language in response {
            guard let name = language.name else { return }
            sourceLanguages.append(name)
            if name != "Auto" {
                targetLanguages.append(name)
            }
            languageDictionary[name] = language.code
            delegate?.language(dictionary: languageDictionary)
        }
        DispatchQueue.main.async {
            self.pickerView.reloadAllComponents()
        }
    }
}
