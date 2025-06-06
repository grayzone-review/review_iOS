//
//  NetworkLogger.swift
//  Up
//
//  Created by Wonbi on 6/6/25.
//

import Alamofire
import Foundation

public final class NetworkLogger: EventMonitor {
    private let apiName: String
    public let queue: DispatchQueue
    
    public init(apiName: String = "") {
        self.apiName = apiName
        self.queue = DispatchQueue(label: "💜 APIEventLogger-\(apiName)")
    }
    
    public func requestDidFinish(_ request: Request) {
        print("🛰 \(apiName) NETWORK Event LOG\n"
              + "✅ Request successfully\n"
              + "-------------------------------\n"
              + "URL: \(request.request?.url?.absoluteString ?? "")\n"
              + "Method: \(request.request?.httpMethod ?? "")\n"
              + "Headers: \(request.request?.allHTTPHeaderFields ?? [:])\n"
              + "Body: \(request.request?.httpBody?.toPrettyPrintedString ?? "")\n"
        )
    }
    
    public func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        switch response.result {
        case .success:
            let url = request.request?.url?.absoluteString ?? ""
            let statusCode = response.response?.statusCode ?? 0
            let dataString = response.data?.toPrettyPrintedString ?? ""
            let headers = response.response?.allHeaderFields
                .map { "\($0.key): \($0.value)" }
                .joined(separator: "\n") ?? "None"

            print("""
            🛰 \(apiName) NETWORK Event LOG
            ✅ Response parsed successfully
            -------------------------------
            URL: \(url)
            StatusCode: \(statusCode)
            Result: \(response.result)\n
            Headers:
            \(headers)
            Data:
            \(dataString)
            """)

        case let .failure(error):
            guard let statusCode = response.response?.statusCode else { return }
                
            switch statusCode {
            case 400...499:
                print("🛰 \(apiName) NETWORK Event LOG\n"
                      + "❌ Client Error: Bad Resquest\n"
                      + "-------------------------------\n"
                      + "URL: \(request.request?.url?.absoluteString ?? "")\n"
                      + "Result: \(response.result)\n"
                      + "StatusCode: \(response.response?.statusCode ?? 0)\n"
                      + "Data: \(response.data?.toPrettyPrintedString ?? "")\n"
                      + "Error: \(error.errorDescription ?? "")\n"
                )
            case 500...599:
                print("🛰 \(apiName) NETWORK Event LOG\n"
                      + "❌ Server Error: Problem with the server\n"
                      + "-------------------------------\n"
                      + "URL: \(request.request?.url?.absoluteString ?? "")\n"
                      + "Result: \(response.result)\n"
                      + "StatusCode: \(response.response?.statusCode ?? 0)\n"
                      + "Data: \(response.data?.toPrettyPrintedString ?? "")\n"
                      + "Error: \(error.errorDescription ?? "")\n"
                )
            default:
                print("🛰 \(apiName) NETWORK Event LOG\n"
                      + "❌ Unexpected Error: \(error.errorDescription ?? "")\n"
                      + "-------------------------------\n"
                      + "URL: \(request.request?.url?.absoluteString ?? "")\n"
                      + "Result: \(response.result)\n"
                      + "StatusCode: \(response.response?.statusCode ?? 0)\n"
                      + "Data: \(response.data?.toPrettyPrintedString ?? "")\n"
                )
            }
        }
    }
    
    public func request(_ request: Request, didFailToCreateURLRequestWithError error: AFError) {
        print("🛰 \(apiName) NETWORK Event LOG\n"
              + "❌ Fail to create URLRequest\n"
              + "-------------------------------\n"
              + "URL: \(request.request?.url?.absoluteString ?? "")\n"
              + "Method: \(request.request?.httpMethod ?? "")\n"
              + "Authorization: \(request.request?.headers["Authorization"] ?? "")\n"
              + "Headers: \(request.request?.allHTTPHeaderFields ?? [:])\n"
              + "Body: \(request.request?.httpBody?.toPrettyPrintedString ?? "")\n"
              + "Error: \(error.errorDescription ?? "")\n"
        )
    }
    
    public func request(_ request: DataRequest, didParseResponse response: DataResponse<Data?, AFError>) {
        switch response.result {
        case .success:
//            print("🛰 \(apiName) NETWORK Event LOG\n"
//                  + "✅ Response parsed successfully\n"
//                  + "-------------------------------\n"
//                  + "URL: \(request.request?.url?.absoluteString ?? "")\n"
//                  + "Result: \(response.result)\n"
//                  + "StatusCode: \(response.response?.statusCode ?? 0)\n"
//                  + "Data: \(response.data?.toPrettyPrintedString ?? "")\n"
//            )
//
            let url = request.request?.url?.absoluteString ?? ""
            let statusCode = response.response?.statusCode ?? 0
            let dataString = response.data?.toPrettyPrintedString ?? ""
            let headers = response.response?.allHeaderFields
                .map { "\($0.key): \($0.value)" }
                .joined(separator: "\n") ?? "None"
            
            print("""
            🛰 \(apiName) NETWORK Event LOG
            ✅ Response parsed successfully
            -------------------------------
            URL: \(url)
            StatusCode: \(statusCode)
            Result: \(response.result)\n
            Headers:
            \(headers)
            Data:
            \(dataString)
            """)
            
        case let .failure(error):
            guard let statusCode = response.response?.statusCode else { return }
            
            switch statusCode {
            case 400...499:
                print("🛰 \(apiName) NETWORK Event LOG\n"
                      + "❌ Client Error: Bad Resquest\n"
                      + "-------------------------------\n"
                      + "URL: \(request.request?.url?.absoluteString ?? "")\n"
                      + "Result: \(response.result)\n"
                      + "StatusCode: \(response.response?.statusCode ?? 0)\n"
                      + "Data: \(response.data?.toPrettyPrintedString ?? "")\n"
                      + "Error: \(error.errorDescription ?? "")\n"
                )
            case 500...599:
                print("🛰 \(apiName) NETWORK Event LOG\n"
                      + "❌ Server Error: Problem with the server\n"
                      + "-------------------------------\n"
                      + "URL: \(request.request?.url?.absoluteString ?? "")\n"
                      + "Result: \(response.result)\n"
                      + "StatusCode: \(response.response?.statusCode ?? 0)\n"
                      + "Data: \(response.data?.toPrettyPrintedString ?? "")\n"
                      + "Error: \(error.errorDescription ?? "")\n"
                )
            default:
                print("🛰 \(apiName) NETWORK Event LOG\n"
                      + "❌ Unexpected Error: \(error.errorDescription ?? "")\n"
                      + "-------------------------------\n"
                      + "URL: \(request.request?.url?.absoluteString ?? "")\n"
                      + "Result: \(response.result)\n"
                      + "StatusCode: \(response.response?.statusCode ?? 0)\n"
                      + "Data: \(response.data?.toPrettyPrintedString ?? "")\n"
                )
            }
        }
    }
}

extension Data {
    var toPrettyPrintedString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString as String
    }
}
