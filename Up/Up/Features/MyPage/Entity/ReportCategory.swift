//
//  ReportCategory.swift
//  Up
//
//  Created by Jun Young Lee on 7/21/25.
//

enum ReportCategory: Int, Identifiable, CaseIterable {
    case violational
    case promotional
    case critical
    case personal
    case bug
    
    var id: Int {
        rawValue
    }
    
    var text: String {
        switch self {
        case .violational:
            "음란/불법/청소년 유해"
        case .promotional:
            "홍보성"
        case .critical:
            "비방/비하/욕설"
        case .personal:
            "개인정보노출"
        case .bug:
            "버그 발견"
        }
    }
}
