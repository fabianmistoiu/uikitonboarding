//
//  SelectSkillStep.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 12/04/2025.
//

import Combine
import UIKit

class SelectSkillStep: OnboardingStep {
    
    typealias StepResult = DJSkill

    let subStepCount: Int = 1
    let currentSubStepIndex = CurrentValueSubject<Int, Never>(0)
    let buttonTitle: String = "Let's go"
    let isButtonEnabled: CurrentValueSubject<Bool, Never> = .init(false)
    let onStepFinished: ((DJSkill) -> Void)

    var viewModel: SelectSkillStepViewModel?
    var selectedSkill: DJSkill?
    var selectedIndexSubscription: AnyCancellable?

    init(onStepFinished: @escaping (DJSkill) -> Void) {
        self.onStepFinished = onStepFinished
    }

    var viewController: UIViewController {
        viewModel = SelectSkillStepViewModel()

        selectedIndexSubscription = viewModel!.$selectedIndex.sink { [weak self] selectedIndex in
            self?.isButtonEnabled.send(selectedIndex != nil)
        }

        let selectSkillStepViewController = SelectSkillStepViewController(viewModel: viewModel!)
        return selectSkillStepViewController
    }
    let footerViewController: UIViewController? = nil

    private lazy var selectSkillStepViewController: SelectSkillStepViewController = SelectSkillStepViewController()

    func handleContinuePressed() {
        guard let selectedSkill = viewModel?.selectedSkill else { return }
        onStepFinished(selectedSkill)
    }
}

