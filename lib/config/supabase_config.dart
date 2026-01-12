import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://pvetmjdrtettzkwngvjg.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_eqxx7B-jnOnAeHoNfAKPRQ_ITWXkle9';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
