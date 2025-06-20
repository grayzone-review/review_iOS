//
//  DateFormatter.swift
//  Up
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

extension DateFormatter {
    // 서버에서 내려주는 날짜 양식에 맞춘 DateFormatter
    static let serverFormat: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        return formatter
    }()
    
    // 리뷰 카드 표시 형식에 맞춘 DateFormatter
    static let reviewCardFormat: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy. MM 작성"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        return formatter
    }()
}
