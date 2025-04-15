//
//  GradientView.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 09/04/2025.
//

import UIKit

class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    var colors: [UIColor] = [] {
        didSet {
            gradientLayer.colors = colors.map(\.cgColor)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }

    convenience init(colors: [UIColor] = []) {
        self.init(frame: .zero)
        defer {
            self.colors = colors
        }
    }

    private func setupGradient() {
        // Customize your gradient here
        gradientLayer.colors = [
            UIColor.systemBlue.cgColor,
            UIColor.systemTeal.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}


#Preview {
    GradientView(colors: [.gradientStart, .gradientEnd])
}
