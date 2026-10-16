import XCTest

final class DebugWorkspaceUITests: XCTestCase {
    @MainActor
    func testSendKeepsFocusedToolDefault() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["screenbridge.icon"].waitForExistence(timeout: 10))
        app.buttons["screenbridge.icon"].tap()
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertTrue(app.buttons["screenbridge.send"].waitForExistence(timeout: 5))
        app.buttons["screenbridge.send"].tap()
        let destination = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Open on Mac")).firstMatch
        for _ in 0..<3 where !destination.isHittable { app.swipeUp() }
        XCTAssertTrue(destination.label.contains("Paste into focused AI tool"))
    }

    @MainActor
    func testDefaultSelectionPinchAndDeleteAll() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["screenbridge.icon"].waitForExistence(timeout: 10))
        app.buttons["screenbridge.icon"].tap()
        XCTAssertTrue(app.buttons["Arrow"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Select"].exists)
        let order = ["Select", "Pen", "Rect", "Ellipse", "Arrow", "Edit annotations", "Undo", "Redo", "screenbridge.more", "Hide tools"]
        for pair in zip(order, order.dropFirst()) {
            XCTAssertLessThan(app.buttons[pair.0].frame.midX, app.buttons[pair.1].frame.midX)
        }
        // Default Select inspects the underlying app view.
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.2)).tap()
        let handle = app.descendants(matching: .any)["screenbridge.drag"].firstMatch
        let beforeDrag = handle.frame.midY
        // The gap between the toolbar and Send is part of the draggable parent.
        let background = app.coordinate(withNormalizedOffset: .zero).withOffset(
            CGVector(dx: handle.frame.midX + 80, dy: handle.frame.maxY + 6))
        let targetY = beforeDrag < app.frame.midY ? 0.85 : 0.1
        background.press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: targetY)))
        XCTAssertGreaterThan(abs(handle.frame.midY - beforeDrag), 100)
        handle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1,
            thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.1)))
        app.buttons["screenbridge.more"].tap()
        let selection = app.buttons["screenbridge.selection"]
        for _ in 0..<3 where !selection.isHittable { app.swipeUp() }
        XCTAssertTrue(selection.exists)
        app.buttons["Close"].tap()
        app.buttons["Arrow"].tap()
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.5))
            .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.65)))
        app.buttons["Edit annotations"].tap()
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.575)).tap()
        XCTAssertTrue(app.buttons["Delete annotation"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Enlarge annotation"].exists)
        let canvas = app.descendants(matching: .any).matching(NSPredicate(format: "label == %@", "Screenshot")).firstMatch
        let before = canvas.value as? String
        canvas.pinch(withScale: 1.5, velocity: 1)
        XCTAssertTrue(app.buttons["Delete annotation"].waitForExistence(timeout: 5))
        let after = canvas.value as? String
        XCTAssertNotEqual(before, after)
        app.buttons["Undo"].tap()
        XCTAssertEqual(canvas.value as? String, before)
        app.buttons["Redo"].tap()
        XCTAssertEqual(canvas.value as? String, after)
        canvas.pinch(withScale: 0.65, velocity: -1)
        XCTAssertNotEqual(canvas.value as? String, after)
        app.buttons["Undo"].tap()
        XCTAssertEqual(canvas.value as? String, after)
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Default selection and pinch resize"
        attachment.lifetime = .keepAlways
        add(attachment)
        app.buttons["screenbridge.more"].tap()
        app.buttons["Delete all"].tap()
        XCTAssertFalse(app.buttons["screenbridge.send"].exists)
        app.buttons["Undo"].tap()
        XCTAssertTrue(app.buttons["screenbridge.send"].exists)
        app.buttons["Edit annotations"].tap()
        app.buttons["Delete annotation"].tap()
        XCTAssertTrue((canvas.value as? String)?.hasPrefix("0 annotations") == true)
    }

    @MainActor
    func testFloatingToolsLogsAndReportChoices() throws {
        let app = XCUIApplication()
        app.launch()
        let icon = app.buttons["screenbridge.icon"]
        XCTAssertTrue(icon.waitForExistence(timeout: 10))
        icon.tap()
        XCTAssertTrue(app.buttons["Hide tools"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Select"].exists)
        XCTAssertFalse(app.buttons["Area"].exists)
        XCTAssertFalse(app.buttons["screenbridge.send"].exists)
        XCTAssertFalse(app.buttons["screenbridge.ai-tools"].exists)
        XCTAssertTrue(app.buttons["Redo"].exists)
        XCTAssertFalse(app.buttons["Colors"].exists)
        app.buttons["screenbridge.more"].tap()
        XCTAssertTrue(app.buttons["Blue annotation color"].exists)
        app.buttons["Blue annotation color"].tap()
        app.buttons["Close"].tap()
        app.buttons["Pen"].tap()
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.55))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.75, dy: 0.65))
        start.press(forDuration: 0.05, thenDragTo: end)
        XCTAssertTrue(app.buttons["Undo"].isEnabled)
        XCTAssertTrue(app.buttons["screenbridge.send"].exists)
        XCTAssertTrue(app.buttons["screenbridge.ai-tools"].exists)
        app.buttons["Undo"].tap()
        XCTAssertFalse(app.buttons["screenbridge.send"].exists)
        XCTAssertTrue(app.buttons["Redo"].isEnabled)
        app.buttons["Redo"].tap()
        XCTAssertTrue(app.buttons["screenbridge.send"].exists)
        let toolbar = XCTAttachment(screenshot: app.screenshot())
        toolbar.name = "Slim toolbar with edit actions"
        toolbar.lifetime = .keepAlways
        add(toolbar)
        app.buttons["screenbridge.more"].tap()
        let logs = app.buttons.containing(.staticText, identifier: "App logs").firstMatch
        for _ in 0..<3 where !app.staticTexts["App logs"].firstMatch.isHittable { app.swipeUp() }
        // NavigationLink may be exposed as a cell rather than a button on older iOS.
        if logs.waitForExistence(timeout: 3) { logs.tap() }
        else { app.staticTexts["App logs"].firstMatch.tap() }
        XCTAssertTrue(app.staticTexts["App launched"].waitForExistence(timeout: 5))
        app.buttons["Close"].tap()
        app.buttons["screenbridge.send"].tap()
        XCTAssertTrue(app.staticTexts["Include in report"].waitForExistence(timeout: 5))
        let screenshotToggle = app.switches["Screenshots and annotations"]
        if !screenshotToggle.isHittable { app.swipeUp() }
        XCTAssertTrue(screenshotToggle.exists)
        let destination = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Open on Mac")).firstMatch
        if !destination.isHittable { app.swipeUp() }
        XCTAssertTrue(destination.label.contains("Paste into focused AI tool"))
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Report evidence choices"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
    @MainActor
    func testSelectAreaAndDeliverToMacInbox() throws {
        let app = XCUIApplication()
        app.launch()
        let icon = app.buttons["screenbridge.icon"]
        XCTAssertTrue(icon.waitForExistence(timeout: 10))
        icon.tap()
        XCTAssertTrue(app.buttons["Pen"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Select a view or area"].exists)
        let handle = app.descendants(matching: .any)["screenbridge.drag"].firstMatch
        XCTAssertTrue(handle.exists)
        if handle.frame.midY > app.frame.midY {
            handle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1,
                thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.1)))
        }
        let before = handle.frame.midY
        handle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.85)))
        let moved = XCTNSPredicateExpectation(predicate: NSPredicate { _, _ in handle.frame.midY > before + 100 }, object: nil)
        XCTAssertEqual(XCTWaiter.wait(for: [moved], timeout: 5), .completed)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.2)).tap()
        app.buttons["screenbridge.more"].tap()
        let selection = app.buttons["screenbridge.selection"]
        for _ in 0..<3 where !selection.isHittable { app.swipeUp() }
        selection.tap()
        XCTAssertTrue(app.staticTexts["Properties"].waitForExistence(timeout: 5))
        app.buttons["Close"].tap()
        app.buttons["Hide tools"].tap()
        XCTAssertFalse(app.buttons["Area"].exists)
        XCTAssertTrue(app.buttons["Show tools"].exists)
        app.buttons["Show tools"].tap()
        XCTAssertTrue(app.buttons["Pen"].waitForExistence(timeout: 5))
        handle.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).press(forDuration: 0.1, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.85, dy: 0.1)))
        app.buttons["screenbridge.more"].tap()
        app.buttons["Select area"].tap()
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.2, dy: 0.55))
            .press(forDuration: 0.05, thenDragTo: app.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.7)))
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Compact draggable tools"
        attachment.lifetime = .keepAlways
        add(attachment)
        app.buttons["screenbridge.send"].tap()
        let destination = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Open on Mac")).firstMatch
        for _ in 0..<3 where !destination.isHittable { app.swipeUp() }
        XCTAssertTrue(destination.exists)
        destination.tap()
        app.buttons["Mac inbox only"].tap()
        let send = app.buttons["screenbridge.submit"]
        for _ in 0..<2 where !send.isHittable { app.swipeUp() }
        send.tap()
        let acknowledged = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "On your Mac. Report")).firstMatch
        XCTAssertTrue(acknowledged.waitForExistence(timeout: 20), app.debugDescription)
    }

    @MainActor
    func testDefaultDesktopHandoffPreparesReport() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["screenbridge.icon"].waitForExistence(timeout: 10))
        app.buttons["screenbridge.icon"].tap()
        XCTAssertFalse(app.buttons["screenbridge.ai-tools"].exists)
        app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        XCTAssertTrue(app.buttons["screenbridge.ai-tools"].waitForExistence(timeout: 5))
        app.buttons["screenbridge.ai-tools"].tap()
        app.buttons["Claude Code"].tap()
        let destination = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Open on Mac")).firstMatch
        for _ in 0..<3 where !destination.isHittable { app.swipeUp() }
        XCTAssertTrue(destination.label.contains("Claude Code"))
        destination.tap()
        for title in ["Claude Desktop", "Claude Code", "Claude in browser", "Mac inbox only"] {
            XCTAssertTrue(app.buttons[title].exists)
        }
        app.buttons["Claude Desktop"].tap()
        let send = app.buttons["screenbridge.submit"]
        for _ in 0..<2 where !send.isHittable { app.swipeUp() }
        send.tap()
        let acknowledged = app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", "On your Mac. Report")).firstMatch
        XCTAssertTrue(acknowledged.waitForExistence(timeout: 20))
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Desktop handoff acknowledged"
        attachment.lifetime = .keepAlways
        add(attachment)
    }

}
