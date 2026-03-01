import SwiftUI
import UniformTypeIdentifiers
import CoreTransferable

struct StatsFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    let document: StatsExportDocument

    init(document: StatsExportDocument) {
        self.document = document
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadCorruptFile)
        }
        document = try JSONDecoder().decode(StatsExportDocument.self, from: data)
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(document)
        return FileWrapper(regularFileWithContents: data)
    }
}

extension StatsFileDocument: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { doc in
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            return try encoder.encode(doc.document)
        }
        .suggestedFileName("wordlike-stats.json")
    }
}
