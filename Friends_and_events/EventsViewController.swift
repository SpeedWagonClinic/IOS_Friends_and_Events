import UIKit
import CoreData

// ViewController to handle displaying and managing events
class EventsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EditEventDelegate {
    
    // Delegate method to reload events after an event is updated
    func eventDidUpdate(_ event: NSManagedObject) {
        loadEvents()
    }
    
    // Outlets for the UI elements
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    // Arrays to store past and upcoming events
    var pastEvents: [NSManagedObject] = []
    var upcomingEvents: [NSManagedObject] = []
    // Core Data context for fetching and saving data
    var context: NSManagedObjectContext!
    // Array to store selected index paths for editing or deleting events
    var selectedIndexPaths: [IndexPath] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up the table view data source and delegate
        eventsTableView.dataSource = self
        eventsTableView.delegate = self
        eventsTableView.allowsMultipleSelection = true
        
        // Obtain the Core Data context from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        context = appDelegate.persistentContainer.viewContext
        
        // Load events from Core Data and update button states
        loadEvents()
        updateButtonStates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Reload events and reset selected index paths when the view appears
        loadEvents()
        selectedIndexPaths.removeAll()
        updateButtonStates()
    }
    
    // Method to load events from Core Data
    func loadEvents() {
        let request = NSFetchRequest<NSManagedObject>(entityName: "Event")
        do {
            let events = try context.fetch(request)
            categorizeEvents(events: events)
            eventsTableView.reloadData()
        } catch {
            print("Failed to fetch events: \(error)")
        }
    }
    
    // Method to categorize events into past and upcoming
    func categorizeEvents(events: [NSManagedObject]) {
        let currentDate = Date()
        pastEvents = events.filter { ($0.value(forKey: "date") as? Date ?? Date()) < currentDate }
        upcomingEvents = events.filter { ($0.value(forKey: "date") as? Date ?? Date()) >= currentDate }
    }
    
    // UITableViewDataSource method to return the number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    // UITableViewDataSource method to return the number of rows in each section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pastEvents.count
        } else {
            return upcomingEvents.count
        }
    }
    
    // UITableViewDataSource method to set the title for each section
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Past Events"
        } else {
            return "Coming Up Events"
        }
    }
    
    // UITableViewDataSource method to configure the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        
        let event: NSManagedObject
        if indexPath.section == 0 {
            event = pastEvents[indexPath.row]
        } else {
            event = upcomingEvents[indexPath.row]
        }
        
        let name = event.value(forKey: "name") as? String ?? "No Name"
        let location = event.value(forKey: "location") as? String ?? "No Location"
        let date = event.value(forKey: "date") as? Date ?? Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        cell.textLabel?.text = name
        cell.detailTextLabel?.text = "\(location) - \(dateFormatter.string(from: date))"
        
        return cell
    }
    
    // UITableViewDelegate method to handle selection of a row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPaths = [indexPath]
        updateButtonStates()
    }
    
    // UITableViewDelegate method to handle deselection of a row
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        selectedIndexPaths.removeAll()
        updateButtonStates()
    }
    
    // Action for the edit button to edit the selected event
    @IBAction func editEvent(_ sender: UIButton) {
        guard let indexPath = selectedIndexPaths.first else {
            print("No event selected to edit.")
            return
        }
        performSegue(withIdentifier: "EditEventSegue", sender: self)
    }
    
    // Action for the delete button to delete the selected events
    @IBAction func deleteEvents(_ sender: UIButton) {
        guard !selectedIndexPaths.isEmpty else {
            print("No events selected to delete.")
            return
        }
        
        let eventsToDelete = selectedIndexPaths.map { indexPath -> NSManagedObject in
            if indexPath.section == 0 {
                return pastEvents[indexPath.row]
            } else {
                return upcomingEvents[indexPath.row]
            }
        }
        
        for event in eventsToDelete {
            context.delete(event)
        }
        
        do {
            try context.save()
            print("Events deleted.")
            loadEvents()
            selectedIndexPaths.removeAll()
            updateButtonStates()
        } catch {
            print("Failed to delete events: \(error)")
        }
    }
    
    // Prepare for segue to EditEventViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditEventSegue",
           let destinationVC = segue.destination as? EditEventViewController,
           let indexPath = selectedIndexPaths.first {
            if indexPath.section == 0 {
                destinationVC.event = pastEvents[indexPath.row]
            } else {
                destinationVC.event = upcomingEvents[indexPath.row]
            }
            destinationVC.context = context
            destinationVC.delegate = self
        }
    }
    
    // Method to update the state of the edit and delete buttons
    func updateButtonStates() {
        editButton.isEnabled = !selectedIndexPaths.isEmpty
        deleteButton.isEnabled = !selectedIndexPaths.isEmpty
    }
}
