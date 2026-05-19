class SyncAction {
  const SyncAction({
    required this.id,
    required this.action,
    required this.productId,
    required this.retryCount,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String action;
  final int productId;
  final int retryCount;
  final String status;
  final DateTime createdAt;
}
