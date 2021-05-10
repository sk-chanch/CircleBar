//
//  SHCircleBar.swift
//  SHCircleBar
//
//  Created by Adrian Perțe on 19/02/2019.
//  Copyright © 2019 softhaus. All rights reserved.
//

import UIKit
import RxSwift


extension ObservableType {
    func map<R>(to value: R) -> Observable<R> {
        return map {_ in value}
    }
    
    func unwrap<T>() -> Observable<T> where Element == Optional<T> {
        return self.filter { $0 != nil }.map { $0! }
    }
}


@IBDesignable class SHCircleBar: UITabBar {
    var tabWidth: CGFloat = 0
    var index: CGFloat = 0 {
        willSet{
            self.previousIndex = index
        }
    }
    private var animated = false
    private var selectedImage: UIImage?
    public var previousIndex: CGFloat = 0
    
    @IBInspectable var imageUnselectColor:UIColor = .red{
        didSet{
            unselectedItemTintColor = imageUnselectColor
        }
    }
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        customInit()
        
    }
    override func draw(_ rect: CGRect) {
        
        let fillColor: UIColor = barTintColor ?? .white
        tabWidth = self.bounds.width / CGFloat(self.items!.count)
        let bezPath = drawPath(for: index)
        
        bezPath.close()
        fillColor.setFill()
        bezPath.fill()
        let mask = CAShapeLayer()
        mask.fillRule = .evenOdd
        mask.fillColor =  (barTintColor ?? .white).cgColor
        mask.path = bezPath.cgPath
        if (self.animated) {
            CATransaction.begin()
            let bezAnimation = CABasicAnimation(keyPath: "path")
            let bezPathFrom = drawPath(for: previousIndex)
            bezAnimation.toValue = bezPath.cgPath
            bezAnimation.fromValue = bezPathFrom.cgPath
            bezAnimation.duration = 0.3
            bezAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            CATransaction.setCompletionBlock {[weak self] in
                   print("end animation")
                self?.previousIndex = self?.index ?? 0
            }
            
            mask.add(bezAnimation, forKey: nil)
            
            CATransaction.commit()
        }
        self.layer.mask = mask

    }
    
    func select(itemAt: Int, animated: Bool) {
        self.index = CGFloat(itemAt)
        self.animated = animated
        self.selectedImage = self.selectedItem?.selectedImage
        self.selectedItem?.selectedImage = nil
        self.setNeedsDisplay()
    }
    
    func customInit(){
        self.tintColor = barTintColor ?? .white
        self.barTintColor = barTintColor ?? .white
        self.backgroundColor = barTintColor ?? .white
        unselectedItemTintColor = imageUnselectColor
    }
    private func drawPath(for index: CGFloat) -> UIBezierPath {
        let bezPath = UIBezierPath()

        let firstPoint = CGPoint(x: (index * tabWidth) - 25, y: 0)
        let firstPointFirstCurve = CGPoint(x: ((tabWidth * index) + tabWidth / 4), y: 0)
        let firstPointSecondCurve = CGPoint(x: ((index * tabWidth) - 25) + tabWidth / 8, y: 52)

        let middlePoint = CGPoint(x: (tabWidth * index) + tabWidth / 2, y: 55)
        let middlePointFirstCurve = CGPoint(x: (((tabWidth * index) + tabWidth) - tabWidth / 8) + 25, y: 52)
        let middlePointSecondCurve = CGPoint(x: (((tabWidth * index) + tabWidth) - tabWidth / 4), y: 0)

        let lastPoint = CGPoint(x: (tabWidth * index) + tabWidth + 25, y: 0)
        bezPath.move(to: firstPoint)
        bezPath.addCurve(to: middlePoint, controlPoint1: firstPointFirstCurve, controlPoint2: firstPointSecondCurve)
        bezPath.addCurve(to: lastPoint, controlPoint1: middlePointFirstCurve, controlPoint2: middlePointSecondCurve)
        bezPath.append(UIBezierPath(rect: self.bounds))
        return bezPath
    }
    

}
