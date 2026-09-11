import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_data_qr/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MedicineDataQRApp());
    await tester.pumpAndSettle();

    expect(find.text('Medicine Data QR'), findsWidgets);
    expect(find.text('Create New Medicine QR'), findsOneWidget);
    expect(find.text('Saved Medicine Strips'), findsOneWidget);
  });
}
