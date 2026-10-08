package com.dotnative.plugins

import android.app.Activity
import android.content.Intent

class SharePlugin(private val activity: Activity) {

    init {

        val channel = NativeChannels.channel("dotnative.share")
        channel.handle("shareText") { args, reply ->
            val fields = args as? Map<*, *>
            val text = fields?.get("text") as? String
            if (text.isNullOrBlank() || text.length > 256_000) {

                reply.failure("invalid_argument", "Text is required and must be at most 256 KB")
                return@handle
            }
            try {

                val subject =
                    (fields["subject"] as? String)?.takeIf {
                        it.isNotBlank()
                    }
                val intent =
                    Intent(Intent.ACTION_SEND).apply {
                        type = "text/plain"
                        putExtra(Intent.EXTRA_TEXT, text)
                        if (subject != null) putExtra(Intent.EXTRA_SUBJECT, subject)
                    }
                activity.startActivity(Intent.createChooser(intent, subject ?: "Share"))
                reply.success()
            } catch (error: Exception) {

                reply.failure("share_unavailable", error.message ?: "No share target is available")
            }
        }
    }
}
