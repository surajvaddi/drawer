import Foundation
import SQLite3

enum AIJobStatus: String, Codable, CaseIterable, Sendable {
    case pending
    case processing
    case completed
    case failed
}

enum AIJobKind: String, Codable, CaseIterable, Sendable {
    case title
    case summary
    case tags
    case facts
    case embedding
    case duplicate
    case related
}

struct AIJob: Identifiable, Equatable, Sendable {
    var id: String
    var itemId: String
    var kind: AIJobKind
    var status: AIJobStatus
    var attempts: Int
    var lastError: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        itemId: String,
        kind: AIJobKind,
        status: AIJobStatus = .pending,
        attempts: Int = 0,
        lastError: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.itemId = itemId
        self.kind = kind
        self.status = status
        self.attempts = attempts
        self.lastError = lastError
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

struct AIJobQueue: Sendable {
    let manager: DatabaseManager
    private let maxAttempts = 3

    func enqueue(itemId: String, kind: AIJobKind) throws -> AIJob {
        let now = Date()
        let job = AIJob(itemId: itemId, kind: kind, createdAt: now, updatedAt: now)
        try manager.exec(
            """
            INSERT INTO ai_jobs(id, item_id, kind, status, attempts, last_error, created_at, updated_at)
            VALUES (
              '\(escape(job.id))',
              '\(escape(itemId))',
              '\(escape(kind.rawValue))',
              '\(AIJobStatus.pending.rawValue)',
              0,
              NULL,
              '\(DBDateCodec.string(from: now))',
              '\(DBDateCodec.string(from: now))'
            );
            """
        )
        return job
    }

    func dequeue() throws -> AIJob? {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = """
        SELECT id, item_id, kind, status, attempts, last_error, created_at, updated_at
        FROM ai_jobs
        WHERE status = 'pending' AND attempts < ?
        ORDER BY created_at ASC
        LIMIT 1;
        """
        guard sqlite3_prepare_v2(manager.db, sql, -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare ai job dequeue failed")
        }
        sqlite3_bind_int(stmt, 1, Int32(maxAttempts))
        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        let job = try mapRow(stmt)
        try markProcessing(id: job.id)
        return job
    }

    func markCompleted(id: String) throws {
        try updateStatus(id: id, status: .completed, lastError: nil)
    }

    func markFailed(id: String, error: String) throws {
        try manager.exec(
            """
            UPDATE ai_jobs SET
              status='\(AIJobStatus.failed.rawValue)',
              attempts=attempts + 1,
              last_error='\(escape(error))',
              updated_at='\(DBDateCodec.string(from: Date()))'
            WHERE id='\(escape(id))';
            """
        )
    }

    func retryFailed() throws -> Int {
        try manager.exec(
            """
            UPDATE ai_jobs SET
              status='\(AIJobStatus.pending.rawValue)',
              updated_at='\(DBDateCodec.string(from: Date()))'
            WHERE status='\(AIJobStatus.failed.rawValue)' AND attempts < \(maxAttempts);
            """
        )
    }

    func pendingCount() throws -> Int {
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        guard sqlite3_prepare_v2(manager.db, "SELECT COUNT(*) FROM ai_jobs WHERE status='pending';", -1, &stmt, nil) == SQLITE_OK else {
            throw OrbError.storage("prepare ai job count failed")
        }
        guard sqlite3_step(stmt) == SQLITE_ROW else { return 0 }
        return Int(sqlite3_column_int(stmt, 0))
    }

    private func markProcessing(id: String) throws {
        try updateStatus(id: id, status: .processing, lastError: nil)
    }

    private func updateStatus(id: String, status: AIJobStatus, lastError: String?) throws {
        try manager.exec(
            """
            UPDATE ai_jobs SET
              status='\(status.rawValue)',
              last_error=\(lastError.map { "'\(escape($0))'" } ?? "NULL"),
              updated_at='\(DBDateCodec.string(from: Date()))'
            WHERE id='\(escape(id))';
            """
        )
    }

    private func mapRow(_ stmt: OpaquePointer?) throws -> AIJob {
        func text(_ index: Int32) -> String? {
            guard let c = sqlite3_column_text(stmt, index) else { return nil }
            return String(cString: c)
        }
        guard
            let id = text(0),
            let itemId = text(1),
            let kindRaw = text(2),
            let kind = AIJobKind(rawValue: kindRaw),
            let statusRaw = text(3),
            let status = AIJobStatus(rawValue: statusRaw),
            let createdRaw = text(6),
            let updatedRaw = text(7)
        else {
            throw OrbError.storage("invalid ai job row")
        }
        return AIJob(
            id: id,
            itemId: itemId,
            kind: kind,
            status: status,
            attempts: Int(sqlite3_column_int(stmt, 4)),
            lastError: text(5),
            createdAt: DBDateCodec.date(from: createdRaw) ?? Date(),
            updatedAt: DBDateCodec.date(from: updatedRaw) ?? Date()
        )
    }

    private func escape(_ value: String) -> String {
        value.replacingOccurrences(of: "'", with: "''")
    }
}
