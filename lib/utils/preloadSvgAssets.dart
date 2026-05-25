import 'package:flutter/services.dart' show rootBundle;

Future<void> preloadSvgAssets(List<String> assetPaths) async {
  for (String path in assetPaths) {
    await rootBundle.loadString(path);
  }
}
