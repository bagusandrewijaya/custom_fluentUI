//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <camera_windows/camera_windows.h>
#include <connectivity_plus/connectivity_plus_windows_plugin.h>
#include <flutter_acrylic/flutter_acrylic_plugin.h>
#include <flutter_webrtc/flutter_web_r_t_c_plugin.h>
#include <flutter_window_close/flutter_window_close_plugin.h>
#include <livekit_client/live_kit_plugin.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>
#include <screen_retriever/screen_retriever_plugin.h>
#include <system_theme/system_theme_plugin.h>
#include <url_launcher_windows/url_launcher_windows.h>
#include <window_manager/window_manager_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  CameraWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CameraWindows"));
  ConnectivityPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ConnectivityPlusWindowsPlugin"));
  FlutterAcrylicPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterAcrylicPlugin"));
  FlutterWebRTCPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterWebRTCPlugin"));
  FlutterWindowClosePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterWindowClosePlugin"));
  LiveKitPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("LiveKitPlugin"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
  ScreenRetrieverPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverPlugin"));
  SystemThemePluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SystemThemePlugin"));
  UrlLauncherWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("UrlLauncherWindows"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
}
