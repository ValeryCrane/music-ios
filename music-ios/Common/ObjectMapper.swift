import Foundation

struct ObjectMapper<F: AnyObject, T: AnyObject> {
    private var fObjects = [ObjectIdentifier: () -> F?]()
    private var tObjects = [ObjectIdentifier: () -> T?]()
    
    private var forwardDict = [ObjectIdentifier: ObjectIdentifier]()    // [F: T]
    private var backwardDict = [ObjectIdentifier: ObjectIdentifier]()   // [T: F]
    
    subscript(_ key: F) -> T? {
        get {
            if let tObjectIdentifier = forwardDict[ObjectIdentifier(key)] {
                return tObjects[tObjectIdentifier]?()
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                forwardDict[ObjectIdentifier(key)] = ObjectIdentifier(newValue)
                backwardDict[ObjectIdentifier(newValue)] = ObjectIdentifier(key)
                tObjects[ObjectIdentifier(newValue)] = { [weak newValue] in
                    return newValue
                }
                fObjects[ObjectIdentifier(key)] = { [weak key] in
                    return key
                }
            } else if let tObjectIdentifier = forwardDict[ObjectIdentifier(key)] {
                tObjects[tObjectIdentifier] = nil
                fObjects[ObjectIdentifier(key)] = nil
                forwardDict[ObjectIdentifier(key)] = nil
                backwardDict[tObjectIdentifier] = nil
            }
        }
    }

    subscript(_ key: T) -> F? {
        get {
            if let fObjectIdentifier = backwardDict[ObjectIdentifier(key)] {
                return fObjects[fObjectIdentifier]?()
            } else {
                return nil
            }
        }
        set {
            if let newValue = newValue {
                forwardDict[ObjectIdentifier(newValue)] = ObjectIdentifier(key)
                backwardDict[ObjectIdentifier(key)] = ObjectIdentifier(newValue)
                fObjects[ObjectIdentifier(newValue)] = { [weak newValue] in
                    return newValue
                }
                tObjects[ObjectIdentifier(key)] = { [weak key] in
                    return key
                }
            } else if let fObjectIdentifier = backwardDict[ObjectIdentifier(key)] {
                fObjects[fObjectIdentifier] = nil
                tObjects[ObjectIdentifier(key)] = nil
                backwardDict[ObjectIdentifier(key)] = nil
                forwardDict[fObjectIdentifier] = nil
            }
        }
    }
}
