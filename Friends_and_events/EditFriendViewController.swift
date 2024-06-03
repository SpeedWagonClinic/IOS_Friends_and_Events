import UIKit
import CoreData

// ViewController to handle editing an existing friend
class EditFriendViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // Outlets for the UI elements
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var phoneNumTextField: UITextField!
    @IBOutlet weak var dobDatePicker: UIDatePicker!
    @IBOutlet weak var hobbiesTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var selectAvatarButton: UIButton!

    // The friend to be edited
    var friend: Friend?
    // Core Data context for fetching and saving data
    var context: NSManagedObjectContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Obtain the Core Data context from AppDelegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Unable to access AppDelegate")
        }
        context = appDelegate.persistentContainer.viewContext

        // Load friend details into the UI elements
        if let friend = friend {
            nameTextField.text = friend.fullname
            genderTextField.text = friend.gender
            phoneNumTextField.text = friend.phoneNum
            if let dob = friend.dob {
                dobDatePicker.date = dob
            }
            hobbiesTextField.text = friend.hobbies
            if let avatarData = friend.avatar {
                avatarImageView.image = UIImage(data: avatarData)
            }
        } else {
            print("No friend data available")
        }
    }

    // Action for the save button to save the edited friend details
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        guard let friend = friend else {
            print("No friend to save")
            return
        }

        // Update the friend attributes with the values from the UI elements
        friend.fullname = nameTextField.text
        friend.gender = genderTextField.text
        friend.phoneNum = phoneNumTextField.text
        friend.dob = dobDatePicker.date
        friend.hobbies = hobbiesTextField.text

        // Convert and set the avatar image if it exists
        if let avatarImage = avatarImageView.image {
            friend.avatar = avatarImage.pngData()
        }

        // Save the updated friend to Core Data
        do {
            try context.save()
            print("Friend updated: \(friend.fullname ?? "No name")")
            navigationController?.popViewController(animated: true)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    // Action for the select avatar button to choose an image
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
