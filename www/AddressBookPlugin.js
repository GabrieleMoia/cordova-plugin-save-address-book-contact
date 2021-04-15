var exec = require('cordova/exec');

exports.saveContact = function (arg0, success, error) {
    exec(success, error, 'AddressBookPlugin', 'saveContact', [arg0]);
};
