import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static Future<void> init() async {
    await Supabase.initialize(
      url: 'https://TU_URL_DE_SUPABASE.supabase.co',
      anonKey: 'TU_ANON_KEY',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
