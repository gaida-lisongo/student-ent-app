import 'package:flutter_riverpod/flutter_riverpod.dart';

final assetBaseUrlProvider = Provider<String>((ref) {
  return 'http://172.20.10.14:3000';
});
