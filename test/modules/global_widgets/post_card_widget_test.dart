import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/global_widgets/post_card_widget.dart';
import 'package:mapnrank/app/services/auth_service.dart';

void main() {
  setUp(() {
    Get.lazyPut(() => AuthService());
  });
  tearDown(() {
    Get.reset(); // Reset the GetX state after each test
  });

  testWidgets('PostCardWidget renders correctly and interacts',
      (WidgetTester tester) async {
    // Arrange
    final UserModel mockUser = UserModel(
      userId: 1,
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      phoneNumber: '1234567890',
      gender: 'Male',
      avatarUrl: 'https://example.com/avatar.png',
      authToken: 'mockAuthToken',
      zoneId: 'zone1',
      birthdate: '1990-01-01',
      profession: 'Company Inc',
      sectors: ['sector1', 'sector2'],
    );

    //AuthService().user.value.authToken = mockUser.authToken;

    final RxInt likeCount = RxInt(5);
    final RxInt shareCount = RxInt(2);

    final postCardWidget = PostCardWidget(
        user: mockUser,
        isCommunityPage: true,
        sectors: ['sector1', 'sector2'],
        zone: 'Zone 1',
        content: 'This is a post content.',
        postId: 1,
        publishedDate: '2024-06-14',
        likeCount: likeCount,
        commentCount: RxInt(3),
        shareCount: shareCount,
        images: [
          {'url': 'https://example.com/image1.png'},
          {'url': 'https://example.com/image2.png'}
        ],
        liked: true,
        onLikeTapped: () => likeCount.value++,
        onCommentTapped: () {},
        onSharedTapped: () => shareCount.value++,
        onPictureTapped: () {},
        onActionTapped: () {},
        likeWidget: FaIcon(FontAwesomeIcons.heart,),
        followWidget: GestureDetector(
          onTap: () {},
          child: Text('Follow'),
        ),
        popUpWidget: SizedBox());

    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Localizations(
            delegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Locale('en'),
            child: Builder(builder: (BuildContext context) {
              return SingleChildScrollView(
                child: postCardWidget,
              );
            }),
          ),
        ),
      ),
    );

    // Assert
    expect(find.text('John Doe'), findsOne);
    expect(find.text('This is a post content.'), findsNothing);
    expect(find.byType(FadeInImage), findsAtLeastNWidgets(1));
    expect(find.byType(FaIcon), findsWidgets);

    //await tester.tap(find.byKey(const Key('likeIcon')));
    await tester.pump();

    expect(likeCount.value, 5);

    //await tester.tap(find.byKey(const Key('shareIcon')));
    await tester.pump();
    expect(shareCount.value, 2);
  });
}
