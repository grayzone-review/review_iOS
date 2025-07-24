//
//  ReportRequest.swift
//  Up
//
//  Created by Jun Young Lee on 7/24/25.
//

/// 신고하기 API Request
struct ReportRequest: Encodable {
    /// 신고자 이름
    let reporterName: String
    /// 신고 대상 이름
    let targetName: String
    /// 신고 타입
    let reportType: String
    /// 신고 사유
    let description: String
}
