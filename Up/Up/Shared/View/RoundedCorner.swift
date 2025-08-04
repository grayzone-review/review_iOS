//
//  RoundedCorner.swift
//  Up
//
//  Created by Jun Young Lee on 6/28/25.
//

import SwiftUI

struct RoundedCorner: Shape {
  var radius: CGFloat
  var corners: UIRectCorner

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect,
      byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius)
    )
    return Path(path.cgPath)
  }
}
