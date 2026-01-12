import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://pvetmjdrtettzkwngvjg.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2ZXRtamRydGV0dHprd25ndmpnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njc1NzExMjUsImV4cCI6MjA4MzE0NzEyNX0.8Z_Ihon68iPX1LnXnQt8hDBoUEtUWNlY0YCOE6_SijA';

  static Future<void> init() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
