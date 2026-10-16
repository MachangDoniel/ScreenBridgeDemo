# ScreenBridge Demo

An example iOS app that shows how to integrate [ScreenBridge](https://github.com/MachangDoniel/ScreenBridge), the development-only inspector that maps on-screen UI to registered Swift source, captures annotated screenshots and sends reports to your Mac for AI coding tools.

<table>
  <tr>
    <td align="center"><img src="Screenshots/01-floating-button.png" width="200" alt="Demo app with floating ScreenBridge button"><br><sub>Accounts + floating inspector</sub></td>
    <td align="center"><img src="Screenshots/03-element-source.png" width="200" alt="Reusable cell label resolved to AccountCell"><br><sub>Reusable cell → <code>AccountCell</code></sub></td>
    <td align="center"><img src="Screenshots/06-swiftui.png" width="200" alt="SwiftUI toggle resolved to ProfileView.swift"><br><sub>SwiftUI → <code>ProfileView.swift</code></sub></td>
  </tr>
  <tr>
    <td align="center"><img src="Screenshots/02-inspector.png" width="200" alt="Inspector sheet"><br><sub>Inspector</sub></td>
    <td align="center"><img src="Screenshots/04-annotate.png" width="200" alt="Annotation and redaction"><br><sub>Annotate + redact</sub></td>
    <td align="center"><img src="Screenshots/05-sent.png" width="200" alt="Report acknowledged"><br><sub>Sent to Mac</sub></td>
  </tr>
</table>

| Screen | Demonstrates |
|---|---|
| **Accounts** (`Accounts/AccountsViewController.swift`) | `UITableView` with reusable cells registered per index path (`cell.screenBridgeSource(_:at:in:)`), navigation push |
| **Account detail** (`Accounts/AccountDetailViewController.swift`) | Controller + view registrations, a view model registered from its own file, a modal sheet (`TransferViewController`), an intentionally clipped footnote to report |
| **Dashboard** (`Dashboard/DashboardViewController.swift`) | Custom view-controller containment with two child controllers |
| **Profile** (`Profile/ProfileView.swift`) | SwiftUI `.screenBridgeSource(...)` modifiers inside a `UIHostingController` |
| `App/AppDelegate.swift` | `ScreenBridge.start()` behind `#if DEBUG`, scene-based UIKit lifecycle, `ScreenBridge.log` |

## Run it

1. Install the Mac helper once (from the framework repo):
   ```bash
   git clone https://github.com/MachangDoniel/ScreenBridge.git && ./ScreenBridge/Scripts/install-helper.sh
   ```
2. Open `ScreenBridgeDemo.xcodeproj`. This development checkout uses the sibling `../ScreenBridge` package so local framework changes appear immediately. Keep both folders next to each other.
3. For a physical device, set your Team under **Signing & Capabilities** (and change the bundle ID if needed).
4. Run the **Debug** configuration. The `ScreenBridge Connection` build phase writes the connection file; check the build log for `note: ScreenBridge: configured …`.
5. Tap the floating viewfinder button for the top drawing/selection toolbar. Use **More** for logs and source details, then **AI tools** to choose a destination or **Paste into focused AI tool** (Pasting into the focused tool is the default for Send). Allow Local Network access on the first run on a device.

## What the integration needs (already done here)

- Package dependency on the `ScreenBridge` product.
- **Run Script phase** placed last, `basedOnDependencyAnalysis: false`, output file `$(TARGET_BUILD_DIR)/$(UNLOCALIZED_RESOURCES_FOLDER_PATH)/ScreenBridgeConnection.json`, and `ENABLE_USER_SCRIPT_SANDBOXING = NO`. See `project.yml`.
- Info.plist: `NSLocalNetworkUsageDescription` and `NSBonjourServices = [_screenbridge._tcp]`.

## Verify Release builds stay clean

```bash
./Scripts/verify-release.sh
```

This archives the app in Release (unsigned) and fails if the bundle contains the connection file, ScreenBridge code or strings, or absolute source paths.

## Project generation

`ScreenBridgeDemo.xcodeproj` is generated from `project.yml` with [XcodeGen](https://github.com/yonaskolb/XcodeGen) and committed so you can open it directly. After editing `project.yml`, run `xcodegen generate`. The package currently uses `path: ../ScreenBridge` for local development. To distribute the demo independently, switch that entry to the GitHub URL and a released version that includes the floating workspace, then regenerate. The checked-in signing team matches the existing local Xcode project.

## Using reports with AI tools

Paste the short report reference into an AI coding tool with access to files on the same Mac, then describe your change in that chat. References point to the saved report and its screenshot filenames; no file is attached automatically. Cloud chats require manually uploaded evidence. MCP-compatible tools can also use the ScreenBridge MCP server.

Manage saved evidence from **ScreenBridge menu bar → Open Inbox**. Right-click a report to delete it, or choose **Delete all reports** and confirm. Reports and their exports are cleaned up together. On receipt of new reports, retention limits the inbox to 200 reports and 30 days.

### Paste into the focused tool

Place the text cursor in your AI coding tool on the Mac, then send the report from the iOS app. ScreenBridge copies the short reference and requests a paste into that field. It never presses Send or opens Claude Code for this action. Grant ScreenBridge **System Settings → Privacy & Security → Accessibility** access once. Without permission or a focused text field, the reference stays on the clipboard for manual ⌘V. Secure fields are excluded. The receiving tool still needs local file access or an MCP connection.
