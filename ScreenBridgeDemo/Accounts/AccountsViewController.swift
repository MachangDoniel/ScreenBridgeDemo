import UIKit
import ScreenBridge

struct DemoAccount: Hashable {
    let id: Int
    let name: String
    let balance: Decimal
    let symbol: String

    static let samples: [DemoAccount] = (0..<60).map { i in
        let names = ["Groceries", "Travel fund", "Rent", "Coffee", "Books", "Gifts", "Hobbies", "Savings jar"]
        let symbols = ["cart", "airplane", "house", "cup.and.saucer", "book", "gift", "paintpalette", "banknote"]
        return DemoAccount(id: i, name: "\(names[i % names.count]) \(i / names.count + 1)", balance: Decimal(120 + i * 37), symbol: symbols[i % symbols.count])
    }
}

/// Table with reusable cells; each cell registers its source for its current row.
final class AccountsViewController: UITableViewController {
    private let accounts = DemoAccount.samples

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Accounts"
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.register(AccountCell.self, forCellReuseIdentifier: AccountCell.reuseID)
        tableView.accessibilityIdentifier = "accounts.table"
        screenBridgeSource(related: [.type(AccountCell.self, role: "cell")])
        ScreenBridge.log("Loaded \(accounts.count) demo accounts", category: "accounts")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        accounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AccountCell.reuseID, for: indexPath) as! AccountCell
        cell.configure(with: accounts[indexPath.row])
        // Re-registered on every configuration; stale after reuse to another row.
        cell.screenBridgeSource("AccountCell", at: indexPath, in: tableView)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let account = accounts[indexPath.row]
        ScreenBridge.log("Opened account \(account.id)", category: "accounts")
        navigationController?.pushViewController(AccountDetailViewController(account: account), animated: true)
    }
}

final class AccountCell: UITableViewCell {
    static let reuseID = "AccountCell"

    private let icon = UIImageView()
    private let nameLabel = UILabel()
    private let balanceLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        ScreenBridge.register(AccountCell.self, role: "cell")
        icon.tintColor = .systemBlue
        icon.contentMode = .scaleAspectFit
        nameLabel.font = .preferredFont(forTextStyle: .body)
        nameLabel.adjustsFontForContentSizeCategory = true
        balanceLabel.font = .preferredFont(forTextStyle: .body).monospacedDigits()
        balanceLabel.adjustsFontForContentSizeCategory = true
        balanceLabel.textColor = .secondaryLabel
        balanceLabel.accessibilityIdentifier = "account.balance"
        let stack = UIStackView(arrangedSubviews: [icon, nameLabel, UIView(), balanceLabel])
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 28),
            stack.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
        accessoryType = .disclosureIndicator
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    func configure(with account: DemoAccount) {
        icon.image = UIImage(systemName: account.symbol)
        nameLabel.text = account.name
        balanceLabel.text = account.balance.formatted(.currency(code: "USD"))
        accessibilityIdentifier = "account.cell.\(account.id)"
    }
}

private extension UIFont {
    func monospacedDigits() -> UIFont {
        UIFont(descriptor: fontDescriptor.addingAttributes([.featureSettings: [[UIFontDescriptor.FeatureKey.type: kNumberSpacingType, UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector]]]), size: 0)
    }
}
