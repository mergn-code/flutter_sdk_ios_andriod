//
//  NotificationService.swift
//  NotificationService
//
//  Created by Syed Hamza Hassan on 17/06/2025.
//

import UserNotifications
import FirebaseMessaging
//import mergn_flutter_plugin

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        //EventManager.shared.notificationViewed(notificationData: request)

        // Check for the media URL
        if let mediaUrlString = request.content.userInfo["image"] as? String,
           let mediaUrl = URL(string: mediaUrlString) {
            
            // Download the image
            downloadImage(from: mediaUrl) { imageData in
                if let imageData = imageData {
                    // Attach the image as a big picture to the notification
                    self.attachBigImageToNotification(imageData: imageData)
                }
                
                // Call the content handler to deliver the notification
                contentHandler(self.bestAttemptContent!)
            }
        } else {
            // If no image, just return the original notification content
            contentHandler(self.bestAttemptContent!)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        // Called when the extension is about to time out
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // Helper function to download the image
    func downloadImage(from url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
            } else {
                completion(data)
            }
        }
        task.resume()
    }

    // Helper function to save the image to a temporary directory
    func saveImageToTempDirectory(data: Data) -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(UUID().uuidString + ".jpg")
        try? data.write(to: fileURL)
        return fileURL
    }

    // Helper function to attach the image as a big picture to the notification
    func attachBigImageToNotification(imageData: Data) {
        let imageURL = saveImageToTempDirectory(data: imageData)

        if let attachment = try? UNNotificationAttachment(identifier: "image", url: imageURL, options: nil) {
            // Attach the image to the notification content
            bestAttemptContent?.attachments = [attachment]
        }
    }
}

