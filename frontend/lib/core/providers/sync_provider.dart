import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sync.dart';
import 'auth_provider.dart';

final syncProvider = NotifierProvider<SyncNotifier, DeviceModel?>(SyncNotifier.new);

class SyncNotifier extends Notifier<DeviceModel?> {
  @override
  DeviceModel? build() => null;

  Future<void> registerDevice(String name, String type, String os, String version) async {
    final api = ref.read(apiClientProvider);
    try {
      final res = await api.dio.post('/sync/devices', data: {
        'device_name': name,
        'device_type': type,
        'os': os,
        'client_version': version,
      });
      if (res.data['success'] == true) {
        state = DeviceModel.fromJson(res.data['data']);
      }
    } catch (_) {}
  }
}
