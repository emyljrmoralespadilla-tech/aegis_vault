import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SafehouseResult {
  final List<dynamic> data;
  final bool isOffline;

  SafehouseResult({required this.data, required this.isOffline});
}

class SafehouseService {
  final supabase = Supabase.instance.client;

  final storage = const FlutterSecureStorage();

  Future<SafehouseResult> getSafehouses() async {
    try {
      final response = await supabase.from('safehouses').select();

      await storage.write(
        key: 'safehouses',
        value: jsonEncode(response),
      );

      return SafehouseResult(data: response, isOffline: false);



    } catch (e) {
      final offlineData = await getOfflineData();
      return SafehouseResult(data: offlineData, isOffline: true);
    }
  }

  Future<List<dynamic>> getOfflineData() async {
    try {
      final cached = await storage.read(key: 'safehouses');
      if (cached != null) {
        return jsonDecode(cached) as List<dynamic>;
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
