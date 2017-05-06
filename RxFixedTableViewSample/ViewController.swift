//
//  ViewController.swift
//  RxFixedTableViewSample
//
//  Created by satorun on 2017/05/06.
//  Copyright © 2017年 satorun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emptyView: ThroughableView!
    @IBOutlet weak var emptyViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentView: UIView!
    let contentViewMinHeight: CGFloat = 100
    
    let disposeBag = DisposeBag()
    
    var listViewController: ListViewController {
        return childViewControllers[0] as! ListViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 下のviewにタッチを通すための指定
        emptyView.targetView = listViewController.view
        
        // contentSize
        listViewController.tableViewContentSize.asObservable().bind {
            self.scrollView.contentSize = $0
            self.emptyViewHeightConstraint.constant = $0.height
        }.addDisposableTo(disposeBag)
        
        // contentOffsetを同期
        listViewController.tableView.rx.contentOffset
            .filter { $0.y != self.scrollView.contentOffset.y }
            .bind(to: self.scrollView.rx.contentOffset)
            .addDisposableTo(disposeBag)
        
        
        let scrollViewContentOffset = scrollView.rx.contentOffset.shareReplay(1)
        scrollViewContentOffset
            .filter { $0.y != self.listViewController.tableView.contentOffset.y }
            .bind(to: self.listViewController.tableView.rx.contentOffset)
            .addDisposableTo(disposeBag)
        
        scrollViewContentOffset
            .bind {
                let hiddenHeight = self.contentView.frame.size.height - self.contentViewMinHeight
                if $0.y < hiddenHeight {
                    self.contentView.frame.origin.y = 0.0
                } else {
                    self.contentView.frame.origin.y = $0.y - hiddenHeight
                }
        }.addDisposableTo(disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        listViewController.insetHeigt = contentView.frame.size.height
    }
}

class ThroughableView: UIView {
    weak var targetView: UIView?
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else {
            return nil
        }
        if hitView == self,
            let convertedPoint = targetView?.convert(point, from: self) {
            return targetView?.hitTest(convertedPoint, with: event)
        }
        return hitView
    }
}

