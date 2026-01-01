// Import conditionnel : utilise tflite_flutter uniquement sur les plateformes natives (Android/iOS)
// et un stub pour le web
export 'fruit_detection_service_stub.dart'
    if (dart.library.io) 'fruit_detection_service_io.dart';


