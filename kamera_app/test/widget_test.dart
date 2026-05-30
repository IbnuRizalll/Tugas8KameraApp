import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kamera_app/main.dart';

void main() {
  testWidgets('menampilkan tampilan awal aplikasi kamera', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Kamera Studio'), findsOneWidget);
    expect(find.text('Tangkap momen terbaik'), findsOneWidget);
    expect(find.text('Belum ada foto'), findsOneWidget);
    expect(find.text('Gallery hasil foto'), findsOneWidget);
    expect(find.text('Gallery masih kosong'), findsOneWidget);
    expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
    expect(find.text('Ambil Foto'), findsOneWidget);
    expect(find.text('Pilih Galeri'), findsOneWidget);
  });
}
