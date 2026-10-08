import AppKit

@MainActor final class SharePlugin: NSObject, @preconcurrency NSSharingServicePickerDelegate {
    private static var instance: SharePlugin?
    private var picker: NSSharingServicePicker?
    private var pendingReply: PluginReply?
    static func register() {
        if instance == nil {
            instance = SharePlugin()
        }
    }

    private override init() {
        super.init()
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
            reply.failure("invalid_argument", "Text and an active window are required")
            return
        }
        let view = presenter.view
        let picker = NSSharingServicePicker(items: [text])
        picker.delegate = self
        self.picker = picker
        pendingReply = reply
        picker.show(relativeTo: view.bounds, of: view, preferredEdge: .minY)
        reply.onCancel = {
            [weak self] in
            Task {
                @MainActor in
                self?.picker = nil
                self?.pendingReply = nil
            }
        }
    }

    func sharingServicePicker(
        _ sharingServicePicker: NSSharingServicePicker, didChoose service: NSSharingService?
    ) {
        pendingReply?.success()
        pendingReply = nil
        picker = nil
    }
}
