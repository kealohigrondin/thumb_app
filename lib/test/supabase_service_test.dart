import 'package:test/test.dart';
import 'package:thumb_app/services/supabase_service.dart';

void main() {
  test('Counter should increment', () {
    const num = 2;
    expect(SupabaseService.increment(num), num + 1);
  });
}
