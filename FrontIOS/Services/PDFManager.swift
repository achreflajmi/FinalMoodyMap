import Foundation

class PDFManager {
    static let shared = PDFManager()
    
    func savePDFToDocuments(data: Data, fileName: String) throws -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        // Remove existing file if it exists
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(at: fileURL)
        }
        
        try data.write(to: fileURL)
        return fileURL
    }
}
