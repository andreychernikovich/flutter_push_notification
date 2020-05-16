package com.rescomms.flutter_push_notifications

import com.google.firebase.components.Component
import com.google.firebase.components.ComponentRegistrar
import com.google.firebase.platforminfo.LibraryVersionComponent
import java.util.*

class AppRegistrar : ComponentRegistrar {
    override fun getComponents(): MutableList<Component<*>> = Collections.singletonList(
        LibraryVersionComponent.create(BuildConfig.LIBRARY_PACKAGE_NAME, BuildConfig.VERSION_NAME))
}