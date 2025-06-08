//
//  AuthIDInterceptor.swift
//  Up
//
//  Created by Wonbi on 6/8/25.
//

import Foundation

import Alamofire

final class AuthIDInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        request.setValue("\(1)", forHTTPHeaderField: "Authorization")
        completion(.success(request))
    }
}
