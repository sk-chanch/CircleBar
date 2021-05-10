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
import RxViewController

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
    
    @IBInspectable var imageSize:CGSize = .init(width: 30, height: 30) {
        didSet{
            circleImageView?.image = image(with: self.tabBar.selectedItem?.image ?? self.tabBar.items?.first?.image, scaledTo: imageSize)
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.circleView = UIView(frame: .zero)
        circleView.layer.cornerRadius = 30
        circleView.backgroundColor = tabBar.barTintColor ?? .white
        circleView.isUserInteractionEnabled = false
        
        self.circleImageView = UIImageView(frame: .zero)
        circleImageView.layer.cornerRadius = 30
        circleImageView.isUserInteractionEnabled = false
        circleImageView.contentMode = .center
        
        circleView.layer.shadowColor = UIColor.lightGray.cgColor
        circleView.layer.shadowOpacity = 0.7
        circleView.layer.shadowRadius = 3
        circleView.layer.shadowOffset = CGSize(width: 1, height: 2)
        circleView.layer.shouldRasterize = true
        circleView.layer.rasterizationScale = UIScreen.main.scale
        
        circleView.addSubview(circleImageView)
        self.view.addSubview(circleView)
        let tabWidth = self.view.bounds.width / CGFloat(self.tabBar.items?.count ?? 4)
        
        circleView.frame = CGRect(x: tabWidth / 2 - 30,
                                  y: self.tabBar.frame.origin.y - 40,
                                  width: 60,
                                  height: 60)
        circleImageView.frame = self.circleView.bounds
        
        
        rx.navigationState
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{[weak self] state in
                switch state {
                case let .didShow(controller,  animate):
                    if !controller.hidesBottomBarWhenPushed {
                        guard animate else {
                            self?.circleView.transform = .identity
                            return
                        }
                        self?.circleView.transform = .identity
                       
                        self?.animateSlideUp()
                    }
                    
                   
                    break
                    
                case let .willShow(controller,  animate):
                   
                   
                    if controller.hidesBottomBarWhenPushed {
                        
                        
                        let customSelectIndex = self?.selectedIndex
                        let itemWidth  =  Int(self?.view.bounds.width ?? 0) / (self?.tabBar.items?.count ?? 0)
                        let offsetX = CGFloat(itemWidth * ((customSelectIndex ?? 0) + 1))
                        
                        
                        guard animate else {
                            self?.circleView.alpha = 0
                            self?.circleView.transform = .identity
                            return
                        }
                        
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
                            
                            self?.circleView.alpha = 0
                           
                            self?.circleView.transform = .init(translationX:  -offsetX,
                                                               y:0)
                            
                        }, completion: {[weak self] in
                            if $0 {
                                self?.customTabbar?.previousIndex = CGFloat(self?.selectedIndex ?? 0)
                            }
                        })
                       
                    }
                }
            }).disposed(by: disposeBag)
        
        
        rx.viewDidLayoutSubviews
            .take(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext:{[weak self] in
                
                self?.animateSlideUp()
            }).disposed(by: disposeBag)
    
    
    }
    
    private func animateSlideUp(){
        circleView.setY(with: view.frame.height)
        let y =   tabBar.frame.origin.y  - 15
        
        circleImageView.tintColor = imageColor
        
        UIView.animate(withDuration: 0.3){[weak self] in
            self?.circleView.alpha = 1
            self?.circleView.setY(with: y)
        }
    }
    
  
   
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        circleImageView.image = image(with: self.tabBar.selectedItem?.image ?? self.tabBar.items?.first?.image, scaledTo: imageSize)
        
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
            UIView.animate(withDuration: 0.3) {[weak self] in
                guard let self  = self else{return}
                self.circleView.frame = CGRect(x: (tabWidth * CGFloat(idx) + tabWidth / 2 - 30),
                                               y: self.tabBar.frame.origin.y - 15, width: 60, height: 60)
            }
            UIView.animate(withDuration: 0.15, animations: {[weak self] in
                self?.circleImageView.alpha = 0
            }) {[weak self] (_) in
                guard let self = self else{
                    return
                }
                self.circleImageView.image = self.image(with: item.image, scaledTo: self.imageSize)
                UIView.animate(withDuration: 0.15, animations: {[weak self] in
                    self?.circleImageView.alpha = 1
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


extension UITabBarController{
    var circleBar:SHCircleBar?{
        tabBar as? SHCircleBar
    }
}



extension Reactive where Base:UITabBarController{
    
    enum NavigationState {
        case willShow(viewController: UIViewController, animated: Bool)
        case didShow(viewController: UIViewController, animated: Bool)
    }
    
    var willShow:Observable<NavigationState>{
        let navList = base.viewControllers?
            .filter{$0 is UINavigationController}
            .map{$0 as? UINavigationController}
            .map{$0?.rx.willShow.asObservable() ?? .empty()} ?? []
        return Observable.merge(navList)
            .map{NavigationState.willShow(viewController: $0, animated: $1)}
    }
    
    
    var didShow:Observable<NavigationState>{
        let navList = base.viewControllers?
            .filter{$0 is UINavigationController}
            .map{$0 as? UINavigationController}
            .map{$0?.rx.didShow.asObservable() ?? .empty()} ?? []
        return Observable.merge(navList)
            .map{NavigationState.didShow(viewController: $0, animated: $1)}
    }
    
    var navigationState:Observable<NavigationState>{
        Observable.merge(willShow, didShow)
    }
}
