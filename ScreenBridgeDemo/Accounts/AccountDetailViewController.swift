import UIKit
import ScreenBridge

final class AccountDetailViewModel {
    let account: DemoAccount

    init(account: DemoAccount) {
        self.account = account
        // Registered from its own file so screens can link to it.
        ScreenBridge.register(AccountDetailViewModel.self, role: "viewModel")
    }

    var title: String { account.name }
    var balanceText: String { account.balance.formatted(.currency(code: "USD")) }
    // Intentionally verbose so it truncates on small screens — something to report.
    var footnote: String { "Balances are illustrative demo values that update whenever the demo data set is regenerated." }
}

final class AccountDetailViewController: UIViewController {
    private let viewModel: AccountDetailViewModel

    init(account: DemoAccount) {
        viewModel = AccountDetailViewModel(account: account)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = viewModel.title
        navigationItem.largeTitleDisplayMode = .never
        screenBridgeSource(related: [.type(AccountDetailViewModel.self, role: "viewModel"), .type(TransferViewController.self, role: "presents")])

        let balance = UILabel()
        balance.text = viewModel.balanceText
        balance.font = .preferredFont(forTextStyle: .largeTitle)
        balance.adjustsFontForContentSizeCategory = true
        balance.accessibilityIdentifier = "detail.balance"
        balance.screenBridgeSource("BalanceLabel")

        let footnote = UILabel()
        footnote.text = viewModel.footnote
        footnote.font = .preferredFont(forTextStyle: .footnote)
        footnote.textColor = .secondaryLabel
        footnote.numberOfLines = 1 // the "bug": clips instead of wrapping
        footnote.accessibilityIdentifier = "detail.footnote"
        footnote.screenBridgeSource("FootnoteLabel")

        var config = UIButton.Configuration.borderedProminent()
        config.title = "Move money"
        config.image = UIImage(systemName: "arrow.left.arrow.right")
        config.imagePadding = 8
        let transfer = UIButton(configuration: config, primaryAction: UIAction { [weak self] _ in self?.presentTransfer() })
        transfer.accessibilityIdentifier = "detail.transfer"

        let stack = UIStackView(arrangedSubviews: [balance, footnote, transfer])
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
        ])
    }

    private func presentTransfer() {
        let nav = UINavigationController(rootViewController: TransferViewController(account: viewModel.account))
        nav.modalPresentationStyle = .pageSheet
        nav.sheetPresentationController?.detents = [.medium(), .large()]
        present(nav, animated: true)
    }
}

/// Presented modally from the detail screen.
final class TransferViewController: UIViewController {
    private let account: DemoAccount

    init(account: DemoAccount) {
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Move money"
        screenBridgeSource()
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [weak self] _ in self?.dismiss(animated: true) })

        let amount = UITextField()
        amount.placeholder = "Amount"
        amount.keyboardType = .decimalPad
        amount.borderStyle = .roundedRect
        amount.accessibilityIdentifier = "transfer.amount"
        amount.screenBridgeSource("AmountField")

        let note = UILabel()
        note.text = "From \(account.name). Demo only — nothing is moved."
        note.font = .preferredFont(forTextStyle: .subheadline)
        note.textColor = .secondaryLabel
        note.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [amount, note])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
        ])
    }
}
