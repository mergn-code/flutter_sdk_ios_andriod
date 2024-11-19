
import 'flutter_plugin_platform_interface.dart';

class FlutterPlugin {
  Future<String?> getPlatformVersion() {
    return FlutterPluginPlatform.instance.getPlatformVersion();
  }
}
