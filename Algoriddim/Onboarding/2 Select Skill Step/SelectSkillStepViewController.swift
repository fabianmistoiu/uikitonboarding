//
//  SelectSkillStepViewController.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 14/04/2025.
//

import UIKit
import Combine

class SelectSkillStepViewModel {
    var skills: [DJSkill] = []
    var selectedSkill: DJSkill? {
        guard let selectedIndex else { return nil }
        return skills[selectedIndex]
    }
    @Published private(set) var selectedIndex: Int?

    init(skills: [DJSkill] = [.new, .amateur, .professional]) {
        self.skills = skills
    }

    func onSelectSkill(_ skill: DJSkill) {
        selectedIndex = skills.firstIndex(of: skill)
    }
}

class SelectSkillStepViewController: UIViewController {

    private var viewModel: SelectSkillStepViewModel
    private var cancellables: Set<AnyCancellable> = []

    private var portraitConstraints: [NSLayoutConstraint] = []
    private var landscapeConstraints: [NSLayoutConstraint] = []

    init(viewModel: SelectSkillStepViewModel = .init()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .Onboarding.icon))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
        ])
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .Contextual.primary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "Welcome DJ"
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.textColor = .Contextual.secondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "What’s your DJ skill level?"
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [headerStackView, optionsStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 40
        return stackView
    }()


    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [iconImageView, titleStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 40
        return stackView
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    private lazy var optionsStackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: viewModel.skills.map { skill in
                self.optionButton(for: skill.localizedDescription, action: { [weak viewModel] in
                    viewModel?.onSelectSkill(skill)
                })
            })
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        return stackView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor,constant: -2),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        return scrollView
    }()

    // MARK: - View controller lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            optionsStackView.widthAnchor.constraint(lessThanOrEqualToConstant: OnboardingConstants.continueButtonMaxWidth)
        ])

        let widthPaddingConstraint = optionsStackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64)
        widthPaddingConstraint.priority = .init(999)
        widthPaddingConstraint.isActive = true

        portraitConstraints = [
            iconImageView.heightAnchor.constraint(equalToConstant: 80),
            scrollView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scrollView.heightAnchor.constraint(equalTo: stackView.heightAnchor, constant: 2)
        ]
        portraitConstraints.forEach { $0.priority = .defaultHigh }

        landscapeConstraints = [
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ]

        updateLayout(for: view.frame.size, with: nil)

        viewModel.$selectedIndex.sink { [weak self] selectedIndex in
            guard let self else { return }

            for (index, optionButton) in optionsStackView.arrangedSubviews.enumerated() {
                guard let optionButton = optionButton as? UIButton else { continue }

                var config = optionButton.configuration
                config?.image = index == selectedIndex ? .checkboxFilled : .checkbox
                config?.background.strokeWidth = index == selectedIndex ? 2 : 0
                optionButton.configuration = config
            }
        }.store(in: &cancellables)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        updateLayout(for: size, with: coordinator)
    }

    // MARK: - Helper

    private func updateLayout(for size: CGSize, with coordinator: UIViewControllerTransitionCoordinator?) {
        let isSmallLandscape = size.width > size.height && (traitCollection.verticalSizeClass == .compact || traitCollection.horizontalSizeClass == .compact)
        headerStackView.axis = isSmallLandscape ? .horizontal : .vertical
        headerStackView.spacing = isSmallLandscape ? 20 : 40

        titleLabel.isHidden = isSmallLandscape

        scrollView.contentInset.top = isSmallLandscape ? 20 : 0
        NSLayoutConstraint.deactivate(isSmallLandscape ? portraitConstraints : landscapeConstraints)
        NSLayoutConstraint.activate(!isSmallLandscape ? portraitConstraints : landscapeConstraints)

    }

    private func optionButton(for text: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.contentHorizontalAlignment = .leading

        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .Contextual.quaternary
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.background.cornerRadius = 12
        config.background.strokeColor = .accent
        config.background.strokeOutset = 2
        config.cornerStyle = .fixed

        config.title = text
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            return outgoing
        }

        config.image = .checkbox
        config.imagePlacement = .leading
        config.imagePadding = 16

        button.configuration = config

        button.addAction(.init(handler: { _ in
            action()
        }), for: .touchUpInside)

        return button
    }

}

#Preview {
    let vc = SelectSkillStepViewController()
    vc.view.backgroundColor = .black
    return vc
}


#Preview("Landscape", traits: .landscapeLeft) {
    let vc = SelectSkillStepViewController()
    vc.view.backgroundColor = .black
    return vc
}
