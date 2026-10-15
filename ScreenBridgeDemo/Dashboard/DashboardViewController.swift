import UIKit
import ScreenBridge

/// Custom containment: two child view controllers stacked vertically.
final class DashboardViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dashboard"
        view.backgroundColor = .systemGroupedBackground
        screenBridgeSource(related: [.type(SummaryCardViewController.self, role: "child"), .type(ActivityViewController.self, role: "child")])

        let summary = SummaryCardViewController()
        let activity = ActivityViewController()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        for child in [summary, activity] as [UIViewController] {
            addChild(child)
            stack.addArrangedSubview(child.view)
            child.didMove(toParent: self)
        }
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            summary.view.heightAnchor.constraint(equalToConstant: 140),
            activity.view.heightAnchor.constraint(equalToConstant: 220),
        ])
    }
}

final class SummaryCardViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ScreenBridge.register(SummaryCardViewController.self, role: "child")
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        let label = UILabel()
        label.text = "This month\n$1,284.00 spent"
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .title2)
        label.adjustsFontForContentSizeCategory = true
        label.accessibilityIdentifier = "dashboard.summary"
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

final class ActivityViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ScreenBridge.register(ActivityViewController.self, role: "child")
        view.backgroundColor = .secondarySystemGroupedBackground
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .continuous
        let bars = UIStackView()
        bars.axis = .horizontal
        bars.alignment = .bottom
        bars.distribution = .fillEqually
        bars.spacing = 8
        bars.translatesAutoresizingMaskIntoConstraints = false
        bars.accessibilityIdentifier = "dashboard.chart"
        bars.isAccessibilityElement = true
        bars.accessibilityLabel = "Weekly activity chart"
        bars.screenBridgeSource("ActivityChart")
        for (i, h) in [0.4, 0.7, 0.55, 0.9, 0.3, 0.65, 0.8].enumerated() {
            let bar = UIView()
            bar.backgroundColor = i == 3 ? .systemBlue : .systemBlue.withAlphaComponent(0.35)
            bar.layer.cornerRadius = 4
            bars.addArrangedSubview(bar)
            bar.heightAnchor.constraint(equalToConstant: 150 * h).isActive = true
        }
        view.addSubview(bars)
        NSLayoutConstraint.activate([
            bars.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            bars.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bars.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            bars.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 20),
        ])
    }
}
