import UIKit

@MainActor final class SharePlugin {
    private static var instance: SharePlugin?
    private var presentation: UIActivityViewController?
    static func register() {
        if instance == nil {
            instance = SharePlugin()
        }
    }

    private init() {
        let channel = NativeChannels.channel("dotnative.share")
        channel.handle("shareText") {
            [weak self] arguments, reply in
            self?.share(arguments, reply)
                ?? reply.failure("unavailable", "Share plugin is unavailable")
        }
    }

    private func share(_ arguments: PluginValue, _ reply: PluginReply) {
        let fields = arguments.fields
        guard let text = fields["text"]?.string, !text.isEmpty, text.utf8.count <= 256_000,
            let presenter = NativeChannels.presenter
        else {
            reply.failure("invalid_argument", "Text and an active presenter are required")
            return
        }
        let sheet = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let subject = fields["subject"]?.string {
            sheet.setValue(subject, forKey: "subject")
        }
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = presenter.view
            popover.sourceRect = CGRect(
                x: presenter.view.bounds.midX, y: presenter.view.bounds.midY, width: 1, height: 1)
            popover.permittedArrowDirections = []
        }
        presentation = sheet
        sheet.completionWithItemsHandler = {
            [weak self] _, _, _, _ in
            Task {
                @MainActor in
                self?.presentation = nil
                reply.success()
            }
        }
        reply.onCancel = {
            [weak self] in
            Task {
                @MainActor in
                self?.presentation?.dismiss(animated: true)
                self?.presentation = nil
            }
        }
        presenter.present(sheet, animated: true)
    }
}
