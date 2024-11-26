//
//  LanguageManager.swift
//  Translator
//
//  Created by Konstantin Lyashenko on 08.09.2023.
//

import Foundation

protocol GetLanguageProtocol: AnyObject {
    func getLanguage(response: [LanguageModel.Languages])
}

struct LanguageManager {
    
    weak var delegate: GetLanguageProtocol?

    func getRequest() {
        var headers: [String: String]?
        let urlString = "https://text-translator2.p.rapidapi.com/getLanguages"
        if let path = Bundle.main.path(forResource: "ApiKeys", ofType: "plist"),
           let data = try? Data(contentsOf: URL(filePath: path)),
           let keys = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
           let rapidAPIKey = keys["rapidAPIKey"] as? String {
            headers = [
                "X-RapidAPI-Key": rapidAPIKey,
                "X-RapidAPI-Host": "text-translator2.p.rapidapi.com"
            ]
        }
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, _, error) in
            if let error = error {
                print(error as Any)
                return
            }
            DispatchQueue.main.async {
                if let data = data {
                    if let dict = self.parseJSON(data) {
                        guard let dict = dict.languages else { return }
                        self.delegate?.getLanguage(response: dict)
                    }
                }
            }
        }
        dataTask.resume()
    }
    
    private func parseJSON(_ data: Data) -> LanguageModel? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let languages = dataDict["languages"] as? [[String: Any]] {
                var languagesArray: [LanguageModel.Languages] = []
                
                for languageDict in languages {
                    if let code = languageDict["code"] as? String,
                       let name = languageDict["name"] as? String {
                        let language = LanguageModel.Languages(code: code, name: name)
                        languagesArray.append(language)
                    }
                }
                languagesArray.insert(LanguageModel.Languages(code: "auto", name: "Auto"), at: 0)
                let response = LanguageModel(languages: languagesArray)
                return response
            } else {
                print("Неверный формат GET JSON")
                return nil
            }
        } catch {
            print("Ошибка при разборе JSON: \(error)")
            return nil
        }
    }
}
