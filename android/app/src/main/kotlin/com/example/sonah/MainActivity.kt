package me.skepr.sonah

import android.app.WallpaperManager
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity: FlutterActivity() {
    private val CHANNEL = "sonah.app/wallpaper"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getWallpaper") {
                try {
                    val wallpaperManager = WallpaperManager.getInstance(context)
                    val wallpaperDrawable = wallpaperManager.drawable
                    
                    if (wallpaperDrawable != null) {
                        val bitmap = (wallpaperDrawable as BitmapDrawable).bitmap
                        val stream = ByteArrayOutputStream()
                        bitmap.compress(Bitmap.CompressFormat.JPEG, 80, stream)
                        val byteArray = stream.toByteArray()
                        result.success(byteArray)
                    } else {
                        result.error("UNAVAILABLE", "Wallpaper not available.", null)
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
