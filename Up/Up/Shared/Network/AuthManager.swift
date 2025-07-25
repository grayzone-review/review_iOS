//
//  AuthManager.swift
//  Up
//
//  Created by Wonbi on 6/6/25.
//

import Foundation

import Alamofire

private struct RefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String?
}

actor AuthManager: RequestInterceptor {
    private let tokenManager = TokenManager.shared
    
    private let refreshSession: Session = {
        let configuration = URLSessionConfiguration.default
        return Session(configuration: configuration)
    }()
    
    private var isRefreshing: Bool = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    nonisolated func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, any Error>) -> Void) {
        var request = urlRequest
        
        Task {
            if let token = await tokenManager.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            completion(.success(request))
        }
    }
    
    nonisolated func retry(_ request: Request, for session: Session, dueTo error: any Error, completion: @escaping (RetryResult) -> Void) {
        Task {
            await self.handleRetry(
                request: request,
                session: session,
                error: error,
                completion: completion
            )
        }
    }
    
    // MARK: – 내부 로직 (actor 격리 메서드)

    /// 실제 토큰 갱신 여부 및 요청 대기/재시도 로직을 actor 내부에서 처리
    private func handleRetry(
        request: Request,
        session: Session,
        error: Error,
        completion: @escaping (RetryResult) -> Void
    ) async {
        // 1) error가 ResponseError.invalidAccessToken인지 검사
        guard let afError = error.asAFError,
              case let .responseValidationFailed(reason) = afError,
              case let .customValidationFailed(innerError) = reason,
              let responseError = innerError as? ResponseError,
              responseError == .invalidAccessToken else {
            completion(.doNotRetry)
            return
        }

        // 2) 이미 토큰 갱신 중이라면, completion 클로저만 큐에 보관하고 리턴
        requestsToRetry.append(completion)
        if isRefreshing {
            return
        }

        // 3) 최초로 401이 발생한 경우: 토큰 갱신 시작
        isRefreshing = true
        let succeeded = await refreshTokensAsync()

        // 4) 토큰 갱신 성공 여부에 따라 대기 중인 모든 요청을 .retry 또는 .doNotRetry로 호출
        let results: [RetryResult] = succeeded
            ? Array(repeating: .retry, count: requestsToRetry.count)
            : Array(repeating: .doNotRetry, count: requestsToRetry.count)

        for (index, retryResult) in requestsToRetry.enumerated() {
            retryResult(results[index])
        }
        requestsToRetry.removeAll()
        isRefreshing = false
    }

    
    // MARK: - refreshTokens(completion:)

    /// actor에서 리프레시 토큰을 읽고, 실제 서버에 “리프레시 토큰”을 보내 새로운 액세스 토큰(및 필요 시 리프레시 토큰)을 요청
    /// 성공 시 actor에 저장하고 true 반환
    /// 실패 시 actor.clearTokens() 후 false 반환
    private func refreshTokensAsync() async -> Bool {
        // 1) actor에서 저장된 리프레시 토큰을 비동기적으로 읽어옴
        guard let currentRefresh = await tokenManager.getRefreshToken() else {
            return false
        }

        // 2) 리프레시 엔드포인트 URL (실제 서버 URL로 수정하세요)
        let url = "https://api.example.com/auth/refresh"
        let parameters: [String: Any] = [
            "refreshToken": currentRefresh
        ]

        do {
            // 3) async/await Alamofire 요청으로 토큰 갱신 시도
            let response = try await refreshSession
                .request(
                    url,
                    method: .post,
                    parameters: parameters,
                    encoding: JSONEncoding.default
                )
                .validate(statusCode: 200..<300)
                .serializingDecodable(RefreshResponse.self)
                .value

            // 4) actor에 새로운 토큰을 비동기적으로 저장
            await tokenManager.setAccessToken(response.accessToken)
            if let newRefresh = response.refreshToken {
                await tokenManager.setRefreshToken(newRefresh)
            }
            return true

        } catch {
            // 5) 갱신 실패 시 모든 토큰을 삭제 (로그아웃 상태로 전환)
            await tokenManager.clearTokens()
            return false
        }
    }
}
