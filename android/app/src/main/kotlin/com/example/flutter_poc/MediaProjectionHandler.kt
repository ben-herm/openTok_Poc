package com.example.flutter_poc
import java.nio.ByteBuffer

interface MediaProjectionHandler {
    fun sendFrame(imageBuffer: ByteBuffer, width: Int, height: Int)
}