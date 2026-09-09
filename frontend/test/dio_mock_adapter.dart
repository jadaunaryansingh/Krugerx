import 'package:dio/dio.dart';
import 'dart:typed_data';

class MockDioAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) onFetch;

  MockDioAdapter(this.onFetch);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}
