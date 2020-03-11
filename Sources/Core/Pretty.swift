//
// Pretty.swift
// SwiftPrettyPrint
//
// Created by Yusuke Hosonuma on 2020/02/27.
// Copyright (c) 2020 Yusuke Hosonuma.
//

import Foundation

struct Pretty {
    let formatter: PrettyFormatter

    func string<T: Any>(_ target: T, debug: Bool) -> String {
        func _string(_ target: Any) -> String {
            string(target, debug: debug)
        }

        func _value(_ target: Any) -> String {
            handleError { try valueString(target, debug: debug) }
        }

        let mirror = Mirror(reflecting: target)
        let typeName = String(describing: mirror.subjectType)

        switch mirror.displayStyle {
        case .optional:
            return _value(target)

        case .collection:
            let elements = mirror.children.map { _string($0.value) }
            return formatter.arrayString(elements: elements)

        case .dictionary:
            return handleError {
                let keysAndValues: [(String, String)] = try extractKeyValues(from: target).map { key, value in
                    (_value(key), _string(value))
                }
                return formatter.dictionaryString(keysAndValues: keysAndValues)
            }

        case .enum:
            if mirror.children.count == 0 {
                if debug {
                    return "\(typeName).\(target)"
                } else {
                    return ".\(target)"
                }
            } else {
                let valueName = "\(target)"[..<"\(target)".firstIndex(of: "(")!] // TODO:

                let prefix: String
                if debug {
                    prefix = "\(typeName).\(valueName)"
                } else {
                    prefix = ".\(valueName)"
                }

                return "\(prefix)(" + _string(mirror.children.first!.value) + ")"
            }

        default:
            break
        }

        // Empty
        if mirror.children.count == 0 {
            return _value(target)
        }

        // ValueObject
        if !debug, mirror.children.count == 1, let value = mirror.children.first?.value {
            return _value(value)
        }

        // Swift.URL
        if typeName == "URL" {
            return handleError {
                guard
                    let field = mirror.children.first?.value as? NSURL,
                    let urlString = field.absoluteString else {
                    throw PrettyError.unknownError(target: target)
                }

                return #"URL("\#(urlString)")"#
            }
        }

        // Object
        let fields: [(String, String)] = mirror.children.map {
            ($0.label ?? "-", _string($0.value))
        }
        return formatter.objectString(typeName: typeName, fields: fields)
    }

    // MARK: - util

    func valueString<T>(_ target: T, debug: Bool) throws -> String {
        let mirror = Mirror(reflecting: target)

        // Note: this function currently supports Optional type that includes a child.
        guard mirror.children.count <= 1 else {
            throw PrettyError.unknownError(target: target)
        }

        switch target {
        case let value as CustomDebugStringConvertible where debug:
            return value.debugDescription

        case let value as CustomStringConvertible:
            if let string = value as? String {
                return "\"\(string)\""
            } else {
                return value.description
            }

        case let value as T?:
            if let value = value {
                if let string = value as? String {
                    return "\"\(string)\""
                } else {
                    return "\(value)"
                }
            } else {
                return "nil"
            }

        default:
            throw PrettyError.notSupported(target: target)
        }
    }

    func extractKeyValues(from dictionary: Any) throws -> [(Any, Any)] {
        try Mirror(reflecting: dictionary).children.map {
            // Note:
            // Each element $0 structure are like following:
            //
            // ```
            // - label : nil
            // + value :          ->  `root`
            //   - key   : "Two"  ->  `key`
            //   - value : 2      ->  `value`
            // ```

            let root = Mirror(reflecting: $0.value)

            guard
                let key = root.children.first?.value,
                let value = root.children.dropFirst().first?.value else {
                throw PrettyError.failedExtractKeyValue(dictionary: dictionary)
            }

            return (key, value)
        }
    }

    private func handleError(_ f: () throws -> String) -> String {
        do {
            return try f()
        } catch {
            dumpError(error: error)
            return "\(error)"
        }
    }

    private func dumpError(error: Error) {
        let message = """
        
        ---------------------------------------------------------
        Fatal error in SwiftPrettyPrint.
        ---------------------------------------------------------
        \(error.localizedDescription)
        Please report issue from below:
        https://github.com/YusukeHosonuma/SwiftPrettyPrint/issues
        ---------------------------------------------------------
        
        """
        print(message)
    }
}
