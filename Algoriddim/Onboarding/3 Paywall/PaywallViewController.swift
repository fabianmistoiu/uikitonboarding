//
//  PaywallViewController.swift
//  Algoriddim
//
//  Created by Fabian Mistoiu on 15/04/2025.
//

import Combine
import UIKit

class PaywallViewController: UIViewController {

    private let viewModel: PaywallViewModel
    private var cancellables: Set<AnyCancellable> = []

    init(viewModel: PaywallViewModel = .init(skill: .professional)) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: UI

    private lazy var closeButton: UIButton = {
        let closeButton = UIButton(type: .system)

        var config = UIButton.Configuration.plain()

        config.image = UIImage(systemName: "xmark")
        config.baseForegroundColor = .white

        // Background styling
        config.background.backgroundColor = .Contextual.quaternary
        config.background.cornerRadius = 20

        // Padding around the icon
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        // Apply configuration
        closeButton.configuration = config

        // Optional: Set constraints to make it circular (40x40)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40)
        ])

        return closeButton
    }()

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: viewModel.bannerImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .Contextual.primary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = viewModel.title
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.textColor = .Contextual.secondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = viewModel.subtitle
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleStackView, bulletPointsStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 20
        return stackView
    }()

    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()

    private lazy var bulletPointsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var productsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .fill
        return stackView
    }()

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(backgroundImageView)
        scrollView.addSubview(stackView)
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor,constant: -2),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        return scrollView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        view.addSubview(productsStackView)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: productsStackView.topAnchor, constant: -20),

            backgroundImageView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.4),

            productsStackView.widthAnchor.constraint(lessThanOrEqualToConstant: OnboardingConstants.continueButtonMaxWidth),
            productsStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            productsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            subtitleLabel.widthAnchor.constraint(equalTo: productsStackView.widthAnchor),
            bulletPointsStackView.widthAnchor.constraint(equalTo: productsStackView.widthAnchor),

            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
        ])

        let highConstraints = [
            backgroundImageView.heightAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1 / 1.2),
            productsStackView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -64),
        ]
        highConstraints.forEach { $0.priority = .init(999) }
        NSLayoutConstraint.activate(highConstraints)

        viewModel.bulletPoints.forEach {
            bulletPointsStackView.addArrangedSubview(bulletPoint(for: $0))
        }


        for (index, product) in viewModel.products.enumerated() {
            productsStackView.addArrangedSubview(productButton(for: product, action: { [weak viewModel] in
                viewModel?.onProductSelected(at: index)
            }))
        }

        viewModel.$selectedProductIndex.sink { [weak self] selectedIndex in
            guard let self else { return }

            for (index, view) in productsStackView.arrangedSubviews.enumerated() {
                guard let productButton = view as? UIButton else { continue }

                var config = productButton.configuration
                config?.background.strokeWidth = index == selectedIndex ? 2 : 0
                productButton.configuration = config
            }
        }.store(in: &cancellables)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        view.layoutIfNeeded()
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
        if bottomOffset.y >= 0 {
            scrollView.setContentOffset(bottomOffset, animated: false)
        }
    }

    // MARK: - Helper

    private func bulletPoint(for title: String) -> UIView {
        let checkmarkImageView = UIImageView(image: UIImage(systemName: "checkmark"))
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.contentMode = .scaleAspectFit
        checkmarkImageView.tintColor = .accent
        checkmarkImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = .systemFont(ofSize: 17, weight: .medium)
        if let attString = try? NSAttributedString(markdown: title) {
            titleLabel.attributedText = attString
        } else {
            titleLabel.text = title
        }
        titleLabel.textColor = .Contextual.secondary
        titleLabel.textAlignment = .left

        let stackView = UIStackView(arrangedSubviews: [checkmarkImageView, titleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8

        return stackView
    }

    private func productButton(for product: PaywallProduct, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true

        button.contentHorizontalAlignment = .trailing

        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = .Contextual.quaternary
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
        config.cornerStyle = .fixed
        config.background.cornerRadius = 12
        config.background.strokeColor = .accent

        config.title = product.formattedPrice
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 17, weight: .regular)
            return outgoing
        }

        config.subtitle = product.formattedSecondaryPrice
        config.titleAlignment = .trailing
        button.configuration = config

        let periodLabel = UILabel()
        periodLabel.translatesAutoresizingMaskIntoConstraints = false
        periodLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        periodLabel.textColor = .Contextual.primary
        periodLabel.textAlignment = .center
        periodLabel.text = product.period
        button.addSubview(periodLabel)
        NSLayoutConstraint.activate([
            periodLabel.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            periodLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 16),
        ])

        if let savingsText = product.savingsText {
            let savingsLabel = UILabel()
            savingsLabel.translatesAutoresizingMaskIntoConstraints = false
            savingsLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            savingsLabel.textColor = .Contextual.primary
            savingsLabel.text = savingsText
            savingsLabel.backgroundColor = .accent
            savingsLabel.layer.cornerRadius = 5
            savingsLabel.clipsToBounds = true
            button.addSubview(savingsLabel)

            NSLayoutConstraint.activate([
                savingsLabel.centerYAnchor.constraint(equalTo: button.topAnchor),
                savingsLabel.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -20),
            ])
        }

        button.addAction(.init(handler: { _ in
            action()
        }), for: .touchUpInside)

        return button
    }
}

#Preview {
    let vc = PaywallViewController()
    vc.view.backgroundColor = .black
    return vc
}
