package uz.visionsystemcorp.gastronomic

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
    override fun onCreate() {
        super.onCreate()
        MapKitFactory.setLocale("en_US")
        MapKitFactory.setApiKey("f65ea3dc-63fd-411e-9043-cce7921a4695")
    }
}