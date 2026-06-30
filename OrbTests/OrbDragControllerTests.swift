import XCTest
@testable import Orb

final class OrbDragControllerTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        suiteName = "orb.drag.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
    }

    func testDragUpdatesWindowOrigin() {
        let settings = SettingsStore(defaults: defaults)
        let controller = OrbDragController(settings: settings)
        controller.persist(origin: NSPoint(x: 120, y: 340))
        XCTAssertEqual(settings.orbPosition?.x, 120)
        XCTAssertEqual(settings.orbPosition?.y, 340)
    }

    func testPositionPersistsAcrossSessions() {
        let settings = SettingsStore(defaults: defaults)
        settings.orbPosition = OrbWindowPosition(x: 50, y: 75)
        let restored = OrbDragController(settings: SettingsStore(defaults: defaults))
            .restoredOrigin(defaultOrigin: .zero)
        XCTAssertEqual(restored.x, 50)
        XCTAssertEqual(restored.y, 75)
    }
}

import AppKit
