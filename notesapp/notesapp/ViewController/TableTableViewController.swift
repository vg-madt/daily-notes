//
//  TableTableViewController.swift
//  notesapp
//
//  Created by admin on 6/14/20.
//  Copyright © 2020 admin. All rights reserved.
//

import UIKit
import CoreData

class TableTableViewController: UITableViewController, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var cellTitle: UILabel!
    @IBOutlet weak var cellDate: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    lazy var resultsController: NSFetchedResultsController<Note> = NSFetchedResultsController.init()
    var titleController: NSFetchedResultsController<Note>!
    let coreDataManager = CoreDataManager()
    var item : [NSManagedObject] = []
    var newNote: Note? = nil

    override func viewDidLoad() {
            super.viewDidLoad()
            searchBar.delegate = self
        //resultsController.delegate = self
           loadData()
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
          
        }
        
        func loadData(){
            let request: NSFetchRequest<Note> = Note.fetchRequest()
            let sortDescriptors = NSSortDescriptor(key: "date", ascending: true)
            request.sortDescriptors = [sortDescriptors]
            resultsController = NSFetchedResultsController(
                
                fetchRequest: request,
                managedObjectContext: coreDataManager.managedContext,
                sectionNameKeyPath: nil,
                cacheName: nil)
            
            resultsController.delegate = self
            do{
                try resultsController.performFetch()
                print("sorted by date")
                //tableView.reloadData()
            } catch {
                print("Perform fetch error: \(error)")
            }
            
        }
    func sortByTitle(){
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let sortDescriptors = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptors]
        resultsController = NSFetchedResultsController(
            
            fetchRequest: request,
            managedObjectContext: coreDataManager.managedContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        resultsController.delegate = self
        do{
            try resultsController.performFetch()
            print("sorted by title")
            //tableView.reloadData()
        } catch {
            print("Perform fetch error: \(error)")
        }
        
        
    }
    
    @objc func segmentChanged(){
        switch segment.selectedSegmentIndex {
        case 0:
           // self.resultsController = nil
            loadData()
            //tableView.reloadData()
        case 1:
            //self.resultsController = nil
            sortByTitle()
            //tableView.reloadData()
        default:
            loadData()
        }
        tableView.reloadData()
    }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            newNote = nil
            
            if segment.selectedSegmentIndex == 0{
            loadData()
            tableView.reloadData()
            } else if segment.selectedSegmentIndex == 1{
                sortByTitle()
                tableView.reloadData()
            }
        }
    
    
        
        
        
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            var predicate: NSPredicate?
            if searchText != ""
            {
               predicate = NSPredicate(format: "title contains[cd] %@", searchText)
                
            }else{
                
            }
            
            resultsController.fetchRequest.predicate = predicate
            do{
                try resultsController.performFetch()
                tableView.reloadData()
            }catch let err{
                print(err)
            }
        }

        // MARK: - Table view data source



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            // #warning Incomplete implementation, return the number of rows
        /*if segment.selectedSegmentIndex == 0{
        loadData()
            print("by date")
        } else if segment.selectedSegmentIndex == 1{
            sortByTitle()
            print("by title")
        }*/
            return resultsController.sections?[section].numberOfObjects ?? 0
        }
       
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
        /*if segment.selectedSegmentIndex == 0{
        loadData()
        }else if segment.selectedSegmentIndex == 1{
            sortByTitle()
        }*/
        //tableView.reloadData()
         
            
            let note = resultsController.object(at: indexPath)
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("EEE MMM d yyyy")
            
            cell.textLabel?.text = note.title
            cell.detailTextLabel?.text = "\(dateFormatter.string(from: note.date!))"
            return cell
        
        }
        
       override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let action = UIContextualAction(style: .destructive, title: "Delete"){
                (action, view, completion) in
                let note = self.resultsController.object(at: indexPath)
                self.resultsController.managedObjectContext.delete(note)
                do{
                    try self.resultsController.managedObjectContext.save()
                    completion(true)
                }
                catch{
                    print("delete failed: \(error)")
                    completion(false)
                }
               
            }
            
            
            action.backgroundColor = .red
            return UISwipeActionsConfiguration(actions: [action])
        }
        
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.beginUpdates()
        }
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.endUpdates()
        }
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            switch type{
            case .insert:
                if let indexPath = newIndexPath{
                    tableView.insertRows(at: [indexPath], with: .automatic)
                }
            case .delete:
                if let indexPath = indexPath{
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            default:
                break
            }
        }
    
    
     
        

       
        
        // MARK: - Navigation

        // In a storyboard-based application, you will often want to do a little preparation before navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            // Get the new view controller using segue.destination.
            // Pass the selected object to the new view controller.
            //let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath)
            if let _ = sender as? UIBarButtonItem, let vc = segue.destination as? AddNotesViewController {
                vc.selectedNote = newNote
                vc.managedContext = resultsController.managedObjectContext
            }
            else if let _ = sender as? UITableViewCell, let vc = segue.destination as? AddNotesViewController{
                if let index = self.tableView.indexPathForSelectedRow{
                    vc.selectedNote = resultsController.object(at: index)
                    vc.managedContext = resultsController.managedObjectContext
                }
                
            }
            
        }
        

        

    }


