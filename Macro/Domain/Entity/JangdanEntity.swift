//
//  JangdanEntity.swift
//  Macro
//
//  Created by leejina on 10/1/24.
//

struct JangdanEntity {
    var name: String
    var bakCount: Int
    var daebak: Int
    var bpm: Int
    var sobakList: [[Accent]]
}

enum Accent {
    case strong
    case medium
    case weak
    case none
}
