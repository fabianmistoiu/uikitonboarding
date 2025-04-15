//
//  PaywallProduct.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 15/04/2025.
//

import Combine
import UIKit

struct PaywallProduct {
    let period: String
    let formattedPrice: String

    let formattedSecondaryPrice: String?
    let savingsText: String?
}

class PaywallViewModel {
    let bannerImage: UIImage
    let title: String
    let subtitle: String

    let bulletPoints: [String]
    let footerActions: [String] = ["Terms", "Privacy policy", "Restore Purchase"]

    let products: [PaywallProduct] = [
        PaywallProduct(
            period: "Yearly",
            formattedPrice: "$59.99",
            formattedSecondaryPrice: "$4.99 per month",
            savingsText: "   SAVE 38%   "
        ),
        PaywallProduct(
            period: "Monthly",
            formattedPrice: "$7.99",
            formattedSecondaryPrice: nil,
            savingsText: nil
        ),
    ]
    @Published var selectedProductIndex: Int = 0

    init(skill: DJSkill) {
        switch skill {
        case .new:
            bannerImage = .Paywall.new
            title = "No DJ Experience? No Problem!"
            subtitle = "Mix your own tracks in minutes"
            bulletPoints = [
                "AI ensures smooth transitions between tracks",
                "Machine learning suggests the next song to match your set",
                "Learn with our fun, intuitive interface and built-in tutorials.",
            ]
        case .amateur:
            bannerImage = .Paywall.new
            title = "Take Your DJing to the Next Level"
            subtitle = "A refined toolkit for DJs looking to upgrade their performance."
            bulletPoints = [
                "Intelligent beat detection syncs BPM and key instantly.",
                "1000+ loops, FX and visuals",
                "Learn with our fun, intuitive interface and built-in tutorials.",
            ]
        case .professional:
            bannerImage = .Paywall.pro
            title = "Elevate Your Sets with DJay Pro"
            subtitle = "Professional-grade tools designed to enhance your performance and creativity."
            bulletPoints = [
                "Advanced MIDI and hardware integration",
                "1000+ loops, FX and visuals",
                "High-resolution waveform display and beat/key matching.",
            ]
        }
    }

    func onProductSelected(at index: Int) {
        selectedProductIndex = index
    }

    func onCloseTapped() {
        
    }

    func onFooterActionTapped(at index: Int) {

    }
}
