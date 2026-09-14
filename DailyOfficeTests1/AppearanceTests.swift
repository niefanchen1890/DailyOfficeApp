import XCTest
@testable import DailyOffice

final class AppearanceTests: XCTestCase {
    @MainActor
    func testWindowAppearanceCanReturnFromDarkToLightAndSystem() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        let view = WindowAppearanceUpdater.AppearanceView()
        view.style = AppAppearance.dark.interfaceStyle
        window.addSubview(view)
        XCTAssertEqual(window.overrideUserInterfaceStyle, .dark)

        view.style = AppAppearance.light.interfaceStyle
        XCTAssertEqual(window.overrideUserInterfaceStyle, .light)

        view.style = AppAppearance.dark.interfaceStyle
        XCTAssertEqual(window.overrideUserInterfaceStyle, .dark)
        view.style = AppAppearance.automatic.interfaceStyle
        XCTAssertEqual(window.overrideUserInterfaceStyle, .unspecified)
    }

    @MainActor
    func testAppearanceFollowsViewIntoItsOwnWindow() {
        let firstWindow = UIWindow()
        let secondWindow = UIWindow()
        let view = WindowAppearanceUpdater.AppearanceView()
        firstWindow.addSubview(view)
        view.style = AppAppearance.dark.interfaceStyle
        secondWindow.addSubview(view)
        XCTAssertEqual(secondWindow.overrideUserInterfaceStyle, .dark)

        view.style = AppAppearance.light.interfaceStyle
        XCTAssertEqual(secondWindow.overrideUserInterfaceStyle, .light)
        XCTAssertEqual(firstWindow.overrideUserInterfaceStyle, .dark)
    }
}
