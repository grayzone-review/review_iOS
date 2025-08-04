//
//  KakaoAPIInterceptor.swift
//  Up
//
//  Created by Wonbi on 7/23/25.
//

import Foundation

import Alamofire

final class KakaoAPIInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        request.setValue("KakaoAK \(AppConfig.kakaoRestApiKey)", forHTTPHeaderField: "Authorization")
        completion(.success(request))
    }
}
