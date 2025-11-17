//
//  String+TeamDisplay.swift
//  DanDan
//
//  Created by Hwnag Seyeon on 11/15/25.
//

import Foundation

extension String {
    /// 팀 영문명(대/소문자) → 한글 표시명 매핑
    var teamDisplayName: String {
        switch self {
        case "Blue", "blue":
            return "파랑팀"
        case "Yellow", "yellow":
            return "노랑팀"
        default:
            return self
        }
    }
}

