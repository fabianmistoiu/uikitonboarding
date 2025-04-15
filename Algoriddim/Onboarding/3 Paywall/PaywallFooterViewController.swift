//
//  PaywallFooterViewController.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 15/04/2025.
//

import UIKit

class PaywallFooterViewController: UIViewController {

    private let viewModel: PaywallViewModel

    init(viewModel: PaywallViewModel = .init(skill: .professional)) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        for (index, title) in viewModel.footerActions.enumerated() {
            let button = footerButtonFor(title)
            button.addAction(.init(handler: { [weak viewModel] _ in
                viewModel?.onFooterActionTapped(at: index)
            }), for: .touchUpInside)
            stackView.addArrangedSubview(button)
        }
    }

    private func footerButtonFor(_ title: String) -> UIButton {
        let whiteTextButton = UIButton(type: .system)

        // Create configuration
        var config = UIButton.Configuration.plain()

        config.title = title
        config.baseForegroundColor = .white
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            return outgoing
        }

        // Apply configuration
        whiteTextButton.configuration = config
        return whiteTextButton
    }
}

#Preview {
    PaywallFooterViewController()
}
