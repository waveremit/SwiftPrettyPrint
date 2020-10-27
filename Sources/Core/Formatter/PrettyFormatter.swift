//
//  PrettyFormatter.swift
//  SwiftPrettyPrint
//
//  Created by Fabian Mücke on 27.10.20.
//

import Foundation

public enum PrettyFormatter {
    case multiline(indent: Int)
    case singleline
}

extension PrettyFormatter {
    var implementation: PrettyFormatterProtocol {
        switch self {
        case let .multiline(indent: indent):
            return MultilineFormatter(indentSize: indent)
        case .singleline:
            return SinglelineFormatter()
        }
    }
}
