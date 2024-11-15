//
//  UINavigationController+.swift
//  ranchat
//
//  Created by 김견 on 11/15/24.
//

import SwiftUI

extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    // 백 제스쳐 강제 구현
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
