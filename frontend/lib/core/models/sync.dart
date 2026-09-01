class DeviceModel {
  final String id;
  final String deviceName;
  final String deviceType;
  final String os;
  final String clientVersion;

  DeviceModel({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.os,
    required this.clientVersion,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      deviceName: json['device_name'] as String,
      deviceType: json['device_type'] as String,
      os: json['os'] as String,
      clientVersion: json['client_version'] as String,
    );
  }
}
