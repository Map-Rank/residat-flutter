// Mocks generated by Mockito 5.4.4 from annotations
// in mapnrank/test/modules/auth/controllers/auth_controller_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mapnrank/app/models/user_model.dart' as _i2;
import 'package:mapnrank/app/repositories/sector_repository.dart' as _i6;
import 'package:mapnrank/app/repositories/user_repository.dart' as _i3;
import 'package:mapnrank/app/repositories/zone_repository.dart' as _i5;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeUserModel_0 extends _i1.SmartFake implements _i2.UserModel {
  _FakeUserModel_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [UserRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockUserRepository extends _i1.Mock implements _i3.UserRepository {
  MockUserRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<dynamic> login(_i2.UserModel? user) => (super.noSuchMethod(
        Invocation.method(
          #login,
          [user],
        ),
        returnValue: _i4.Future<dynamic>.value(),
      ) as _i4.Future<dynamic>);

  @override
  _i4.Future<dynamic> logout<int>() => (super.noSuchMethod(
        Invocation.method(
          #logout,
          [],
        ),
        returnValue: _i4.Future<dynamic>.value(),
      ) as _i4.Future<dynamic>);

  @override
  _i4.Future<_i2.UserModel> register(_i2.UserModel? user) =>
      (super.noSuchMethod(
        Invocation.method(
          #register,
          [user],
        ),
        returnValue: _i4.Future<_i2.UserModel>.value(_FakeUserModel_0(
          this,
          Invocation.method(
            #register,
            [user],
          ),
        )),
      ) as _i4.Future<_i2.UserModel>);

  @override
  _i4.Future<dynamic> signOut() => (super.noSuchMethod(
        Invocation.method(
          #signOut,
          [],
        ),
        returnValue: _i4.Future<dynamic>.value(),
      ) as _i4.Future<dynamic>);
}

/// A class which mocks [ZoneRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockZoneRepository extends _i1.Mock implements _i5.ZoneRepository {
  MockZoneRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<dynamic> getAllRegions(
    int? levelId,
    int? parentId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getAllRegions,
          [
            levelId,
            parentId,
          ],
        ),
        returnValue: _i4.Future<dynamic>.value(),
      ) as _i4.Future<dynamic>);

  @override
  _i4.Future<dynamic> getAllDivisions(
    int? levelId,
    int? parentId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getAllDivisions,
          [
            levelId,
            parentId,
          ],
        ),
        returnValue: _i4.Future<dynamic>.value(),
      ) as _i4.Future<dynamic>);

  @override
  _i4.Future<dynamic> getAllSubdivisions(
    int? levelId,
    int? parentId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getAllSubdivisions,
          [
            levelId,
            parentId,
          ],
        ),
        returnValue: _i4.Future<dynamic>.value(),
      ) as _i4.Future<dynamic>);
}

/// A class which mocks [SectorRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockSectorRepository extends _i1.Mock implements _i6.SectorRepository {
  MockSectorRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<dynamic> getAllSectors() => (super.noSuchMethod(
        Invocation.method(
          #getAllSectors,
          [],
        ),
        returnValue: _i4.Future<dynamic>.value(),
      ) as _i4.Future<dynamic>);
}
