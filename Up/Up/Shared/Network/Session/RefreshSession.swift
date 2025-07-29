//
//  RefreshSession.swift
//  Up
//
//  Created by Wonbi on 7/29/25.
//

import Foundation

import Alamofire

final class RefreshNetworkSession {
    private let session: Session

    init(
        eventLogger: EventMonitor = NetworkLogger(apiName: "Up Refresh")
    ) {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // 요청 타임아웃 30초

        self.session = Session(
            configuration: configuration,
            eventMonitors: [eventLogger]
        )
    }
    func request<T: Decodable>(
        _ convertible: URLRequestConvertible,
        as type: T.Type
    ) async throws -> Result<NetworkResponse<T>, FailResponse> {
        // 1) DataRequest 만들기
        var failResponse: FailResponse?
        let dataRequest = session.request(convertible)
            .validate { _, _, data in
                guard let data else { return .success(()) }
                
                failResponse = try? JSONDecoder().decode(FailResponse.self, from: data)
                
                if let failResponse {
                    if let responseError = ResponseError(rawValue: failResponse.code),
                       responseError == .invalidAccessToken {
                        return .failure(responseError)
                    } else {
                        return .failure(failResponse)
                    }
                }
                
                return .success(())
            }

        let response = await dataRequest.serializingData().response
        
        switch response.result {
        case let .success(data):
            return .success(try JSONDecoder().decode(NetworkResponse<T>.self, from: data))
            
        case let .failure(error):
            if case let .responseValidationFailed(reason) = error,
               case let .customValidationFailed(failError) = reason,
               let failResponse = failError as? FailResponse
            {
                return .failure(failResponse)
            } else {
                throw error
            }
        }
    }
}
