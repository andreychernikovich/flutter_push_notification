class NotificationAction {
  String title;
  String identifier;
  /// foreground, background
  String activationMode;
  /// default, textInput
  String behavior;

  NotificationAction({
    this.title,
    this.identifier,
    this.activationMode = 'foreground',
    this.behavior = 'default'
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'identifier': identifier,
      'activationMode': activationMode,
      'behavior': behavior
    };
  }
}