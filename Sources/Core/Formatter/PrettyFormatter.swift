//
//  Formatter.swift
//  SwiftPrettyPrint
//
//  Created by Yusuke Hosonuma on 2020/02/26.
//

public protocol PrettyFormatter {
    func collectionString(elements: [String]) -> String
    func dictionaryString(keysAndValues: [(String, String)]) -> String
    func tupleString(elements: [(String?, String)]) -> String
    func objectString(typeName: String, fields: [(String, String)]) -> String
}

public extension PrettyFormatter {
    static func multiline(indent: Int) -> PrettyFormatter {
        MultilineFormatter(indentSize: indent)
    }

    static var singleline: PrettyFormatter {
        SinglelineFormatter()
    }
}
