#if os(iOS)
import SwiftUI
import UIKit
import MessageUI

// https://swiftuirecipes.com/blog/send-mail-in-swiftui

struct ComposeMailData {
    let subject: String
    let recipients: [String]?
    let message: String
    let attachments: [AttachmentData]?
}

struct AttachmentData {
    let data: Data
    let mimeType: String
    let fileName: String
}

typealias MailViewCallback = ((Result<MFMailComposeResult, Error>) -> Void)?

struct MailView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    @Binding var data: ComposeMailData
    let callback: MailViewCallback

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let dismiss: DismissAction
        @Binding var data: ComposeMailData
        let callback: MailViewCallback

        init(dismiss: DismissAction,
             data: Binding<ComposeMailData>,
             callback: MailViewCallback) {
            self.dismiss = dismiss
            _data = data
            self.callback = callback
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            if let error = error {
                callback?(.failure(error))
            } else {
                callback?(.success(result))
            }
            dismiss()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss, data: $data, callback: callback)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setSubject(data.subject)
        vc.setToRecipients(data.recipients)
        vc.setMessageBody(data.message, isHTML: false)
        data.attachments?.forEach {
            vc.addAttachmentData($0.data, mimeType: $0.mimeType, fileName: $0.fileName)
        }
        vc.accessibilityElementDidLoseFocus()
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {
    }
    
    static var canSendMail: Bool {
        MFMailComposeViewController.canSendMail()
    }
}
#endif
