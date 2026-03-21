//
//  MockReportUserUseCase.swift
//  ranchatTests
//

@testable import ranchat

class MockReportUserUseCase: ReportUserUseCase {
    var shouldThrow = false
    var callCount = 0
    var lastReportType: ReportType?

    func execute(roomId: String, reporterId: String, reportedUserId: String, reportType: ReportType, reportReason: String) async throws {
        callCount += 1
        lastReportType = reportType
        if shouldThrow { throw ApiHelperError.networkError("mock error") }
    }
}
