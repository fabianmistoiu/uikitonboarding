//
//  ViewController.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 09/04/2025.
//

import UIKit
import Combine

class OnboardingViewController: UIViewController {

    private let viewModel: OnboardingViewModel = OnboardingViewModel()
    private var onboardingStepLeadingConstraint: NSLayoutConstraint?
    private var footerLeadingConstraint: NSLayoutConstraint?
    private var stepViewController: UIViewController?
    private var footerViewController: UIViewController?
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - UI

    lazy var continueButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(lessThanOrEqualToConstant: OnboardingConstants.continueButtonMaxWidth).isActive = true
        button.setContentCompressionResistancePriority(.required, for: .vertical)

        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = UIColor.accent
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 12, trailing: 20)
        configuration.background.cornerRadius = 12
        configuration.cornerStyle = .fixed
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            return outgoing
        }
        button.configuration = configuration

        viewModel.$buttonTitle.sink { [weak button] title in
            guard let button else { return }
            UIView.transition(with: button, duration: OnboardingConstants.animationDuration, options: .transitionCrossDissolve, animations: {
                button.setTitle(title, for: .normal)
            }, completion: nil)
        }.store(in: &cancellables)

        viewModel.$isButtonEnabled.sink { [weak button] isEnabled in
            guard let button else { return }

            button.isUserInteractionEnabled = isEnabled
            button.alpha = isEnabled ? 1 : 0.3
        }.store(in: &cancellables)

        button.addAction(UIAction(handler: { [weak self] _ in
            self?.viewModel.handleContinuePressed()
        }), for: .touchUpInside)

        return button
    }()

    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.setContentCompressionResistancePriority(.required, for: .vertical)
        pageControl.isUserInteractionEnabled = false
        pageControl.numberOfPages = viewModel.totalStepCount

        viewModel.$currentStepIndex.sink { [weak pageControl] index in
            pageControl?.currentPage = index
        }.store(in: &cancellables)

        return pageControl
    }()

    lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - View controller lifecycle

    override func loadView() {
        view = GradientView(colors: [.gradientStart, .gradientEnd])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let stackView = UIStackView(arrangedSubviews: [containerView, continueButton, pageControl])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            view.topAnchor.constraint(equalTo: stackView.topAnchor),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 8),
        ])

        let buttonMaxWidthConstraint = view.leadingAnchor.constraint(equalTo: continueButton.leadingAnchor, constant: -32)
        buttonMaxWidthConstraint.priority = .init(999)
        buttonMaxWidthConstraint.isActive = true

        viewModel.$currentStepViewController.sink { [weak self] vc in
            if let vc {
                self?.addOnboardingViewController(vc)
            }
        }.store(in: &cancellables)

        viewModel.$currentFooterViewController.sink { [weak self] vc in
            self?.addFooterViewController(vc)
        }.store(in: &cancellables)

    }

    // MARK: -

    func addOnboardingViewController(_ vc: UIViewController) {
        let currentStepVC = stepViewController
        let animated = currentStepVC != nil

        currentStepVC?.willMove(toParent: nil)
        addChild(vc)
        containerView.addSubview(vc.view)

        let completion: (Bool) -> Void = { _ in
            currentStepVC?.view.removeFromSuperview()
            currentStepVC?.removeFromParent()
            vc.didMove(toParent: self)
        }

        vc.view.translatesAutoresizingMaskIntoConstraints = false
        let onboardingStepLeadingConstraint = containerView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor)
        NSLayoutConstraint.activate([
            onboardingStepLeadingConstraint,
            containerView.widthAnchor.constraint(equalTo: vc.view.widthAnchor),
            containerView.topAnchor.constraint(equalTo: vc.view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
        ])

        if animated {
            onboardingStepLeadingConstraint.constant = -view.bounds.width
            view.layoutIfNeeded()
            self.onboardingStepLeadingConstraint?.constant = view.bounds.width
            onboardingStepLeadingConstraint.constant = 0
            UIView.animate(withDuration: OnboardingConstants.animationDuration) {
                self.view.layoutIfNeeded()
            } completion: { success in
                completion(success)
            }
        } else {
            completion(true)
        }

        self.onboardingStepLeadingConstraint = onboardingStepLeadingConstraint
        stepViewController = vc
    }

    func addFooterViewController(_ vc: UIViewController?) {
        let currentFooterVC = footerViewController
        let animated = true

        currentFooterVC?.willMove(toParent: nil)
        if let vc {
            addChild(vc)
            view.addSubview(vc.view)
        }

        let completion: (Bool) -> Void = { _ in
            currentFooterVC?.view.removeFromSuperview()
            currentFooterVC?.removeFromParent()
            vc?.didMove(toParent: self)
        }

        var footerLeadingConstraint: NSLayoutConstraint?
        if let vc {
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            footerLeadingConstraint = continueButton.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor)
            let footerConstraints = [
                footerLeadingConstraint!,
                continueButton.widthAnchor.constraint(equalTo: vc.view.widthAnchor),
                pageControl.topAnchor.constraint(equalTo: vc.view.topAnchor),
                pageControl.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor)
            ]
            footerConstraints.forEach { $0.priority = .init(rawValue: 998) }
            NSLayoutConstraint.activate(footerConstraints)
        }

        if animated {
            footerLeadingConstraint?.constant = -view.bounds.width
            view.layoutIfNeeded()
            self.footerLeadingConstraint?.constant = view.bounds.width
            footerLeadingConstraint?.constant = 0
            UIView.animate(withDuration: OnboardingConstants.animationDuration) {
                self.pageControl.alpha = vc == nil ? 1 : 0
                self.view.layoutIfNeeded()
            } completion: { success in
                completion(success)
                self.pageControl.alpha = vc == nil ? 1 : 0
            }
        } else {
            completion(true)
        }
        self.footerLeadingConstraint = footerLeadingConstraint
        footerViewController = vc
    }
}

#Preview {
    OnboardingViewController()
}

