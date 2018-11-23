package com.example.flutterimagecompress

import android.content.Context
import it.sephiroth.android.library.exif2.ExifInterface
import it.sephiroth.android.library.exif2.ExifOutputStream
import java.io.ByteArrayOutputStream
import java.io.File

/// create 2018/11/23 by cai


interface AutoSaveExif {

    var info: ImageInfo

    fun loadExif(act: Context, arr: ByteArray) {
        info = handleMetadata(arr)
    }

    fun saveExif(array: ByteArray): ByteArray {
        val outputStream = ByteArrayOutputStream()
        outputStream.write(array)
        info.exif?.let {
            val exifOutputStream = ExifOutputStream(it)
            exifOutputStream.writeExifData(outputStream)
        }
        return outputStream.toByteArray()
    }


}

class ImageInfo {
    var exif: ExifInterface? = null
    var srcFile: File? = null
}

private fun handleMetadata(arr: ByteArray): ImageInfo {
    val exifInterface = ExifInterface()
    exifInterface.readExif(arr.inputStream(), ExifInterface.Options.OPTION_ALL)
    return ImageInfo().apply {
        exif = exifInterface
    }
}
