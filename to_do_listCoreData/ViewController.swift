//
//  ViewController.swift
//  to_do_listCoreData
//
//  Created by Apple on 30/06/25.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var txt1: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
   
    var todoarr: [Todo] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        getData()
    }

    
    @IBAction func Add(_ sender: Any) {
        guard let text = txt1.text, !text.isEmpty else {
            print("Empty text. Not saving.")
            return
        }
        
        let contextref = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newTodo = Todo(context: contextref)
        newTodo.tname = text
        
        do {
            try contextref.save()
            print("Record Inserted")
        } catch {
            print("Error saving context: \(error)")
        }
        
        txt1.text = ""
        getData()
    }
    
    
    func getData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            todoarr = try context.fetch(Todo.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("Error in Fetch Data")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoarr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let todoItem = todoarr[indexPath.row]
        cell.textLabel?.text = todoItem.tname
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTodo = todoarr[indexPath.row]
        
        let alert = UIAlertController(title: "Edit Todo", message: "Update your item", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = selectedTodo.tname
        }
        
        let saveAction = UIAlertAction(title: "Update", style: .default) { _ in
            guard let newText = alert.textFields?.first?.text, !newText.isEmpty else { return }
            
            selectedTodo.tname = newText
            
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            do {
                try context.save()
                print("Item updated")
                self.getData()
            } catch {
                print("Failed to update: \(error)")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let itemToDelete = todoarr[indexPath.row]
            context.delete(itemToDelete)
            
            do {
                try context.save()
                print("Item deleted")
            } catch {
                print("Failed to delete: \(error)")
            }
            
            getData()
        }
    }
}
