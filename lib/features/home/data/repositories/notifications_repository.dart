/// Repository for notifications.
///
/// Currently returns an empty list as notifications are not yet implemented.
class NotificationsRepository {
  /// Returns the list of notifications.
  Future<List<dynamic>> getNotifications() async {
    // Notifications feature not yet implemented.
    return <dynamic>[];
  }

  /// Marks a notification as read.
  Future<void> markAsRead(String notificationId) async {
    // Notifications feature not yet implemented.
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    // Notifications feature not yet implemented.
  }

  /// Clears all notifications.
  Future<void> clearNotifications() async {
    // Notifications feature not yet implemented.
  }
}
