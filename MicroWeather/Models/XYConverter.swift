//
//  XYConverter.swift
//  MicroWeather
//
//  Created by 김정원 on 4/30/25.
//

import Foundation

public struct LCCParameters {
    public let Re: Double       // 지구반경 [km]
    public let grid: Double     // 격자간격 [km]
    public let slat1: Double    // 표준위도1 [°]
    public let slat2: Double    // 표준위도2 [°]
    public let olon: Double     // 기준점 경도 [°]
    public let olat: Double     // 기준점 위도 [°]
    public let xo: Double       // 기준점 X좌표 [격자]
    public let yo: Double       // 기준점 Y좌표 [격자]
    
    public static let defaultShortForecast = LCCParameters(
        Re:    6371.00877,
        grid:  5.0,
        slat1: 30.0,
        slat2: 60.0,
        olon:  126.0,
        olat:  38.0,
        xo:    210.0/5.0,
        yo:    675.0/5.0
    )
}

public final class XYConverter {
    static let shared = XYConverter()
    
    private let PI       = Double.pi
    private let DEGRAD   = Double.pi/180.0
    private let RADDEG   = 180.0/Double.pi
    
    private let re: Double
    private let slat1: Double
    private let slat2: Double
    private let olon: Double
    private let olat: Double
    private let xo: Double
    private let yo: Double
    
    private let sn: Double
    private let sf: Double
    private let ro: Double
    
    private init(params p: LCCParameters = .defaultShortForecast) {
        // 1) 기본 파라미터
        self.re    = p.Re / p.grid
        self.slat1 = p.slat1 * DEGRAD
        self.slat2 = p.slat2 * DEGRAD
        self.olon  = p.olon  * DEGRAD
        self.olat  = p.olat  * DEGRAD
        self.xo    = p.xo
        self.yo    = p.yo
        
        // 2) 투영 상수 sn
        //    sn = log(cos(slat1)/cos(slat2)) / log(tan(π/4+slat2/2)/tan(π/4+slat1/2))
        let t1 = tan(PI*0.25 + slat1*0.5)
        let t2 = tan(PI*0.25 + slat2*0.5)
        self.sn = log(cos(slat1)/cos(slat2)) / log(t2/t1)
        
        // 3) 투영 상수 sf
        //    sf = (tan(π/4+slat1/2)^sn * cos(slat1)) / sn
        self.sf = pow(t1, sn)*cos(slat1)/sn
        
        // 4) 기준 반지름 ro
        //    ro = re * sf / (tan(π/4+olat/2)^sn)
        self.ro = re * sf / pow(tan(PI*0.25 + olat*0.5), sn)
    }
    
    public func calculateCoordinate(lon: Double, lat: Double) -> (x: Int, y: Int) {
        // ra = re*sf / [ tan(π/4 + lat/2)^sn ]
        let rlat = lat * DEGRAD
        let ra = re * sf / pow(tan(PI*0.25 + rlat*0.5), sn)
        
        // θ = (lon*DEGRAD – olon) * sn, 범위 ±π
        var theta = (lon*DEGRAD - olon)
        if theta > PI  { theta -= 2.0 * PI }
        if theta < -PI { theta += 2.0 * PI }
        theta *= sn
        
        // X, Y 계산
        let xVal = ra * sin(theta) + xo
        let yVal = ro - ra * cos(theta) + yo
        
        return (
            x: Int(floor(xVal + 1.5)),
            y: Int(floor(yVal + 1.5))
        )
    }
    
}
