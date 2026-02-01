//import Foundation
//import AppIntents
//
//@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
//struct Intent: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
//    static let intentClassName = "IntentIntent"
//    
//    static var title: LocalizedStringResource = "自动记账"
//    static var description = IntentDescription("test")
//    
//    @Parameter(title: "记账内容", default: "")
//    var content: String?
//        
//    
//    static var parameterSummary: some ParameterSummary {
//        Summary("好享记账") {
//            \.$content
//        }
//    }
//    
//    static var predictionConfiguration: some IntentPredictionConfiguration {
//        IntentPrediction(parameters: (\.$content)) { content in
//            DisplayRepresentation(
//                title: "自动记账",
//                subtitle: "test"
//            )
//        }
//    }
//    
//    @MainActor
//    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog  {
//        print(content!)
//        if let jsonData = content!.data(using: .utf8) {
//            do {
//                // 尝试解析JSON数据为字典
//                if let dictData = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
//                    // 成功转换，现在可以使用这个字典了
//                    print(dictData)
//                    let token = UserDefaults.standard.string(forKey: "flutter.token")
//                    if(token == nil){
//                        return .result(value: "error", dialog: IntentDialog(full: "", supporting: "未记账，原因是token失效"));
//                    }
//                    
//                    let type = (dictData["type"] ?? "未知" ) as! String ;
//                    let positive = (dictData["positive"] ?? "未知" ) as! String ;
//                    let money = (String((dictData["money"] ?? "未知" ) as! String ));
//                    let label = (dictData["label"] ?? "未知" ) as! String ;
//                    let dialog = IntentDialog(full: "", supporting: "已记账：\(money)，分类为\(type)")
//
//                    // 创建URL对象
//                    guard let url = URL(string: "https://journal.aceword.xyz/api/expense/current") else {
//                        fatalError("Invalid URL")
//                    }
//                    
//                    // 创建URLRequest对象
//                    var request = URLRequest(url: url)
//                    request.httpMethod = "POST"
//                    let parameters = ["type": type,
//                                      "positive" : positive == "收入" ? "1" : "0",
//                                      "price":money,
//                                      "label":label,
//                                      "activityId":"123"
//                    ]
//                    
//
//                    let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
//                    request.httpBody = jsonData
//                    request.addValue(token!, forHTTPHeaderField: "Authorization")
//                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                    // 创建URLSession数据任务
//                    let session = URLSession.shared
//                    let task = session.dataTask(with: request) { (data, response, error) in
//                        // 确保没有错误发生
//                        if let error = error {
//                            print("Error: \(error)")
//                            return
//                        }
//                        
//                        // 确保我们得到了响应数据
//                        guard let data = data else {
//                            print("No data in response")
//                            return
//                        }
//                        
//                        // 例如，解析JSON
//                        if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) {
//                            print("Response JSON: \(jsonObject)")
//                        } else {
//                            print("Failed to parse Response JSON")
//                        }
//                    }
//                     
//                    // 启动任务
//                    task.resume()
//                    return .result(value: "ok", dialog: dialog)
//                }
//            } catch {
//                print("解析错误:", error)
//                    return .result(value: "error", dialog: IntentDialog(full: "", supporting: "未记账，原因是入参解析错误"));
//            }
//        }
//        let dialog = IntentDialog(full: "", supporting: "解析错误")
//        return .result(value: "ok", dialog: dialog)
//    }
//}

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct Intent: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "IntentIntent"
    
    static var title: LocalizedStringResource = "自动记账"
    static var description = IntentDescription("test")
    
    @Parameter(title: "记账内容", default: "")
    var content: String?
    
    static var parameterSummary: some ParameterSummary {
        Summary("好享记账") {
            \.$content
        }
    }
    
    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$content)) { content in
            DisplayRepresentation(
                title: "自动记账",
                subtitle: "test"
            )
        }
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog  {
        print(content!)
        if let jsonData = content!.data(using: .utf8) {
            do {
                // 尝试解析JSON数据为字典
                if let dictData = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                    // 成功转换，现在可以使用这个字典了
                    print(dictData)
                    let token = UserDefaults.standard.string(forKey: "flutter.token")
                    if(token == nil){
                        return .result(value: "error", dialog: IntentDialog(full: "", supporting: "未记账，原因是token失效"));
                    }
                    
                    let type = (dictData["type"] ?? "未知" ) as! String ;
                    let positive = (dictData["positive"] ?? "未知" ) as! String ;
                    let money = (dictData["money"] ?? "未知" ) as! String ;
                    let label = (dictData["label"] ?? "未知" ) as! String ;
                    let dialog = IntentDialog(full: "", supporting: "已记账：\(money)，分类为\(type)")

                    // 创建URL对象
                    guard let url = URL(string: "https://journal.aceword.xyz/api/expense/current") else {
                        fatalError("Invalid URL")
                    }
                    
                    // 创建URLRequest对象
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    let parameters = ["type": type,
                                      "positive" : positive == "收入" ? "1" : "0",
                                      "price":money,
                                      "label":label,
                                      "activityId":"123"
                    ]
                    
                    let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
                    request.httpBody = jsonData
                    request.addValue(token!, forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    // 创建URLSession数据任务
                    let session = URLSession.shared
                    let task = session.dataTask(with: request) { data, response, error in
                        // 确保没有错误发生
                        if let error = error {
                            print("Error: \(error)")
//                            return .result(value: "error", dialog: IntentDialog(full: "", supporting: "未记账，原因是网络请求错误"))
                        }
                        
                        // 确保我们得到了响应数据
//                        guard let data = data else {
//                            print("No data in response")
//                            //.result(value: "error", dialog: IntentDialog(full: "", supporting: "未记账，原因是没有响应数据"))
//
//                        }
                        
                        // 例如，解析JSON
                        if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: []) {
                            print("Response JSON: \(jsonObject)")
                        } else {
                            print("Failed to parse Response JSON")
//                            return .result(value: "error", dialog: IntentDialog(full: "", supporting: "未记账，原因是响应数据解析错误"))
                        }
                    }
                    
                    // 启动任务
                    task.resume()
                    return .result(value: "ok", dialog: dialog)
                }
            } catch {
                print("解析错误:", error)
                return .result(value: "error", dialog: IntentDialog(full: "", supporting: "未记账，原因是入参解析错误"))
            }
        }
        let dialog = IntentDialog(full: "", supporting: "解析错误")
        return .result(value: "ok", dialog: dialog)
    }
}
