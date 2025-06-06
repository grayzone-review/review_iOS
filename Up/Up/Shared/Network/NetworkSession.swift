//
//  NetworkSession.swift
//  Up
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation
import Alamofire

protocol NetworkSession {
    /// 반환값 없이(on‐fire) 요청만 보낼 때 사용
    /// 서버에 요청만 보내고, 응답 데이터는 필요 없을 경우 호출
    func execute(
        _ convertible: URLRequestConvertible
    ) async throws
    
    /// URLRequestConvertible 또는 URLRequest를 받아서, 지정된 Decodable 타입을 반환
    func request<T: Decodable>(
        _ convertible: URLRequestConvertible,
        as type: T.Type
    ) async throws -> NetworkResponse<T>

    /// 단순 Data만 받을 때
    func requestData(
        _ convertible: URLRequestConvertible
    ) async throws -> Data

    /// 서버로부터 String 응답을 받을 때
    func requestString(
        _ convertible: URLRequestConvertible,
        encoding: String.Encoding
    ) async throws -> String
}

/// Alamofire를 통해 실제 네트워크 요청을 수행하는 클래스
final class AlamofireNetworkSession: NetworkSession {
    /// Alamofire의 Session 인스턴스. 커스텀 설정이 필요하면 여기서 초기화 가능.
    private let session: Session

    /// 기본 생성자: 기본 Session 설정 사용
    init(
        interceptor: RequestInterceptor = AuthManager(),
        eventLogger: EventMonitor = NetworkLogger(apiName: "Up Default")
    ) {
        // URLSessionConfiguration 커스터마이징 예시 (타임아웃 등)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30 // 요청 타임아웃 30초

        // interceptor: AuthInterceptor(actor)를 붙여서,
        // 모든 요청마다 adapt/ retry 로직이 적용되도록 설정
        self.session = Session(
            configuration: configuration,
            interceptor: interceptor,
            eventMonitors: [eventLogger]
        )
    }
    
    /// 반환값 없이(on‐fire) 요청만 보낼 때 사용
    /// 서버에 요청만 보내고, 응답 데이터는 필요 없을 경우 호출
    func execute(
        _ convertible: URLRequestConvertible
    ) async throws {
        let dataRequest = session.request(convertible)
            .validate(statusCode: 200..<300)
        
        _ = try await dataRequest
            .serializingData()
            .value
        // Data는 무시하고, 에러가 발생하면 throw
    }

    /// JSON을 Decodable 타입으로 디코딩하여 반환
    func request<T: Decodable>(
        _ convertible: URLRequestConvertible,
        as type: T.Type
    ) async throws -> NetworkResponse<T> {
        // 1) DataRequest 만들기
        let dataRequest = session.request(convertible)

        // 2) 응답을 Decodable 타입으로 직렬화하고 .value로 꺼내오기
        return try await dataRequest
            .serializingDecodable(NetworkResponse<T>.self)
            .value
    }

    /// 단순 Data 형태로 반환
    func requestData(
        _ convertible: URLRequestConvertible
    ) async throws -> Data {
        let dataRequest = session.request(convertible)
        return try await dataRequest
            .serializingData()
            .value
    }

    /// 단순 String 형태로 반환
    func requestString(
        _ convertible: URLRequestConvertible,
        encoding: String.Encoding = .utf8
    ) async throws -> String {
        let dataRequest = session.request(convertible)
        return try await dataRequest
            .serializingString(encoding: encoding)
            .value
    }
}

extension Encodable {
    func toDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let jsonData = try? JSONSerialization.jsonObject(with: data),
              let dictionaryData = jsonData as? [String: Any] else { return [:] }
        return dictionaryData
    }
}
