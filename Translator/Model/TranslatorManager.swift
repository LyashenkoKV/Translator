//
//  TranslaterManager.swift
//  Translator
//
//  Created by Konstantin Lyashenko on 08.09.2023.
//

import Foundation

protocol TranslaterManagerDelegate {
    func didUpdateText(_ languageModel: TranslatorModel)
    func translationProgressUpdated(_ progress: Float)
}

struct TranslatorManager {
    
    var delegate: TranslaterManagerDelegate?
    
    func postRequest(source: String, target: String, text: String) {
        var headers: [String: String]?
        let urlString = "https://text-translator2.p.rapidapi.com/translate"
        if let path = Bundle.main.path(forResource: "ApiKeys", ofType: "plist"),
           let data = try? Data(contentsOf: URL(filePath: path)),
           let keys = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
           let rapidAPIKey = keys["rapidAPIKey"] as? String {
            headers = [
                "content-type": "application/x-www-form-urlencoded",
                "X-RapidAPI-Key": rapidAPIKey,
                "X-RapidAPI-Host": "text-translator2.p.rapidapi.com"
            ]
        }
        let postData = NSMutableData(data: "source_language=\(source)".data(using: String.Encoding.utf8)!)
        postData.append("&target_language=\(target)".data(using: String.Encoding.utf8)!)
        postData.append("&text=\(text)".data(using: String.Encoding.utf8)!)

        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if (error != nil) {
                print(error as Any)
            }
            var totalExpectedDataSize: Int64 = 0
            var receiveDataSize: Int64 = 0
            
            if let httpResponse = response as? HTTPURLResponse {
                if let contentLength = httpResponse.allHeaderFields["Content-Length"] as? String {
                    if let contentLengthInt = Int64(contentLength) {
                        totalExpectedDataSize = contentLengthInt
                    }
                }
            }
            DispatchQueue.main.async {
                if let data = data {
                    if let text = self.parseJSON(data) {
                        self.delegate?.didUpdateText(text)
                    }
                }
            }
            DispatchQueue.main.async {
                if let data = data {
                    receiveDataSize += Int64(data.count)
                    let progress = Float(receiveDataSize) / Float(totalExpectedDataSize)
                    self.delegate?.translationProgressUpdated(progress)
                }
            }
        }
        dataTask.resume()
    }
    
    private func parseJSON(_ data: Data) -> TranslatorModel? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataDict = json["data"] as? [String: Any],
               let translatedText = dataDict["translatedText"] as? String,
               let status = json["status"] as? String {
                
                var detectedSourceLanguage: TranslatorModel.DetectedSourceLanguage? = nil
                
                if let detectedLanguageDict = dataDict["detectedSourceLanguage"] as? [String: Any],
                   let detectedSourceLanguageCode = detectedLanguageDict["code"] as? String,
                   let detectedSourceLanguageName = detectedLanguageDict["name"] as? String {
                    detectedSourceLanguage = TranslatorModel.DetectedSourceLanguage(code: detectedSourceLanguageCode, name: detectedSourceLanguageName)
                }
                print("Received JSON data: \(json)")
                
                let translationResponse = TranslatorModel(detectedSourceLanguage: detectedSourceLanguage, translatedText: translatedText, status: status)
                return translationResponse
            } else {
                print("Неверный формат POST JSON")
                return nil
            }
        } catch {
            print("Ошибка при разборе JSON: \(error)")
            return nil
        }
    }
}
