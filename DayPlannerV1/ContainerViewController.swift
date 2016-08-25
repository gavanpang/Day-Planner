//
//  ContainerViewController.swift
//  DayPlannerV1
//
//  Created by Gavan Pang on 21/07/2016.
//  Copyright © 2016 Gavan Pang. All rights reserved.
//

import UIKit
import QuartzCore

enum SlideOutState {
    case BothCollapsed
    case LeftPanelExpanded
    case RightPanelExpanded
}

class ContainerViewController : UIViewController {
    
    var currentState: SlideOutState = SlideOutState.BothCollapsed {
        didSet {
            let shouldShowShadow = currentState != .BothCollapsed
            showShadowForCenterViewController(shouldShowShadow)
        }
    }
    
    var centerNavigationController  : UINavigationController!;
    var centerViewController        : CenterViewController!;
    var leftViewController          : LeftPanelViewController?;
    var rightViewController         : RightPanelViewController?;
    
    let centerPanelExpandedOffset: CGFloat = 35;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centerViewController = UIStoryboard.centerViewController();
        centerViewController.delegate = self;
        
        // wrap the centerViewController in a navigation controller, so we can push views to it
        // and display bar button items in the navigation bar
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerNavigationController.setNavigationBarHidden(true, animated: false);
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
    }
    
}

// MARK: CenterViewController delegate

extension ContainerViewController: CenterViewControllerDelegate {
    
    // The following are delegate methods for CenterViewController
    func toggleLeftPanel() {
        
        let notAlreadyExpanded = (currentState != SlideOutState.LeftPanelExpanded);
        
        if notAlreadyExpanded {
            addLeftPanelViewController();
        }
        
        animateLeftPanel(notAlreadyExpanded);
    }
    
    func toggleRightPanel() {

        let notAlreadyExpanded = (currentState != SlideOutState.RightPanelExpanded);
        
        if notAlreadyExpanded {
            addRightPanelViewController();
        }
        
        animateRightPanel(notAlreadyExpanded);
    }
    
    func collapseSidePanels() {
        switch (currentState) {
            case SlideOutState.RightPanelExpanded:
                toggleRightPanel()
            case SlideOutState.LeftPanelExpanded:
                toggleLeftPanel()
            default:
                break
        }
    }
    
    func leftOrRightPanelIsOpen() -> Bool {
        if(currentState == SlideOutState.BothCollapsed) {
            return false;
        } else {
            return true;
        }
    }
    
    // The following are internal functions for animating views
    func addLeftPanelViewController() {
        if (leftViewController == nil) {
            leftViewController = UIStoryboard.leftViewController();
            
            addChildLeftPanelController(leftViewController!);
        }
    }
    
    func addRightPanelViewController() {
        if (rightViewController == nil) {
            rightViewController = UIStoryboard.rightViewController();
            
            addChildRightPanelController(rightViewController!);
        }
    }
    
    func addChildLeftPanelController(leftPanelController: LeftPanelViewController) {
        leftPanelController.delegate = self.centerViewController;
        
        view.insertSubview(leftPanelController.view, atIndex: 0)
        
        addChildViewController(leftPanelController)
        leftPanelController.didMoveToParentViewController(self)
    }
    
    func addChildRightPanelController(rightPanelController: RightPanelViewController) {
        rightPanelController.delegate = self.centerViewController;
        
        view.insertSubview(rightPanelController.view, atIndex: 0)
        
        addChildViewController(rightPanelController)
        rightPanelController.didMoveToParentViewController(self)
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = SlideOutState.LeftPanelExpanded
            
            animateCenterPanelXPosition(CGRectGetWidth(centerNavigationController.view.frame) - centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { _ in
                self.currentState = SlideOutState.BothCollapsed
                
                self.leftViewController!.view.removeFromSuperview()
                self.leftViewController = nil;
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .CurveEaseInOut, animations: {
            self.centerNavigationController.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func animateRightPanel(shouldExpand: Bool) {
        if (shouldExpand) {
            currentState = SlideOutState.RightPanelExpanded
            
            animateCenterPanelXPosition(-CGRectGetWidth(centerNavigationController.view.frame) + centerPanelExpandedOffset)
        } else {
            animateCenterPanelXPosition(0) { _ in
                self.currentState = SlideOutState.BothCollapsed
                
                self.rightViewController!.view.removeFromSuperview()
                self.rightViewController = nil;
            }
        }
    }
    
    func showShadowForCenterViewController(shouldShowShadow: Bool) {
        if (shouldShowShadow) {
            centerNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            centerNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}


private extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()) }
    
    class func leftViewController() -> LeftPanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LeftViewController") as? LeftPanelViewController
    }
    
    class func rightViewController() -> RightPanelViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("RightViewController") as? RightPanelViewController
    }
    
    class func centerViewController() -> CenterViewController? {
        return mainStoryboard().instantiateViewControllerWithIdentifier("CenterViewController") as? CenterViewController
    }
}