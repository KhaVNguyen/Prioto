//
//  ConcentricProgressRing.swift
//
//  Created by Daniel Loewenherz on 6/30/16.
//  Copyright © 2016 Lionheart Software, LLC. All rights reserved.
//

import UIKit

public struct ProgressRing {
    public var width: CGFloat?
    public var color: UIColor?
    public var backgroundColor: UIColor?

    public init?(color: UIColor? = nil, backgroundColor: UIColor? = nil, width: CGFloat? = nil) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.width = width
    }

    public init(color: UIColor, backgroundColor: UIColor? = nil, width: CGFloat) {
        self.color = color
        self.backgroundColor = backgroundColor
        self.width = width
    }
}

public class ProgressRingLayer: CAShapeLayer {
    var completion: (Void -> Void)?

    public var progress: CGFloat? {
        get {
            return strokeEnd
        }

        set {
            strokeEnd = newValue ?? 0
        }
    }

    public init(center: CGPoint, radius: CGFloat, width: CGFloat, color: UIColor) {
        super.init()

        let bezier = UIBezierPath(arcCenter: center, radius: radius, startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(M_PI * 2 - M_PI_2), clockwise: true)
        delegate = self
        path = bezier.CGPath
        fillColor = UIColor.clearColor().CGColor
        strokeColor = color.CGColor
        lineWidth = width
        lineCap = kCALineCapRound
        strokeStart = 0
        strokeEnd = 0
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(layer: AnyObject) {
        super.init(layer: layer)
    }

    public func setProgress(progress: CGFloat, duration: CGFloat, completion: (Void -> Void)? = nil) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = strokeEnd
        animation.toValue = progress
        animation.duration = CFTimeInterval(duration)
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)

        strokeEnd = progress
        addAnimation(animation, forKey: "strokeEnd")
    }

    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag {
            completion?()
        }
    }
}

public final class CircleLayer: ProgressRingLayer {
    override init(center: CGPoint, radius: CGFloat, width: CGFloat, color: UIColor) {
        super.init(center: center, radius: radius, width: width, color: color)
        progress = 1
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

enum ConcentricProgressRingViewError: ErrorType {
    case InvalidParameters
}

 public final class ConcentricProgressRingView: UIView, SequenceType {
    public var arcs: [ProgressRingLayer] = []
    var circles: [CircleLayer] = []

    @available(*, unavailable, message="Progress rings without a color, width, or progress set (such as those provided) can't be used with this initializer. Please use the other initializer that accepts default values.")
    public init?(center: CGPoint, radius: CGFloat, margin: CGFloat, rings: [ProgressRing?]) {
        return nil
    }

    public convenience init(center: CGPoint, radius: CGFloat, margin: CGFloat, rings theRings: [ProgressRing?], defaultColor: UIColor? = UIColor.whiteColor(), defaultBackgroundColor: UIColor = UIColor.clearColor(), defaultWidth: CGFloat?) throws {
        var rings: [ProgressRing] = []

        for ring in theRings {
            guard var ring = ring else {
                continue
            }

            guard let color = ring.color ?? defaultColor,
                let width = ring.width ?? defaultWidth else {
                    throw ConcentricProgressRingViewError.InvalidParameters
            }

            let backgroundColor = ring.backgroundColor ?? defaultBackgroundColor

            ring.color = color
            ring.backgroundColor = backgroundColor
            ring.width = width
            rings.append(ring)
        }

        self.init(center: center, radius: radius, margin: margin, rings: rings)
    }

    public init(center: CGPoint, radius: CGFloat, margin: CGFloat, rings: [ProgressRing]) {
        let frame = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2)
        let theCenter = CGPointMake(radius, radius)

        super.init(frame: frame)

        var offset: CGFloat = 0
        for ring in rings {
            let color = ring.color!
            let width = ring.width!

            let radius = radius - (width / 2) - offset
            offset = offset + margin + width

            if let backgroundColor = ring.backgroundColor {
                let circle = CircleLayer(center: theCenter, radius: radius, width: width, color: backgroundColor)
                circles.append(circle)
                layer.addSublayer(circle)
            }

            let arc = ProgressRingLayer(center: theCenter, radius: radius, width: width, color: color)
            arcs.append(arc)
            layer.addSublayer(arc)
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public subscript(index: Int) -> ProgressRingLayer {
        return arcs[index]
    }

    public func generate() -> IndexingGenerator<[ProgressRingLayer]> {
        return arcs.generate()
    }
}
