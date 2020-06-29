import 'NotificationAction.dart';

class NotificationCategory {
  String identifier;
  List<NotificationAction> actions;

  NotificationCategory(
    this.identifier,
    this.actions
  );

  Map<String, dynamic> toJson() {
    return {'identifier': identifier, 'actions': new List.generate(actions.length, (index) => actions[index].toJson())};
  }
}
