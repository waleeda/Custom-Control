//
//  UISelectionControl.swift
//  CustomControl
//
//  Created by waleed azhar on 2017-04-03.
//  Copyright © 2017 waleed azhar. All rights reserved.
//

import UIKit

//Selector Control
class UISelectionControl: UIControl {
    
    public var selectedSegment = 0 {
        didSet{
            self.segment = self.selectionState.segments[selectionState.selectedSegement]
        }
    }
    
    private var segment:SegmentState = NullSegment()
    
    private var handleView:UIView = UIView()
    
    private var containerLayer: CALayer?
    
    private var handleLayer: CALayer?
    
    private var highlight:CAShapeLayer = CAShapeLayer()
    
    private let lineCapArch:CGFloat = .pi/16
    
    fileprivate var selectionState: SelectionControlState
    
    init?(frame:CGRect, nullSegment null:Bool, with segments:Int, colors:[UIColor]) {
        
        guard segments == colors.count else {
            return nil
        }
        selectionState = SelectionControlState(handleRadian: 0.0, useNullSegment: null, isTracking: false, numberOfSegments: segments, segmentColors: colors)
        super.init(frame: frame)
        self.backgroundColor = .clear
        handleView.backgroundColor = .clear
        
    }
    
    
    override init(frame: CGRect) {
        selectionState = SelectionControlState(handleRadian: 0, useNullSegment: true, isTracking: false, numberOfSegments: 3,segmentColors:[])
        
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        handleView.backgroundColor = .clear
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        selectionState = SelectionControlState(handleRadian: 0, useNullSegment: true, isTracking: false, numberOfSegments: 3, segmentColors: [])
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
        handleView.backgroundColor = .clear
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 250, height: 250)
    }
    //set up layers
    override func layoutSubviews() {
        
        let track = CAShapeLayer()
        track.path = UIBezierPath(ovalIn: self.bounds.insetBy(dx: 22, dy: 22)).cgPath
        track.fillColor = UIColor.clear.cgColor
        track.lineWidth = 44
        track.borderWidth = 1
        track.strokeColor = UIColor(white: 1, alpha: 0.5).cgColor
        self.layer.addSublayer(track)
        
        highlight.frame = self.bounds
        highlight.lineCap = kCALineCapRound
        highlight.fillColor = UIColor.clear.cgColor
        highlight.lineWidth = 44
        layer.addSublayer(highlight)
        
        handleView.isMultipleTouchEnabled = false
        handleView.frame = self.bounds
        self.addSubview(handleView)
        
        let handle = CAShapeLayer()
        self.handleLayer = handle
        handle.frame = CGRect(origin: CGPoint(x:handleView.frame.width - 43,
                                              y: handleView.frame.height/2 - 20),
                              
                              size: CGSize(width: 44, height: 44))
        
        handle.path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 42, height: 42)).cgPath
        handle.fillColor = UIColor.white.cgColor
        handleView.layer.addSublayer(handle)
        layer.zPosition = -1000.0
        
    }
    //control state changes
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = (touches.first?.location(in: self))!
        let locationInhandle = (self.layer.convert(touchLocation, to: self.handleLayer))
        
        if (handleLayer?.contains(locationInhandle))! && !selectionState.isTracking {
            var rads:CGFloat = 0.0
            self.isSelected = true
            rads = angle(c: self.window!.center, t: touchLocation)
            selectionState.change(new: .tracking(true))
            selectionState.change(new:.radian(rads))
            setSegement()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if selectionState.isTracking {
            var rads:CGFloat = 0.0
            let touchLocation = (touches.first?.location(in: self.window!))!
            rads = angle(c: self.window!.center, t: touchLocation)
            self.selectionState.change(new: .radian(rads))
            setSegement()
            render()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if selectionState.isTracking {
            selectionState.change(new: .tracking(false))
            render()
            sendActions(for: .valueChanged)
        }
        
    }
    //render handle bar && final animations
    internal func render(){
        
        let state = selectionState
        
        if state.isTracking {
            self.handleView.layer.sublayerTransform = CATransform3DMakeRotation(state.handleRadian, 0, 0, 1)
            renderHighlight()
        }else {
            
            let finalRad:CGFloat
            // account for null segement start & end range
            if selectedSegment == 0 && state.useNullSegment{
                finalRad = state.handleRadian > segment.startRad ? 2*CGFloat.pi : 0
            } else {
                finalRad = segment.endRad
            }
            
            //animation for rotating handle to its final position
            let rotation = CABasicAnimation(keyPath: "sublayerTransform.rotation")
            rotation.fromValue = state.handleRadian
            rotation.toValue = finalRad
            rotation.duration = 0.4
            rotation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            rotation.isRemovedOnCompletion = true
            
            self.handleView.layer.sublayerTransform = CATransform3DMakeRotation(finalRad, 0, 0, 1)
            handleView.layer.add(rotation, forKey: "rotation")
            
            
            //update highlight path
            highlight.path = UIBezierPath(arcCenter: CGPoint(x:self.bounds.midX,
                                                             y: self.bounds.midY),
                                          radius: (self.bounds.midX) - 22,
                                          startAngle: segment.startRad,
                                          endAngle: segment.endRad,
                                          clockwise: true).cgPath
            
            highlight.strokeColor = segment.color
            highlight.masksToBounds = true
            
            //animation for highlight line
            let stroke = CABasicAnimation(keyPath: "strokeEnd")
            stroke.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            stroke.fromValue = (selectionState.handleRadian - segment.startRad) / (segment.endRad - segment.startRad)
            stroke.toValue = 1.0
            stroke.duration = 0.4
            highlight.add(stroke, forKey: "")
            
        }
        
    }
    
    //render highlight
    internal func renderHighlight() {
        let state = selectionState
        
        highlight.path = UIBezierPath(arcCenter: CGPoint(x:self.bounds.midX,
                                                         y: self.bounds.midY),
                                      radius: (self.bounds.midX) - 22,
                                      startAngle: segment.startRad,
                                      endAngle: state.handleRadian,
                                      clockwise: true).cgPath
        
        highlight.strokeColor = segment.color
        highlight.masksToBounds = true
    }
    // setter function
    private func setSegement(){
        let s = selectionState.selectedSegement
        if(selectedSegment != s){
            self.selectedSegment = s
            
        }
    }
    
    // helper function to calcuate the radians between positive x axis & handleBar, clockwise
    private func angle( c:CGPoint , t:CGPoint) -> CGFloat {
        
        let t2 = t - c
        
        if t2.x == 0 {
            if t2.y > 0{
                return CGFloat.pi/2.0
            } else {
                return (3.0/2.0)*CGFloat.pi
            }
        }
        let out = atan(t2.y/t2.x)
        
        if t2.x >= 0 && t2.y >= 0{
            return out
        } else if t2.x < 0 && t2.y >= 0{
            return  CGFloat.pi + out
        } else if t2.x < 0 && t2.y < 0{
            return out + CGFloat.pi
        } else if (t2.x >= 0 && t2.y < 0) {
            return 2*CGFloat.pi + out
        }
        
        return 0.0
    }
    
}

//model the state of selection controller
fileprivate struct SelectionControlState{
    
    var handleRadian:CGFloat
    var useNullSegment:Bool
    var isTracking:Bool
   
    var selectedSegement:Int {
        
        for (i,s) in self.segments.enumerated(){
            if s.contains(radian: handleRadian) {
                return i
            }
        }
        
        return 0
    }
    
    var numberOfSegments:Int
    
    fileprivate var segments:[SegmentState] {

        var result:[SegmentState] = []
        var previousRad:CGFloat = 0
        
        if useNullSegment{
            result.append(NullSegment())
            previousRad = NullSegment.radOffset
        }
        
        let offset:CGFloat = ((2 * .pi) - (2 * previousRad)) / (CGFloat(numberOfSegments))
        
        for i in 1...numberOfSegments{
            result.append(Segment(startRad: previousRad, endRad: previousRad + offset, color: segmentColors[i - 1].cgColor ?? UIColor.blue.cgColor))
            previousRad += offset
        }
        return result
    }
    let segmentColors:[UIColor]
}

// changing state
fileprivate enum SelctionStateChange{
    case tracking(Bool)
    case radian(CGFloat)
}


extension SelectionControlState{
    fileprivate mutating func change(new: SelctionStateChange) {
        switch new {
        case .radian(let a):
            self.handleRadian = a
        case .tracking(let b):
            self.isTracking = b
        }
    }
    
}

//segment model
fileprivate protocol SegmentState {
    var startRad:CGFloat {get}
    var endRad:CGFloat {get}
    var color:CGColor {get}
}

struct Segment: SegmentState{
    let startRad:CGFloat
    let endRad:CGFloat
    let color:CGColor
}

extension SegmentState{
    func contains(radian: CGFloat) -> Bool {
        return self.startRad <= radian && radian <= self.endRad
    }
}

struct NullSegment:SegmentState {
    static let radOffset:CGFloat = .pi/4
    let startRad:CGFloat = (2.0 * .pi) - radOffset
    let endRad:CGFloat = radOffset
    let color:CGColor =  UIColor.black.cgColor
}


extension CGPoint{
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}




