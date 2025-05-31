//
//  DateFormatter.swift
//  Grayzone
//
//  Created by Jun Young Lee on 5/31/25.
//

import Foundation

extension DateFormatter {
    // 서버에서 내려주는 날짜 양식에 맞춘 DateFormatter
    static let shared: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        return formatter
    }()
}
