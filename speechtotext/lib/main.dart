import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Text Demo',
      home: SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  @override
  _SpeechScreenState createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  stt.SpeechToText _speech = stt.SpeechToText();
  FlutterTts flutterTts = FlutterTts();
  bool _isListening = false;
  String _text = '';

  String _userName = '';
  List<String> _selectedServers = [];
  Map<String, double> _serverPrices = {'Apache': 3, 'Amazon': 5, 'Google': 6};
  double _totalPrice = 0.0;
  bool _isPurchaseConfirmed = false;

  @override
  void initState() {
    super.initState();
    _initAssistant();
  }

  void _initAssistant() async {
    await flutterTts.setLanguage('es-ES');
    await flutterTts.speak('¡Bienvenido! Soy tu asistente de voz. ¿Cómo te llamas?');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice Assistant Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _text.isNotEmpty ? _text : 'Presiona el botón para empezar a hablar',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? _stopListening : _startListening,
              child: Text(_isListening ? 'Detener reconocimiento' : 'Iniciar reconocimiento'),
            ),
          ],
        ),
      ),
    );
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _speech.listen(
          onResult: (result) {
            setState(() {
              _text = result.recognizedWords;
              if (_text.trim().isNotEmpty) {
                _handleSpeechInput(_text.trim());
              }
            });
          },
          listenOptions: stt.SpeechListenOptions(
            cancelOnError: true,
          ),
        );
        setState(() => _isListening = true);
      } else {
        setState(() => _text = 'El reconocimiento de voz no está disponible');
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() {
        _isListening = false;
        _text = '';
      });
    }
  }

  void _handleSpeechInput(String input) async {
    print('Usuario dijo: $input');
    if (_userName.isEmpty) {
      _userName = input.isNotEmpty ? input : 'Usuario';
      await flutterTts.speak('Mucho gusto $_userName, ¿qué servidor o servidores te gustaría comprar? Puedes elegir entre Apache, Amazon y Google.');
    } else if (_selectedServers.isEmpty) {
      List<String> servers = ['Apache', 'Amazon', 'Google'];
      bool found = false;
      for (String server in servers) {
        if (input.toLowerCase().contains(server.toLowerCase())) {
          _selectedServers.add(server);
          found = true;
        }
      }
      if (!found) {
        await flutterTts.speak('Lo siento, no entendí qué servidor o servidores deseas. Por favor, intenta nuevamente.');
      } else {
        await flutterTts.speak('¿Cuántos servidores de ${_selectedServers.join(' y ')} te gustaría comprar?');
      }
    } else if (_totalPrice == 0.0) {
      try {
        int quantity = parseNumber(input);
        await _calculateTotalPrice(quantity);
      } catch (e) {
        print('Error al procesar la entrada: $e');
        await flutterTts.speak('Lo siento, solo puedo aceptar números enteros como cantidad. Por favor, intenta de nuevo.');
      }
    } else if (!_isPurchaseConfirmed) {
      if (input.contains('sí') || input.contains('aceptar')) {
        await _completePurchase();
      } else if (input.contains('cancelar')) {
        _resetState();
      }
    } else {
      // El usuario ha confirmado la compra y estamos esperando su correo electrónico
      await _requestEmailAddress();
    }
  }

  int parseNumber(String input) {
    switch (input.toLowerCase()) {
      case 'uno':
        return 1;
      case 'dos':
        return 2;
      case 'tres':
        return 3;
      case 'cuatro':
        return 4;
      case 'cinco':
        return 5;
      case 'seis':
        return 6;
      case 'siete':
        return 7;
      case 'ocho':
        return 8;
      case 'nueve':
        return 9;
      case 'diez':
        return 10;
      default:
        return int.tryParse(input) ?? 0;
    }
  }

  Future<void> _calculateTotalPrice(int quantity) async {
    if (quantity <= 0) {
      await flutterTts.speak('Lo siento, no he entendido la cantidad de servidores correctamente. ¿Cuántos servidores te gustaría comprar?');
      return;
    }

    _totalPrice = 0.0;
    for (String server in _selectedServers) {
      double price = _serverPrices[server] ?? 0;
      _totalPrice += price * quantity;
    }
    await flutterTts.speak('El precio total es de $_totalPrice dólares. ¿Deseas continuar con la compra?');
    _isPurchaseConfirmed = false;
  }

  Future<void> _completePurchase() async {
    await flutterTts.speak('tu correo fue registrado con exito tu paga fue realizada exitosamente , ¿qué servidor o servidores te gustaría comprar? Puedes elegir entre Apache, Amazon y Google.');
    _isPurchaseConfirmed = true;
  }

  void _resetState() {
    _userName = '';
    _selectedServers = [];
    _totalPrice = 0.0;
    _isPurchaseConfirmed = false;
    _speech.stop();
    setState(() => _isListening = false);
    _startListening();
  }

  Future<void> _requestEmailAddress() async {
    // Aquí deberías agregar el código para solicitar y procesar el correo electrónico del usuario
    // Una vez que se ha procesado el correo electrónico, puedes decir 'Su compra ha sido exitosa'
    // y luego restablecer el estado
    await flutterTts.speak('Su compra ha sido exitosa.');
    _resetState();
  }
}
