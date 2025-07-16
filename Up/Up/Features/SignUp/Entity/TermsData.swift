//
//  TermsData.swift
//  Up
//
//  Created by Wonbi on 7/9/25.
//

struct TermsData: Equatable, Identifiable {
    var id: String { code }
    
    /// 약관 이름
    let term: String
    /// 약관 상세 URL
    let url: String
    /// 약관 코드 (회원 가입시 동의한 약관으로 넘겨줄 코드)
    let code: String
    /// 필수 여부
    let isRequired: Bool
    /// 사용자가 약관에 동의 하였는지 여부
    var isAgree: Bool = false
    
    init(term: String, url: String, code: String, isRequired: Bool) {
        self.term = term
        self.url = url
        self.code = code
        self.isRequired = isRequired
    }
}
