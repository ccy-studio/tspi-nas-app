import 'package:logger/logger.dart';

class LogUtil {
  static final Logger _logger = Logger();

  static void logDebug(String message) {
    _logger.d(message);
  }

  static void logInfo(String message) {
    _logger.i(message);
  }

  static void logWarning(String message) {
    _logger.w(message);
  }

  static void logError(String message) {
    _logger.e(message);
  }
}
