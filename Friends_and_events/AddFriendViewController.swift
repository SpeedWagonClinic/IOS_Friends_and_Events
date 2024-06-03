import UIKit
import CoreData

// ViewController to handle adding a new friend
class AddFriendViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    // Outlets for the UI elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var gender: UITextField!
    @IBOutlet weak var phoneNum: UITextField!
    @IBOutlet weak var dob: UIDatePicker!
    @IBOutlet weak var hobbies: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var selectAvatarButton: UIButton!

    // Core Data context for saving data
    var context: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Obtain the Core Data context from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        context = appDelegate.persistentContainer.viewContext
    }

    // Action for the save button
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let context = context else {
            print("Core Data context is not initialized.")
            return
        }

        // Create a new Friend entity
        guard let newFriend = NSEntityDescription.insertNewObject(forEntityName: "Friend", into: context) as? Friend else {
            print("Error creating new friend entity.")
            return
        }

        // Set the attributes for the new friend
        newFriend.fullname = nameTextField.text
        newFriend.dob = dob.date
        newFriend.gender = gender.text
        newFriend.hobbies = hobbies.text
        newFriend.phoneNum = phoneNum.text

        // Convert and set the avatar image if it exists
        if let avatarImage = avatarImageView.image {
            newFriend.avatar = avatarImage.pngData()
        }

        // Save the new friend to Core Data
        do {
            try context.save()
            print("Friend saved: \(newFriend.fullname ?? "No name")")
            NotificationCenter.default.post(name: NSNotification.Name("FriendAdded"), object: nil)
            dismiss(animated: true, completion: nil)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    // Action for the select avatar button
    @IBAction func selectAvatarButtonTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate method to handle selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            avatarImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    // UIImagePickerControllerDelegate method to handle cancel action
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
