//
//  SHCircleBarController.swift
//  SHCircleBar
//
//  Created by Adrian Perțe on 19/02/2019.
//  Copyright © 2019 softhaus. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
open class SHCircleBarController: UITabBarController {

    private let disposeBag = DisposeBag()
    fileprivate var shouldSelectOnTabBar = true
    private var circleView : UIView!
    private var circleImageView: UIImageView!
    open override var selectedViewController: UIViewController? {
        willSet {
            guard shouldSelectOnTabBar, let newValue = newValue else {
                shouldSelectOnTabBar = true
                return
            }
            guard let tabBar = tabBar as? SHCircleBar, let index = viewControllers?.index(of: newValue) else {return}
            tabBar.select(itemAt: index, animated: true)
        }
    }
    
    open override var selectedIndex: Int {
        willSet {
            guard shouldSelectOnTabBar else {
                shouldSelectOnTabBar = true
                return
            }
            guard let tabBar = tabBar as? SHCircleBar else {
                return
            }
            tabBar.select(itemAt: selectedIndex, animated: true)
        }
    }
    
    private var customTabbar:SHCircleBar?{
        tabBar as? SHCircleBar
    }
    
    @IBInspectable var imageColor:UIColor = .white{
        didSet{
            circleImageView?.tintColor = imageColor
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.circleView = UIView(frame: .zero)
        circleView.layer.cornerRadius = 30
        circleView.backgroundColor = .white
        circleView.isUserInteractionEnabled = false
        
        self.circleImageView = UIImageView(frame: .zero)
        circleImageView.layer.cornerRadius = 30
        circleImageView.isUserInteractionEnabled = false
        circleImageView.contentMode = .center
        
        circleView.addSubview(circleImageView)
        self.view.addSubview(circleView)
        let tabWidth = self.view.bounds.width / CGFloat(self.tabBar.items?.count ?? 4)
        
        circleView.frame = CGRect(x: tabWidth / 2 - 30,
                                  y: self.tabBar.frame.origin.y - 40,
                                  width: 60,
                                  height: 60)
        circleImageView.frame = self.circleView.bounds
        
        
        let navList = viewControllers?
            .filter{$0 is UINavigationController}
            .map{$0 as? UINavigationController}
        
        
        let navWillShowList = navList?
            .map{$0?.rx.willShow.asObservable() ?? .empty()} ?? []
        
        
        let navDidShowList = navList?
            .map{$0?.rx.didShow.asObservable() ?? .empty()} ?? []
        
        
       Observable.merge(navDidShowList)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{[weak self] v in
                if !v.viewController.hidesBottomBarWhenPushed {
                    self?.circleView.transform = .identity
                    UIView.animate(withDuration: 0.5){
                        self?.circleView.alpha = 1
                    }
                }
            }).disposed(by: disposeBag)
        
        
        Observable.merge(navWillShowList)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{[weak self] v in
                if v.viewController.hidesBottomBarWhenPushed {
                   
                    UIView.animate(withDuration: 0.45, delay: 0, options: .curveEaseOut){
                        self?.circleView.alpha = 0
                        let customSelectIndex = self?.selectedIndex//self?.selectedIndex == 0 ? 1:self?.selectedIndex
                        let itemWidth  =  Int(self?.view.bounds.width ?? 0) / (self?.tabBar.items?.count ?? 0)
                        let offsetX = CGFloat(itemWidth * ((customSelectIndex ?? 0) + 1))
                        self?.circleView.transform = .init(translationX:  -offsetX,
                                                           y:0)
                        
                        self?.customTabbar?.previousIndex = CGFloat(self?.selectedIndex ?? 0)
                    }
                }
            }).disposed(by: disposeBag)
        
        
        view.rx.viewWillAppear
            .take(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{[weak self] in
                
                self?.circleView.setY(with: self?.view.frame.height ?? 0)
                let safeBottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
                let y =   (self?.tabBar.frame.origin.y ?? 0) - (safeBottom) - 15
                
                self?.circleImageView.tintColor = self?.imageColor
                
                UIView.animate(withDuration: 0.3){
                    self?.circleView.setY(with: y)
                }
            }).disposed(by: disposeBag)
    
    
    }
    
  
   
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        circleImageView.image = image(with: self.tabBar.selectedItem?.image ?? self.tabBar.items?.first?.image, scaledTo: CGSize(width: 30, height: 30))
        
    }
    
    private var _barHeight: CGFloat = 74
    open var barHeight: CGFloat {
        get {
            if #available(iOS 11.0, *) {
                return _barHeight + view.safeAreaInsets.bottom
            } else {
                return _barHeight
            }
        }
        set {
            _barHeight = newValue
            updateTabBarFrame()
        }
    }
    
    private func updateTabBarFrame() {
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = barHeight
        tabFrame.origin.y = self.view.frame.size.height - barHeight
        self.tabBar.frame = tabFrame
        tabBar.setNeedsLayout()
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateTabBarFrame()
    }
    
    open override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
        }
        updateTabBarFrame()
    }
    
    open override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.index(of: item) else { return }
        if  idx != selectedIndex, let controller = viewControllers?[idx] {
            shouldSelectOnTabBar = false
            selectedIndex = idx
            let tabWidth = self.view.bounds.width / CGFloat(self.tabBar.items!.count)
            UIView.animate(withDuration: 0.3) {
                self.circleView.frame = CGRect(x: (tabWidth * CGFloat(idx) + tabWidth / 2 - 30), y: self.tabBar.frame.origin.y - 15, width: 60, height: 60)
            }
            UIView.animate(withDuration: 0.15, animations: {
                self.circleImageView.alpha = 0
            }) { (_) in
                self.circleImageView.image = self.image(with: item.image, scaledTo: CGSize(width: 30, height: 30))
                UIView.animate(withDuration: 0.15, animations: {
                    self.circleImageView.alpha = 1
                })
            }
            delegate?.tabBarController?(self, didSelect: controller)
        }
    }
    private func image(with image: UIImage?, scaledTo newSize: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, _: false, _: 0.0)
        image?.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage?.withRenderingMode(.alwaysTemplate)
    }
    
}


internal extension UIView{
    func setY(with y:CGFloat){
        frame = .init(x: frame.origin.x,
                      y: y,
                      width: frame.width,
                      height: frame.height)
    }
}


internal extension Reactive where Base:UIView{
  
    var willMoveToWindow: Observable<Bool> {
        return self.sentMessage(#selector(Base.willMove(toWindow:)))
            .map({ $0.filter({ !($0 is NSNull) }) })
            .map({ $0.isEmpty == false })
    }
    
    var viewWillAppear: Observable<()> {
        return self.willMoveToWindow
            .filter({ $0 })
            .map({ _ in Void() })
    }
   
    
}



