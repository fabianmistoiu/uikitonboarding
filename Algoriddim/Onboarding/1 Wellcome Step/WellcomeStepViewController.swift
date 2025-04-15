//
//  WellcomeStepViewController.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 12/04/2025.
//

import UIKit

class WellcomeStepViewController: UIViewController {

    enum SubStep {
        case step1, step2
    }

    private var step1Constraints: [NSLayoutConstraint] = []
    private var step2PortraitConstraints: [NSLayoutConstraint] = []
    private var step2LandscapeConstraints: [NSLayoutConstraint] = []

    public var currentStep: SubStep = .step1 {
        didSet {
            updateLayout(for: currentStep)
        }
    }

    // MARK: - UI
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .Onboarding.logo))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 212 / 64).isActive = true
        return imageView
    }()

    private lazy var heroImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .Onboarding.hero))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 310 / 140).isActive = true
        return imageView
    }()

    private lazy var adaImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .Onboarding.ada))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 202 / 64).isActive = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .Contextual.primary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Mix Your\nFavorite Music"
        return label
    }()

    private lazy var welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.textColor = .Contextual.primary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Welcome to djay!"
        return label
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [logoImageView, secondaryStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 32
        return stackView
    }()

    private lazy var secondaryStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [heroImageView, titleLabel, adaImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 32
        return stackView
    }()

    // MARK: - View controller lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(mainStackView)
        mainStackView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor).isActive = true

        view.addSubview(welcomeLabel)
        welcomeLabel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor).isActive = true
        welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        setupStepsConstraints()
        updateLayout(for: currentStep)
        updateLayout(for: view.frame.size, with: nil)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        updateLayout(for: size, with: coordinator)
    }

    // MARK: - Helper

    private func setupStepsConstraints() {
        step1Constraints = [
            logoImageView.heightAnchor.constraint(equalToConstant: 64),
            heroImageView.heightAnchor.constraint(equalToConstant: 50),
            adaImageView.heightAnchor.constraint(equalToConstant: 20),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            welcomeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        step1Constraints.forEach { $0.priority = .init(rawValue: 999)}

        step2PortraitConstraints = [
            logoImageView.heightAnchor.constraint(equalToConstant: 64),
            heroImageView.heightAnchor.constraint(equalToConstant: 140),
            adaImageView.heightAnchor.constraint(equalToConstant: 64),
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            welcomeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50)
        ]

        step2LandscapeConstraints = [
            logoImageView.heightAnchor.constraint(equalToConstant: 40),
            mainStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 10),
            heroImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.4, constant: -84),
            adaImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.33, constant: -84),
            titleLabel.widthAnchor.constraint(equalTo: adaImageView.widthAnchor),
            welcomeLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 50)
        ]
    }

    private func updateLayout(for size: CGSize, with coordinator: UIViewControllerTransitionCoordinator?) {
        let isSmallLandscape = size.width > size.height && (traitCollection.verticalSizeClass == .compact || traitCollection.horizontalSizeClass == .compact)
        secondaryStackView.axis = isSmallLandscape ? .horizontal : .vertical
        secondaryStackView.removeArrangedSubview(heroImageView)
        secondaryStackView.insertArrangedSubview(heroImageView, at: isSmallLandscape ? 1 : 0)

        if currentStep == .step2 {
            NSLayoutConstraint.deactivate(isSmallLandscape ? step2PortraitConstraints : step2LandscapeConstraints)
            NSLayoutConstraint.activate(!isSmallLandscape ? step2PortraitConstraints : step2LandscapeConstraints)
            titleLabel.font = .systemFont(ofSize: isSmallLandscape ? 25 : 34, weight: .bold)
        }
    }

    func updateLayout(for step: SubStep){
        switch step {
        case .step1:
            NSLayoutConstraint.deactivate(step2PortraitConstraints)
            NSLayoutConstraint.deactivate(step2LandscapeConstraints)
            NSLayoutConstraint.activate(step1Constraints)

            [heroImageView, titleLabel, adaImageView].forEach { $0.layer.opacity = 0 }
            welcomeLabel.layer.opacity = 1

            titleLabel.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            titleLabel.font = .systemFont(ofSize: 34, weight: .bold)

        case .step2:
            let isPortrait = view.frame.size.width < view.frame.size.height

            NSLayoutConstraint.deactivate(step1Constraints)
            NSLayoutConstraint.activate(isPortrait ? step2PortraitConstraints : step2LandscapeConstraints)

            [heroImageView, titleLabel, adaImageView].forEach { $0.layer.opacity = 1 }
            welcomeLabel.layer.opacity = 0

            titleLabel.transform = .identity
            titleLabel.font = .systemFont(ofSize: isPortrait ? 34 : 25, weight: .bold)
        }
    }

    func animate(to step: SubStep, duration: TimeInterval = OnboardingConstants.animationDuration) {
        UIView.animate(withDuration: duration) {
            self.currentStep = step
            self.view.layoutIfNeeded()
        }
    }
}

import SwiftUI

#Preview("Step 1") {
    let vc = WellcomeStepViewController()
    vc.view.backgroundColor = .black
    return vc
}

#Preview("Step 1 Landscape", traits: .landscapeLeft) {
    let vc = WellcomeStepViewController()
    vc.view.backgroundColor = .black
    return vc
}

#Preview("Step 2") {
    let vc = WellcomeStepViewController()
    vc.currentStep = .step2
    vc.view.backgroundColor = .black
    return vc
}

#Preview("Step 2 Landscape", traits: .landscapeLeft) {
    let vc = WellcomeStepViewController()
    vc.currentStep = .step2
    vc.view.backgroundColor = .black
    return vc
}
