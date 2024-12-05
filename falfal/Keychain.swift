import Security
import SwiftUICore

class Keychain {
    class func save(key: String, value: String) {
        // Delete any existing items before adding the new one
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: value.data(using: .utf8)!
        ]
        
        SecItemDelete(query as CFDictionary) // Delete existing item if any
        SecItemAdd(query as CFDictionary, nil) // Add new item
    }
    
    class func get(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: kCFBooleanTrue!,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        
        if let data = result as? Data, let value = String(data: data, encoding: .utf8) {
            return value
        }
        
        return nil
    }
    
    class func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
