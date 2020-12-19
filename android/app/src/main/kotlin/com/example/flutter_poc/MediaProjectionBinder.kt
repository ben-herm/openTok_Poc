package com.example.flutter_poc

import android.os.Binder

class MediaProjectionBinder : Binder() {
    public var mediaProjectionHandler: MediaProjectionHandler? = null
}