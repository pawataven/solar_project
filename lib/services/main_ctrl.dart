import 'package:http/http.dart' as http;

class Esp32Service {
  final String esp32Ip;

  Esp32Service({required this.esp32Ip});

  Future<void> setPumpState(bool isOn) async {
    final state = isOn ? "true" : "false";
    final url = Uri.parse('$esp32Ip/pump?state=$state');
    await http.get(url);
  }
}