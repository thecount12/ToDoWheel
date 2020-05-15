//
//  ViewController.swift
//  ToDoWheel
//
//  Created by William Gunnells on 4/28/20.
//  Copyright © 2020 William Gunnells. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import ChameleonFramework

class ItemViewController: UITableViewController {

    var itemArray = [Item]()
    
    var selectedCategory : Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        tableView.rowHeight = 80.0
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory!.name
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller does not exist.")
        }
        navBar.barTintColor = UIColor(hexString: "808080")
    }

    // MARK: - Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemWheelCell", for: indexPath)
//        let item = itemArray[indexPath.row]
//        cell.textLabel?.text = item.title
        
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemWheelCell", for: indexPath) as! SwipeTableViewCell
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
//        cell.backgroundColor = UIColor(hexString: categories[indexPath.row].cat_color ?? "1D9Bf6")
        if let color = FlatWhite().darken(byPercentage:CGFloat(indexPath.row) / CGFloat(itemArray.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
        
        
//        cell.accessoryType = item.done ? .checkmark : .none
        cell.delegate = self
        return cell
        
    }

    // MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        context.delete(itemArray[indexPath.row]) // to delete items
//        itemArray.remove(at: indexPath.row)  // to delete items. 
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        saveItems()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Add button action
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        
        let alert = UIAlertController(title: "Add detail Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            let newItem = Item(context: self.context)
            print("Success!")
            print(textField.text!)
            newItem.title = textField.text!
            newItem.done = false
            newItem.parentCategory = self.selectedCategory

            self.itemArray.append(newItem)
            self.saveItems()
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
    
    // MARK: - save
    func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context \(error)")
        }
        
//        self.tableView.reloadData()
    }
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
    
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
    
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, addtionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }

    
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
    
        tableView.reloadData()
    }
   


}

extension ItemViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        loadItems(with: request, predicate: predicate)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            // release async. lets not hold up the app.
            DispatchQueue.main.async {
                searchBar.resignFirstResponder() // release keyboard
            }
            
        }
    }
}

extension ItemViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("Item deleted")
            self.context.delete(self.itemArray[indexPath.row])
            self.itemArray.remove(at: indexPath.row)
            self.saveItems()
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



