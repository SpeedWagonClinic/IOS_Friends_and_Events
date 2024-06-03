import Foundation
import CoreData

protocol EditEventDelegate: AnyObject {
    func eventDidUpdate(_ event: NSManagedObject)
}
