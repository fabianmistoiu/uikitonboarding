//
//  PaywallStep.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 15/04/2025.
//


import Combine
import UIKit

class PaywallStep: OnboardingStep {
    typealias StepResult = ()

    let subStepCount: Int = 1
    let currentSubStepIndex = CurrentValueSubject<Int, Never>(0)
    let buttonTitle: String = "Continue for free"
    let isButtonEnabled: CurrentValueSubject<Bool, Never> = .init(true)
    let onStepFinished: ((()) -> Void)
    var skill: DJSkill?

    init(onStepFinished: @escaping (()) -> Void) {
        self.onStepFinished = onStepFinished
    }

    var viewController: UIViewController {
        let viewModel: PaywallViewModel = .init(skill: skill ?? .amateur)
        return PaywallViewController(viewModel: viewModel)
    }
    var footerViewController: UIViewController? {
        return PaywallFooterViewController()
    }

    func handleContinuePressed() {
        // TODO: handle purchase in viewModel
        onStepFinished(())
    }
}
