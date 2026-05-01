import os

/// Centralized logger with a fixed subsystem. Category is derived from the caller's type.
enum QontoLogger {

    private static let subsystem = "com.qonto"

    static func warning(_ message: String, caller: Any.Type) {
        let logger = Logger(subsystem: subsystem, category: String(describing: caller))
        logger.warning("\(message)")
    }

    static func error(_ message: String, caller: Any.Type) {
        let logger = Logger(subsystem: subsystem, category: String(describing: caller))
        logger.error("\(message)")
    }

    static func info(_ message: String, caller: Any.Type) {
        let logger = Logger(subsystem: subsystem, category: String(describing: caller))
        logger.info("\(message)")
    }
}
