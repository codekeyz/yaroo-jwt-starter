import 'package:yaroo/http/http.dart';
import 'package:yaroorm/yaroorm.dart';
import 'package:logger/logger.dart';

import '../../src/services/services.dart';

class CoreProvider extends ServiceProvider {
  @override
  void register() {
    final shouldLog =
        app.config.isDebug && app.config.environment == 'development';
    app.singleton<Logger>(Logger(filter: _CustomLogFilter(shouldLog)));

    app.singleton<AuthService>(AuthService(app.config.key, app.config.url));
    app.singleton<UserService>(UserService());
  }

  @override
  void boot() async {
    await DB.defaultDriver.connect();
  }
}

class _CustomLogFilter extends LogFilter {
  final bool loggingEnabled;

  _CustomLogFilter(this.loggingEnabled);

  @override
  bool shouldLog(LogEvent event) => loggingEnabled;
}
