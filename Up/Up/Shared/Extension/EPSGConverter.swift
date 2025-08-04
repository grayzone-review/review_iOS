//
//  EPSGConverter.swift
//  Up
//
//  Created by Wonbi on 6/1/25.
//

import Foundation
import simd // 벡터/매트릭스 연산 편의용


enum EPSGConverter {
    // EPSG:5174 프로젝션 파라미터
    private static let a_bessel: Double = 6_377_397.155                  // Bessel 1841 장축 (meter)
    private static let f_bessel: Double = 1.0 / 299.1528128              // Bessel 1841 편평률
    private static let lon0_deg: Double = 127.0028902777778              // 중앙 자오선 (degree)
    private static let lat0_deg: Double = 38.0                            // 원점 위도 (degree)
    private static let k0: Double    = 1.0                                 // 축척 계수
    private static let falseEasting: Double  = 200_000.0                  // X₀ (meter)
    private static let falseNorthing: Double = 500_000.0                  // Y₀ (meter)
    
    /// EPSG:5174 (중부원점 TM) X/Y → Bessel 타원체 상 위도/경도 (radian)
    /// - Parameters:
    ///   - x: EPSG:5174 X (meter)
    ///   - y: EPSG:5174 Y (meter)
    /// - Returns: (φ, λ) in **radian**, or `nil` if 계산 오류
    private static func inverseTransverseMercator_EPSG5174_to_BesselLatLon(
        x: Double,
        y: Double
    ) -> (phi: Double, lambda: Double) {
        // 1) Bessel 타원체 이심률 e² 계산
        let e2 = 2 * f_bessel - f_bessel * f_bessel                   // e² = 2f - f²
        let e4 = e2 * e2
        let e6 = e4 * e2
        
        // 2) 원점 위도(M₀) 계산 (적분식 결과)
        let lat0 = lat0_deg * .pi / 180.0                             // radian
        let m0 = a_bessel * (
            (1 - e2/4 - 3*e4/64 - 5*e6/256) * lat0
            - (3*e2/8 + 3*e4/32 + 45*e6/1024) * sin(2 * lat0)
            + (15*e4/256 + 45*e6/1024) * sin(4 * lat0)
            - (35*e6/3072) * sin(6 * lat0)
        )
        
        // 3) 실제 M 계산
        let m = (y - falseNorthing) / k0 + m0
        
        // 4) μ (footpoint latitude) 계산
        let mu = m / (a_bessel * (1 - e2/4 - 3*e4/64 - 5*e6/256))
        
        // 5) e1 (보조 이심률) 계산
        let e1 = (1 - sqrt(1 - e2)) / (1 + sqrt(1 - e2))
        
        // 6) μ로부터 φ₁ (footpoint latitude) 역방향 수열 보정 (series expansion)
        let j1 = (3*e1/2 - 27*pow(e1, 3)/32)
        let j2 = (21*e1*e1/16 - 55*pow(e1, 4)/32)
        let j3 = (151*pow(e1, 3)/96)
        let j4 = (1097*pow(e1, 4)/512)
        
        let phi1 = mu
        + j1 * sin(2 * mu)
        + j2 * sin(4 * mu)
        + j3 * sin(6 * mu)
        + j4 * sin(8 * mu)
        
        // 7) φ₁ 기반으로 보정 상수들 계산
        let sinPhi1 = sin(phi1)
        let cosPhi1 = cos(phi1)
        let tanPhi1 = tan(phi1)
        
        // 두 번째 이심률(e′²) = e² / (1 - e²)
        let ep2 = e2 / (1 - e2)
        
        // N₁ (radius of curvature in prime vertical)
        let n1 = a_bessel / sqrt(1 - e2 * sinPhi1 * sinPhi1)
        
        // R₁ (radius of curvature in meridian)
        let r1 = a_bessel * (1 - e2) / pow(1 - e2 * sinPhi1 * sinPhi1, 1.5)
        
        // T₁ = tan²(φ₁)
        let t1 = tanPhi1 * tanPhi1
        
        // C₁ = ep2 * cos²(φ₁)
        let c1 = ep2 * cosPhi1 * cosPhi1
        
        // D = (x - falseEasting) / (N₁ * k0)
        let d = (x - falseEasting) / (n1 * k0)
        
        // 8) φ (역투영 최종 위도) 계산 (series)
        let term1 = d * d / 2
        let term2 = (5 + 3*t1 + 10*c1 - 4*c1*c1 - 9*ep2) * pow(d, 4) / 24
        let term3 = (61 + 90*t1 + 298*c1 + 45*t1*t1 - 252*ep2 - 3*c1*c1) * pow(d, 6) / 720
        
        let phi = phi1 - (n1 * tanPhi1 / r1) * (term1 - term2 + term3)
        
        // 9) λ (역투영 최종 경도) 계산 (series)
        let term4 = d
        let term5 = (1 + 2*t1 + c1) * pow(d, 3) / 6
        let term6 = (5 - 2*c1 + 28*t1 - 3*c1*c1 + 8*ep2 + 24*t1*t1) * pow(d, 5) / 120
        
        let lambda = (lon0_deg * .pi / 180.0) + (term4 - term5 + term6) / cosPhi1
        
        return (phi: phi, lambda: lambda)
    }
    
    
    // MARK: - 2) Bessel 타원체 경·위도 → 직교좌표(X, Y, Z) (Bessel) → WGS84 직교좌표(X′, Y′, Z′) (Helmert 변환) → WGS84 경·위도
    
    // 2-1) Bessel 타원체 상 경·위도를 직교(X, Y, Z)로
    private static func latLonToECEF_Bessel(phi: Double, lambda: Double) -> SIMD3<Double> {
        // Bessel 이심률, 장축/단축
        let e2 = 2 * f_bessel - f_bessel * f_bessel
        let sinPhi = sin(phi)
        let cosPhi = cos(phi)
        
        // N (radius of curvature in prime vertical) for Bessel
        let n = a_bessel / sqrt(1 - e2 * sinPhi * sinPhi)
        
        // ECEF (X, Y, Z)
        let x = n * cosPhi * cos(lambda)
        let y = n * cosPhi * sin(lambda)
        let z = n * (1 - e2) * sinPhi
        
        return SIMD3(x, y, z)
    }
    
    // 2-2) Helmert 7-parameter (Bessel → WGS84) 변환
    private static func helmertTransform_BesselToWGS84(_ xyz_bessel: SIMD3<Double>) -> SIMD3<Double> {
        // Helmert (towgs84) 파라미터 (EPSG:5174 정의 기준)
        // dx, dy, dz (meter)
        let tx = -115.80
        let ty =  474.99
        let tz =  674.11
        
        // 회전각(arc-second → radian)
        // 각 순서: rx, ry, rz 순으로 EPSG:5174 정의
        let rx_arcsec =  1.16
        let ry_arcsec = -2.31
        let rz_arcsec = -1.63
        
        let radPerSec = .pi / (180.0 * 3600.0)   // 1 arcsec = π / (180×3600) rad
        let rx = rx_arcsec * radPerSec
        let ry = ry_arcsec * radPerSec
        let rz = rz_arcsec * radPerSec
        
        // 스케일(ppm) → scale factor
        let ds_ppm = 6.43
        let s = 1.0 + ds_ppm * 1e-6            // 1 + (ₚₚₘ × 10^-6)
        
        // PROJ.4 헬머트 변환 공식(EPSG/PROJ.4 기준):
        //   X₂ = tx + s*( X₁ - rz*Y₁ + ry*Z₁ )
        //   Y₂ = ty + s*( rz*X₁ + Y₁ - rx*Z₁ )
        //   Z₂ = tz + s*( -ry*X₁ + rx*Y₁ + Z₁ )
        //
        // 여기서 (X₁, Y₁, Z₁) = Bessel ECEF, (X₂, Y₂, Z₂) = WGS84 ECEF
        
        let X1 = xyz_bessel.x
        let Y1 = xyz_bessel.y
        let Z1 = xyz_bessel.z
        
        let X2 = tx + s * (X1 - rz * Y1 + ry * Z1)
        let Y2 = ty + s * (rz * X1 + Y1 - rx * Z1)
        let Z2 = tz + s * (-ry * X1 + rx * Y1 + Z1)
        
        return SIMD3(X2, Y2, Z2)
    }
    
    // 2-3) WGS84 ECEF → WGS84 경·위도 (φ′, λ′) + 고도(h′) 역변환 (iterative)
    private static func ecefToLatLonECEF_WGS84(_ xyz: SIMD3<Double>) -> (lat: Double, lon: Double) {
        // WGS84 장축/편평률, 이심률
        let a_w =  6_378_137.0
        let f_w =  1.0 / 298.257_223_563
        let e2_w = 2 * f_w - f_w * f_w
        
        let x = xyz.x
        let y = xyz.y
        let z = xyz.z
        
        // 경도 (λ′)
        let lon = atan2(y, x)
        
        // 초기 위도 추정 (Bowring’s formula 활용)
        let p = sqrt(x*x + y*y)
        var phi = atan2(z, p * (1 - e2_w))    // 초기값
        
        // 반복 보정
        let epsilon = 1e-12                   // convergence tolerance
        var phiPrev: Double = 0.0
        
        repeat {
            let sinPhi = sin(phi)
            let n = a_w / sqrt(1 - e2_w * sinPhi * sinPhi)
            let h = p / cos(phi) - n
            phiPrev = phi
            phi = atan2(z, p * (1 - e2_w * (n / (n + h))))
        } while abs(phi - phiPrev) > epsilon
        
        return (lat: phi, lon: lon)
    }
    
    
    // MARK: - 최종 변환 함수
    
    /// EPSG:5174 (중부원점 TM) 좌표 → WGS84 (경도·위도, degree)
    ///
    /// - Parameters:
    ///   - x: EPSG:5174 X (meter)
    ///   - y: EPSG:5174 Y (meter)
    /// - Returns: (위도, 경도) in degree; 변환 실패 시 `nil`
    static func convert(x: Double, y: Double) -> (latitude: Double, longitude: Double) {
        // 1) EPSG:5174 평면좌표 → Bessel 타원체 경·위도(radian)
        let (phi_bessel, lambda_bessel) = inverseTransverseMercator_EPSG5174_to_BesselLatLon(x: x, y: y)
        
        // 2) Bessel φ/λ → ECEF (X₁, Y₁, Z₁)
        let ecef_bessel = latLonToECEF_Bessel(phi: phi_bessel, lambda: lambda_bessel)
        
        // 3) ECEF_Bessel → Helmert → ECEF_WGS84 (X₂, Y₂, Z₂)
        let ecef_wgs = helmertTransform_BesselToWGS84(ecef_bessel)
        
        // 4) ECEF_WGS84 → WGS84 φ′/λ′ (radian) + 높이(h′) 계산
        let (phi_wgs, lambda_wgs) = ecefToLatLonECEF_WGS84(ecef_wgs)
        
        // 5) radian → degree 변환
        let lat_deg = phi_wgs * 180.0 / .pi
        let lon_deg = lambda_wgs * 180.0 / .pi
        
        return (latitude: lat_deg, longitude: lon_deg)
    }
}
