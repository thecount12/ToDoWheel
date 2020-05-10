//
//  SpokeViewController.swift
//  ToDoWheel
//
//  Created by William Gunnells on 5/3/20.
//  Copyright © 2020 William Gunnells. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class SpokeViewController: UITableViewController {

    var spokes = [Spoke]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSpokes()
        tableView.rowHeight = 80.0
    }

    // MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return spokes.count
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "SpokeCell", for: indexPath)
//        cell.textLabel?.text = spokes[indexPath.row].spoke_name
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SpokeCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = spokes[indexPath.row].spoke_name
        cell.delegate = self
        return cell
    }
    
    // MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCategory", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CategoryViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedSpoke = spokes[indexPath.row]
        }
    }
    
       
    // MARK: - Data Manipulation Methods
       
    func saveSpokes() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
//        tableView.reloadData()
    }
    
    
    func loadSpokes () {
        let request : NSFetchRequest<Spoke> = Spoke.fetchRequest()
        do {
        spokes = try context.fetch(request)
        } catch {
            print("Error loading categories \(error)")
        }
        tableView.reloadData()
    }
    
    // MARK: - Add New Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add detail Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newItem = Spoke(context: self.context)
            print("Success!")
            print(textField.text!)
            newItem.spoke_name = textField.text!
            self.spokes.append(newItem)
            self.saveSpokes()
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
        alertTextField.placeholder = "Create new item"
        textField = alertTextField
        print(alertTextField.text!)
         }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
}

extension SpokeViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("Item deleted")
            self.context.delete(self.spokes[indexPath.row])
            self.spokes.remove(at: indexPath.row)
            self.saveSpokes()
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon.png")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        // options.transitionStyle = .border
        return options
    }
}
