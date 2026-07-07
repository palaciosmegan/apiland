class ApiConstants {
  // Con `adb reverse tcp:7090 tcp:7090`, el localhost del emulador apunta al
  // localhost del PC. 7090 es el HTTPS del backend (el badCertificateCallback
  // de DioClient acepta el cert autofirmado en debug).
  static const baseUrl = 'https://localhost:7090';
  static const timeout = Duration(seconds: 10);
}