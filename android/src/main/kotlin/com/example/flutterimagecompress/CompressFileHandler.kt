package com.example.flutterimagecompress

import android.app.Activity
import android.graphics.BitmapFactory
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

class CompressFileHandler(var call: MethodCall, var result: MethodChannel.Result) : AutoSaveExif {

    override var info: ImageInfo = ImageInfo()

    companion object {
        @JvmStatic
        val executor = Executors.newFixedThreadPool(5)
    }

    fun handle(activity: Activity) {
        executor.execute {
            val args: List<Any> = call.arguments as List<Any>
            val file = args[0] as String
            val minWidth = args[1] as Int
            val minHeight = args[2] as Int
            val quality = args[3] as Int
            val rotate = args[4] as Int
            try {
                loadExif(activity, File(file).readBytes())
                val bitmap = BitmapFactory.decodeFile(file)
                var array = bitmap.compress(minWidth, minHeight, quality, rotate)
                array = saveExif(array)
                result.success(array)
            } catch (e: Exception) {
                result.success(null)
            }
        }
    }

    fun handleGetFile(activity: Activity) {
        executor.execute {
            val args: List<Any> = call.arguments as List<Any>
            val file = args[0] as String
            val minWidth = args[1] as Int
            val minHeight = args[2] as Int
            val quality = args[3] as Int
            val targetPath = args[4] as String
            val rotate = args[5] as Int
            try {
                loadExif(activity, File(file).readBytes())
                val bitmap = BitmapFactory.decodeFile(file)
                var array = bitmap.compress(minWidth, minHeight, quality, rotate)
                array = saveExif(array)
                val targetFile = File(targetPath)
                targetFile.writeBytes(array)
                result.success(targetPath)
            } catch (e: Exception) {
                result.success(null)
            }
        }
    }

}