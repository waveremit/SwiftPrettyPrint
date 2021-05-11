//
// MirrorProvider.swift
// SwiftPrettyPrint
//
// Created by Fabian Mücke on 2021/05/11.
// Copyright (c) 2020 Fabian Mücke.
//


import Foundation

public protocol MirrorProvider {
    func mirror<T: Any>(reflecting: T) -> Mirror
}

public struct DefaultMirrorProvider: MirrorProvider {
    private init() {}

    public static let shared: DefaultMirrorProvider = .init()

    public func mirror<T>(reflecting target: T) -> Mirror {
        Mirror(reflecting: target)
    }
}
