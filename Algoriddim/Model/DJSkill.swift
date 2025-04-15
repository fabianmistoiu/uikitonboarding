//
//  DJSkill.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 15/04/2025.
//


enum DJSkill {
    case new, amateur, professional
}

extension DJSkill {
    var localizedDescription: String {
        switch self {
        case .new:
            return "I’m new to DJing"
        case .amateur:
            return "I’ve used DJ apps before"
        case .professional:
            return "I’m a professional DJ"
        }
    }
}
