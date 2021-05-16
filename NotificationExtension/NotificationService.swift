//
//  NotificationService.swift
//  AllInOneNotificationServiceExtension
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            // bestAttemptContent.body = "\(bestAttemptContent.body) [modified]"

            guard let notificationType = notificationTypeFromContent(bestAttemptContent) else {
                finish()
                return
            }

            switch notificationType {
            case .image:
                attachImage()
            case .text:
                attachText()
            default:
                finish()
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        finish()
    }

    private func notificationTypeFromContent(_ content: UNMutableNotificationContent) -> NotificationType? {
        guard let notificationType = content.userInfo["type"] as? String else {
            return nil
        }
        let type = NotificationType(rawValue: notificationType)
        return type
    }

    private func attachImage() {
        guard let thumbnailString = bestAttemptContent?.userInfo["thumbnailUrl"] as? String,
            let url = URL(string: thumbnailString) else {
            finish()
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { (downloadedTempURL, _, error) in

            guard error == nil, let downloadedTempURL = downloadedTempURL else {
                self.finish()
                return
            }

            do {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                let documentsURL = URL(fileURLWithPath: documentsPath)
                let fileURL = documentsURL.appendingPathComponent("image.jpg")
                try FileManager.default.moveItem(at: downloadedTempURL, to: fileURL)
                let attachment = try UNNotificationAttachment(identifier: "image", url: fileURL, options: nil)
                self.bestAttemptContent?.attachments = [attachment]
                self.finish()
            } catch {
                self.finish()
            }
        }
        task.resume()
    }

    private func attachText() {
        guard let customText = bestAttemptContent?.userInfo["customText"] as? String else {
            finish()
            return
        }
        if let bodyText = bestAttemptContent?.body {
            bestAttemptContent?.subtitle = bodyText
        }
        bestAttemptContent?.body = customText
        finish()
    }

    private func finish() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
