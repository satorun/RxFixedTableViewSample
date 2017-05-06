//
//  ListViewController.swift
//  RxFixedTableViewSample
//
//  Created by satorun on 2017/05/06.
//  Copyright © 2017年 satorun. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tableViewContentSize = Variable<CGSize>(CGSize.zero)
    var insetHeigt: CGFloat = 0.0 {
        didSet {
            tableView.reloadData()
        }
    }
    
    fileprivate var dataSource: ListViewControllerDataSource? {
        didSet {
            tableView.dataSource = dataSource
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.addObserver(self, forKeyPath: "contentSize", options: [.old, .new], context: nil)
        tableView.showsVerticalScrollIndicator = false
        dataSource = ListViewControllerDataSource()
    }
    
    deinit {
        tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            if let newValue = change?[.newKey] as? CGSize,
                let oldValue = change?[.oldKey] as? CGSize,
                newValue.height != 0.0,
                oldValue.height != newValue.height {
                tableViewContentSize.value = newValue
            }
        }
    }
}

class ListViewControllerDataSource: NSObject, UITableViewDataSource {
    enum Section: Int {
        case inset
        case data
        case loading
        case error
        
        static var allValues: [Section] {
            return [.inset, .data, .loading, .error]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allValues.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sec = Section(rawValue: section) else { return 0 }
        switch sec {
        case .inset:
            return 1
        case .data:
            return 100
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let sec = Section(rawValue: indexPath.section)!
        
        switch sec {
        case .data:
            cell.textLabel?.text = "\(indexPath.section)-\(indexPath.row)"
        default:
            break
        }
        return cell
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        typealias Section = ListViewControllerDataSource.Section
        guard let sec = Section(rawValue: indexPath.section) else { return 0 }

        switch sec {
        case .inset:
            return insetHeigt
        default:
            return 44
        }
    }
}
