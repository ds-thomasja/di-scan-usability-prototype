import 'package:di_scan_prototype/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots on the password gate', (WidgetTester tester) async {
    await tester.pumpWidget(const DIScanApp());
    await tester.pumpAndSettle();

    expect(find.text('DI Scan'), findsOneWidget);
    expect(find.text('Entsperren'), findsOneWidget);
  });
}
