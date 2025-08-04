//
//  ResponseError.swift
//  Up
//
//  Created by Jun Young Lee on 7/25/25.
//

import Foundation

enum ResponseError: Int, Error {
    case userNotFound = 2010 // 존재하지 않는 회원 ID 또는 탈퇴된 유저 접근 시
    case nicknameExist = 2011 // 닉네임 중복 체크 실패 (회원가입/변경 시)
    case needAuthoraization = 3000 // 인증 헤더 누락 등 로그인 필요 요청 시 사용
    case notMember = 3001 // 유저 정보가 없는 비회원 상태 접근 시
    case invalidAccessToken = 3002 // 액세스 토큰 형식 오류 또는 위조된 토큰
    case invalidRefreshToken = 3003 // 리프레시 토큰 형식 오류 또는 위조된 토큰
    case noPermission = 3004 // 관리자 또는 특정 유저 권한이 없을 때
    case invalidSocialToken = 3101 // 소셜 로그인 시 잘못된 인증 정보 제공
    case notSupportedSocialLoginProvider = 3102 // 카카오, 구글 등 외의 미지원 OAuth provider 요청
    case notExistCompany = 4001 // 존재하지 않는 회사 ID로 요청한 경우
    case notExistRegion = 4002 // 없는 지역/지역코드로 접근하거나 조회 시
    case notExistReview = 4101 // 리뷰 ID가 잘못되었거나 삭제된 경우
    case alreadyBeenLiked = 4102 // 중복 좋아요 요청 방지용
    case didNotLiked = 4103 // 좋아요 취소 요청 시 해당 기록이 없는 경우
    case noExistComment = 4201 // 댓글이 존재하지 않거나 삭제된 경우
    case unableToReply = 4202 // 대댓글 제한 또는 비공개 글에 답글 시도
    case alreadyBeenFollowed = 4301 // 이미 팔로우 상태인데 중복 요청한 경우
    case didNotFollowed = 4302 // 언팔로우 요청 시 실제 팔로우 상태가 아님
    case invalidRequest = 4400 // 유효하지 않은 파라미터, 필드, 포맷 등
    case internalServerError = 5000 // 알 수 없는 런타임 예외, DB/Redis 장애 포함
}
