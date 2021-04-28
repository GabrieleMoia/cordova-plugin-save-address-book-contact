import Contacts
import ContactsUI

@objc(AddressBookPlugin) class AddressBookPlugin : CDVPlugin, CNContactViewControllerDelegate , UIViewControllerTransitioningDelegate {
    // MARK: Properties
    var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
    let store = CNContactStore()
    
    @objc(saveContact:) func saveContact(_ command: CDVInvokedUrlCommand) {
        let contact = CNMutableContact()
        
        self.requestAccess { (value) in
            if (value) {
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
                    
                    let controller = CNContactViewController(forUnknownContact: contact)
                    controller.contactStore = self.store
                    controller.delegate = self
                    controller.allowsActions = true
                    controller.title = "Aggiungi Contatto"
                    let navigationController = UINavigationController(rootViewController: controller)
                    navigationController.setNavigationBarHidden(false, animated: true)
                    self.viewController.present(navigationController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func contactViewController(_ viewController: CNContactViewController, shouldPerformDefaultActionFor property: CNContactProperty) -> Bool {
        print(property.key)
        return true
    }
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
        case .denied:
            self.showSettingsAlert(completionHandler)
        case .restricted, .notDetermined:
            self.store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    DispatchQueue.main.async {
                        self.showSettingsAlert(completionHandler)
                    }
                }
            }
        }
    }
    
    private func showSettingsAlert(_ completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: "Per salvare il contatto in rubrica, è necessario abilitare Impostazioni > People Directory > Contatti", preferredStyle: .alert)
        if let url = URL(string:UIApplicationOpenSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                alert.addAction(UIAlertAction(title: "Apri impostazioni", style: .default) { action in
                    completionHandler(false)
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                })
            }
        }
        alert.addAction(UIAlertAction(title: "Annulla", style: .cancel) { action in
            completionHandler(false)
        })
        self.viewController.present(alert, animated: true, completion: nil)
    }
}
