//
//  APIError.swift
//  Up
//
//  Created by Wonbi on 7/9/25.
//

enum APIError: Error {
    case statusCodeError(message: String)
    case successError(message: String)
    case decodeError(Error)
    case unknown(Error)
}
