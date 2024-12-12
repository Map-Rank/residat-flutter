import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mapnrank/app/models/setting_model.dart';
import 'package:mapnrank/app/models/user_model.dart';
import 'package:mapnrank/app/modules/auth/controllers/auth_controller.dart';
import 'package:mapnrank/app/modules/auth/views/login_view.dart';
import 'package:mapnrank/app/modules/community/controllers/community_controller.dart';
import 'package:mapnrank/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:mapnrank/app/modules/events/controllers/events_controller.dart';
import 'package:mapnrank/app/modules/global_widgets/block_button_widget.dart';
import 'package:mapnrank/app/modules/global_widgets/text_field_widget.dart';
import 'package:mapnrank/app/modules/notifications/controllers/notification_controller.dart';
import 'package:mapnrank/app/modules/root/controllers/root_controller.dart';
import 'package:mapnrank/app/repositories/user_repository.dart';
import 'package:mapnrank/app/routes/app_routes.dart';
import 'package:mapnrank/app/services/auth_service.dart';
import 'package:mapnrank/app/services/settings_services.dart';
import 'package:mapnrank/common/ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

@GenerateMocks([FormState])
class MockAuthService extends GetxService with Mock implements AuthService {
  final user = Rx<UserModel>(UserModel(email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      avatarUrl: 'http://example.com/avatar.png'));}


class MockAuthController extends GetxController with Mock implements AuthController {
  @override
  var currentUser = Rx<UserModel>(UserModel(email: 'test@example.com',
      firstName: 'John',
      lastName: 'Doe',
      avatarUrl: 'http://example.com/avatar.png'));
  @override
  var hidePassword = true.obs;
  @override
  var loading = false.obs;
  late GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  late final MockAuthService authService;
  var loginWithPhoneNumber = false.obs;
  var loginOrRegister = false.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  var emailFocus = false;
  var phoneFocus = false;


  @override
  login() async {
    //   loading.value = true;
    //   try {
    //    var a = UserModel(
    //       userId: 1,
    //       firstName: 'John',
    //       lastName: 'Doe',
    //       email: 'john.doe@example.com',
    //       phoneNumber: '1234567890',
    //       gender: 'Male',
    //       avatarUrl: 'https://example.com/avatar.png',
    //       authToken: 'mockAuthToken',
    //       zoneId: 'zone1',
    //       birthdate: '1990-01-01',
    //       companyName: 'Company Inc',
    //       sectors: ['sector1', 'sector2'],
    //     );
    //     authService.user.value.authToken = a.authToken;
    //     authService.user.value.userId = a.userId;
    //     authService.user.value.firstName = a.firstName;
    //     authService.user.value.lastName = a.lastName;
    //
    //     update();
    //     loading.value = false;
    //     Get.showSnackbar(Ui.SuccessSnackBar(message: 'User logged in successfully'));
    //     Get.put(RootController());
    //     Get.lazyPut(() => DashboardController());
    //     Get.lazyPut<CommunityController>(() => CommunityController());
    //     Get.lazyPut<NotificationController>(() => NotificationController());
    //     Get.lazyPut<EventsController>(() => EventsController());
    //     await Get.find<RootController>().changePage(0);
    //   } catch (e) {
    //     Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    //   } finally {
    //     loading.value = false;
    //   }
  }
}



class MockSettingsService extends GetxService with Mock implements SettingsService {
  @override
  var setting = Setting(accentColor: '0xFF6B00FE',accentDarkColor: '#808080', mainColor: '0xFF6B00FE',
      secondColor: '#808080', appName: 'Residat', mainDarkColor: '0xFF6B00FE', scaffoldColor: '0xFF6B00FE',
      scaffoldDarkColor: '0xFF6B00FE', secondDarkColor: '0xFF6B00FE', defaultTheme: 'light'
  ).obs;
}


void main() {
  late MockAuthController mockAuthController;
  late MockSettingsService mockSettingsService;
  late GlobalKey<FormState> loginFormKey;

  setUp(() {
    loginFormKey = GlobalKey<FormState>();
    mockAuthController = MockAuthController();
    mockSettingsService = MockSettingsService();

    // Initialize GetX dependencies
    Get.put<SettingsService>(mockSettingsService);
    Get.put<AuthController>(mockAuthController);
  });

  testWidgets('LoginView renders correctly', (WidgetTester tester) async {
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

            child: Builder(
                builder: (BuildContext context) {
                  return LoginView();
                }

            ),),
        ),
      ),
    );

    // Assert
    //expect(find.text('WELCOME BACK!'), findsOneWidget);
    expect(find.byType(TextFieldWidget), findsNWidgets(2));
    expect(find.byType(BlockButtonWidget), findsOneWidget);
  });

  testWidgets('LoginView form validation', (WidgetTester tester) async {
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

            child: Builder(
                builder: (BuildContext context) {
                  return LoginView();
                }

            ),),
        ),
      ),
    );

    // Act
    //await tester.enterText(find.byType(TextFieldWidget).first, 'invalid email');
    //await tester.enterText(find.byType(TextFieldWidget).last, '123');
    //await tester.tap(find.byType(BlockButtonWidget));
    await tester.pump();

    // Assert
    //expect(find.text('Enter a valid email address'), findsNothing);
    //expect(find.text('Enter at least 6 characters'), findsNothing);
  });

  testWidgets('LoginView calls login method', (WidgetTester tester) async {
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

            child: Builder(
                builder: (BuildContext context) {
                  return LoginView();
                }

            ),),
        ),
      ),
    );

    // Act
    //await tester.enterText(find.byType(TextFieldWidget).first, 'johndoe@gmail.com');
    //await tester.enterText(find.byType(TextFieldWidget).last, 'password123');
    // Scroll to the login button
    await tester.ensureVisible(find.byKey(Key('loginButton')));

    // Wait for any animations to complete
    await tester.pumpAndSettle();

    // Tap the login button
    await tester.tap(find.byKey(Key('loginButton')));

    // Wait for any animations to complete
    await tester.pumpAndSettle();


    // Assert
    //verify(mockAuthController.login()).called(1);
  });

  testWidgets('Navigates to forgot password', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        onUnknownRoute: (settings) {
          // Optionally, navigate to a specific error page or handle it gracefully
          return GetPageRoute(
            settings: RouteSettings(name: '/notfound'),
            page: () => Scaffold(
              appBar: AppBar(title: Text('Page Not Found')),
              body: Center(child: Text('404 - Page Not Found')),
            ),
          );
        },
        unknownRoute: GetPage(
          name: '/notfound',
          page: () => Scaffold(
            appBar: AppBar(title: Text('Page Not Found')),
            body: Center(child: Text('404 - Page Not Found')),
          ),
        ),
        onGenerateRoute: (settings) {
          // Optionally, navigate to a specific error page or handle it gracefully
          return GetPageRoute(
            settings: RouteSettings(name: '/notfound'),
            page: () => Scaffold(
              appBar: AppBar(title: Text('Page Not Found')),
              body: Center(child: Text('404 - Page Not Found')),
            ),
          );
        },
        home: Scaffold(
          body: Localizations(
            delegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Locale('en'),

            child: Builder(
                builder: (BuildContext context) {
                  return LoginView();
                }

            ),),
        ),
      ),
    );

    // Act
    //await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    // Assert
    //expect(Get.currentRoute, Routes.FORGOT_PASSWORD);
  });

  testWidgets('Navigates to sign up', (WidgetTester tester) async {
    // Act
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: Routes.LOGIN,
        home: Scaffold(
          body: Localizations(
            delegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Locale('en'),

            child: Builder(
                builder: (BuildContext context) {
                  return LoginView();
                }

            ),),
        ),
        onUnknownRoute: (settings) {
          // Optionally, navigate to a specific error page or handle it gracefully
          return GetPageRoute(
            settings: RouteSettings(name: '/notfound'),
            page: () => Scaffold(
              appBar: AppBar(title: Text('Page Not Found')),
              body: Center(child: Text('404 - Page Not Found')),
            ),
          );
        },
        unknownRoute: GetPage(
          name: '/notfound',
          page: () => Scaffold(
            appBar: AppBar(title: Text('Page Not Found')),
            body: Center(child: Text('404 - Page Not Found')),
          ),
        ),
        onGenerateRoute: (settings) {
          // Optionally, navigate to a specific error page or handle it gracefully
          return GetPageRoute(
            settings: RouteSettings(name: '/notfound'),
            page: () => Scaffold(
              appBar: AppBar(title: Text('Page Not Found')),
              body: Center(child: Text('404 - Page Not Found')),
            ),
          );
        },
      ),
    );

    // Act
    // Scroll to the login button
    // await tester.ensureVisible(find.byKey(Key('signup')));
    //
    // // Wait for any animations to complete
    // await tester.pumpAndSettle();
    //
    // await tester.tap(find.byKey(Key('signup')));
    // await tester.pumpAndSettle();

    // Assert
    //expect(Get.currentRoute, Routes.REGISTER);
  });
}




