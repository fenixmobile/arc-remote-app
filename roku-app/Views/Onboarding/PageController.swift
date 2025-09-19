//
//  PageController.swift
//  roku-app
//
//  Created by Ali İhsan Çağlayan on 18.09.2025.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var contentControllers: [UIViewController] = []
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        swipeOff()
        setupOnboardingFlow()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupOnboardingFlow() {
        let onboardingVC1 = OnboardingVC1()
        let onboardingVC2 = OnboardingVC2()
        let onboardingVC3 = OnboardingVC3()
        let onboardingRatingVC = OnboardingRatingVC()
        
        contentControllers = [
            onboardingVC1,
            onboardingVC2,
            onboardingVC3,
            onboardingRatingVC
        ]
        print("Initial Controllers:", contentControllers.map { type(of: $0) })
        
        if let firstViewController = contentControllers.first {
            setViewControllers([firstViewController],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    func swipeOff() {
        for view in view.subviews {
            if let scrollView = view as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = contentControllers.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return contentControllers[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = contentControllers.firstIndex(of: viewController), currentIndex < contentControllers.count - 1 else {
            return nil
        }
        return contentControllers[currentIndex + 1]
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = viewControllers?.first,
           let currentIndex = contentControllers.firstIndex(of: currentViewController) {
            (contentControllers[currentIndex] as? OnboardingVC1)?.pageControl.currentPage = currentIndex
            (contentControllers[currentIndex] as? OnboardingVC2)?.pageCntrl.currentPage = currentIndex
            (contentControllers[currentIndex] as? OnboardingVC3)?.pgCntrl.currentPage = currentIndex
            (contentControllers[currentIndex] as? OnboardingRatingVC)?.cntrl.currentPage = currentIndex
        }
    }
    
    func showNextPage() {
        if let currentViewController = viewControllers?.first,
           let currentIndex = contentControllers.firstIndex(of: currentViewController),
           currentIndex < contentControllers.count - 1 {
            let nextIndex = currentIndex + 1
            //            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.setViewControllers([self.contentControllers[nextIndex]], direction: .forward, animated: false, completion: nil)
            //            }, completion: nil)
            (contentControllers[nextIndex] as? OnboardingVC1)?.pageControl.currentPage = nextIndex
            (contentControllers[nextIndex] as? OnboardingVC2)?.pageCntrl.currentPage = nextIndex
            (contentControllers[nextIndex] as? OnboardingVC3)?.pgCntrl.currentPage = nextIndex
            (contentControllers[nextIndex] as? OnboardingRatingVC)?.cntrl.currentPage = nextIndex
        } else {
            UserDefaultsManager.shared.markOnboardingCompleted()
            navigationController?.setViewControllers([MainTabBarController()], animated: false)
        }
    }
}
