//
//  TermResponse.swift
//  Up
//
//  Created by Wonbi on 7/9/25.
//

public struct TermsListResponse: Codable {
    public let terms: [TermResponse]
    
    func toDomain() -> [TermsData] {
        return self.terms.map { $0.toDomain() }
    }
}

public struct TermResponse: Codable {
    /// 약관 이름
    public let term: String
    /// 약관 상세 URL
    public let url: String
    /// 약관 코드 (회원 가입시 동의한 약관으로 넘겨줄 코드)
    public let code: String
    /// 필수 여부
    public let required: Bool
    
    func toDomain() -> TermsData {
        return TermsData(
            term: self.term,
            url: self.url,
            code: self.code,
            isRequired: self.required
        )
    }
}
