/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A data object that holds a single image and its metadata.
*/
import Combine
import Foundation
import os

private let logger = Logger(subsystem: "com.apple.sample.CaptureSample",
                            category: "CaptureInfo")

/// This is a lightweight data object that holds a single capture sample, a reference to its capture directory,
/// and any metadata saved with the image.
struct CaptureInfo: Identifiable {
    /// This helper data object tracks whether associated files exist in the file system.
    struct FileExistence {
        var image: Bool = false
        var depth: Bool = false
        var gravity: Bool = false
    }
    
    enum Error: Swift.Error {
        case invalidPhotoString
        case noSuchDirectory(URL)
    }
    
    static let imageSuffix: String = ".HEIC"
    
    /// This is a unique identifier for the capture sample.
    let id: String
    
    let captureNumber: UInt32
    
    /// This is a URL pointing to the sample's parent directory.
    let captureDir: URL
    
    init(id: String, captureNumber: UInt32, captureDir: URL) {
        self.id = id
        self.captureNumber = captureNumber
        self.captureDir = captureDir
    }
    
    var photoIdString: String {
        return CaptureInfo.photoIdString(for:captureNumber, uuid: id)
    }
    
    var imageUrl: URL {
        return CaptureInfo.imageUrl(in: captureDir, captureNumber:captureNumber, uuid: id)
    }
    
    var depthUrl: URL {
        return CaptureInfo.depthUrl(in: captureDir, captureNumber:captureNumber, uuid: id)
    }
    
    var gravityUrl: URL {
        return CaptureInfo.gravityUrl(in: captureDir, captureNumber:captureNumber, uuid: id)
    }
    
    /// This method checks for the existence of the image and metadata files associated with this capture.
    /// This method uses a `Promise` instance to return the data asynchronously once it has finished
    /// checking.
    func checkFilesExist() -> Future<FileExistence, CaptureInfo.Error> {
        let future = Future<FileExistence, CaptureInfo.Error> { promise in
            CaptureInfo.loaderQueue.async {
                guard CaptureInfo.doesDirectoryExist(url: captureDir) else {
                    logger.error("checkFilesExist: can't find dir \(captureDir)!")
                    promise(.failure(CaptureInfo.Error.noSuchDirectory(captureDir)))
                    return
                }
                do {
                    let existence = try CaptureInfo.checkFilesExist(inFolder: captureDir, captureNumber: captureNumber, uuid: id)
                    promise(.success(existence))
                } catch {
                    logger.error("checkFilesExist: error \(String(describing: error))!")
                    promise(.failure(CaptureInfo.Error.noSuchDirectory(captureDir)))
                }
            }
        }
        return future
    }
    
    /// This method deletes all associated metadata files synchronously. Don't call this method
    /// on the main thread.
    func deleteAllFiles() {
        dispatchPrecondition(condition: .notOnQueue(.main))
        deleteHelper(delete: imageUrl, fileType: "image")
        deleteHelper(delete: depthUrl, fileType: "depth")
        deleteHelper(delete: gravityUrl, fileType: "gravity")
    }
    
    private func deleteHelper(delete: URL, fileType: String) {
        do {
            logger.log("Deleting \(fileType) at \"\(delete.path)\"...")
            try FileManager.default.removeItem(atPath: delete.path)
            logger.log("... deleted \"\(delete.path)\".")
        } catch {
            logger.error("Can't delete \(fileType) \"\(delete.path)\" error=\(String(describing: error))")
        }
    }
    
    /// This method synchronously checks which data files already exist in a specified capture directory.
    static func checkFilesExist(inFolder captureDir: URL, captureNumber: UInt32, uuid: String) throws -> FileExistence {
        dispatchPrecondition(condition: .notOnQueue(DispatchQueue.main))

        guard CaptureInfo.doesDirectoryExist(url: captureDir) else {
            throw Error.noSuchDirectory(captureDir)
        }
        
        var result = FileExistence()
        result.image = FileManager.default.fileExists(atPath: imageUrl(in: captureDir, captureNumber:captureNumber, uuid:uuid).path)
        result.depth = FileManager.default.fileExists(atPath: depthUrl(in: captureDir,  captureNumber:captureNumber, uuid:uuid).path)
        result.gravity = FileManager.default.fileExists(atPath: gravityUrl(in: captureDir, captureNumber:captureNumber, uuid:uuid).path)
        return result
    }
    
    static private func doesDirectoryExist(url: URL) -> Bool {
        guard url.isFileURL else { return false }
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path,
                                             isDirectory: &isDirectory) else {
            return false
        }
        return isDirectory.boolValue
    }
    
    /// This method extracts the image `extractCaptureNumber` out of a previously created `photoIdString`.
    /// It throws an exception if `photoString` isn't valid or it can't extract an ID.
    static func extractCaptureNumber(from photoString: String) throws -> UInt32 {
    
        let underscore = CharacterSet(charactersIn: "_")
        let scanner = Scanner(string: photoString)
        scanner.charactersToBeSkipped = underscore
        
        var imgPrefix, captureNumber, imgUUID, remaining: NSString?
        scanner.scanUpToCharacters(from: underscore, into: &imgPrefix)
        scanner.scanUpToCharacters(from: underscore, into: &captureNumber)
        scanner.scanUpToCharacters(from: underscore, into: &imgUUID)
        scanner.scanUpToCharacters(from: underscore, into: &remaining)

        guard let id = UInt32( captureNumber! as String ) else {
            throw Error.invalidPhotoString
        }
        return id

    }
    
    static func extractUUID(from photoString: String) throws -> String {
    
        let underscore = CharacterSet(charactersIn: "_")
        let scanner = Scanner(string: photoString)
        scanner.charactersToBeSkipped = underscore
        
        var imgPrefix, captureNumber, imgUUID, remaining: NSString?
        scanner.scanUpToCharacters(from: underscore, into: &imgPrefix)
        scanner.scanUpToCharacters(from: underscore, into: &captureNumber)
        scanner.scanUpToCharacters(from: underscore, into: &imgUUID)
        scanner.scanUpToCharacters(from: underscore, into: &remaining)

        return imgUUID! as String
    }
    /// This method returns the base name for a capture. It's based on the capture's unique identifier.
    static func photoIdString(for captureNumber: UInt32, uuid: String) -> String {
        return String(format: "%@_%04d_%@", photoStringPrefix, captureNumber, uuid)
    }
    
    static func photoIdString(from imageUrl: URL) throws -> String {
        let basename = imageUrl.lastPathComponent
        guard basename.hasSuffix(imageSuffix), let suffixStartIndex = basename.lastIndex(of: ".") else {
            throw Error.invalidPhotoString
        }
        return String(basename[..<suffixStartIndex])
    }
    
    /// This method returns the file URL for the image data relative to a specified directory.
    static func imageUrl(in captureDir: URL, captureNumber: UInt32, uuid: String) -> URL {
        return captureDir.appendingPathComponent(photoIdString(for:captureNumber, uuid: uuid).appending(imageSuffix))
    }

    /// This method returns the file URL for the image data relative to a specified directory.
    static func jpgImageUrl(in captureDir: URL, captureNumber: UInt32, uuid: String) -> URL {
        return captureDir.appendingPathComponent(photoIdString(for:captureNumber, uuid: uuid).appending(".jpg"))
    }

    /// This method returns the file URL for the gravity data relative to a specified directory.
    static func gravityUrl(in captureDir: URL, captureNumber: UInt32, uuid: String) -> URL {
        return captureDir.appendingPathComponent(photoIdString(for:captureNumber, uuid: uuid).appending("_gravity.TXT"))
    }
    
    /// This method returns the file URL for the depth data relative to a specified directory.
    static func depthUrl(in captureDir: URL, captureNumber: UInt32, uuid: String) -> URL {
        return captureDir.appendingPathComponent(photoIdString(for:captureNumber, uuid: uuid).appending("_depth.TIF"))
    }
    
    /// `CaptureInfo` uses this serial queue for all file system access.
    private static let loaderQueue =
        DispatchQueue(label: "com.apple.example.CaptureSample.CaptureInfo.loaderQueue",
                      qos: .userInitiated)
    
    /// `CaptureInfo` uses this string prefix to create a file base name.
    private static let photoStringPrefix = "IMG"
}
