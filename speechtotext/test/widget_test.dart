import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speechtotext/main.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  stt.SpeechToText _speech = stt.SpeechToText(); // Inicializa _speech como una instancia de SpeechToText

  testWidgets('Prueba básica de incremento del contador', (WidgetTester tester) async {
    // Cambiar el idioma predeterminado del dispositivo a español
    await SystemChannels.platform.invokeMethod('SystemLocale', 'es_ES');

    // Construir nuestra aplicación y activar un frame.
    await tester.pumpWidget(MyApp());

    // Verificar que nuestro contador comience en 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tocar el ícono '+' y activar un frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verificar que nuestro contador haya incrementado.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
