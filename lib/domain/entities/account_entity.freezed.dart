// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'account_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccountEntity {
  String get uuid;
  String get name;
  AccountType get type;
  String get currencyCode;
  double get initialBalance;
  double get currentBalance;
  String? get color;
  String? get icon;
  bool get isActive;
  int get sortOrder;
  String? get note;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get syncStatus;

  /// Create a copy of AccountEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AccountEntityCopyWith<AccountEntity> get copyWith =>
      _$AccountEntityCopyWithImpl<AccountEntity>(
          this as AccountEntity, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AccountEntity &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.initialBalance, initialBalance) ||
                other.initialBalance == initialBalance) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      uuid,
      name,
      type,
      currencyCode,
      initialBalance,
      currentBalance,
      color,
      icon,
      isActive,
      sortOrder,
      note,
      createdAt,
      updatedAt,
      deletedAt,
      syncStatus);

  @override
  String toString() {
    return 'AccountEntity(uuid: $uuid, name: $name, type: $type, currencyCode: $currencyCode, initialBalance: $initialBalance, currentBalance: $currentBalance, color: $color, icon: $icon, isActive: $isActive, sortOrder: $sortOrder, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, syncStatus: $syncStatus)';
  }
}

/// @nodoc
abstract mixin class $AccountEntityCopyWith<$Res> {
  factory $AccountEntityCopyWith(
          AccountEntity value, $Res Function(AccountEntity) _then) =
      _$AccountEntityCopyWithImpl;
  @useResult
  $Res call(
      {String uuid,
      String name,
      AccountType type,
      String currencyCode,
      double initialBalance,
      double currentBalance,
      String? color,
      String? icon,
      bool isActive,
      int sortOrder,
      String? note,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String syncStatus});
}

/// @nodoc
class _$AccountEntityCopyWithImpl<$Res>
    implements $AccountEntityCopyWith<$Res> {
  _$AccountEntityCopyWithImpl(this._self, this._then);

  final AccountEntity _self;
  final $Res Function(AccountEntity) _then;

  /// Create a copy of AccountEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? name = null,
    Object? type = null,
    Object? currencyCode = null,
    Object? initialBalance = null,
    Object? currentBalance = null,
    Object? color = freezed,
    Object? icon = freezed,
    Object? isActive = null,
    Object? sortOrder = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? syncStatus = null,
  }) {
    return _then(AccountEntity(
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as AccountType,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      initialBalance: null == initialBalance
          ? _self.initialBalance
          : initialBalance // ignore: cast_nullable_to_non_nullable
              as double,
      currentBalance: null == currentBalance
          ? _self.currentBalance
          : currentBalance // ignore: cast_nullable_to_non_nullable
              as double,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      syncStatus: null == syncStatus
          ? _self.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [AccountEntity].
extension AccountEntityPatterns on AccountEntity {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_AccountEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AccountEntity() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_AccountEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AccountEntity():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_AccountEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AccountEntity() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String uuid,
            String name,
            AccountType type,
            String currencyCode,
            double initialBalance,
            double currentBalance,
            String? color,
            String? icon,
            bool isActive,
            int sortOrder,
            String? note,
            DateTime createdAt,
            DateTime updatedAt,
            DateTime? deletedAt,
            String syncStatus)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AccountEntity() when $default != null:
        return $default(
            _that.uuid,
            _that.name,
            _that.type,
            _that.currencyCode,
            _that.initialBalance,
            _that.currentBalance,
            _that.color,
            _that.icon,
            _that.isActive,
            _that.sortOrder,
            _that.note,
            _that.createdAt,
            _that.updatedAt,
            _that.deletedAt,
            _that.syncStatus);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String uuid,
            String name,
            AccountType type,
            String currencyCode,
            double initialBalance,
            double currentBalance,
            String? color,
            String? icon,
            bool isActive,
            int sortOrder,
            String? note,
            DateTime createdAt,
            DateTime updatedAt,
            DateTime? deletedAt,
            String syncStatus)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AccountEntity():
        return $default(
            _that.uuid,
            _that.name,
            _that.type,
            _that.currencyCode,
            _that.initialBalance,
            _that.currentBalance,
            _that.color,
            _that.icon,
            _that.isActive,
            _that.sortOrder,
            _that.note,
            _that.createdAt,
            _that.updatedAt,
            _that.deletedAt,
            _that.syncStatus);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String uuid,
            String name,
            AccountType type,
            String currencyCode,
            double initialBalance,
            double currentBalance,
            String? color,
            String? icon,
            bool isActive,
            int sortOrder,
            String? note,
            DateTime createdAt,
            DateTime updatedAt,
            DateTime? deletedAt,
            String syncStatus)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AccountEntity() when $default != null:
        return $default(
            _that.uuid,
            _that.name,
            _that.type,
            _that.currencyCode,
            _that.initialBalance,
            _that.currentBalance,
            _that.color,
            _that.icon,
            _that.isActive,
            _that.sortOrder,
            _that.note,
            _that.createdAt,
            _that.updatedAt,
            _that.deletedAt,
            _that.syncStatus);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _AccountEntity extends AccountEntity {
  const _AccountEntity(
      {required this.uuid,
      required this.name,
      required this.type,
      required this.currencyCode,
      required this.initialBalance,
      required this.currentBalance,
      this.color,
      this.icon,
      this.isActive = true,
      this.sortOrder = 0,
      this.note,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.syncStatus = 'pending'})
      : super._();

  @override
  final String uuid;
  @override
  final String name;
  @override
  final AccountType type;
  @override
  final String currencyCode;
  @override
  final double initialBalance;
  @override
  final double currentBalance;
  @override
  final String? color;
  @override
  final String? icon;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final int sortOrder;
  @override
  final String? note;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  @JsonKey()
  final String syncStatus;

  /// Create a copy of AccountEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AccountEntityCopyWith<_AccountEntity> get copyWith =>
      __$AccountEntityCopyWithImpl<_AccountEntity>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AccountEntity &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.initialBalance, initialBalance) ||
                other.initialBalance == initialBalance) &&
            (identical(other.currentBalance, currentBalance) ||
                other.currentBalance == currentBalance) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.syncStatus, syncStatus) ||
                other.syncStatus == syncStatus));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      uuid,
      name,
      type,
      currencyCode,
      initialBalance,
      currentBalance,
      color,
      icon,
      isActive,
      sortOrder,
      note,
      createdAt,
      updatedAt,
      deletedAt,
      syncStatus);

  @override
  String toString() {
    return 'AccountEntity(uuid: $uuid, name: $name, type: $type, currencyCode: $currencyCode, initialBalance: $initialBalance, currentBalance: $currentBalance, color: $color, icon: $icon, isActive: $isActive, sortOrder: $sortOrder, note: $note, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, syncStatus: $syncStatus)';
  }
}

/// @nodoc
abstract mixin class _$AccountEntityCopyWith<$Res>
    implements $AccountEntityCopyWith<$Res> {
  factory _$AccountEntityCopyWith(
          _AccountEntity value, $Res Function(_AccountEntity) _then) =
      __$AccountEntityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String uuid,
      String name,
      AccountType type,
      String currencyCode,
      double initialBalance,
      double currentBalance,
      String? color,
      String? icon,
      bool isActive,
      int sortOrder,
      String? note,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String syncStatus});
}

/// @nodoc
class __$AccountEntityCopyWithImpl<$Res>
    implements _$AccountEntityCopyWith<$Res> {
  __$AccountEntityCopyWithImpl(this._self, this._then);

  final _AccountEntity _self;
  final $Res Function(_AccountEntity) _then;

  /// Create a copy of AccountEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? uuid = null,
    Object? name = null,
    Object? type = null,
    Object? currencyCode = null,
    Object? initialBalance = null,
    Object? currentBalance = null,
    Object? color = freezed,
    Object? icon = freezed,
    Object? isActive = null,
    Object? sortOrder = null,
    Object? note = freezed,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? syncStatus = null,
  }) {
    return _then(_AccountEntity(
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as AccountType,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      initialBalance: null == initialBalance
          ? _self.initialBalance
          : initialBalance // ignore: cast_nullable_to_non_nullable
              as double,
      currentBalance: null == currentBalance
          ? _self.currentBalance
          : currentBalance // ignore: cast_nullable_to_non_nullable
              as double,
      color: freezed == color
          ? _self.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String?,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      sortOrder: null == sortOrder
          ? _self.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      syncStatus: null == syncStatus
          ? _self.syncStatus
          : syncStatus // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
