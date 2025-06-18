//
//  TransverseMercator.swift
//  MicroWeather
//
//  Created by 김정원 on 6/17/25.
//

import Foundation

struct TransverseMercator {
    // GRS80
    private static let a  = 6377397.155            // 장반경(m)
    private static let fInv = 298.257222101        // 역편평률
    private static let f  = 1.0 / fInv
    private static let e2 = f * (2 - f)            // 이심률^2

    // TM 파라미터 (Korea 2000 / EPSG:5179)
    private static let lat0 = 38.0 * .pi / 180     // 기준 위도
    private static let lon0 = 127.0 * .pi / 180    // 기준 경도
    private static let k0   = 1.0                  // 축척 계수
    private static let FE   = 200000.0             // false easting (m)
    private static let FN   = 500000.0             // false northing (m)

    /// 위경도(deg) → TM 좌표(m)
    static func project(lat: Double, lon: Double) -> (Double, Double) {
        let φ = lat * .pi / 180
        let λ = lon * .pi / 180

        // 보조 변수
        let sinφ = sin(φ), cosφ = cos(φ), tanφ = tan(φ)
        let N = a / sqrt(1 - e2 * sinφ * sinφ)
        let T = tanφ * tanφ
        let C = e2 / (1 - e2) * cosφ * cosφ
        let A = (λ - lon0) * cosφ

        // 자오선 곡선 거리 M
        let M = meridionalArc(φ)

        // 투영
        let x = FE + k0 * N * (
            A
            + (1 - T + C) * pow(A,3) / 6
            + (5 - 18*T + T*T + 72*C - 58 * e2/(1-e2)) * pow(A,5) / 120
        )
        let y = FN + k0 * (
            M - meridionalArc(lat0)
            + N * tanφ * (
                pow(A,2)/2
                + (5 - T + 9*C + 4*C*C) * pow(A,4) / 24
                + (61 - 58*T + T*T + 600*C - 330 * e2/(1-e2)) * pow(A,6) / 720
            )
        )
        return (x, y)
    }

    /// 위도 φ 라디안에 대한 자오선 곡선 거리 M 계산
    private static func meridionalArc(_ φ: Double) -> Double {
        let n = f / (2 - f)
        let a0 = 1 - e2/4 - 3*pow(e2,2)/64 - 5*pow(e2,3)/256
        let a2 = 3*(e2/8 + pow(e2,2)/32 + 45*pow(e2,3)/1024)
        let a4 = 15*(pow(e2,2)/256 + 45*pow(e2,3)/1024)
        let a6 = 35*pow(e2,3)/3072

        return a * (
            a0*φ
            - a2*sin(2*φ)
            + a4*sin(4*φ)
            - a6*sin(6*φ)
        )
    }
}

