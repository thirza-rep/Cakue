// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TransactionEntity {
  String get uuid;
  String get userUuid;
  TransactionType get type;
  String get accountUuid;
  String? get toAccountUuid;
  String? get categoryUuid;
  double get amount;
  double get baseAmount;
  double get exchangeRate;
  String get currencyCode;
  DateTime get date;
  String? get note;
  String? get merchant;
  String? get receiptImagePath;
  List<String>? get tags;
  bool get isRecurring;
  DateTime get createdAt;
  DateTime get updatedAt;
  DateTime? get deletedAt;
  String get syncStatus;

  /// Create a copy of TransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TransactionEntityCopyWith<TransactionEntity> get copyWith =>
      _$TransactionEntityCopyWithImpl<TransactionEntity>(
          this as TransactionEntity, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TransactionEntity &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.userUuid, userUuid) ||
                other.userUuid == userUuid) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.accountUuid, accountUuid) ||
                other.accountUuid == accountUuid) &&
            (identical(other.toAccountUuid, toAccountUuid) ||
                other.toAccountUuid == toAccountUuid) &&
            (identical(other.categoryUuid, categoryUuid) ||
                other.categoryUuid == categoryUuid) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.baseAmount, baseAmount) ||
                other.baseAmount == baseAmount) &&
            (identical(other.exchangeRate, exchangeRate) ||
                other.exchangeRate == exchangeRate) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.merchant, merchant) ||
                other.merchant == merchant) &&
            (identical(other.receiptImagePath, receiptImagePath) ||
                other.receiptImagePath == receiptImagePath) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
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
  int get hashCode => Object.hashAll([
        runtimeType,
        uuid,
        userUuid,
        type,
        accountUuid,
        toAccountUuid,
        categoryUuid,
        amount,
        baseAmount,
        exchangeRate,
        currencyCode,
        date,
        note,
        merchant,
        receiptImagePath,
        const DeepCollectionEquality().hash(tags),
        isRecurring,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus
      ]);

  @override
  String toString() {
    return 'TransactionEntity(uuid: $uuid, userUuid: $userUuid, type: $type, accountUuid: $accountUuid, toAccountUuid: $toAccountUuid, categoryUuid: $categoryUuid, amount: $amount, baseAmount: $baseAmount, exchangeRate: $exchangeRate, currencyCode: $currencyCode, date: $date, note: $note, merchant: $merchant, receiptImagePath: $receiptImagePath, tags: $tags, isRecurring: $isRecurring, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, syncStatus: $syncStatus)';
  }
}

/// @nodoc
abstract mixin class $TransactionEntityCopyWith<$Res> {
  factory $TransactionEntityCopyWith(
          TransactionEntity value, $Res Function(TransactionEntity) _then) =
      _$TransactionEntityCopyWithImpl;
  @useResult
  $Res call(
      {String uuid,
      String userUuid,
      TransactionType type,
      String accountUuid,
      String? toAccountUuid,
      String? categoryUuid,
      double amount,
      double baseAmount,
      double exchangeRate,
      String currencyCode,
      DateTime date,
      String? note,
      String? merchant,
      String? receiptImagePath,
      List<String>? tags,
      bool isRecurring,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String syncStatus});
}

/// @nodoc
class _$TransactionEntityCopyWithImpl<$Res>
    implements $TransactionEntityCopyWith<$Res> {
  _$TransactionEntityCopyWithImpl(this._self, this._then);

  final TransactionEntity _self;
  final $Res Function(TransactionEntity) _then;

  /// Create a copy of TransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uuid = null,
    Object? userUuid = null,
    Object? type = null,
    Object? accountUuid = null,
    Object? toAccountUuid = freezed,
    Object? categoryUuid = freezed,
    Object? amount = null,
    Object? baseAmount = null,
    Object? exchangeRate = null,
    Object? currencyCode = null,
    Object? date = null,
    Object? note = freezed,
    Object? merchant = freezed,
    Object? receiptImagePath = freezed,
    Object? tags = freezed,
    Object? isRecurring = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? syncStatus = null,
  }) {
    return _then(TransactionEntity(
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      userUuid: null == userUuid
          ? _self.userUuid
          : userUuid // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      accountUuid: null == accountUuid
          ? _self.accountUuid
          : accountUuid // ignore: cast_nullable_to_non_nullable
              as String,
      toAccountUuid: freezed == toAccountUuid
          ? _self.toAccountUuid
          : toAccountUuid // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryUuid: freezed == categoryUuid
          ? _self.categoryUuid
          : categoryUuid // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      baseAmount: null == baseAmount
          ? _self.baseAmount
          : baseAmount // ignore: cast_nullable_to_non_nullable
              as double,
      exchangeRate: null == exchangeRate
          ? _self.exchangeRate
          : exchangeRate // ignore: cast_nullable_to_non_nullable
              as double,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      merchant: freezed == merchant
          ? _self.merchant
          : merchant // ignore: cast_nullable_to_non_nullable
              as String?,
      receiptImagePath: freezed == receiptImagePath
          ? _self.receiptImagePath
          : receiptImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isRecurring: null == isRecurring
          ? _self.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
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

/// Adds pattern-matching-related methods to [TransactionEntity].
extension TransactionEntityPatterns on TransactionEntity {
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
    TResult Function(_TransactionEntity value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TransactionEntity() when $default != null:
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
    TResult Function(_TransactionEntity value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionEntity():
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
    TResult? Function(_TransactionEntity value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionEntity() when $default != null:
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
            String userUuid,
            TransactionType type,
            String accountUuid,
            String? toAccountUuid,
            String? categoryUuid,
            double amount,
            double baseAmount,
            double exchangeRate,
            String currencyCode,
            DateTime date,
            String? note,
            String? merchant,
            String? receiptImagePath,
            List<String>? tags,
            bool isRecurring,
            DateTime createdAt,
            DateTime updatedAt,
            DateTime? deletedAt,
            String syncStatus)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TransactionEntity() when $default != null:
        return $default(
            _that.uuid,
            _that.userUuid,
            _that.type,
            _that.accountUuid,
            _that.toAccountUuid,
            _that.categoryUuid,
            _that.amount,
            _that.baseAmount,
            _that.exchangeRate,
            _that.currencyCode,
            _that.date,
            _that.note,
            _that.merchant,
            _that.receiptImagePath,
            _that.tags,
            _that.isRecurring,
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
            String userUuid,
            TransactionType type,
            String accountUuid,
            String? toAccountUuid,
            String? categoryUuid,
            double amount,
            double baseAmount,
            double exchangeRate,
            String currencyCode,
            DateTime date,
            String? note,
            String? merchant,
            String? receiptImagePath,
            List<String>? tags,
            bool isRecurring,
            DateTime createdAt,
            DateTime updatedAt,
            DateTime? deletedAt,
            String syncStatus)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionEntity():
        return $default(
            _that.uuid,
            _that.userUuid,
            _that.type,
            _that.accountUuid,
            _that.toAccountUuid,
            _that.categoryUuid,
            _that.amount,
            _that.baseAmount,
            _that.exchangeRate,
            _that.currencyCode,
            _that.date,
            _that.note,
            _that.merchant,
            _that.receiptImagePath,
            _that.tags,
            _that.isRecurring,
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
            String userUuid,
            TransactionType type,
            String accountUuid,
            String? toAccountUuid,
            String? categoryUuid,
            double amount,
            double baseAmount,
            double exchangeRate,
            String currencyCode,
            DateTime date,
            String? note,
            String? merchant,
            String? receiptImagePath,
            List<String>? tags,
            bool isRecurring,
            DateTime createdAt,
            DateTime updatedAt,
            DateTime? deletedAt,
            String syncStatus)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TransactionEntity() when $default != null:
        return $default(
            _that.uuid,
            _that.userUuid,
            _that.type,
            _that.accountUuid,
            _that.toAccountUuid,
            _that.categoryUuid,
            _that.amount,
            _that.baseAmount,
            _that.exchangeRate,
            _that.currencyCode,
            _that.date,
            _that.note,
            _that.merchant,
            _that.receiptImagePath,
            _that.tags,
            _that.isRecurring,
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

class _TransactionEntity implements TransactionEntity {
  const _TransactionEntity(
      {required this.uuid,
      required this.userUuid,
      required this.type,
      required this.accountUuid,
      this.toAccountUuid,
      this.categoryUuid,
      required this.amount,
      required this.baseAmount,
      required this.exchangeRate,
      required this.currencyCode,
      required this.date,
      this.note,
      this.merchant,
      this.receiptImagePath,
      List<String>? tags,
      this.isRecurring = false,
      required this.createdAt,
      required this.updatedAt,
      this.deletedAt,
      this.syncStatus = 'pending'})
      : _tags = tags;

  @override
  final String uuid;
  @override
  final String userUuid;
  @override
  final TransactionType type;
  @override
  final String accountUuid;
  @override
  final String? toAccountUuid;
  @override
  final String? categoryUuid;
  @override
  final double amount;
  @override
  final double baseAmount;
  @override
  final double exchangeRate;
  @override
  final String currencyCode;
  @override
  final DateTime date;
  @override
  final String? note;
  @override
  final String? merchant;
  @override
  final String? receiptImagePath;
  final List<String>? _tags;
  @override
  List<String>? get tags {
    final value = _tags;
    if (value == null) return null;
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool isRecurring;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  @JsonKey()
  final String syncStatus;

  /// Create a copy of TransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TransactionEntityCopyWith<_TransactionEntity> get copyWith =>
      __$TransactionEntityCopyWithImpl<_TransactionEntity>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TransactionEntity &&
            (identical(other.uuid, uuid) || other.uuid == uuid) &&
            (identical(other.userUuid, userUuid) ||
                other.userUuid == userUuid) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.accountUuid, accountUuid) ||
                other.accountUuid == accountUuid) &&
            (identical(other.toAccountUuid, toAccountUuid) ||
                other.toAccountUuid == toAccountUuid) &&
            (identical(other.categoryUuid, categoryUuid) ||
                other.categoryUuid == categoryUuid) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.baseAmount, baseAmount) ||
                other.baseAmount == baseAmount) &&
            (identical(other.exchangeRate, exchangeRate) ||
                other.exchangeRate == exchangeRate) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.merchant, merchant) ||
                other.merchant == merchant) &&
            (identical(other.receiptImagePath, receiptImagePath) ||
                other.receiptImagePath == receiptImagePath) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isRecurring, isRecurring) ||
                other.isRecurring == isRecurring) &&
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
  int get hashCode => Object.hashAll([
        runtimeType,
        uuid,
        userUuid,
        type,
        accountUuid,
        toAccountUuid,
        categoryUuid,
        amount,
        baseAmount,
        exchangeRate,
        currencyCode,
        date,
        note,
        merchant,
        receiptImagePath,
        const DeepCollectionEquality().hash(_tags),
        isRecurring,
        createdAt,
        updatedAt,
        deletedAt,
        syncStatus
      ]);

  @override
  String toString() {
    return 'TransactionEntity(uuid: $uuid, userUuid: $userUuid, type: $type, accountUuid: $accountUuid, toAccountUuid: $toAccountUuid, categoryUuid: $categoryUuid, amount: $amount, baseAmount: $baseAmount, exchangeRate: $exchangeRate, currencyCode: $currencyCode, date: $date, note: $note, merchant: $merchant, receiptImagePath: $receiptImagePath, tags: $tags, isRecurring: $isRecurring, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, syncStatus: $syncStatus)';
  }
}

/// @nodoc
abstract mixin class _$TransactionEntityCopyWith<$Res>
    implements $TransactionEntityCopyWith<$Res> {
  factory _$TransactionEntityCopyWith(
          _TransactionEntity value, $Res Function(_TransactionEntity) _then) =
      __$TransactionEntityCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String uuid,
      String userUuid,
      TransactionType type,
      String accountUuid,
      String? toAccountUuid,
      String? categoryUuid,
      double amount,
      double baseAmount,
      double exchangeRate,
      String currencyCode,
      DateTime date,
      String? note,
      String? merchant,
      String? receiptImagePath,
      List<String>? tags,
      bool isRecurring,
      DateTime createdAt,
      DateTime updatedAt,
      DateTime? deletedAt,
      String syncStatus});
}

/// @nodoc
class __$TransactionEntityCopyWithImpl<$Res>
    implements _$TransactionEntityCopyWith<$Res> {
  __$TransactionEntityCopyWithImpl(this._self, this._then);

  final _TransactionEntity _self;
  final $Res Function(_TransactionEntity) _then;

  /// Create a copy of TransactionEntity
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? uuid = null,
    Object? userUuid = null,
    Object? type = null,
    Object? accountUuid = null,
    Object? toAccountUuid = freezed,
    Object? categoryUuid = freezed,
    Object? amount = null,
    Object? baseAmount = null,
    Object? exchangeRate = null,
    Object? currencyCode = null,
    Object? date = null,
    Object? note = freezed,
    Object? merchant = freezed,
    Object? receiptImagePath = freezed,
    Object? tags = freezed,
    Object? isRecurring = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? deletedAt = freezed,
    Object? syncStatus = null,
  }) {
    return _then(_TransactionEntity(
      uuid: null == uuid
          ? _self.uuid
          : uuid // ignore: cast_nullable_to_non_nullable
              as String,
      userUuid: null == userUuid
          ? _self.userUuid
          : userUuid // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType,
      accountUuid: null == accountUuid
          ? _self.accountUuid
          : accountUuid // ignore: cast_nullable_to_non_nullable
              as String,
      toAccountUuid: freezed == toAccountUuid
          ? _self.toAccountUuid
          : toAccountUuid // ignore: cast_nullable_to_non_nullable
              as String?,
      categoryUuid: freezed == categoryUuid
          ? _self.categoryUuid
          : categoryUuid // ignore: cast_nullable_to_non_nullable
              as String?,
      amount: null == amount
          ? _self.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      baseAmount: null == baseAmount
          ? _self.baseAmount
          : baseAmount // ignore: cast_nullable_to_non_nullable
              as double,
      exchangeRate: null == exchangeRate
          ? _self.exchangeRate
          : exchangeRate // ignore: cast_nullable_to_non_nullable
              as double,
      currencyCode: null == currencyCode
          ? _self.currencyCode
          : currencyCode // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      note: freezed == note
          ? _self.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
      merchant: freezed == merchant
          ? _self.merchant
          : merchant // ignore: cast_nullable_to_non_nullable
              as String?,
      receiptImagePath: freezed == receiptImagePath
          ? _self.receiptImagePath
          : receiptImagePath // ignore: cast_nullable_to_non_nullable
              as String?,
      tags: freezed == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isRecurring: null == isRecurring
          ? _self.isRecurring
          : isRecurring // ignore: cast_nullable_to_non_nullable
              as bool,
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
