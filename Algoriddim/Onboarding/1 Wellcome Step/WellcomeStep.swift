//
//  WellcomeStep.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 10/04/2025.
//

import Combine
import UIKit

class WellcomeStep: OnboardingStep {
    
    typealias StepResult = ()

    let subStepCount: Int = 2
    let currentSubStepIndex = CurrentValueSubject<Int, Never>(0)
    let buttonTitle: String = "Continue"
    let isButtonEnabled: CurrentValueSubject<Bool, Never> = .init(true)
    let onStepFinished: ((()) -> Void)

    init(onStepFinished: @escaping (()) -> Void) {
        self.onStepFinished = onStepFinished
    }

    var viewController: UIViewController {
        welcomeStepViewController = .init()
        currentSubStepIndex.send(0)
        return welcomeStepViewController
    }
    let footerViewController: UIViewController? = nil

    private var welcomeStepViewController: WellcomeStepViewController!

    func handleContinuePressed() {
        if currentSubStepIndex.value == 1 {
            onStepFinished(())
        } else {
            currentSubStepIndex.send(1)
            welcomeStepViewController?.animate(to: .step2)
        }
    }
}
