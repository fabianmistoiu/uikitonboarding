//
//  OnboardingViewModel.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 15/04/2025.
//

import Combine
import UIKit

class OnboardingViewModel {
    /// Index for the current step
    @Published private(set) var currentStepIndex: Int = 0
    /// Total number of onboarding steps (including sub steps)
    @Published private(set) var totalStepCount: Int = 0
    @Published private(set) var buttonTitle: String = ""
    @Published private(set) var isButtonEnabled: Bool = true
    @Published private(set) var currentStepViewController: UIViewController?
    /// If set will replace page view
    @Published private(set) var currentFooterViewController: UIViewController?

    private var steps: [any OnboardingStep] = []
    private var currentStep: (any OnboardingStep)? {
        didSet {
            stepSubscription.removeAll()

            currentStep?.currentSubStepIndex.sink { [weak self] index in
                guard let self else { return }
                currentStepIndex = subStepsBeforeCurrentStep() + index
            }.store(in: &stepSubscription)

            currentStep?.isButtonEnabled.sink { [weak self] isEnabled in
                self?.isButtonEnabled = isEnabled
            }.store(in: &stepSubscription)

            buttonTitle = currentStep?.buttonTitle ?? ""
            currentStepViewController = currentStep?.viewController
            currentFooterViewController = currentStep?.footerViewController
        }
    }
    private var userSkill: DJSkill? {
        didSet {
            let paywallStep = steps.first(where: { $0 is PaywallStep }) as? PaywallStep
            paywallStep?.skill = userSkill
        }
    }
    private var stepSubscription = Set<AnyCancellable>()

    init() {
        self.steps = [
            WellcomeStep(onStepFinished: { [weak self] _ in
                self?.proceedToNextStep()
            }),
            SelectSkillStep(onStepFinished: { [weak self] skill in
                self?.userSkill = skill
                self?.proceedToNextStep()
            }),
            PaywallStep(onStepFinished: { [weak self] _ in
                // TODO: go to home screen
                // Restart flow for testing purposes
                guard let self else { return }
                currentStep = steps.first
            })
        ]
        setupFirstStep()
    }

    func handleContinuePressed() {
        currentStep?.handleContinuePressed()
    }

    private func setupFirstStep() {
        currentStep = steps.first

        self.totalStepCount = steps.reduce(into: 0) { result, step in
            result += step.subStepCount
        }
    }

    private func subStepsBeforeCurrentStep() -> Int {
        guard let stepIndex = steps.firstIndex(where: { $0  === self.currentStep }) else { return 0 }

        var retVal: Int = 0
        for i in 0..<stepIndex {
            retVal += steps[i].subStepCount
        }
        return retVal
    }

    private func proceedToNextStep() {
        guard let stepIndex = steps.firstIndex(where: { $0  === self.currentStep }) else { return }
        currentStep = steps[stepIndex + 1]
    }
}
