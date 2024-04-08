class InstanceIndex {
  InstanceIndex({required this.instance, required this.port});

  final int instance;
  final int port;

  InstanceIndex copyWith({int? instance, int? port}) {
    return InstanceIndex(
      instance: instance ?? this.instance,
      port: port ?? this.port,
    );
  }

  @override
  operator ==(Object other) {
    if (other is InstanceIndex) {
      return other.instance == instance && other.port == port;
    }
    return false;
  }

  @override
  int get hashCode => instance.hashCode ^ port.hashCode;

  @override
  String toString() => '($instance, $port)';
}
