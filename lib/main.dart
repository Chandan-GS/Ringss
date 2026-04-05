import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_a_b/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // 1. Ensure all Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Supabase.initialize(
    url: 'https://trsfgbskdbusjxpbryij.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRyc2ZnYnNrZGJ1c2p4cGJyeWlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0MjI5MzMsImV4cCI6MjA3Nzk5ODkzM30.MVDTGNiJsZgd_pMbJ_j78-Yeoe6yKWUB-UQiR4c3G1w', // Paste your anon (public) key here
  );
  GoogleFonts.config.allowRuntimeFetching = false;

  runApp(const RingssApp());
}
