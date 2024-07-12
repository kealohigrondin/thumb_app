import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test/test.dart';
import 'package:thumb_app/secrets.dart';
import 'package:thumb_app/services/supabase_service.dart';

void main() {
  test('Counter should increment', () {
    const num = 2;
    expect(SupabaseService.increment(num), num + 1);
  });

  test('getRidesWithChats should return two rides', () async {
    await Supabase.initialize(
      url: SUPABASE_URL,
      anonKey: SUPABASE_ANON_KEY,
    );
    final rides = await SupabaseService.getRidesWithChats('815757e3-4be8-418a-9d3e-b293018a430b');
    expect(rides.length, 2);
  });
}
