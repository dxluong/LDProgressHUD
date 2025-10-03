//
//  LDProgressAnimatedView.swift
//
//  Created by Luong on 2/10/25.
//

import UIKit

class LDProgressAnimatedView: UIView {
    
    private var _ringAnimatedLayer: CAShapeLayer?
    
    // Properties
    var radius: CGFloat = 0.0 {
        didSet {
            if radius != oldValue {
                _ringAnimatedLayer?.removeFromSuperlayer()
                _ringAnimatedLayer = nil
                layoutAnimatedLayer()
            }
        }
    }
    
    var strokeColor: UIColor = .black {
        didSet {
            _ringAnimatedLayer?.strokeColor = strokeColor.cgColor
        }
    }
    
    var strokeThickness: CGFloat = 0.0 {
        didSet {
            _ringAnimatedLayer?.lineWidth = strokeThickness
        }
    }
    
    var strokeEnd: CGFloat = 1.0 {
        didSet {
            _ringAnimatedLayer?.strokeEnd = strokeEnd
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutAnimatedLayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        layoutAnimatedLayer()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            layoutAnimatedLayer()
        } else {
            _ringAnimatedLayer?.removeFromSuperlayer()
            _ringAnimatedLayer = nil
        }
    }
    
    private func layoutAnimatedLayer() {
        guard let layer = ringAnimatedLayer else { return }
        self.layer.addSublayer(layer)
        
        let widthDiff = bounds.width - layer.bounds.width
        let heightDiff = bounds.height - layer.bounds.height
        layer.position = CGPoint(x: bounds.width - layer.bounds.width / 2 - widthDiff / 2, y: bounds.height - layer.bounds.height / 2 - heightDiff / 2)
    }
    
    private var ringAnimatedLayer: CAShapeLayer? {
        get {
            if _ringAnimatedLayer == nil {
                let arcCenter = CGPoint(x: radius + strokeThickness / 2 + 5, y: radius + strokeThickness / 2 + 5)
                let smoothedPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: -CGFloat.pi / 2, endAngle: CGFloat.pi + CGFloat.pi / 2, clockwise: true)
                
                _ringAnimatedLayer = CAShapeLayer()
                _ringAnimatedLayer?.contentsScale = UIScreen.main.scale
                _ringAnimatedLayer?.frame = CGRect(x: 0.0, y: 0.0, width: arcCenter.x * 2, height: arcCenter.y * 2)
                _ringAnimatedLayer?.fillColor = UIColor.clear.cgColor
                _ringAnimatedLayer?.strokeColor = strokeColor.cgColor
                _ringAnimatedLayer?.lineWidth = strokeThickness
                _ringAnimatedLayer?.lineCap = .round
                _ringAnimatedLayer?.lineJoin = .bevel
                _ringAnimatedLayer?.path = smoothedPath.cgPath
            }
            return _ringAnimatedLayer
        }
    }
    
    override var frame: CGRect {
        didSet {
            if !frame.equalTo(super.frame) {
                super.frame = frame
                
                if superview != nil {
                    layoutAnimatedLayer()
                }
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: (radius + strokeThickness / 2 + 5) * 2, height: (radius + strokeThickness / 2 + 5) * 2)
    }
}
