//
//  LDIndefiniteAnimatedView.swift
//
//  Created by Luong on 2/10/25.
//

import UIKit

class LDIndefiniteAnimatedView: UIView {
    private var _indefiniteAnimatedLayer: CAShapeLayer?

    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if newSuperview != nil {
            layoutAnimatedLayer()
        } else {
            _indefiniteAnimatedLayer?.removeFromSuperlayer()
            _indefiniteAnimatedLayer = nil
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutAnimatedLayer()
    }

    private func layoutAnimatedLayer() {
        guard let layer = indefiniteAnimatedLayer else { return }

        if layer.superlayer == nil {
            self.layer.addSublayer(layer)
        }

        let widthDiff = bounds.width - layer.bounds.width
        let heightDiff = bounds.height - layer.bounds.height
        layer.position = CGPoint(x: bounds.width - layer.bounds.width / 2 - widthDiff / 2,
                                y: bounds.height - layer.bounds.height / 2 - heightDiff / 2)
    }

    var indefiniteAnimatedLayer: CAShapeLayer? {
        if _indefiniteAnimatedLayer == nil {
            let arcCenter = CGPoint(x: radius + strokeThickness / 2 + 5, y: radius + strokeThickness / 2 + 5)
            let smoothedPath = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: CGFloat(Double.pi * 3 / 2), endAngle: CGFloat(Double.pi / 2 + Double.pi * 5), clockwise: true)
            
            _indefiniteAnimatedLayer = CAShapeLayer()
            _indefiniteAnimatedLayer?.contentsScale = UIScreen.main.scale
            _indefiniteAnimatedLayer?.frame = CGRect(x: 0.0, y: 0.0, width: arcCenter.x * 2, height: arcCenter.y * 2)
            _indefiniteAnimatedLayer?.fillColor = UIColor.clear.cgColor
            _indefiniteAnimatedLayer?.strokeColor = strokeColor.cgColor
            _indefiniteAnimatedLayer?.lineWidth = strokeThickness
            _indefiniteAnimatedLayer?.lineCap = .round
            _indefiniteAnimatedLayer?.lineJoin = .bevel
            _indefiniteAnimatedLayer?.path = smoothedPath.cgPath
            
            let maskLayer = CALayer()
            guard let path = LDProgressHUD.imageBundle.path(forResource: "angle-mask", ofType: "png") else {
                return nil
            }
            
            maskLayer.contents = UIImage(contentsOfFile: path)?.cgImage as Any
            maskLayer.frame = _indefiniteAnimatedLayer?.bounds ?? .zero
            _indefiniteAnimatedLayer?.mask = maskLayer
            
            let animationDuration: TimeInterval = 1.0
            let linearCurve = CAMediaTimingFunction(name: .linear)
            
            let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotationAnimation.fromValue = 0
            rotationAnimation.toValue = Double.pi * 2
            rotationAnimation.duration = animationDuration
            rotationAnimation.timingFunction = linearCurve
            rotationAnimation.isRemovedOnCompletion = false
            rotationAnimation.repeatCount = .infinity
            rotationAnimation.fillMode = .forwards
            rotationAnimation.autoreverses = false
            
            _indefiniteAnimatedLayer?.mask?.add(rotationAnimation, forKey: "rotate")
            
            let animationGroup = CAAnimationGroup()
            animationGroup.duration = animationDuration
            animationGroup.repeatCount = .infinity
            animationGroup.isRemovedOnCompletion = false
            animationGroup.timingFunction = linearCurve
            
            let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
            strokeStartAnimation.fromValue = 0.015
            strokeStartAnimation.toValue = 0.515
            
            let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
            strokeEndAnimation.fromValue = 0.485
            strokeEndAnimation.toValue = 0.985
            
            animationGroup.animations = [strokeStartAnimation, strokeEndAnimation]
            _indefiniteAnimatedLayer?.add(animationGroup, forKey: "progress")
        }
        
        return _indefiniteAnimatedLayer
    }

    override var frame: CGRect {
        didSet {
            if frame != oldValue {
                super.frame = frame
                if superview != nil {
                    layoutAnimatedLayer()
                }
            }
        }
    }

    @IBInspectable var radius: CGFloat = 0 {
        didSet {
            if radius != oldValue {
                _indefiniteAnimatedLayer?.removeFromSuperlayer()
                _indefiniteAnimatedLayer = nil

                if superview != nil {
                    layoutAnimatedLayer()
                }
            }
        }
    }

    @IBInspectable var strokeColor: UIColor = .black {
        didSet {
            _indefiniteAnimatedLayer?.strokeColor = strokeColor.cgColor
        }
    }

    @IBInspectable var strokeThickness: CGFloat = 1.0 {
        didSet {
            _indefiniteAnimatedLayer?.lineWidth = strokeThickness
        }
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: (radius + strokeThickness / 2 + 5) * 2,
                      height: (radius + strokeThickness / 2 + 5) * 2)
    }
}
