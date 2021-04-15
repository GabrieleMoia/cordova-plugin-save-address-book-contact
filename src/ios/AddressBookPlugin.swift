import Contacts
import ContactsUI

@objc(AddressBookPlugin) class AddressBookPlugin : CDVPlugin, CNContactViewControllerDelegate , UIViewControllerTransitioningDelegate{
    // MARK: Properties
    var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
    @objc(saveContact:) func saveContact(_ command: CDVInvokedUrlCommand) {
        CNContactStore().requestAccess(for: .contacts) { (access, error) in
            print("Access: \(access)")
        }
        
        let contact = CNMutableContact()
        
        if let value = command.arguments[0] as? [String: Any] {
            if let name = value["NOME"] as? String, let secondName = value["COGNOME"] as? String {
                contact.givenName = name
                contact.familyName = secondName
                if let number = value["NUMERO_CELL"] as? String {
                    contact.phoneNumbers = [CNLabeledValue(
                                                label:CNLabelPhoneNumberiPhone,
                                                value:CNPhoneNumber(stringValue: number))]
                }
                if let email = value["MAIL_UTENTE"] as? String {
                    let workEmail = CNLabeledValue(label:CNLabelWork, value: email as NSString)
                    contact.emailAddresses = [workEmail]
                }
            }
            let store = CNContactStore()
            let controller = CNContactViewController(forUnknownContact: contact)
            controller.contactStore = store
            controller.delegate = self
            controller.allowsActions = true
            controller.title = "Aggiungi Contatto"
            let navigationController = UINavigationController(rootViewController: controller)
            self.viewController.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        print(property.key)
        return true
    }
}
