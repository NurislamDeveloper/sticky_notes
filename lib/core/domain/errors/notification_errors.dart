sealed class NotificationError {
  const NotificationError();
}
class NotificationInitializationError extends NotificationError {
  final String message;
  const NotificationInitializationError(this.message);
}
class NotificationPermissionError extends NotificationError {
  final String message;
  const NotificationPermissionError(this.message);
}
class NotificationSchedulingError extends NotificationError {
  final String message;
  const NotificationSchedulingError(this.message);
}
class NotificationCancellationError extends NotificationError {
  final String message;
  const NotificationCancellationError(this.message);
}
class NotificationDisplayError extends NotificationError {
  final String message;
  const NotificationDisplayError(this.message);
}
