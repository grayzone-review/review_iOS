//
//  ReviewRequest.swift
//  Up
//
//  Created by Jun Young Lee on 6/19/25.
//

struct ReviewRequest: Encodable {
    struct Ratings: Encodable {
        /// 워라밸 평가 점수
        let workLifeBalance: Double
        /// 복지 평가 점수
        let welfare: Double
        /// 급여 평가 점수
        let salary: Double
        /// 기업 문화 평가 점수
        let companyCulture: Double
        /// 경영진 평가 점수
        let management: Double
    }
    
    /// 각 평가 항목에 대한 점수
    let ratings: Ratings
    /// 회사의 장점
    let advantagePoint: String
    /// 회사의 단점
    let disadvantagePoint: String
    /// 경영진에 대한 의견
    let managementFeedback: String
    /// 직무명
    let jobRole: String
    /// 근무 기간 (예: 1년 이상, 1년 미만 등)
    let employmentPeriod: String
}
