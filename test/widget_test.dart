import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_data_qr/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MedicineDataQRApp());
    await tester.pumpAndSettle();

    expect(find.text('Medicine Data QR'), findsWidgets);
    expect(find.text('Create New Medicine QR'), findsOneWidget);
    expect(find.text('Saved Medicine Strips'), findsOneWidget);
  });
}
