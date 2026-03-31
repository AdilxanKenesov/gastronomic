package uz.visionsystemcorp.gastronomic

import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Android 15+ Edge-to-Edge rejimini faollashtirish
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}
