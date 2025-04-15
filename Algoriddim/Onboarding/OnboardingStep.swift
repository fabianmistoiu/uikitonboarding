//
//  OnboardingStep.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 15/04/2025.
//

import Combine
import UIKit

protocol OnboardingStep<StepResult>: AnyObject {
    associatedtype StepResult

    var buttonTitle: String { get }
    var isButtonEnabled: CurrentValueSubject<Bool, Never> { get }

    var subStepCount: Int { get }
    var currentSubStepIndex: CurrentValueSubject<Int, Never> { get }

    var viewController: UIViewController { get }
    var footerViewController: UIViewController? { get }

    var onStepFinished: ((_ result: StepResult) -> Void) { get }
    func handleContinuePressed()
}
