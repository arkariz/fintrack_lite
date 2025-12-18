import 'package:fintrack_lite/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FinTrackApp());

    // Verify home screen is present (based on placeholder)
    expect(find.text('FinTrack Lite'), findsOneWidget);
    expect(find.text('Coming Soon: Transaction List'), findsOneWidget);
  });
}
