import UIKit

struct Config: Codable {
    let introLogoUrlString: String?
    let introImageUrlString: String?
    let logoNormalUrlString: String?
    let logoDimmedUrlString: String?
}

typealias ResourceInfo = (type: ResourceImageType, url: URL)

enum ResourceImageType: String {
    case introLogo
    case introImage
    case logoNormal
    case logoDimmed

    var fileName: String {
        return "\(self.rawValue).png"
    }
}

protocol DownloaderDelegate: class {
    func downloader(_ downloader: ResourceManager.Downloader.Type, didUpdateProgress progress: Progress)
    func downloaderDidFinish(_ downloader: ResourceManager.Downloader.Type)
}

class ResourceManager {
    private static var resourceURL: URL {
        // 取得library directory的url
        let libraryURL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]

        // 等於建立一個新的folder叫Resource
        let resourceURL = libraryURL.appendingPathComponent("Resource")
        if FileManager.default.fileExists(atPath: resourceURL.path) == false {
            do {
                try FileManager.default.createDirectory(at: resourceURL,
                                                        withIntermediateDirectories: false,
                                                        attributes: nil)
            } catch (let error) {
                print(error.localizedDescription)
            }
        }
        return resourceURL
    }

    class Downloader {
        private static var progress = Progress()
        static weak var delegate: DownloaderDelegate?

        class func updateImages(completionHandler: @escaping ((Bool) -> Void)) {
            let config = Config(introLogoUrlString: "", introImageUrlString: "", logoNormalUrlString: "", logoDimmedUrlString: "")
            self.updateImages(config: config, completionHandler: completionHandler)
        }

        class func updateImages(config: Config, completionHandler: @escaping ((Bool) -> Void)) {
            guard let commonLogoURL = URL(string: config.introLogoUrlString ?? ""),
                  let introCenterURL = URL(string: config.introImageUrlString ?? ""),
                  let logoNormalImageURL = URL(string: config.logoNormalUrlString ?? ""),
                  let logoDimmedImageURL = URL(string: config.logoDimmedUrlString ?? "") else {
                progress.totalUnitCount = 1
                progress.completedUnitCount = 1
                delegate?.downloader(self, didUpdateProgress: progress)
                completionHandler(false)
                return
            }

            removeAllResourceInfo()
            var resultInfo: [Bool] = []
            let requestInfo: [ResourceInfo] = [(type: .introLogo, url: commonLogoURL),
                                               (type: .introImage, url: introCenterURL),
                                               (type: .logoNormal, url: logoNormalImageURL),
                                               (type: .logoDimmed, url: logoDimmedImageURL)]
            progress.totalUnitCount = Int64(requestInfo.count)
            progress.completedUnitCount = 0

            let dispatchGroup = DispatchGroup()
            let queue = DispatchQueue.global()

            for info in requestInfo {
                dispatchGroup.enter()
                queue.async(group: dispatchGroup) {
                    self.updateImage(of: info) { isSucceeded in
                        resultInfo.append(isSucceeded)
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: queue) {
                let finalResult = resultInfo.allSatisfy { $0 == true }
                if finalResult {
                    storeNonImageInfo()
                }

                completionHandler(finalResult)
            }
        }

        private class func updateImage(of info: ResourceInfo, completionHandler: @escaping ((Bool) -> Void)) {
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)

            let request = URLRequest(url: URL(string: "")!)

            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                let isSucceeded: Bool

                if let tempLocalUrl = tempLocalUrl, error == nil {
                    do {
                        let targetURL = resourceURL.appendingPathComponent(info.type.fileName)
                        try FileManager.default.copyItem(at: tempLocalUrl, to: targetURL)
                        isSucceeded = true

                        progress.completedUnitCount += 1
                        print("ImageDownload fininshed count: \(progress.completedUnitCount)")
                        delegate?.downloader(self, didUpdateProgress: progress)
                    } catch (let writeError) {
                        isSucceeded = false
                        print("error writing file \(resourceURL) : \(writeError)")

                    }
                } else {
                    isSucceeded = false
                    if let error = error {
                        print("Failure: %@", error.localizedDescription)
                    }
                }
                completionHandler(isSucceeded)
            }

            task.resume()
        }

        class func removeAllResourceInfo() {
            let fileManager = FileManager.default
            guard let fileURLs = fileManager.enumerator(at: resourceURL, includingPropertiesForKeys: nil) else { return }
            for case let fileURL as URL in fileURLs {
                do {
                    try fileManager.removeItem(at: fileURL)
                } catch (let error) {
                    print(error.localizedDescription)
                }
            }
        }

        class func removeAllResourceInfoOldWay() {
            let fileManager = FileManager.default
            let fileURLs = fileManager.enumerator(at: resourceURL, includingPropertiesForKeys: nil)
            while let fileURL = fileURLs?.nextObject() {
                guard let url = fileURL as? URL else { return }
                do {
                    try fileManager.removeItem(at: url)
                } catch (let error) {
                    print("remove file error : \(error.localizedDescription)")
                }
            }
        }

        private class func storeNonImageInfo() {
            // store
        }
    }

    class Repository {
        class func image(of type: ResourceImageType) -> UIImage? {
            let fileURL = resourceURL.appendingPathComponent(type.fileName)

            if let image = UIImage(contentsOfFile: fileURL.path) {
                return image
            } else {
                return nil
            }
        }
    }
}
