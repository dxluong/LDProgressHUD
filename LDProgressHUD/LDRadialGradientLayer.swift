//
//  LDRadialGradientLayer.swift
//
//  Created by Luong on 2/10/25.
//

import QuartzCore

class LDRadialGradientLayer: CALayer {
    
    var gradientCenter = CGPoint.zero
    
    override func draw(in context: CGContext) {
        let locationsCount: size_t = 2
        let locations = [0.0, 1.0] as [CGFloat]
        
        let colors = [
            CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.0),
            CGFloat(0.0), CGFloat(0.0), CGFloat(0.0), CGFloat(0.75)
        ]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let gradient = CGGradient(colorSpace: colorSpace,
                                     colorComponents: colors,
                                     locations: locations,
                                     count: locationsCount) {
            let radius = min(self.bounds.width, self.bounds.height)
            context.drawRadialGradient(gradient, startCenter: gradientCenter, startRadius: 0, endCenter: gradientCenter, endRadius: radius, options: .drawsAfterEndLocation)
        }
    }
}
