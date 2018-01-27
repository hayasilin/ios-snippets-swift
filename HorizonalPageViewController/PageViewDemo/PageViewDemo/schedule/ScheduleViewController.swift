//
//  ScheduleViewController.swift
//  Travostyle
//
//  Created by Jeff on 2017/5/9.
//  Copyright © 2017年 Jeff. All rights reserved.
//

import UIKit

enum PageType: Int {
    case fragment = 0
    case info
    case cost
    case plan
    case typeNumber
    
    var title: String {
        switch self {
        case .fragment:
            return "動態"
        case .info:
            return "資訊"
        case .cost:
            return "花費"
        case .plan:
            return "規劃"
        default:
            return ""
        }
    }
}

class ScheduleViewController: BaseViewController {

    @IBOutlet weak fileprivate var pageCollectionView: UICollectionView!
    @IBOutlet weak fileprivate var pageControllerView: UIView!
    
    fileprivate var nowPage: PageType = .fragment
    fileprivate var pageViewController: PageViewController?

    var initPageType = PageType.fragment

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.isTranslucent = false

        let nib = UINib(nibName: "PageCollectionViewCell", bundle: nil)

        pageCollectionView.register(nib, forCellWithReuseIdentifier: PageCollectionViewCell.identifier)

//        pageCollectionView.register(PageCollectionViewCell.self, forCellWithReuseIdentifier: PageCollectionViewCell.identifier)

        let fragmentsViewController = FirstViewController()

        let infoViewController = SecondViewController()

        let costViewController = ThirdViewController()

        pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil, controllers: [fragmentsViewController, infoViewController, costViewController])
        pageViewController?.view.frame = pageControllerView.bounds
        pageControllerView?.addSubview(pageViewController!.view)
        pageViewController?.pageDelegate = self
        addChildViewController(pageViewController!)
        
        nowPage = initPageType
        pageViewController?.set(page: nowPage)
    }

    //MARK: Event Handler
    func onTagglenewTripBtn(_ sender:UIButton){
        
    }
    
    func onTagglenewFriendBtn(_ sender:UIButton){
        
    }
}


// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ScheduleViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return PageType.typeNumber.rawValue
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / CGFloat(PageType.typeNumber.rawValue), height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageCollectionViewCell.identifier, for: indexPath) as! PageCollectionViewCell
        
        guard let pageType = PageType(rawValue:indexPath.row) else {
            assertionFailure("unknown page type \(indexPath.row).")
            return cell
        }
        cell.pageType = pageType
        
        if cell.pageType == nowPage {
            cell.isNowPage = true
        } else {
            cell.isNowPage = false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PageCollectionViewCell
        nowPage = cell.pageType
        
        collectionView.reloadData()
        pageViewController!.set(page: nowPage)
    }
}

extension ScheduleViewController: PageViewControllerDalegate {
    func pageViewController(_ pageViewController: UIPageViewController, nowPage: PageType) {
        self.nowPage = nowPage
        pageCollectionView.reloadData()
    }
}
