@objc(AddressBookPlugin) class AddressBookPlugin : CDVPlugin{
    // MARK: Properties
    var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)
    @objc(saveContact:) func saveContact(_ command: CDVInvokedUrlCommand) {
        

    }
}