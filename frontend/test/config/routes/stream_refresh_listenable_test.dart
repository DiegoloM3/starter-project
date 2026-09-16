import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/config/routes/stream_refresh_listenable.dart';

import '../../helpers/pump_app.dart';

void main() {
  test('notifies once per stream event', () async {
    final controller = StreamController<int>();
    final listenable = StreamRefreshListenable(controller.stream);
    var notifications = 0;
    listenable.addListener(() => notifications++);

    controller
      ..add(1)
      ..add(2);
    await flush();

    expect(notifications, 2);
    listenable.dispose();
    await controller.close();
  });

  test('stops listening once disposed', () async {
    final controller = StreamController<int>();
    final listenable = StreamRefreshListenable(controller.stream);
    var notifications = 0;
    listenable.addListener(() => notifications++);

    listenable.dispose();
    expect(controller.hasListener, isFalse);
    await controller.close();
    expect(notifications, 0);
  });
}
