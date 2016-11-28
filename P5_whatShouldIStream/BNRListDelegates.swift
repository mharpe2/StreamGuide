//
//  BNRListDelegates.swift
//  P5_whatShouldIStream
//
//  Created by Michael Harper on 11/1/16.
//  Copyright © 2016 MJH. All rights reserved.
//

import CoreData
import UIKit

//MARK: BNR Delegate

//MARK: TableView Delegate

class ListFetchedResultsTableViewControllerDelegate: FetchedResultsControllerDelegate {
    
    private weak var tableView: UITableView?
    
    // MARK: - Lifecycle
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    func fetchedResultsControllerDidPerformFetch(controller: FetchedResultsController<List>) {
        tableView?.reloadData()
    }
    
    func fetchedResultsControllerWillChangeContent(controller: FetchedResultsController<List>) {
        tableView?.beginUpdates()
    }
    
    func fetchedResultsControllerDidChangeContent(controller: FetchedResultsController<List>) {
        tableView?.endUpdates()
    }
    
    func fetchedResultsController(controller: FetchedResultsController<List>,
                                  didChangeObject change: FetchedResultsObjectChange<List>) {
        switch change {
        case let .Insert(_, indexPath):
            tableView?.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
        case let .Delete(_, indexPath):
            tableView?.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            
        case let .Move(_, fromIndexPath, toIndexPath):
            tableView?.moveRowAtIndexPath(fromIndexPath, toIndexPath: toIndexPath)
            
        case let .Update(_, indexPath):
            tableView?.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    func fetchedResultsController(controller: FetchedResultsController<List>,
                                  didChangeSection change: FetchedResultsSectionChange<List>) {
        switch change {
        case let .Insert(_, index):
            tableView?.insertSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
            
        case let .Delete(_, index):
            tableView?.deleteSections(NSIndexSet(index: index), withRowAnimation: .Automatic)
        }
    }
}
