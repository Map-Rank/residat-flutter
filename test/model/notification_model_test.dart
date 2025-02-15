import 'package:flutter_test/flutter_test.dart';
import 'package:mapnrank/app/models/notification_model.dart';
import 'package:mapnrank/app/models/user_model.dart';

void main() {
  group('NotificationModel Tests', () {
    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'id': '123',
        'content': 'This is a notification',
        'title': 'Notification Title',
        'date': '2024-12-10',
        'zoneId': 'zone123',
        'zoneName': 'Zone Name',
        'bannerUrl': 'https://example.com/banner.png',
        'imageNotificationBanner': ['https://example.com/image1.png'],
        'userModel': {
          'id': '456',
          'name': 'John Doe',
          'email': 'johndoe@example.com',
        }
      };

      // Act
      final notification = NotificationModel();
      notification.fromJson(json);


    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final userModel = UserModel(userId: 456, firstName: 'John Doe', email: 'johndoe@example.com');
      final notification = NotificationModel(
        notificationId: 1,
        content: 'This is a notification',
        title: 'Notification Title',
        date: '2024-12-10',
        zoneId: 'zone123',
        zoneName: 'Zone Name',
        bannerUrl: 'https://example.com/banner.png',
        imageNotificationBanner: ['https://example.com/image1.png'],
        userModel: userModel,
      );

      // Act
      final json = notification.toJson();


    });
  });
}
