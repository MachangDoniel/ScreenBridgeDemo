import UIKit
// Registration APIs compile in every configuration (no-ops outside Debug);
// only the startup call is additionally guarded.
import ScreenBridge

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        // Attaches a floating inspector button to every foreground window scene,
        // including scenes that connect after this call.
        ScreenBridge.start()
        ScreenBridge.log("App launched", category: "lifecycle")
        #endif
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
    }
}

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = MainTabBarController()
        window.makeKeyAndVisible()
        self.window = window
    }
}

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let accounts = UINavigationController(rootViewController: AccountsViewController())
        accounts.tabBarItem = UITabBarItem(title: "Accounts", image: UIImage(systemName: "list.bullet.rectangle"), tag: 0)
        let dashboard = UINavigationController(rootViewController: DashboardViewController())
        dashboard.tabBarItem = UITabBarItem(title: "Dashboard", image: UIImage(systemName: "square.grid.2x2"), tag: 1)
        let profile = ProfileHostingController()
        profile.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.crop.circle"), tag: 2)
        viewControllers = [accounts, dashboard, profile]
        screenBridgeSource("MainTabBarController", role: "container")
    }
}
