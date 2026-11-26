// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GenerationsTable extends Generations
    with TableInfo<$GenerationsTable, GenerationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GenerationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => ComparableExpr(id).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionNameMeta = const VerificationMeta(
    'regionName',
  );
  @override
  late final GeneratedColumn<String> regionName = GeneratedColumn<String>(
    'region_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, regionName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'generation';
  @override
  VerificationContext validateIntegrity(
    Insertable<GenerationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('region_name')) {
      context.handle(
        _regionNameMeta,
        regionName.isAcceptableOrUnknown(data['region_name']!, _regionNameMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GenerationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GenerationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      regionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region_name'],
      ),
    );
  }

  @override
  $GenerationsTable createAlias(String alias) {
    return $GenerationsTable(attachedDatabase, alias);
  }
}

class GenerationRow extends DataClass implements Insertable<GenerationRow> {
  final int id;
  final String name;
  final String? regionName;
  const GenerationRow({required this.id, required this.name, this.regionName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || regionName != null) {
      map['region_name'] = Variable<String>(regionName);
    }
    return map;
  }

  GenerationsCompanion toCompanion(bool nullToAbsent) {
    return GenerationsCompanion(
      id: Value(id),
      name: Value(name),
      regionName: regionName == null && nullToAbsent
          ? const Value.absent()
          : Value(regionName),
    );
  }

  factory GenerationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GenerationRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      regionName: serializer.fromJson<String?>(json['regionName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'regionName': serializer.toJson<String?>(regionName),
    };
  }

  GenerationRow copyWith({
    int? id,
    String? name,
    Value<String?> regionName = const Value.absent(),
  }) => GenerationRow(
    id: id ?? this.id,
    name: name ?? this.name,
    regionName: regionName.present ? regionName.value : this.regionName,
  );
  GenerationRow copyWithCompanion(GenerationsCompanion data) {
    return GenerationRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      regionName: data.regionName.present
          ? data.regionName.value
          : this.regionName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GenerationRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('regionName: $regionName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, regionName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GenerationRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.regionName == this.regionName);
}

class GenerationsCompanion extends UpdateCompanion<GenerationRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> regionName;
  const GenerationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.regionName = const Value.absent(),
  });
  GenerationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.regionName = const Value.absent(),
  }) : name = Value(name);
  static Insertable<GenerationRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? regionName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (regionName != null) 'region_name': regionName,
    });
  }

  GenerationsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? regionName,
  }) {
    return GenerationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      regionName: regionName ?? this.regionName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (regionName.present) {
      map['region_name'] = Variable<String>(regionName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GenerationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('regionName: $regionName')
          ..write(')'))
        .toString();
  }
}

class $PokemonSpeciesTable extends PokemonSpecies
    with TableInfo<$PokemonSpeciesTable, SpeciesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonSpeciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => ComparableExpr(id).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generationIdMeta = const VerificationMeta(
    'generationId',
  );
  @override
  late final GeneratedColumn<int> generationId = GeneratedColumn<int>(
    'generation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES generation (id)',
    ),
  );
  static const VerificationMeta _evolutionChainIdMeta = const VerificationMeta(
    'evolutionChainId',
  );
  @override
  late final GeneratedColumn<int> evolutionChainId = GeneratedColumn<int>(
    'evolution_chain_id',
    aliasedName,
    true,
    check: () => ComparableExpr(evolutionChainId).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    generationId,
    evolutionChainId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('generation_id')) {
      context.handle(
        _generationIdMeta,
        generationId.isAcceptableOrUnknown(
          data['generation_id']!,
          _generationIdMeta,
        ),
      );
    }
    if (data.containsKey('evolution_chain_id')) {
      context.handle(
        _evolutionChainIdMeta,
        evolutionChainId.isAcceptableOrUnknown(
          data['evolution_chain_id']!,
          _evolutionChainIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      generationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}generation_id'],
      ),
      evolutionChainId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}evolution_chain_id'],
      ),
    );
  }

  @override
  $PokemonSpeciesTable createAlias(String alias) {
    return $PokemonSpeciesTable(attachedDatabase, alias);
  }
}

class SpeciesRow extends DataClass implements Insertable<SpeciesRow> {
  final int id;
  final String name;
  final int? generationId;
  final int? evolutionChainId;
  const SpeciesRow({
    required this.id,
    required this.name,
    this.generationId,
    this.evolutionChainId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || generationId != null) {
      map['generation_id'] = Variable<int>(generationId);
    }
    if (!nullToAbsent || evolutionChainId != null) {
      map['evolution_chain_id'] = Variable<int>(evolutionChainId);
    }
    return map;
  }

  PokemonSpeciesCompanion toCompanion(bool nullToAbsent) {
    return PokemonSpeciesCompanion(
      id: Value(id),
      name: Value(name),
      generationId: generationId == null && nullToAbsent
          ? const Value.absent()
          : Value(generationId),
      evolutionChainId: evolutionChainId == null && nullToAbsent
          ? const Value.absent()
          : Value(evolutionChainId),
    );
  }

  factory SpeciesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      generationId: serializer.fromJson<int?>(json['generationId']),
      evolutionChainId: serializer.fromJson<int?>(json['evolutionChainId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'generationId': serializer.toJson<int?>(generationId),
      'evolutionChainId': serializer.toJson<int?>(evolutionChainId),
    };
  }

  SpeciesRow copyWith({
    int? id,
    String? name,
    Value<int?> generationId = const Value.absent(),
    Value<int?> evolutionChainId = const Value.absent(),
  }) => SpeciesRow(
    id: id ?? this.id,
    name: name ?? this.name,
    generationId: generationId.present ? generationId.value : this.generationId,
    evolutionChainId: evolutionChainId.present
        ? evolutionChainId.value
        : this.evolutionChainId,
  );
  SpeciesRow copyWithCompanion(PokemonSpeciesCompanion data) {
    return SpeciesRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      generationId: data.generationId.present
          ? data.generationId.value
          : this.generationId,
      evolutionChainId: data.evolutionChainId.present
          ? data.evolutionChainId.value
          : this.evolutionChainId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('generationId: $generationId, ')
          ..write('evolutionChainId: $evolutionChainId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, generationId, evolutionChainId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.generationId == this.generationId &&
          other.evolutionChainId == this.evolutionChainId);
}

class PokemonSpeciesCompanion extends UpdateCompanion<SpeciesRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> generationId;
  final Value<int?> evolutionChainId;
  const PokemonSpeciesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.generationId = const Value.absent(),
    this.evolutionChainId = const Value.absent(),
  });
  PokemonSpeciesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.generationId = const Value.absent(),
    this.evolutionChainId = const Value.absent(),
  }) : name = Value(name);
  static Insertable<SpeciesRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? generationId,
    Expression<int>? evolutionChainId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (generationId != null) 'generation_id': generationId,
      if (evolutionChainId != null) 'evolution_chain_id': evolutionChainId,
    });
  }

  PokemonSpeciesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? generationId,
    Value<int?>? evolutionChainId,
  }) {
    return PokemonSpeciesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      generationId: generationId ?? this.generationId,
      evolutionChainId: evolutionChainId ?? this.evolutionChainId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (generationId.present) {
      map['generation_id'] = Variable<int>(generationId.value);
    }
    if (evolutionChainId.present) {
      map['evolution_chain_id'] = Variable<int>(evolutionChainId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonSpeciesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('generationId: $generationId, ')
          ..write('evolutionChainId: $evolutionChainId')
          ..write(')'))
        .toString();
  }
}

class $PokemonRecordsTable extends PokemonRecords
    with TableInfo<$PokemonRecordsTable, PokemonRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => ComparableExpr(id).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nationalNumberMeta = const VerificationMeta(
    'nationalNumber',
  );
  @override
  late final GeneratedColumn<int> nationalNumber = GeneratedColumn<int>(
    'national_number',
    aliasedName,
    false,
    check: () => ComparableExpr(nationalNumber).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES species (id)',
    ),
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    check: () => ComparableExpr(height).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
    'weight',
    aliasedName,
    true,
    check: () => ComparableExpr(weight).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseStatTotalMeta = const VerificationMeta(
    'baseStatTotal',
  );
  @override
  late final GeneratedColumn<int> baseStatTotal = GeneratedColumn<int>(
    'base_stat_total',
    aliasedName,
    true,
    check: () => ComparableExpr(baseStatTotal).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _shinyImageUrlMeta = const VerificationMeta(
    'shinyImageUrl',
  );
  @override
  late final GeneratedColumn<String> shinyImageUrl = GeneratedColumn<String>(
    'shiny_image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nationalNumber,
    name,
    imageUrl,
    updatedAt,
    speciesId,
    height,
    weight,
    baseStatTotal,
    isDefault,
    shinyImageUrl,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('national_number')) {
      context.handle(
        _nationalNumberMeta,
        nationalNumber.isAcceptableOrUnknown(
          data['national_number']!,
          _nationalNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nationalNumberMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('base_stat_total')) {
      context.handle(
        _baseStatTotalMeta,
        baseStatTotal.isAcceptableOrUnknown(
          data['base_stat_total']!,
          _baseStatTotalMeta,
        ),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('shiny_image_url')) {
      context.handle(
        _shinyImageUrlMeta,
        shinyImageUrl.isAcceptableOrUnknown(
          data['shiny_image_url']!,
          _shinyImageUrlMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PokemonRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nationalNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}national_number'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight'],
      ),
      baseStatTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_stat_total'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      shinyImageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shiny_image_url'],
      ),
    );
  }

  @override
  $PokemonRecordsTable createAlias(String alias) {
    return $PokemonRecordsTable(attachedDatabase, alias);
  }
}

class PokemonRow extends DataClass implements Insertable<PokemonRow> {
  final int id;
  final int nationalNumber;
  final String name;
  final String? imageUrl;
  final DateTime updatedAt;
  final int? speciesId;
  final int? height;
  final int? weight;
  final int? baseStatTotal;
  final bool isDefault;
  final String? shinyImageUrl;
  const PokemonRow({
    required this.id,
    required this.nationalNumber,
    required this.name,
    this.imageUrl,
    required this.updatedAt,
    this.speciesId,
    this.height,
    this.weight,
    this.baseStatTotal,
    required this.isDefault,
    this.shinyImageUrl,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['national_number'] = Variable<int>(nationalNumber);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || speciesId != null) {
      map['species_id'] = Variable<int>(speciesId);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || weight != null) {
      map['weight'] = Variable<int>(weight);
    }
    if (!nullToAbsent || baseStatTotal != null) {
      map['base_stat_total'] = Variable<int>(baseStatTotal);
    }
    map['is_default'] = Variable<bool>(isDefault);
    if (!nullToAbsent || shinyImageUrl != null) {
      map['shiny_image_url'] = Variable<String>(shinyImageUrl);
    }
    return map;
  }

  PokemonRecordsCompanion toCompanion(bool nullToAbsent) {
    return PokemonRecordsCompanion(
      id: Value(id),
      nationalNumber: Value(nationalNumber),
      name: Value(name),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      updatedAt: Value(updatedAt),
      speciesId: speciesId == null && nullToAbsent
          ? const Value.absent()
          : Value(speciesId),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      weight: weight == null && nullToAbsent
          ? const Value.absent()
          : Value(weight),
      baseStatTotal: baseStatTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(baseStatTotal),
      isDefault: Value(isDefault),
      shinyImageUrl: shinyImageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(shinyImageUrl),
    );
  }

  factory PokemonRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonRow(
      id: serializer.fromJson<int>(json['id']),
      nationalNumber: serializer.fromJson<int>(json['nationalNumber']),
      name: serializer.fromJson<String>(json['name']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      speciesId: serializer.fromJson<int?>(json['speciesId']),
      height: serializer.fromJson<int?>(json['height']),
      weight: serializer.fromJson<int?>(json['weight']),
      baseStatTotal: serializer.fromJson<int?>(json['baseStatTotal']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      shinyImageUrl: serializer.fromJson<String?>(json['shinyImageUrl']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nationalNumber': serializer.toJson<int>(nationalNumber),
      'name': serializer.toJson<String>(name),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'speciesId': serializer.toJson<int?>(speciesId),
      'height': serializer.toJson<int?>(height),
      'weight': serializer.toJson<int?>(weight),
      'baseStatTotal': serializer.toJson<int?>(baseStatTotal),
      'isDefault': serializer.toJson<bool>(isDefault),
      'shinyImageUrl': serializer.toJson<String?>(shinyImageUrl),
    };
  }

  PokemonRow copyWith({
    int? id,
    int? nationalNumber,
    String? name,
    Value<String?> imageUrl = const Value.absent(),
    DateTime? updatedAt,
    Value<int?> speciesId = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> weight = const Value.absent(),
    Value<int?> baseStatTotal = const Value.absent(),
    bool? isDefault,
    Value<String?> shinyImageUrl = const Value.absent(),
  }) => PokemonRow(
    id: id ?? this.id,
    nationalNumber: nationalNumber ?? this.nationalNumber,
    name: name ?? this.name,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    updatedAt: updatedAt ?? this.updatedAt,
    speciesId: speciesId.present ? speciesId.value : this.speciesId,
    height: height.present ? height.value : this.height,
    weight: weight.present ? weight.value : this.weight,
    baseStatTotal: baseStatTotal.present
        ? baseStatTotal.value
        : this.baseStatTotal,
    isDefault: isDefault ?? this.isDefault,
    shinyImageUrl: shinyImageUrl.present
        ? shinyImageUrl.value
        : this.shinyImageUrl,
  );
  PokemonRow copyWithCompanion(PokemonRecordsCompanion data) {
    return PokemonRow(
      id: data.id.present ? data.id.value : this.id,
      nationalNumber: data.nationalNumber.present
          ? data.nationalNumber.value
          : this.nationalNumber,
      name: data.name.present ? data.name.value : this.name,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      height: data.height.present ? data.height.value : this.height,
      weight: data.weight.present ? data.weight.value : this.weight,
      baseStatTotal: data.baseStatTotal.present
          ? data.baseStatTotal.value
          : this.baseStatTotal,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      shinyImageUrl: data.shinyImageUrl.present
          ? data.shinyImageUrl.value
          : this.shinyImageUrl,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonRow(')
          ..write('id: $id, ')
          ..write('nationalNumber: $nationalNumber, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('speciesId: $speciesId, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('baseStatTotal: $baseStatTotal, ')
          ..write('isDefault: $isDefault, ')
          ..write('shinyImageUrl: $shinyImageUrl')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nationalNumber,
    name,
    imageUrl,
    updatedAt,
    speciesId,
    height,
    weight,
    baseStatTotal,
    isDefault,
    shinyImageUrl,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonRow &&
          other.id == this.id &&
          other.nationalNumber == this.nationalNumber &&
          other.name == this.name &&
          other.imageUrl == this.imageUrl &&
          other.updatedAt == this.updatedAt &&
          other.speciesId == this.speciesId &&
          other.height == this.height &&
          other.weight == this.weight &&
          other.baseStatTotal == this.baseStatTotal &&
          other.isDefault == this.isDefault &&
          other.shinyImageUrl == this.shinyImageUrl);
}

class PokemonRecordsCompanion extends UpdateCompanion<PokemonRow> {
  final Value<int> id;
  final Value<int> nationalNumber;
  final Value<String> name;
  final Value<String?> imageUrl;
  final Value<DateTime> updatedAt;
  final Value<int?> speciesId;
  final Value<int?> height;
  final Value<int?> weight;
  final Value<int?> baseStatTotal;
  final Value<bool> isDefault;
  final Value<String?> shinyImageUrl;
  const PokemonRecordsCompanion({
    this.id = const Value.absent(),
    this.nationalNumber = const Value.absent(),
    this.name = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.speciesId = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.baseStatTotal = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.shinyImageUrl = const Value.absent(),
  });
  PokemonRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int nationalNumber,
    required String name,
    this.imageUrl = const Value.absent(),
    required DateTime updatedAt,
    this.speciesId = const Value.absent(),
    this.height = const Value.absent(),
    this.weight = const Value.absent(),
    this.baseStatTotal = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.shinyImageUrl = const Value.absent(),
  }) : nationalNumber = Value(nationalNumber),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<PokemonRow> custom({
    Expression<int>? id,
    Expression<int>? nationalNumber,
    Expression<String>? name,
    Expression<String>? imageUrl,
    Expression<DateTime>? updatedAt,
    Expression<int>? speciesId,
    Expression<int>? height,
    Expression<int>? weight,
    Expression<int>? baseStatTotal,
    Expression<bool>? isDefault,
    Expression<String>? shinyImageUrl,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nationalNumber != null) 'national_number': nationalNumber,
      if (name != null) 'name': name,
      if (imageUrl != null) 'image_url': imageUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (speciesId != null) 'species_id': speciesId,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (baseStatTotal != null) 'base_stat_total': baseStatTotal,
      if (isDefault != null) 'is_default': isDefault,
      if (shinyImageUrl != null) 'shiny_image_url': shinyImageUrl,
    });
  }

  PokemonRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? nationalNumber,
    Value<String>? name,
    Value<String?>? imageUrl,
    Value<DateTime>? updatedAt,
    Value<int?>? speciesId,
    Value<int?>? height,
    Value<int?>? weight,
    Value<int?>? baseStatTotal,
    Value<bool>? isDefault,
    Value<String?>? shinyImageUrl,
  }) {
    return PokemonRecordsCompanion(
      id: id ?? this.id,
      nationalNumber: nationalNumber ?? this.nationalNumber,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      speciesId: speciesId ?? this.speciesId,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      baseStatTotal: baseStatTotal ?? this.baseStatTotal,
      isDefault: isDefault ?? this.isDefault,
      shinyImageUrl: shinyImageUrl ?? this.shinyImageUrl,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nationalNumber.present) {
      map['national_number'] = Variable<int>(nationalNumber.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (baseStatTotal.present) {
      map['base_stat_total'] = Variable<int>(baseStatTotal.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (shinyImageUrl.present) {
      map['shiny_image_url'] = Variable<String>(shinyImageUrl.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonRecordsCompanion(')
          ..write('id: $id, ')
          ..write('nationalNumber: $nationalNumber, ')
          ..write('name: $name, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('speciesId: $speciesId, ')
          ..write('height: $height, ')
          ..write('weight: $weight, ')
          ..write('baseStatTotal: $baseStatTotal, ')
          ..write('isDefault: $isDefault, ')
          ..write('shinyImageUrl: $shinyImageUrl')
          ..write(')'))
        .toString();
  }
}

class $PokemonTypesTable extends PokemonTypes
    with TableInfo<$PokemonTypesTable, TypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => ComparableExpr(id).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'type';
  @override
  VerificationContext validateIntegrity(
    Insertable<TypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TypeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $PokemonTypesTable createAlias(String alias) {
    return $PokemonTypesTable(attachedDatabase, alias);
  }
}

class TypeRow extends DataClass implements Insertable<TypeRow> {
  final int id;
  final String name;
  const TypeRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  PokemonTypesCompanion toCompanion(bool nullToAbsent) {
    return PokemonTypesCompanion(id: Value(id), name: Value(name));
  }

  factory TypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TypeRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  TypeRow copyWith({int? id, String? name}) =>
      TypeRow(id: id ?? this.id, name: name ?? this.name);
  TypeRow copyWithCompanion(PokemonTypesCompanion data) {
    return TypeRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TypeRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TypeRow && other.id == this.id && other.name == this.name);
}

class PokemonTypesCompanion extends UpdateCompanion<TypeRow> {
  final Value<int> id;
  final Value<String> name;
  const PokemonTypesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  PokemonTypesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<TypeRow> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  PokemonTypesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return PokemonTypesCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonTypesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $PokemonTypeLinksTable extends PokemonTypeLinks
    with TableInfo<$PokemonTypeLinksTable, PokemonTypeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonTypeLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<int> typeId = GeneratedColumn<int>(
    'type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES type (id)',
    ),
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    check: () => ComparableExpr(slot).isBetweenValues(1, 2),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pokemonId, typeId, slot];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_type';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonTypeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('type_id')) {
      context.handle(
        _typeIdMeta,
        typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_typeIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pokemonId, typeId};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {pokemonId, slot},
  ];
  @override
  PokemonTypeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonTypeRow(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      typeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type_id'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
    );
  }

  @override
  $PokemonTypeLinksTable createAlias(String alias) {
    return $PokemonTypeLinksTable(attachedDatabase, alias);
  }
}

class PokemonTypeRow extends DataClass implements Insertable<PokemonTypeRow> {
  final int pokemonId;
  final int typeId;
  final int slot;
  const PokemonTypeRow({
    required this.pokemonId,
    required this.typeId,
    required this.slot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['type_id'] = Variable<int>(typeId);
    map['slot'] = Variable<int>(slot);
    return map;
  }

  PokemonTypeLinksCompanion toCompanion(bool nullToAbsent) {
    return PokemonTypeLinksCompanion(
      pokemonId: Value(pokemonId),
      typeId: Value(typeId),
      slot: Value(slot),
    );
  }

  factory PokemonTypeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonTypeRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      typeId: serializer.fromJson<int>(json['typeId']),
      slot: serializer.fromJson<int>(json['slot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'typeId': serializer.toJson<int>(typeId),
      'slot': serializer.toJson<int>(slot),
    };
  }

  PokemonTypeRow copyWith({int? pokemonId, int? typeId, int? slot}) =>
      PokemonTypeRow(
        pokemonId: pokemonId ?? this.pokemonId,
        typeId: typeId ?? this.typeId,
        slot: slot ?? this.slot,
      );
  PokemonTypeRow copyWithCompanion(PokemonTypeLinksCompanion data) {
    return PokemonTypeRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      slot: data.slot.present ? data.slot.value : this.slot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonTypeRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('typeId: $typeId, ')
          ..write('slot: $slot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pokemonId, typeId, slot);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonTypeRow &&
          other.pokemonId == this.pokemonId &&
          other.typeId == this.typeId &&
          other.slot == this.slot);
}

class PokemonTypeLinksCompanion extends UpdateCompanion<PokemonTypeRow> {
  final Value<int> pokemonId;
  final Value<int> typeId;
  final Value<int> slot;
  final Value<int> rowid;
  const PokemonTypeLinksCompanion({
    this.pokemonId = const Value.absent(),
    this.typeId = const Value.absent(),
    this.slot = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonTypeLinksCompanion.insert({
    required int pokemonId,
    required int typeId,
    required int slot,
    this.rowid = const Value.absent(),
  }) : pokemonId = Value(pokemonId),
       typeId = Value(typeId),
       slot = Value(slot);
  static Insertable<PokemonTypeRow> custom({
    Expression<int>? pokemonId,
    Expression<int>? typeId,
    Expression<int>? slot,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (typeId != null) 'type_id': typeId,
      if (slot != null) 'slot': slot,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonTypeLinksCompanion copyWith({
    Value<int>? pokemonId,
    Value<int>? typeId,
    Value<int>? slot,
    Value<int>? rowid,
  }) {
    return PokemonTypeLinksCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      typeId: typeId ?? this.typeId,
      slot: slot ?? this.slot,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<int>(typeId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonTypeLinksCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('typeId: $typeId, ')
          ..write('slot: $slot, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FavoritesTable extends Favorites
    with TableInfo<$FavoritesTable, FavoriteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoritesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pokemonId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pokemonId};
  @override
  FavoriteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteRow(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FavoritesTable createAlias(String alias) {
    return $FavoritesTable(attachedDatabase, alias);
  }
}

class FavoriteRow extends DataClass implements Insertable<FavoriteRow> {
  final int pokemonId;
  final DateTime createdAt;
  const FavoriteRow({required this.pokemonId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FavoritesCompanion toCompanion(bool nullToAbsent) {
    return FavoritesCompanion(
      pokemonId: Value(pokemonId),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoriteRow copyWith({int? pokemonId, DateTime? createdAt}) => FavoriteRow(
    pokemonId: pokemonId ?? this.pokemonId,
    createdAt: createdAt ?? this.createdAt,
  );
  FavoriteRow copyWithCompanion(FavoritesCompanion data) {
    return FavoriteRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pokemonId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteRow &&
          other.pokemonId == this.pokemonId &&
          other.createdAt == this.createdAt);
}

class FavoritesCompanion extends UpdateCompanion<FavoriteRow> {
  final Value<int> pokemonId;
  final Value<DateTime> createdAt;
  const FavoritesCompanion({
    this.pokemonId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FavoritesCompanion.insert({
    this.pokemonId = const Value.absent(),
    required DateTime createdAt,
  }) : createdAt = Value(createdAt);
  static Insertable<FavoriteRow> custom({
    Expression<int>? pokemonId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FavoritesCompanion copyWith({
    Value<int>? pokemonId,
    Value<DateTime>? createdAt,
  }) {
    return FavoritesCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoritesCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SyncMetadataRecordsTable extends SyncMetadataRecords
    with TableInfo<$SyncMetadataRecordsTable, SyncMetadataRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetadataRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _resourceKeyMeta = const VerificationMeta(
    'resourceKey',
  );
  @override
  late final GeneratedColumn<String> resourceKey = GeneratedColumn<String>(
    'resource_key',
    aliasedName,
    false,
    check: () => ComparableExpr(resourceKey.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextOffsetMeta = const VerificationMeta(
    'nextOffset',
  );
  @override
  late final GeneratedColumn<int> nextOffset = GeneratedColumn<int>(
    'next_offset',
    aliasedName,
    false,
    check: () => ComparableExpr(nextOffset).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCountMeta = const VerificationMeta(
    'totalCount',
  );
  @override
  late final GeneratedColumn<int> totalCount = GeneratedColumn<int>(
    'total_count',
    aliasedName,
    true,
    check: () => ComparableExpr(totalCount).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(['idle', 'syncing', 'success', 'failed']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('idle'),
  );
  static const VerificationMeta _lastSuccessAtMeta = const VerificationMeta(
    'lastSuccessAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSuccessAt =
      GeneratedColumn<DateTime>(
        'last_success_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompleteMeta = const VerificationMeta(
    'isComplete',
  );
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
    'is_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    resourceKey,
    nextOffset,
    totalCount,
    status,
    lastSuccessAt,
    lastError,
    isComplete,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_metadata';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetadataRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('resource_key')) {
      context.handle(
        _resourceKeyMeta,
        resourceKey.isAcceptableOrUnknown(
          data['resource_key']!,
          _resourceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_resourceKeyMeta);
    }
    if (data.containsKey('next_offset')) {
      context.handle(
        _nextOffsetMeta,
        nextOffset.isAcceptableOrUnknown(data['next_offset']!, _nextOffsetMeta),
      );
    }
    if (data.containsKey('total_count')) {
      context.handle(
        _totalCountMeta,
        totalCount.isAcceptableOrUnknown(data['total_count']!, _totalCountMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_success_at')) {
      context.handle(
        _lastSuccessAtMeta,
        lastSuccessAt.isAcceptableOrUnknown(
          data['last_success_at']!,
          _lastSuccessAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('is_complete')) {
      context.handle(
        _isCompleteMeta,
        isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {resourceKey};
  @override
  SyncMetadataRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetadataRow(
      resourceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resource_key'],
      )!,
      nextOffset: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_offset'],
      )!,
      totalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_count'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastSuccessAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_success_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      isComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete'],
      )!,
    );
  }

  @override
  $SyncMetadataRecordsTable createAlias(String alias) {
    return $SyncMetadataRecordsTable(attachedDatabase, alias);
  }
}

class SyncMetadataRow extends DataClass implements Insertable<SyncMetadataRow> {
  final String resourceKey;
  final int nextOffset;
  final int? totalCount;
  final String status;
  final DateTime? lastSuccessAt;
  final String? lastError;
  final bool isComplete;
  const SyncMetadataRow({
    required this.resourceKey,
    required this.nextOffset,
    this.totalCount,
    required this.status,
    this.lastSuccessAt,
    this.lastError,
    required this.isComplete,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['resource_key'] = Variable<String>(resourceKey);
    map['next_offset'] = Variable<int>(nextOffset);
    if (!nullToAbsent || totalCount != null) {
      map['total_count'] = Variable<int>(totalCount);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastSuccessAt != null) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['is_complete'] = Variable<bool>(isComplete);
    return map;
  }

  SyncMetadataRecordsCompanion toCompanion(bool nullToAbsent) {
    return SyncMetadataRecordsCompanion(
      resourceKey: Value(resourceKey),
      nextOffset: Value(nextOffset),
      totalCount: totalCount == null && nullToAbsent
          ? const Value.absent()
          : Value(totalCount),
      status: Value(status),
      lastSuccessAt: lastSuccessAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSuccessAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      isComplete: Value(isComplete),
    );
  }

  factory SyncMetadataRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetadataRow(
      resourceKey: serializer.fromJson<String>(json['resourceKey']),
      nextOffset: serializer.fromJson<int>(json['nextOffset']),
      totalCount: serializer.fromJson<int?>(json['totalCount']),
      status: serializer.fromJson<String>(json['status']),
      lastSuccessAt: serializer.fromJson<DateTime?>(json['lastSuccessAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'resourceKey': serializer.toJson<String>(resourceKey),
      'nextOffset': serializer.toJson<int>(nextOffset),
      'totalCount': serializer.toJson<int?>(totalCount),
      'status': serializer.toJson<String>(status),
      'lastSuccessAt': serializer.toJson<DateTime?>(lastSuccessAt),
      'lastError': serializer.toJson<String?>(lastError),
      'isComplete': serializer.toJson<bool>(isComplete),
    };
  }

  SyncMetadataRow copyWith({
    String? resourceKey,
    int? nextOffset,
    Value<int?> totalCount = const Value.absent(),
    String? status,
    Value<DateTime?> lastSuccessAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    bool? isComplete,
  }) => SyncMetadataRow(
    resourceKey: resourceKey ?? this.resourceKey,
    nextOffset: nextOffset ?? this.nextOffset,
    totalCount: totalCount.present ? totalCount.value : this.totalCount,
    status: status ?? this.status,
    lastSuccessAt: lastSuccessAt.present
        ? lastSuccessAt.value
        : this.lastSuccessAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    isComplete: isComplete ?? this.isComplete,
  );
  SyncMetadataRow copyWithCompanion(SyncMetadataRecordsCompanion data) {
    return SyncMetadataRow(
      resourceKey: data.resourceKey.present
          ? data.resourceKey.value
          : this.resourceKey,
      nextOffset: data.nextOffset.present
          ? data.nextOffset.value
          : this.nextOffset,
      totalCount: data.totalCount.present
          ? data.totalCount.value
          : this.totalCount,
      status: data.status.present ? data.status.value : this.status,
      lastSuccessAt: data.lastSuccessAt.present
          ? data.lastSuccessAt.value
          : this.lastSuccessAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      isComplete: data.isComplete.present
          ? data.isComplete.value
          : this.isComplete,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataRow(')
          ..write('resourceKey: $resourceKey, ')
          ..write('nextOffset: $nextOffset, ')
          ..write('totalCount: $totalCount, ')
          ..write('status: $status, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastError: $lastError, ')
          ..write('isComplete: $isComplete')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    resourceKey,
    nextOffset,
    totalCount,
    status,
    lastSuccessAt,
    lastError,
    isComplete,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetadataRow &&
          other.resourceKey == this.resourceKey &&
          other.nextOffset == this.nextOffset &&
          other.totalCount == this.totalCount &&
          other.status == this.status &&
          other.lastSuccessAt == this.lastSuccessAt &&
          other.lastError == this.lastError &&
          other.isComplete == this.isComplete);
}

class SyncMetadataRecordsCompanion extends UpdateCompanion<SyncMetadataRow> {
  final Value<String> resourceKey;
  final Value<int> nextOffset;
  final Value<int?> totalCount;
  final Value<String> status;
  final Value<DateTime?> lastSuccessAt;
  final Value<String?> lastError;
  final Value<bool> isComplete;
  final Value<int> rowid;
  const SyncMetadataRecordsCompanion({
    this.resourceKey = const Value.absent(),
    this.nextOffset = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.status = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetadataRecordsCompanion.insert({
    required String resourceKey,
    this.nextOffset = const Value.absent(),
    this.totalCount = const Value.absent(),
    this.status = const Value.absent(),
    this.lastSuccessAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : resourceKey = Value(resourceKey);
  static Insertable<SyncMetadataRow> custom({
    Expression<String>? resourceKey,
    Expression<int>? nextOffset,
    Expression<int>? totalCount,
    Expression<String>? status,
    Expression<DateTime>? lastSuccessAt,
    Expression<String>? lastError,
    Expression<bool>? isComplete,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (resourceKey != null) 'resource_key': resourceKey,
      if (nextOffset != null) 'next_offset': nextOffset,
      if (totalCount != null) 'total_count': totalCount,
      if (status != null) 'status': status,
      if (lastSuccessAt != null) 'last_success_at': lastSuccessAt,
      if (lastError != null) 'last_error': lastError,
      if (isComplete != null) 'is_complete': isComplete,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetadataRecordsCompanion copyWith({
    Value<String>? resourceKey,
    Value<int>? nextOffset,
    Value<int?>? totalCount,
    Value<String>? status,
    Value<DateTime?>? lastSuccessAt,
    Value<String?>? lastError,
    Value<bool>? isComplete,
    Value<int>? rowid,
  }) {
    return SyncMetadataRecordsCompanion(
      resourceKey: resourceKey ?? this.resourceKey,
      nextOffset: nextOffset ?? this.nextOffset,
      totalCount: totalCount ?? this.totalCount,
      status: status ?? this.status,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastError: lastError ?? this.lastError,
      isComplete: isComplete ?? this.isComplete,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (resourceKey.present) {
      map['resource_key'] = Variable<String>(resourceKey.value);
    }
    if (nextOffset.present) {
      map['next_offset'] = Variable<int>(nextOffset.value);
    }
    if (totalCount.present) {
      map['total_count'] = Variable<int>(totalCount.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastSuccessAt.present) {
      map['last_success_at'] = Variable<DateTime>(lastSuccessAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetadataRecordsCompanion(')
          ..write('resourceKey: $resourceKey, ')
          ..write('nextOffset: $nextOffset, ')
          ..write('totalCount: $totalCount, ')
          ..write('status: $status, ')
          ..write('lastSuccessAt: $lastSuccessAt, ')
          ..write('lastError: $lastError, ')
          ..write('isComplete: $isComplete, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StatsTable extends Stats with TableInfo<$StatsTable, StatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => ComparableExpr(id).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stat';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $StatsTable createAlias(String alias) {
    return $StatsTable(attachedDatabase, alias);
  }
}

class StatRow extends DataClass implements Insertable<StatRow> {
  final int id;
  final String name;
  const StatRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  StatsCompanion toCompanion(bool nullToAbsent) {
    return StatsCompanion(id: Value(id), name: Value(name));
  }

  factory StatRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  StatRow copyWith({int? id, String? name}) =>
      StatRow(id: id ?? this.id, name: name ?? this.name);
  StatRow copyWithCompanion(StatsCompanion data) {
    return StatRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatRow && other.id == this.id && other.name == this.name);
}

class StatsCompanion extends UpdateCompanion<StatRow> {
  final Value<int> id;
  final Value<String> name;
  const StatsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  StatsCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<StatRow> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  StatsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return StatsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $PokemonStatsTable extends PokemonStats
    with TableInfo<$PokemonStatsTable, PokemonStatRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonStatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statIdMeta = const VerificationMeta('statId');
  @override
  late final GeneratedColumn<int> statId = GeneratedColumn<int>(
    'stat_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stat (id)',
    ),
  );
  static const VerificationMeta _baseValueMeta = const VerificationMeta(
    'baseValue',
  );
  @override
  late final GeneratedColumn<int> baseValue = GeneratedColumn<int>(
    'base_value',
    aliasedName,
    false,
    check: () => ComparableExpr(baseValue).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [pokemonId, statId, baseValue];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_stat';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonStatRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('stat_id')) {
      context.handle(
        _statIdMeta,
        statId.isAcceptableOrUnknown(data['stat_id']!, _statIdMeta),
      );
    } else if (isInserting) {
      context.missing(_statIdMeta);
    }
    if (data.containsKey('base_value')) {
      context.handle(
        _baseValueMeta,
        baseValue.isAcceptableOrUnknown(data['base_value']!, _baseValueMeta),
      );
    } else if (isInserting) {
      context.missing(_baseValueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pokemonId, statId};
  @override
  PokemonStatRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonStatRow(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      statId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stat_id'],
      )!,
      baseValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_value'],
      )!,
    );
  }

  @override
  $PokemonStatsTable createAlias(String alias) {
    return $PokemonStatsTable(attachedDatabase, alias);
  }
}

class PokemonStatRow extends DataClass implements Insertable<PokemonStatRow> {
  final int pokemonId;
  final int statId;
  final int baseValue;
  const PokemonStatRow({
    required this.pokemonId,
    required this.statId,
    required this.baseValue,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['stat_id'] = Variable<int>(statId);
    map['base_value'] = Variable<int>(baseValue);
    return map;
  }

  PokemonStatsCompanion toCompanion(bool nullToAbsent) {
    return PokemonStatsCompanion(
      pokemonId: Value(pokemonId),
      statId: Value(statId),
      baseValue: Value(baseValue),
    );
  }

  factory PokemonStatRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonStatRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      statId: serializer.fromJson<int>(json['statId']),
      baseValue: serializer.fromJson<int>(json['baseValue']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'statId': serializer.toJson<int>(statId),
      'baseValue': serializer.toJson<int>(baseValue),
    };
  }

  PokemonStatRow copyWith({int? pokemonId, int? statId, int? baseValue}) =>
      PokemonStatRow(
        pokemonId: pokemonId ?? this.pokemonId,
        statId: statId ?? this.statId,
        baseValue: baseValue ?? this.baseValue,
      );
  PokemonStatRow copyWithCompanion(PokemonStatsCompanion data) {
    return PokemonStatRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      statId: data.statId.present ? data.statId.value : this.statId,
      baseValue: data.baseValue.present ? data.baseValue.value : this.baseValue,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonStatRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('statId: $statId, ')
          ..write('baseValue: $baseValue')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pokemonId, statId, baseValue);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonStatRow &&
          other.pokemonId == this.pokemonId &&
          other.statId == this.statId &&
          other.baseValue == this.baseValue);
}

class PokemonStatsCompanion extends UpdateCompanion<PokemonStatRow> {
  final Value<int> pokemonId;
  final Value<int> statId;
  final Value<int> baseValue;
  final Value<int> rowid;
  const PokemonStatsCompanion({
    this.pokemonId = const Value.absent(),
    this.statId = const Value.absent(),
    this.baseValue = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonStatsCompanion.insert({
    required int pokemonId,
    required int statId,
    required int baseValue,
    this.rowid = const Value.absent(),
  }) : pokemonId = Value(pokemonId),
       statId = Value(statId),
       baseValue = Value(baseValue);
  static Insertable<PokemonStatRow> custom({
    Expression<int>? pokemonId,
    Expression<int>? statId,
    Expression<int>? baseValue,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (statId != null) 'stat_id': statId,
      if (baseValue != null) 'base_value': baseValue,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonStatsCompanion copyWith({
    Value<int>? pokemonId,
    Value<int>? statId,
    Value<int>? baseValue,
    Value<int>? rowid,
  }) {
    return PokemonStatsCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      statId: statId ?? this.statId,
      baseValue: baseValue ?? this.baseValue,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (statId.present) {
      map['stat_id'] = Variable<int>(statId.value);
    }
    if (baseValue.present) {
      map['base_value'] = Variable<int>(baseValue.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonStatsCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('statId: $statId, ')
          ..write('baseValue: $baseValue, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AbilitiesTable extends Abilities
    with TableInfo<$AbilitiesTable, AbilityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AbilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => ComparableExpr(id).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectSummaryMeta = const VerificationMeta(
    'effectSummary',
  );
  @override
  late final GeneratedColumn<String> effectSummary = GeneratedColumn<String>(
    'effect_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, effectSummary];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ability';
  @override
  VerificationContext validateIntegrity(
    Insertable<AbilityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('effect_summary')) {
      context.handle(
        _effectSummaryMeta,
        effectSummary.isAcceptableOrUnknown(
          data['effect_summary']!,
          _effectSummaryMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AbilityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AbilityRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      effectSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effect_summary'],
      ),
    );
  }

  @override
  $AbilitiesTable createAlias(String alias) {
    return $AbilitiesTable(attachedDatabase, alias);
  }
}

class AbilityRow extends DataClass implements Insertable<AbilityRow> {
  final int id;
  final String name;
  final String? effectSummary;
  const AbilityRow({required this.id, required this.name, this.effectSummary});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || effectSummary != null) {
      map['effect_summary'] = Variable<String>(effectSummary);
    }
    return map;
  }

  AbilitiesCompanion toCompanion(bool nullToAbsent) {
    return AbilitiesCompanion(
      id: Value(id),
      name: Value(name),
      effectSummary: effectSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(effectSummary),
    );
  }

  factory AbilityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AbilityRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      effectSummary: serializer.fromJson<String?>(json['effectSummary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'effectSummary': serializer.toJson<String?>(effectSummary),
    };
  }

  AbilityRow copyWith({
    int? id,
    String? name,
    Value<String?> effectSummary = const Value.absent(),
  }) => AbilityRow(
    id: id ?? this.id,
    name: name ?? this.name,
    effectSummary: effectSummary.present
        ? effectSummary.value
        : this.effectSummary,
  );
  AbilityRow copyWithCompanion(AbilitiesCompanion data) {
    return AbilityRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      effectSummary: data.effectSummary.present
          ? data.effectSummary.value
          : this.effectSummary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AbilityRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('effectSummary: $effectSummary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, effectSummary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AbilityRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.effectSummary == this.effectSummary);
}

class AbilitiesCompanion extends UpdateCompanion<AbilityRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> effectSummary;
  const AbilitiesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.effectSummary = const Value.absent(),
  });
  AbilitiesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.effectSummary = const Value.absent(),
  }) : name = Value(name);
  static Insertable<AbilityRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? effectSummary,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (effectSummary != null) 'effect_summary': effectSummary,
    });
  }

  AbilitiesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? effectSummary,
  }) {
    return AbilitiesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      effectSummary: effectSummary ?? this.effectSummary,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (effectSummary.present) {
      map['effect_summary'] = Variable<String>(effectSummary.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AbilitiesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('effectSummary: $effectSummary')
          ..write(')'))
        .toString();
  }
}

class $PokemonAbilitiesTable extends PokemonAbilities
    with TableInfo<$PokemonAbilitiesTable, PokemonAbilityRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonAbilitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _abilityIdMeta = const VerificationMeta(
    'abilityId',
  );
  @override
  late final GeneratedColumn<int> abilityId = GeneratedColumn<int>(
    'ability_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES ability (id)',
    ),
  );
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<int> slot = GeneratedColumn<int>(
    'slot',
    aliasedName,
    false,
    check: () => ComparableExpr(slot).isBetweenValues(1, 3),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [pokemonId, abilityId, slot, isHidden];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_ability';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonAbilityRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('ability_id')) {
      context.handle(
        _abilityIdMeta,
        abilityId.isAcceptableOrUnknown(data['ability_id']!, _abilityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_abilityIdMeta);
    }
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pokemonId, abilityId};
  @override
  PokemonAbilityRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonAbilityRow(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      abilityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ability_id'],
      )!,
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
    );
  }

  @override
  $PokemonAbilitiesTable createAlias(String alias) {
    return $PokemonAbilitiesTable(attachedDatabase, alias);
  }
}

class PokemonAbilityRow extends DataClass
    implements Insertable<PokemonAbilityRow> {
  final int pokemonId;
  final int abilityId;
  final int slot;
  final bool isHidden;
  const PokemonAbilityRow({
    required this.pokemonId,
    required this.abilityId,
    required this.slot,
    required this.isHidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['ability_id'] = Variable<int>(abilityId);
    map['slot'] = Variable<int>(slot);
    map['is_hidden'] = Variable<bool>(isHidden);
    return map;
  }

  PokemonAbilitiesCompanion toCompanion(bool nullToAbsent) {
    return PokemonAbilitiesCompanion(
      pokemonId: Value(pokemonId),
      abilityId: Value(abilityId),
      slot: Value(slot),
      isHidden: Value(isHidden),
    );
  }

  factory PokemonAbilityRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonAbilityRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      abilityId: serializer.fromJson<int>(json['abilityId']),
      slot: serializer.fromJson<int>(json['slot']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'abilityId': serializer.toJson<int>(abilityId),
      'slot': serializer.toJson<int>(slot),
      'isHidden': serializer.toJson<bool>(isHidden),
    };
  }

  PokemonAbilityRow copyWith({
    int? pokemonId,
    int? abilityId,
    int? slot,
    bool? isHidden,
  }) => PokemonAbilityRow(
    pokemonId: pokemonId ?? this.pokemonId,
    abilityId: abilityId ?? this.abilityId,
    slot: slot ?? this.slot,
    isHidden: isHidden ?? this.isHidden,
  );
  PokemonAbilityRow copyWithCompanion(PokemonAbilitiesCompanion data) {
    return PokemonAbilityRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      abilityId: data.abilityId.present ? data.abilityId.value : this.abilityId,
      slot: data.slot.present ? data.slot.value : this.slot,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonAbilityRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('abilityId: $abilityId, ')
          ..write('slot: $slot, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pokemonId, abilityId, slot, isHidden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonAbilityRow &&
          other.pokemonId == this.pokemonId &&
          other.abilityId == this.abilityId &&
          other.slot == this.slot &&
          other.isHidden == this.isHidden);
}

class PokemonAbilitiesCompanion extends UpdateCompanion<PokemonAbilityRow> {
  final Value<int> pokemonId;
  final Value<int> abilityId;
  final Value<int> slot;
  final Value<bool> isHidden;
  final Value<int> rowid;
  const PokemonAbilitiesCompanion({
    this.pokemonId = const Value.absent(),
    this.abilityId = const Value.absent(),
    this.slot = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonAbilitiesCompanion.insert({
    required int pokemonId,
    required int abilityId,
    required int slot,
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pokemonId = Value(pokemonId),
       abilityId = Value(abilityId),
       slot = Value(slot);
  static Insertable<PokemonAbilityRow> custom({
    Expression<int>? pokemonId,
    Expression<int>? abilityId,
    Expression<int>? slot,
    Expression<bool>? isHidden,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (abilityId != null) 'ability_id': abilityId,
      if (slot != null) 'slot': slot,
      if (isHidden != null) 'is_hidden': isHidden,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonAbilitiesCompanion copyWith({
    Value<int>? pokemonId,
    Value<int>? abilityId,
    Value<int>? slot,
    Value<bool>? isHidden,
    Value<int>? rowid,
  }) {
    return PokemonAbilitiesCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      abilityId: abilityId ?? this.abilityId,
      slot: slot ?? this.slot,
      isHidden: isHidden ?? this.isHidden,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (abilityId.present) {
      map['ability_id'] = Variable<int>(abilityId.value);
    }
    if (slot.present) {
      map['slot'] = Variable<int>(slot.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonAbilitiesCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('abilityId: $abilityId, ')
          ..write('slot: $slot, ')
          ..write('isHidden: $isHidden, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MovesTable extends Moves with TableInfo<$MovesTable, MoveRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MovesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => ComparableExpr(id).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeIdMeta = const VerificationMeta('typeId');
  @override
  late final GeneratedColumn<int> typeId = GeneratedColumn<int>(
    'type_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES type (id)',
    ),
  );
  static const VerificationMeta _powerMeta = const VerificationMeta('power');
  @override
  late final GeneratedColumn<int> power = GeneratedColumn<int>(
    'power',
    aliasedName,
    true,
    check: () => ComparableExpr(power).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<int> accuracy = GeneratedColumn<int>(
    'accuracy',
    aliasedName,
    true,
    check: () => ComparableExpr(accuracy).isBetweenValues(0, 100),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, typeId, power, accuracy];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'move';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoveRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type_id')) {
      context.handle(
        _typeIdMeta,
        typeId.isAcceptableOrUnknown(data['type_id']!, _typeIdMeta),
      );
    }
    if (data.containsKey('power')) {
      context.handle(
        _powerMeta,
        power.isAcceptableOrUnknown(data['power']!, _powerMeta),
      );
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoveRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoveRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      typeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type_id'],
      ),
      power: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}power'],
      ),
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accuracy'],
      ),
    );
  }

  @override
  $MovesTable createAlias(String alias) {
    return $MovesTable(attachedDatabase, alias);
  }
}

class MoveRow extends DataClass implements Insertable<MoveRow> {
  final int id;
  final String name;
  final int? typeId;
  final int? power;
  final int? accuracy;
  const MoveRow({
    required this.id,
    required this.name,
    this.typeId,
    this.power,
    this.accuracy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || typeId != null) {
      map['type_id'] = Variable<int>(typeId);
    }
    if (!nullToAbsent || power != null) {
      map['power'] = Variable<int>(power);
    }
    if (!nullToAbsent || accuracy != null) {
      map['accuracy'] = Variable<int>(accuracy);
    }
    return map;
  }

  MovesCompanion toCompanion(bool nullToAbsent) {
    return MovesCompanion(
      id: Value(id),
      name: Value(name),
      typeId: typeId == null && nullToAbsent
          ? const Value.absent()
          : Value(typeId),
      power: power == null && nullToAbsent
          ? const Value.absent()
          : Value(power),
      accuracy: accuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(accuracy),
    );
  }

  factory MoveRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoveRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      typeId: serializer.fromJson<int?>(json['typeId']),
      power: serializer.fromJson<int?>(json['power']),
      accuracy: serializer.fromJson<int?>(json['accuracy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'typeId': serializer.toJson<int?>(typeId),
      'power': serializer.toJson<int?>(power),
      'accuracy': serializer.toJson<int?>(accuracy),
    };
  }

  MoveRow copyWith({
    int? id,
    String? name,
    Value<int?> typeId = const Value.absent(),
    Value<int?> power = const Value.absent(),
    Value<int?> accuracy = const Value.absent(),
  }) => MoveRow(
    id: id ?? this.id,
    name: name ?? this.name,
    typeId: typeId.present ? typeId.value : this.typeId,
    power: power.present ? power.value : this.power,
    accuracy: accuracy.present ? accuracy.value : this.accuracy,
  );
  MoveRow copyWithCompanion(MovesCompanion data) {
    return MoveRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      typeId: data.typeId.present ? data.typeId.value : this.typeId,
      power: data.power.present ? data.power.value : this.power,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoveRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('typeId: $typeId, ')
          ..write('power: $power, ')
          ..write('accuracy: $accuracy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, typeId, power, accuracy);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoveRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.typeId == this.typeId &&
          other.power == this.power &&
          other.accuracy == this.accuracy);
}

class MovesCompanion extends UpdateCompanion<MoveRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> typeId;
  final Value<int?> power;
  final Value<int?> accuracy;
  const MovesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.typeId = const Value.absent(),
    this.power = const Value.absent(),
    this.accuracy = const Value.absent(),
  });
  MovesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.typeId = const Value.absent(),
    this.power = const Value.absent(),
    this.accuracy = const Value.absent(),
  }) : name = Value(name);
  static Insertable<MoveRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? typeId,
    Expression<int>? power,
    Expression<int>? accuracy,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (typeId != null) 'type_id': typeId,
      if (power != null) 'power': power,
      if (accuracy != null) 'accuracy': accuracy,
    });
  }

  MovesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? typeId,
    Value<int?>? power,
    Value<int?>? accuracy,
  }) {
    return MovesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      typeId: typeId ?? this.typeId,
      power: power ?? this.power,
      accuracy: accuracy ?? this.accuracy,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (typeId.present) {
      map['type_id'] = Variable<int>(typeId.value);
    }
    if (power.present) {
      map['power'] = Variable<int>(power.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<int>(accuracy.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MovesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('typeId: $typeId, ')
          ..write('power: $power, ')
          ..write('accuracy: $accuracy')
          ..write(')'))
        .toString();
  }
}

class $VersionGroupsTable extends VersionGroups
    with TableInfo<$VersionGroupsTable, VersionGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VersionGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => ComparableExpr(id).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    check: () => ComparableExpr(sortOrder).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'version_group';
  @override
  VerificationContext validateIntegrity(
    Insertable<VersionGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VersionGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VersionGroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $VersionGroupsTable createAlias(String alias) {
    return $VersionGroupsTable(attachedDatabase, alias);
  }
}

class VersionGroupRow extends DataClass implements Insertable<VersionGroupRow> {
  final int id;
  final String name;
  final int sortOrder;
  const VersionGroupRow({
    required this.id,
    required this.name,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  VersionGroupsCompanion toCompanion(bool nullToAbsent) {
    return VersionGroupsCompanion(
      id: Value(id),
      name: Value(name),
      sortOrder: Value(sortOrder),
    );
  }

  factory VersionGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VersionGroupRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  VersionGroupRow copyWith({int? id, String? name, int? sortOrder}) =>
      VersionGroupRow(
        id: id ?? this.id,
        name: name ?? this.name,
        sortOrder: sortOrder ?? this.sortOrder,
      );
  VersionGroupRow copyWithCompanion(VersionGroupsCompanion data) {
    return VersionGroupRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VersionGroupRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VersionGroupRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder);
}

class VersionGroupsCompanion extends UpdateCompanion<VersionGroupRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> sortOrder;
  const VersionGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  VersionGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int sortOrder,
  }) : name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<VersionGroupRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  VersionGroupsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? sortOrder,
  }) {
    return VersionGroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VersionGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $PokemonMovesTable extends PokemonMoves
    with TableInfo<$PokemonMovesTable, PokemonMoveRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PokemonMovesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _moveIdMeta = const VerificationMeta('moveId');
  @override
  late final GeneratedColumn<int> moveId = GeneratedColumn<int>(
    'move_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES move (id)',
    ),
  );
  static const VerificationMeta _versionGroupIdMeta = const VerificationMeta(
    'versionGroupId',
  );
  @override
  late final GeneratedColumn<int> versionGroupId = GeneratedColumn<int>(
    'version_group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES version_group (id)',
    ),
  );
  static const VerificationMeta _learnMethodMeta = const VerificationMeta(
    'learnMethod',
  );
  @override
  late final GeneratedColumn<String> learnMethod = GeneratedColumn<String>(
    'learn_method',
    aliasedName,
    false,
    check: () => ComparableExpr(learnMethod.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelLearnedMeta = const VerificationMeta(
    'levelLearned',
  );
  @override
  late final GeneratedColumn<int> levelLearned = GeneratedColumn<int>(
    'level_learned',
    aliasedName,
    false,
    check: () => ComparableExpr(levelLearned).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    pokemonId,
    moveId,
    versionGroupId,
    learnMethod,
    levelLearned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pokemon_move';
  @override
  VerificationContext validateIntegrity(
    Insertable<PokemonMoveRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('move_id')) {
      context.handle(
        _moveIdMeta,
        moveId.isAcceptableOrUnknown(data['move_id']!, _moveIdMeta),
      );
    } else if (isInserting) {
      context.missing(_moveIdMeta);
    }
    if (data.containsKey('version_group_id')) {
      context.handle(
        _versionGroupIdMeta,
        versionGroupId.isAcceptableOrUnknown(
          data['version_group_id']!,
          _versionGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_versionGroupIdMeta);
    }
    if (data.containsKey('learn_method')) {
      context.handle(
        _learnMethodMeta,
        learnMethod.isAcceptableOrUnknown(
          data['learn_method']!,
          _learnMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_learnMethodMeta);
    }
    if (data.containsKey('level_learned')) {
      context.handle(
        _levelLearnedMeta,
        levelLearned.isAcceptableOrUnknown(
          data['level_learned']!,
          _levelLearnedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {
    pokemonId,
    moveId,
    versionGroupId,
    learnMethod,
    levelLearned,
  };
  @override
  PokemonMoveRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PokemonMoveRow(
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      moveId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}move_id'],
      )!,
      versionGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_group_id'],
      )!,
      learnMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}learn_method'],
      )!,
      levelLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_learned'],
      )!,
    );
  }

  @override
  $PokemonMovesTable createAlias(String alias) {
    return $PokemonMovesTable(attachedDatabase, alias);
  }
}

class PokemonMoveRow extends DataClass implements Insertable<PokemonMoveRow> {
  final int pokemonId;
  final int moveId;
  final int versionGroupId;
  final String learnMethod;
  final int levelLearned;
  const PokemonMoveRow({
    required this.pokemonId,
    required this.moveId,
    required this.versionGroupId,
    required this.learnMethod,
    required this.levelLearned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['move_id'] = Variable<int>(moveId);
    map['version_group_id'] = Variable<int>(versionGroupId);
    map['learn_method'] = Variable<String>(learnMethod);
    map['level_learned'] = Variable<int>(levelLearned);
    return map;
  }

  PokemonMovesCompanion toCompanion(bool nullToAbsent) {
    return PokemonMovesCompanion(
      pokemonId: Value(pokemonId),
      moveId: Value(moveId),
      versionGroupId: Value(versionGroupId),
      learnMethod: Value(learnMethod),
      levelLearned: Value(levelLearned),
    );
  }

  factory PokemonMoveRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PokemonMoveRow(
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      moveId: serializer.fromJson<int>(json['moveId']),
      versionGroupId: serializer.fromJson<int>(json['versionGroupId']),
      learnMethod: serializer.fromJson<String>(json['learnMethod']),
      levelLearned: serializer.fromJson<int>(json['levelLearned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pokemonId': serializer.toJson<int>(pokemonId),
      'moveId': serializer.toJson<int>(moveId),
      'versionGroupId': serializer.toJson<int>(versionGroupId),
      'learnMethod': serializer.toJson<String>(learnMethod),
      'levelLearned': serializer.toJson<int>(levelLearned),
    };
  }

  PokemonMoveRow copyWith({
    int? pokemonId,
    int? moveId,
    int? versionGroupId,
    String? learnMethod,
    int? levelLearned,
  }) => PokemonMoveRow(
    pokemonId: pokemonId ?? this.pokemonId,
    moveId: moveId ?? this.moveId,
    versionGroupId: versionGroupId ?? this.versionGroupId,
    learnMethod: learnMethod ?? this.learnMethod,
    levelLearned: levelLearned ?? this.levelLearned,
  );
  PokemonMoveRow copyWithCompanion(PokemonMovesCompanion data) {
    return PokemonMoveRow(
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      moveId: data.moveId.present ? data.moveId.value : this.moveId,
      versionGroupId: data.versionGroupId.present
          ? data.versionGroupId.value
          : this.versionGroupId,
      learnMethod: data.learnMethod.present
          ? data.learnMethod.value
          : this.learnMethod,
      levelLearned: data.levelLearned.present
          ? data.levelLearned.value
          : this.levelLearned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PokemonMoveRow(')
          ..write('pokemonId: $pokemonId, ')
          ..write('moveId: $moveId, ')
          ..write('versionGroupId: $versionGroupId, ')
          ..write('learnMethod: $learnMethod, ')
          ..write('levelLearned: $levelLearned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(pokemonId, moveId, versionGroupId, learnMethod, levelLearned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PokemonMoveRow &&
          other.pokemonId == this.pokemonId &&
          other.moveId == this.moveId &&
          other.versionGroupId == this.versionGroupId &&
          other.learnMethod == this.learnMethod &&
          other.levelLearned == this.levelLearned);
}

class PokemonMovesCompanion extends UpdateCompanion<PokemonMoveRow> {
  final Value<int> pokemonId;
  final Value<int> moveId;
  final Value<int> versionGroupId;
  final Value<String> learnMethod;
  final Value<int> levelLearned;
  final Value<int> rowid;
  const PokemonMovesCompanion({
    this.pokemonId = const Value.absent(),
    this.moveId = const Value.absent(),
    this.versionGroupId = const Value.absent(),
    this.learnMethod = const Value.absent(),
    this.levelLearned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PokemonMovesCompanion.insert({
    required int pokemonId,
    required int moveId,
    required int versionGroupId,
    required String learnMethod,
    this.levelLearned = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : pokemonId = Value(pokemonId),
       moveId = Value(moveId),
       versionGroupId = Value(versionGroupId),
       learnMethod = Value(learnMethod);
  static Insertable<PokemonMoveRow> custom({
    Expression<int>? pokemonId,
    Expression<int>? moveId,
    Expression<int>? versionGroupId,
    Expression<String>? learnMethod,
    Expression<int>? levelLearned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (moveId != null) 'move_id': moveId,
      if (versionGroupId != null) 'version_group_id': versionGroupId,
      if (learnMethod != null) 'learn_method': learnMethod,
      if (levelLearned != null) 'level_learned': levelLearned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PokemonMovesCompanion copyWith({
    Value<int>? pokemonId,
    Value<int>? moveId,
    Value<int>? versionGroupId,
    Value<String>? learnMethod,
    Value<int>? levelLearned,
    Value<int>? rowid,
  }) {
    return PokemonMovesCompanion(
      pokemonId: pokemonId ?? this.pokemonId,
      moveId: moveId ?? this.moveId,
      versionGroupId: versionGroupId ?? this.versionGroupId,
      learnMethod: learnMethod ?? this.learnMethod,
      levelLearned: levelLearned ?? this.levelLearned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (moveId.present) {
      map['move_id'] = Variable<int>(moveId.value);
    }
    if (versionGroupId.present) {
      map['version_group_id'] = Variable<int>(versionGroupId.value);
    }
    if (learnMethod.present) {
      map['learn_method'] = Variable<String>(learnMethod.value);
    }
    if (levelLearned.present) {
      map['level_learned'] = Variable<int>(levelLearned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PokemonMovesCompanion(')
          ..write('pokemonId: $pokemonId, ')
          ..write('moveId: $moveId, ')
          ..write('versionGroupId: $versionGroupId, ')
          ..write('learnMethod: $learnMethod, ')
          ..write('levelLearned: $levelLearned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EggGroupsTable extends EggGroups
    with TableInfo<$EggGroupsTable, EggGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EggGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    check: () => ComparableExpr(id).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    check: () => ComparableExpr(name.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'egg_group';
  @override
  VerificationContext validateIntegrity(
    Insertable<EggGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EggGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EggGroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $EggGroupsTable createAlias(String alias) {
    return $EggGroupsTable(attachedDatabase, alias);
  }
}

class EggGroupRow extends DataClass implements Insertable<EggGroupRow> {
  final int id;
  final String name;
  const EggGroupRow({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  EggGroupsCompanion toCompanion(bool nullToAbsent) {
    return EggGroupsCompanion(id: Value(id), name: Value(name));
  }

  factory EggGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EggGroupRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  EggGroupRow copyWith({int? id, String? name}) =>
      EggGroupRow(id: id ?? this.id, name: name ?? this.name);
  EggGroupRow copyWithCompanion(EggGroupsCompanion data) {
    return EggGroupRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EggGroupRow(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EggGroupRow && other.id == this.id && other.name == this.name);
}

class EggGroupsCompanion extends UpdateCompanion<EggGroupRow> {
  final Value<int> id;
  final Value<String> name;
  const EggGroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  EggGroupsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<EggGroupRow> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  EggGroupsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return EggGroupsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EggGroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $SpeciesEggGroupsTable extends SpeciesEggGroups
    with TableInfo<$SpeciesEggGroupsTable, SpeciesEggGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SpeciesEggGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _speciesIdMeta = const VerificationMeta(
    'speciesId',
  );
  @override
  late final GeneratedColumn<int> speciesId = GeneratedColumn<int>(
    'species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES species (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _eggGroupIdMeta = const VerificationMeta(
    'eggGroupId',
  );
  @override
  late final GeneratedColumn<int> eggGroupId = GeneratedColumn<int>(
    'egg_group_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES egg_group (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [speciesId, eggGroupId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'species_egg_group';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesEggGroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('species_id')) {
      context.handle(
        _speciesIdMeta,
        speciesId.isAcceptableOrUnknown(data['species_id']!, _speciesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesIdMeta);
    }
    if (data.containsKey('egg_group_id')) {
      context.handle(
        _eggGroupIdMeta,
        eggGroupId.isAcceptableOrUnknown(
          data['egg_group_id']!,
          _eggGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eggGroupIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {speciesId, eggGroupId};
  @override
  SpeciesEggGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesEggGroupRow(
      speciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}species_id'],
      )!,
      eggGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}egg_group_id'],
      )!,
    );
  }

  @override
  $SpeciesEggGroupsTable createAlias(String alias) {
    return $SpeciesEggGroupsTable(attachedDatabase, alias);
  }
}

class SpeciesEggGroupRow extends DataClass
    implements Insertable<SpeciesEggGroupRow> {
  final int speciesId;
  final int eggGroupId;
  const SpeciesEggGroupRow({required this.speciesId, required this.eggGroupId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['species_id'] = Variable<int>(speciesId);
    map['egg_group_id'] = Variable<int>(eggGroupId);
    return map;
  }

  SpeciesEggGroupsCompanion toCompanion(bool nullToAbsent) {
    return SpeciesEggGroupsCompanion(
      speciesId: Value(speciesId),
      eggGroupId: Value(eggGroupId),
    );
  }

  factory SpeciesEggGroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesEggGroupRow(
      speciesId: serializer.fromJson<int>(json['speciesId']),
      eggGroupId: serializer.fromJson<int>(json['eggGroupId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'speciesId': serializer.toJson<int>(speciesId),
      'eggGroupId': serializer.toJson<int>(eggGroupId),
    };
  }

  SpeciesEggGroupRow copyWith({int? speciesId, int? eggGroupId}) =>
      SpeciesEggGroupRow(
        speciesId: speciesId ?? this.speciesId,
        eggGroupId: eggGroupId ?? this.eggGroupId,
      );
  SpeciesEggGroupRow copyWithCompanion(SpeciesEggGroupsCompanion data) {
    return SpeciesEggGroupRow(
      speciesId: data.speciesId.present ? data.speciesId.value : this.speciesId,
      eggGroupId: data.eggGroupId.present
          ? data.eggGroupId.value
          : this.eggGroupId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesEggGroupRow(')
          ..write('speciesId: $speciesId, ')
          ..write('eggGroupId: $eggGroupId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(speciesId, eggGroupId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesEggGroupRow &&
          other.speciesId == this.speciesId &&
          other.eggGroupId == this.eggGroupId);
}

class SpeciesEggGroupsCompanion extends UpdateCompanion<SpeciesEggGroupRow> {
  final Value<int> speciesId;
  final Value<int> eggGroupId;
  final Value<int> rowid;
  const SpeciesEggGroupsCompanion({
    this.speciesId = const Value.absent(),
    this.eggGroupId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SpeciesEggGroupsCompanion.insert({
    required int speciesId,
    required int eggGroupId,
    this.rowid = const Value.absent(),
  }) : speciesId = Value(speciesId),
       eggGroupId = Value(eggGroupId);
  static Insertable<SpeciesEggGroupRow> custom({
    Expression<int>? speciesId,
    Expression<int>? eggGroupId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (speciesId != null) 'species_id': speciesId,
      if (eggGroupId != null) 'egg_group_id': eggGroupId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SpeciesEggGroupsCompanion copyWith({
    Value<int>? speciesId,
    Value<int>? eggGroupId,
    Value<int>? rowid,
  }) {
    return SpeciesEggGroupsCompanion(
      speciesId: speciesId ?? this.speciesId,
      eggGroupId: eggGroupId ?? this.eggGroupId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (speciesId.present) {
      map['species_id'] = Variable<int>(speciesId.value);
    }
    if (eggGroupId.present) {
      map['egg_group_id'] = Variable<int>(eggGroupId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesEggGroupsCompanion(')
          ..write('speciesId: $speciesId, ')
          ..write('eggGroupId: $eggGroupId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EvolutionsTable extends Evolutions
    with TableInfo<$EvolutionsTable, EvolutionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EvolutionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _fromSpeciesIdMeta = const VerificationMeta(
    'fromSpeciesId',
  );
  @override
  late final GeneratedColumn<int> fromSpeciesId = GeneratedColumn<int>(
    'from_species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES species (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _toSpeciesIdMeta = const VerificationMeta(
    'toSpeciesId',
  );
  @override
  late final GeneratedColumn<int> toSpeciesId = GeneratedColumn<int>(
    'to_species_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES species (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _triggerMeta = const VerificationMeta(
    'trigger',
  );
  @override
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    check: () => ComparableExpr(trigger.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minLevelMeta = const VerificationMeta(
    'minLevel',
  );
  @override
  late final GeneratedColumn<int> minLevel = GeneratedColumn<int>(
    'min_level',
    aliasedName,
    true,
    check: () => ComparableExpr(minLevel).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemNameMeta = const VerificationMeta(
    'itemName',
  );
  @override
  late final GeneratedColumn<String> itemName = GeneratedColumn<String>(
    'item_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _minHappinessMeta = const VerificationMeta(
    'minHappiness',
  );
  @override
  late final GeneratedColumn<int> minHappiness = GeneratedColumn<int>(
    'min_happiness',
    aliasedName,
    true,
    check: () => ComparableExpr(minHappiness).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeOfDayMeta = const VerificationMeta(
    'timeOfDay',
  );
  @override
  late final GeneratedColumn<String> timeOfDay = GeneratedColumn<String>(
    'time_of_day',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    fromSpeciesId,
    toSpeciesId,
    trigger,
    minLevel,
    itemName,
    minHappiness,
    timeOfDay,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'evolution';
  @override
  VerificationContext validateIntegrity(
    Insertable<EvolutionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('from_species_id')) {
      context.handle(
        _fromSpeciesIdMeta,
        fromSpeciesId.isAcceptableOrUnknown(
          data['from_species_id']!,
          _fromSpeciesIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromSpeciesIdMeta);
    }
    if (data.containsKey('to_species_id')) {
      context.handle(
        _toSpeciesIdMeta,
        toSpeciesId.isAcceptableOrUnknown(
          data['to_species_id']!,
          _toSpeciesIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_toSpeciesIdMeta);
    }
    if (data.containsKey('trigger')) {
      context.handle(
        _triggerMeta,
        trigger.isAcceptableOrUnknown(data['trigger']!, _triggerMeta),
      );
    } else if (isInserting) {
      context.missing(_triggerMeta);
    }
    if (data.containsKey('min_level')) {
      context.handle(
        _minLevelMeta,
        minLevel.isAcceptableOrUnknown(data['min_level']!, _minLevelMeta),
      );
    }
    if (data.containsKey('item_name')) {
      context.handle(
        _itemNameMeta,
        itemName.isAcceptableOrUnknown(data['item_name']!, _itemNameMeta),
      );
    }
    if (data.containsKey('min_happiness')) {
      context.handle(
        _minHappinessMeta,
        minHappiness.isAcceptableOrUnknown(
          data['min_happiness']!,
          _minHappinessMeta,
        ),
      );
    }
    if (data.containsKey('time_of_day')) {
      context.handle(
        _timeOfDayMeta,
        timeOfDay.isAcceptableOrUnknown(data['time_of_day']!, _timeOfDayMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {fromSpeciesId, toSpeciesId};
  @override
  EvolutionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EvolutionRow(
      fromSpeciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_species_id'],
      )!,
      toSpeciesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_species_id'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      minLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_level'],
      ),
      itemName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_name'],
      ),
      minHappiness: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_happiness'],
      ),
      timeOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_of_day'],
      ),
    );
  }

  @override
  $EvolutionsTable createAlias(String alias) {
    return $EvolutionsTable(attachedDatabase, alias);
  }
}

class EvolutionRow extends DataClass implements Insertable<EvolutionRow> {
  final int fromSpeciesId;
  final int toSpeciesId;
  final String trigger;
  final int? minLevel;
  final String? itemName;
  final int? minHappiness;
  final String? timeOfDay;
  const EvolutionRow({
    required this.fromSpeciesId,
    required this.toSpeciesId,
    required this.trigger,
    this.minLevel,
    this.itemName,
    this.minHappiness,
    this.timeOfDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['from_species_id'] = Variable<int>(fromSpeciesId);
    map['to_species_id'] = Variable<int>(toSpeciesId);
    map['trigger'] = Variable<String>(trigger);
    if (!nullToAbsent || minLevel != null) {
      map['min_level'] = Variable<int>(minLevel);
    }
    if (!nullToAbsent || itemName != null) {
      map['item_name'] = Variable<String>(itemName);
    }
    if (!nullToAbsent || minHappiness != null) {
      map['min_happiness'] = Variable<int>(minHappiness);
    }
    if (!nullToAbsent || timeOfDay != null) {
      map['time_of_day'] = Variable<String>(timeOfDay);
    }
    return map;
  }

  EvolutionsCompanion toCompanion(bool nullToAbsent) {
    return EvolutionsCompanion(
      fromSpeciesId: Value(fromSpeciesId),
      toSpeciesId: Value(toSpeciesId),
      trigger: Value(trigger),
      minLevel: minLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(minLevel),
      itemName: itemName == null && nullToAbsent
          ? const Value.absent()
          : Value(itemName),
      minHappiness: minHappiness == null && nullToAbsent
          ? const Value.absent()
          : Value(minHappiness),
      timeOfDay: timeOfDay == null && nullToAbsent
          ? const Value.absent()
          : Value(timeOfDay),
    );
  }

  factory EvolutionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EvolutionRow(
      fromSpeciesId: serializer.fromJson<int>(json['fromSpeciesId']),
      toSpeciesId: serializer.fromJson<int>(json['toSpeciesId']),
      trigger: serializer.fromJson<String>(json['trigger']),
      minLevel: serializer.fromJson<int?>(json['minLevel']),
      itemName: serializer.fromJson<String?>(json['itemName']),
      minHappiness: serializer.fromJson<int?>(json['minHappiness']),
      timeOfDay: serializer.fromJson<String?>(json['timeOfDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'fromSpeciesId': serializer.toJson<int>(fromSpeciesId),
      'toSpeciesId': serializer.toJson<int>(toSpeciesId),
      'trigger': serializer.toJson<String>(trigger),
      'minLevel': serializer.toJson<int?>(minLevel),
      'itemName': serializer.toJson<String?>(itemName),
      'minHappiness': serializer.toJson<int?>(minHappiness),
      'timeOfDay': serializer.toJson<String?>(timeOfDay),
    };
  }

  EvolutionRow copyWith({
    int? fromSpeciesId,
    int? toSpeciesId,
    String? trigger,
    Value<int?> minLevel = const Value.absent(),
    Value<String?> itemName = const Value.absent(),
    Value<int?> minHappiness = const Value.absent(),
    Value<String?> timeOfDay = const Value.absent(),
  }) => EvolutionRow(
    fromSpeciesId: fromSpeciesId ?? this.fromSpeciesId,
    toSpeciesId: toSpeciesId ?? this.toSpeciesId,
    trigger: trigger ?? this.trigger,
    minLevel: minLevel.present ? minLevel.value : this.minLevel,
    itemName: itemName.present ? itemName.value : this.itemName,
    minHappiness: minHappiness.present ? minHappiness.value : this.minHappiness,
    timeOfDay: timeOfDay.present ? timeOfDay.value : this.timeOfDay,
  );
  EvolutionRow copyWithCompanion(EvolutionsCompanion data) {
    return EvolutionRow(
      fromSpeciesId: data.fromSpeciesId.present
          ? data.fromSpeciesId.value
          : this.fromSpeciesId,
      toSpeciesId: data.toSpeciesId.present
          ? data.toSpeciesId.value
          : this.toSpeciesId,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      minLevel: data.minLevel.present ? data.minLevel.value : this.minLevel,
      itemName: data.itemName.present ? data.itemName.value : this.itemName,
      minHappiness: data.minHappiness.present
          ? data.minHappiness.value
          : this.minHappiness,
      timeOfDay: data.timeOfDay.present ? data.timeOfDay.value : this.timeOfDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EvolutionRow(')
          ..write('fromSpeciesId: $fromSpeciesId, ')
          ..write('toSpeciesId: $toSpeciesId, ')
          ..write('trigger: $trigger, ')
          ..write('minLevel: $minLevel, ')
          ..write('itemName: $itemName, ')
          ..write('minHappiness: $minHappiness, ')
          ..write('timeOfDay: $timeOfDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    fromSpeciesId,
    toSpeciesId,
    trigger,
    minLevel,
    itemName,
    minHappiness,
    timeOfDay,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EvolutionRow &&
          other.fromSpeciesId == this.fromSpeciesId &&
          other.toSpeciesId == this.toSpeciesId &&
          other.trigger == this.trigger &&
          other.minLevel == this.minLevel &&
          other.itemName == this.itemName &&
          other.minHappiness == this.minHappiness &&
          other.timeOfDay == this.timeOfDay);
}

class EvolutionsCompanion extends UpdateCompanion<EvolutionRow> {
  final Value<int> fromSpeciesId;
  final Value<int> toSpeciesId;
  final Value<String> trigger;
  final Value<int?> minLevel;
  final Value<String?> itemName;
  final Value<int?> minHappiness;
  final Value<String?> timeOfDay;
  final Value<int> rowid;
  const EvolutionsCompanion({
    this.fromSpeciesId = const Value.absent(),
    this.toSpeciesId = const Value.absent(),
    this.trigger = const Value.absent(),
    this.minLevel = const Value.absent(),
    this.itemName = const Value.absent(),
    this.minHappiness = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EvolutionsCompanion.insert({
    required int fromSpeciesId,
    required int toSpeciesId,
    required String trigger,
    this.minLevel = const Value.absent(),
    this.itemName = const Value.absent(),
    this.minHappiness = const Value.absent(),
    this.timeOfDay = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : fromSpeciesId = Value(fromSpeciesId),
       toSpeciesId = Value(toSpeciesId),
       trigger = Value(trigger);
  static Insertable<EvolutionRow> custom({
    Expression<int>? fromSpeciesId,
    Expression<int>? toSpeciesId,
    Expression<String>? trigger,
    Expression<int>? minLevel,
    Expression<String>? itemName,
    Expression<int>? minHappiness,
    Expression<String>? timeOfDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (fromSpeciesId != null) 'from_species_id': fromSpeciesId,
      if (toSpeciesId != null) 'to_species_id': toSpeciesId,
      if (trigger != null) 'trigger': trigger,
      if (minLevel != null) 'min_level': minLevel,
      if (itemName != null) 'item_name': itemName,
      if (minHappiness != null) 'min_happiness': minHappiness,
      if (timeOfDay != null) 'time_of_day': timeOfDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EvolutionsCompanion copyWith({
    Value<int>? fromSpeciesId,
    Value<int>? toSpeciesId,
    Value<String>? trigger,
    Value<int?>? minLevel,
    Value<String?>? itemName,
    Value<int?>? minHappiness,
    Value<String?>? timeOfDay,
    Value<int>? rowid,
  }) {
    return EvolutionsCompanion(
      fromSpeciesId: fromSpeciesId ?? this.fromSpeciesId,
      toSpeciesId: toSpeciesId ?? this.toSpeciesId,
      trigger: trigger ?? this.trigger,
      minLevel: minLevel ?? this.minLevel,
      itemName: itemName ?? this.itemName,
      minHappiness: minHappiness ?? this.minHappiness,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (fromSpeciesId.present) {
      map['from_species_id'] = Variable<int>(fromSpeciesId.value);
    }
    if (toSpeciesId.present) {
      map['to_species_id'] = Variable<int>(toSpeciesId.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (minLevel.present) {
      map['min_level'] = Variable<int>(minLevel.value);
    }
    if (itemName.present) {
      map['item_name'] = Variable<String>(itemName.value);
    }
    if (minHappiness.present) {
      map['min_happiness'] = Variable<int>(minHappiness.value);
    }
    if (timeOfDay.present) {
      map['time_of_day'] = Variable<String>(timeOfDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EvolutionsCompanion(')
          ..write('fromSpeciesId: $fromSpeciesId, ')
          ..write('toSpeciesId: $toSpeciesId, ')
          ..write('trigger: $trigger, ')
          ..write('minLevel: $minLevel, ')
          ..write('itemName: $itemName, ')
          ..write('minHappiness: $minHappiness, ')
          ..write('timeOfDay: $timeOfDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TypeEfficaciesTable extends TypeEfficacies
    with TableInfo<$TypeEfficaciesTable, TypeEfficacyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TypeEfficaciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attackerTypeIdMeta = const VerificationMeta(
    'attackerTypeId',
  );
  @override
  late final GeneratedColumn<int> attackerTypeId = GeneratedColumn<int>(
    'attacker_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES type (id)',
    ),
  );
  static const VerificationMeta _defenderTypeIdMeta = const VerificationMeta(
    'defenderTypeId',
  );
  @override
  late final GeneratedColumn<int> defenderTypeId = GeneratedColumn<int>(
    'defender_type_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES type (id)',
    ),
  );
  static const VerificationMeta _damageFactorMeta = const VerificationMeta(
    'damageFactor',
  );
  @override
  late final GeneratedColumn<int> damageFactor = GeneratedColumn<int>(
    'damage_factor',
    aliasedName,
    false,
    check: () => damageFactor.isIn([0, 50, 100, 200]),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    attackerTypeId,
    defenderTypeId,
    damageFactor,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'type_efficacy';
  @override
  VerificationContext validateIntegrity(
    Insertable<TypeEfficacyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attacker_type_id')) {
      context.handle(
        _attackerTypeIdMeta,
        attackerTypeId.isAcceptableOrUnknown(
          data['attacker_type_id']!,
          _attackerTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_attackerTypeIdMeta);
    }
    if (data.containsKey('defender_type_id')) {
      context.handle(
        _defenderTypeIdMeta,
        defenderTypeId.isAcceptableOrUnknown(
          data['defender_type_id']!,
          _defenderTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defenderTypeIdMeta);
    }
    if (data.containsKey('damage_factor')) {
      context.handle(
        _damageFactorMeta,
        damageFactor.isAcceptableOrUnknown(
          data['damage_factor']!,
          _damageFactorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_damageFactorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attackerTypeId, defenderTypeId};
  @override
  TypeEfficacyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TypeEfficacyRow(
      attackerTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attacker_type_id'],
      )!,
      defenderTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}defender_type_id'],
      )!,
      damageFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}damage_factor'],
      )!,
    );
  }

  @override
  $TypeEfficaciesTable createAlias(String alias) {
    return $TypeEfficaciesTable(attachedDatabase, alias);
  }
}

class TypeEfficacyRow extends DataClass implements Insertable<TypeEfficacyRow> {
  final int attackerTypeId;
  final int defenderTypeId;
  final int damageFactor;
  const TypeEfficacyRow({
    required this.attackerTypeId,
    required this.defenderTypeId,
    required this.damageFactor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attacker_type_id'] = Variable<int>(attackerTypeId);
    map['defender_type_id'] = Variable<int>(defenderTypeId);
    map['damage_factor'] = Variable<int>(damageFactor);
    return map;
  }

  TypeEfficaciesCompanion toCompanion(bool nullToAbsent) {
    return TypeEfficaciesCompanion(
      attackerTypeId: Value(attackerTypeId),
      defenderTypeId: Value(defenderTypeId),
      damageFactor: Value(damageFactor),
    );
  }

  factory TypeEfficacyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TypeEfficacyRow(
      attackerTypeId: serializer.fromJson<int>(json['attackerTypeId']),
      defenderTypeId: serializer.fromJson<int>(json['defenderTypeId']),
      damageFactor: serializer.fromJson<int>(json['damageFactor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attackerTypeId': serializer.toJson<int>(attackerTypeId),
      'defenderTypeId': serializer.toJson<int>(defenderTypeId),
      'damageFactor': serializer.toJson<int>(damageFactor),
    };
  }

  TypeEfficacyRow copyWith({
    int? attackerTypeId,
    int? defenderTypeId,
    int? damageFactor,
  }) => TypeEfficacyRow(
    attackerTypeId: attackerTypeId ?? this.attackerTypeId,
    defenderTypeId: defenderTypeId ?? this.defenderTypeId,
    damageFactor: damageFactor ?? this.damageFactor,
  );
  TypeEfficacyRow copyWithCompanion(TypeEfficaciesCompanion data) {
    return TypeEfficacyRow(
      attackerTypeId: data.attackerTypeId.present
          ? data.attackerTypeId.value
          : this.attackerTypeId,
      defenderTypeId: data.defenderTypeId.present
          ? data.defenderTypeId.value
          : this.defenderTypeId,
      damageFactor: data.damageFactor.present
          ? data.damageFactor.value
          : this.damageFactor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TypeEfficacyRow(')
          ..write('attackerTypeId: $attackerTypeId, ')
          ..write('defenderTypeId: $defenderTypeId, ')
          ..write('damageFactor: $damageFactor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(attackerTypeId, defenderTypeId, damageFactor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TypeEfficacyRow &&
          other.attackerTypeId == this.attackerTypeId &&
          other.defenderTypeId == this.defenderTypeId &&
          other.damageFactor == this.damageFactor);
}

class TypeEfficaciesCompanion extends UpdateCompanion<TypeEfficacyRow> {
  final Value<int> attackerTypeId;
  final Value<int> defenderTypeId;
  final Value<int> damageFactor;
  final Value<int> rowid;
  const TypeEfficaciesCompanion({
    this.attackerTypeId = const Value.absent(),
    this.defenderTypeId = const Value.absent(),
    this.damageFactor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TypeEfficaciesCompanion.insert({
    required int attackerTypeId,
    required int defenderTypeId,
    required int damageFactor,
    this.rowid = const Value.absent(),
  }) : attackerTypeId = Value(attackerTypeId),
       defenderTypeId = Value(defenderTypeId),
       damageFactor = Value(damageFactor);
  static Insertable<TypeEfficacyRow> custom({
    Expression<int>? attackerTypeId,
    Expression<int>? defenderTypeId,
    Expression<int>? damageFactor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attackerTypeId != null) 'attacker_type_id': attackerTypeId,
      if (defenderTypeId != null) 'defender_type_id': defenderTypeId,
      if (damageFactor != null) 'damage_factor': damageFactor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TypeEfficaciesCompanion copyWith({
    Value<int>? attackerTypeId,
    Value<int>? defenderTypeId,
    Value<int>? damageFactor,
    Value<int>? rowid,
  }) {
    return TypeEfficaciesCompanion(
      attackerTypeId: attackerTypeId ?? this.attackerTypeId,
      defenderTypeId: defenderTypeId ?? this.defenderTypeId,
      damageFactor: damageFactor ?? this.damageFactor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attackerTypeId.present) {
      map['attacker_type_id'] = Variable<int>(attackerTypeId.value);
    }
    if (defenderTypeId.present) {
      map['defender_type_id'] = Variable<int>(defenderTypeId.value);
    }
    if (damageFactor.present) {
      map['damage_factor'] = Variable<int>(damageFactor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TypeEfficaciesCompanion(')
          ..write('attackerTypeId: $attackerTypeId, ')
          ..write('defenderTypeId: $defenderTypeId, ')
          ..write('damageFactor: $damageFactor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TriviaResultsTable extends TriviaResults
    with TableInfo<$TriviaResultsTable, TriviaResultRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TriviaResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    check: () => ComparableExpr(score).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctAnswersMeta = const VerificationMeta(
    'correctAnswers',
  );
  @override
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
    'correct_answers',
    aliasedName,
    false,
    check: () => ComparableExpr(correctAnswers).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  @override
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    check: () => ComparableExpr(totalQuestions).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    score,
    correctAnswers,
    totalQuestions,
    playedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trivia_result';
  @override
  VerificationContext validateIntegrity(
    Insertable<TriviaResultRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
        _correctAnswersMeta,
        correctAnswers.isAcceptableOrUnknown(
          data['correct_answers']!,
          _correctAnswersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctAnswersMeta);
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TriviaResultRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TriviaResultRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      correctAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_answers'],
      )!,
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
    );
  }

  @override
  $TriviaResultsTable createAlias(String alias) {
    return $TriviaResultsTable(attachedDatabase, alias);
  }
}

class TriviaResultRow extends DataClass implements Insertable<TriviaResultRow> {
  final int id;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final DateTime playedAt;
  const TriviaResultRow({
    required this.id,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.playedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['score'] = Variable<int>(score);
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['played_at'] = Variable<DateTime>(playedAt);
    return map;
  }

  TriviaResultsCompanion toCompanion(bool nullToAbsent) {
    return TriviaResultsCompanion(
      id: Value(id),
      score: Value(score),
      correctAnswers: Value(correctAnswers),
      totalQuestions: Value(totalQuestions),
      playedAt: Value(playedAt),
    );
  }

  factory TriviaResultRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TriviaResultRow(
      id: serializer.fromJson<int>(json['id']),
      score: serializer.fromJson<int>(json['score']),
      correctAnswers: serializer.fromJson<int>(json['correctAnswers']),
      totalQuestions: serializer.fromJson<int>(json['totalQuestions']),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'score': serializer.toJson<int>(score),
      'correctAnswers': serializer.toJson<int>(correctAnswers),
      'totalQuestions': serializer.toJson<int>(totalQuestions),
      'playedAt': serializer.toJson<DateTime>(playedAt),
    };
  }

  TriviaResultRow copyWith({
    int? id,
    int? score,
    int? correctAnswers,
    int? totalQuestions,
    DateTime? playedAt,
  }) => TriviaResultRow(
    id: id ?? this.id,
    score: score ?? this.score,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    playedAt: playedAt ?? this.playedAt,
  );
  TriviaResultRow copyWithCompanion(TriviaResultsCompanion data) {
    return TriviaResultRow(
      id: data.id.present ? data.id.value : this.id,
      score: data.score.present ? data.score.value : this.score,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TriviaResultRow(')
          ..write('id: $id, ')
          ..write('score: $score, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, score, correctAnswers, totalQuestions, playedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TriviaResultRow &&
          other.id == this.id &&
          other.score == this.score &&
          other.correctAnswers == this.correctAnswers &&
          other.totalQuestions == this.totalQuestions &&
          other.playedAt == this.playedAt);
}

class TriviaResultsCompanion extends UpdateCompanion<TriviaResultRow> {
  final Value<int> id;
  final Value<int> score;
  final Value<int> correctAnswers;
  final Value<int> totalQuestions;
  final Value<DateTime> playedAt;
  const TriviaResultsCompanion({
    this.id = const Value.absent(),
    this.score = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.playedAt = const Value.absent(),
  });
  TriviaResultsCompanion.insert({
    this.id = const Value.absent(),
    required int score,
    required int correctAnswers,
    required int totalQuestions,
    required DateTime playedAt,
  }) : score = Value(score),
       correctAnswers = Value(correctAnswers),
       totalQuestions = Value(totalQuestions),
       playedAt = Value(playedAt);
  static Insertable<TriviaResultRow> custom({
    Expression<int>? id,
    Expression<int>? score,
    Expression<int>? correctAnswers,
    Expression<int>? totalQuestions,
    Expression<DateTime>? playedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (score != null) 'score': score,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (playedAt != null) 'played_at': playedAt,
    });
  }

  TriviaResultsCompanion copyWith({
    Value<int>? id,
    Value<int>? score,
    Value<int>? correctAnswers,
    Value<int>? totalQuestions,
    Value<DateTime>? playedAt,
  }) {
    return TriviaResultsCompanion(
      id: id ?? this.id,
      score: score ?? this.score,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      playedAt: playedAt ?? this.playedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TriviaResultsCompanion(')
          ..write('id: $id, ')
          ..write('score: $score, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('playedAt: $playedAt')
          ..write(')'))
        .toString();
  }
}

class $TriviaAnswersTable extends TriviaAnswers
    with TableInfo<$TriviaAnswersTable, TriviaAnswerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TriviaAnswersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _triviaResultIdMeta = const VerificationMeta(
    'triviaResultId',
  );
  @override
  late final GeneratedColumn<int> triviaResultId = GeneratedColumn<int>(
    'trivia_result_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES trivia_result (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pokemonIdMeta = const VerificationMeta(
    'pokemonId',
  );
  @override
  late final GeneratedColumn<int> pokemonId = GeneratedColumn<int>(
    'pokemon_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pokemon (id)',
    ),
  );
  static const VerificationMeta _correctMeta = const VerificationMeta(
    'correct',
  );
  @override
  late final GeneratedColumn<bool> correct = GeneratedColumn<bool>(
    'correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _answeredInMsMeta = const VerificationMeta(
    'answeredInMs',
  );
  @override
  late final GeneratedColumn<int> answeredInMs = GeneratedColumn<int>(
    'answered_in_ms',
    aliasedName,
    true,
    check: () => ComparableExpr(answeredInMs).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    triviaResultId,
    pokemonId,
    correct,
    answeredInMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trivia_answer';
  @override
  VerificationContext validateIntegrity(
    Insertable<TriviaAnswerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('trivia_result_id')) {
      context.handle(
        _triviaResultIdMeta,
        triviaResultId.isAcceptableOrUnknown(
          data['trivia_result_id']!,
          _triviaResultIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triviaResultIdMeta);
    }
    if (data.containsKey('pokemon_id')) {
      context.handle(
        _pokemonIdMeta,
        pokemonId.isAcceptableOrUnknown(data['pokemon_id']!, _pokemonIdMeta),
      );
    } else if (isInserting) {
      context.missing(_pokemonIdMeta);
    }
    if (data.containsKey('correct')) {
      context.handle(
        _correctMeta,
        correct.isAcceptableOrUnknown(data['correct']!, _correctMeta),
      );
    } else if (isInserting) {
      context.missing(_correctMeta);
    }
    if (data.containsKey('answered_in_ms')) {
      context.handle(
        _answeredInMsMeta,
        answeredInMs.isAcceptableOrUnknown(
          data['answered_in_ms']!,
          _answeredInMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TriviaAnswerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TriviaAnswerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      triviaResultId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}trivia_result_id'],
      )!,
      pokemonId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pokemon_id'],
      )!,
      correct: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}correct'],
      )!,
      answeredInMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_in_ms'],
      ),
    );
  }

  @override
  $TriviaAnswersTable createAlias(String alias) {
    return $TriviaAnswersTable(attachedDatabase, alias);
  }
}

class TriviaAnswerRow extends DataClass implements Insertable<TriviaAnswerRow> {
  final int id;
  final int triviaResultId;
  final int pokemonId;
  final bool correct;
  final int? answeredInMs;
  const TriviaAnswerRow({
    required this.id,
    required this.triviaResultId,
    required this.pokemonId,
    required this.correct,
    this.answeredInMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['trivia_result_id'] = Variable<int>(triviaResultId);
    map['pokemon_id'] = Variable<int>(pokemonId);
    map['correct'] = Variable<bool>(correct);
    if (!nullToAbsent || answeredInMs != null) {
      map['answered_in_ms'] = Variable<int>(answeredInMs);
    }
    return map;
  }

  TriviaAnswersCompanion toCompanion(bool nullToAbsent) {
    return TriviaAnswersCompanion(
      id: Value(id),
      triviaResultId: Value(triviaResultId),
      pokemonId: Value(pokemonId),
      correct: Value(correct),
      answeredInMs: answeredInMs == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredInMs),
    );
  }

  factory TriviaAnswerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TriviaAnswerRow(
      id: serializer.fromJson<int>(json['id']),
      triviaResultId: serializer.fromJson<int>(json['triviaResultId']),
      pokemonId: serializer.fromJson<int>(json['pokemonId']),
      correct: serializer.fromJson<bool>(json['correct']),
      answeredInMs: serializer.fromJson<int?>(json['answeredInMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'triviaResultId': serializer.toJson<int>(triviaResultId),
      'pokemonId': serializer.toJson<int>(pokemonId),
      'correct': serializer.toJson<bool>(correct),
      'answeredInMs': serializer.toJson<int?>(answeredInMs),
    };
  }

  TriviaAnswerRow copyWith({
    int? id,
    int? triviaResultId,
    int? pokemonId,
    bool? correct,
    Value<int?> answeredInMs = const Value.absent(),
  }) => TriviaAnswerRow(
    id: id ?? this.id,
    triviaResultId: triviaResultId ?? this.triviaResultId,
    pokemonId: pokemonId ?? this.pokemonId,
    correct: correct ?? this.correct,
    answeredInMs: answeredInMs.present ? answeredInMs.value : this.answeredInMs,
  );
  TriviaAnswerRow copyWithCompanion(TriviaAnswersCompanion data) {
    return TriviaAnswerRow(
      id: data.id.present ? data.id.value : this.id,
      triviaResultId: data.triviaResultId.present
          ? data.triviaResultId.value
          : this.triviaResultId,
      pokemonId: data.pokemonId.present ? data.pokemonId.value : this.pokemonId,
      correct: data.correct.present ? data.correct.value : this.correct,
      answeredInMs: data.answeredInMs.present
          ? data.answeredInMs.value
          : this.answeredInMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TriviaAnswerRow(')
          ..write('id: $id, ')
          ..write('triviaResultId: $triviaResultId, ')
          ..write('pokemonId: $pokemonId, ')
          ..write('correct: $correct, ')
          ..write('answeredInMs: $answeredInMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, triviaResultId, pokemonId, correct, answeredInMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TriviaAnswerRow &&
          other.id == this.id &&
          other.triviaResultId == this.triviaResultId &&
          other.pokemonId == this.pokemonId &&
          other.correct == this.correct &&
          other.answeredInMs == this.answeredInMs);
}

class TriviaAnswersCompanion extends UpdateCompanion<TriviaAnswerRow> {
  final Value<int> id;
  final Value<int> triviaResultId;
  final Value<int> pokemonId;
  final Value<bool> correct;
  final Value<int?> answeredInMs;
  const TriviaAnswersCompanion({
    this.id = const Value.absent(),
    this.triviaResultId = const Value.absent(),
    this.pokemonId = const Value.absent(),
    this.correct = const Value.absent(),
    this.answeredInMs = const Value.absent(),
  });
  TriviaAnswersCompanion.insert({
    this.id = const Value.absent(),
    required int triviaResultId,
    required int pokemonId,
    required bool correct,
    this.answeredInMs = const Value.absent(),
  }) : triviaResultId = Value(triviaResultId),
       pokemonId = Value(pokemonId),
       correct = Value(correct);
  static Insertable<TriviaAnswerRow> custom({
    Expression<int>? id,
    Expression<int>? triviaResultId,
    Expression<int>? pokemonId,
    Expression<bool>? correct,
    Expression<int>? answeredInMs,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (triviaResultId != null) 'trivia_result_id': triviaResultId,
      if (pokemonId != null) 'pokemon_id': pokemonId,
      if (correct != null) 'correct': correct,
      if (answeredInMs != null) 'answered_in_ms': answeredInMs,
    });
  }

  TriviaAnswersCompanion copyWith({
    Value<int>? id,
    Value<int>? triviaResultId,
    Value<int>? pokemonId,
    Value<bool>? correct,
    Value<int?>? answeredInMs,
  }) {
    return TriviaAnswersCompanion(
      id: id ?? this.id,
      triviaResultId: triviaResultId ?? this.triviaResultId,
      pokemonId: pokemonId ?? this.pokemonId,
      correct: correct ?? this.correct,
      answeredInMs: answeredInMs ?? this.answeredInMs,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (triviaResultId.present) {
      map['trivia_result_id'] = Variable<int>(triviaResultId.value);
    }
    if (pokemonId.present) {
      map['pokemon_id'] = Variable<int>(pokemonId.value);
    }
    if (correct.present) {
      map['correct'] = Variable<bool>(correct.value);
    }
    if (answeredInMs.present) {
      map['answered_in_ms'] = Variable<int>(answeredInMs.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TriviaAnswersCompanion(')
          ..write('id: $id, ')
          ..write('triviaResultId: $triviaResultId, ')
          ..write('pokemonId: $pokemonId, ')
          ..write('correct: $correct, ')
          ..write('answeredInMs: $answeredInMs')
          ..write(')'))
        .toString();
  }
}

class $AchievementsTable extends Achievements
    with TableInfo<$AchievementsTable, AchievementRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AchievementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    check: () => ComparableExpr(key.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievement';
  @override
  VerificationContext validateIntegrity(
    Insertable<AchievementRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AchievementRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AchievementRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $AchievementsTable createAlias(String alias) {
    return $AchievementsTable(attachedDatabase, alias);
  }
}

class AchievementRow extends DataClass implements Insertable<AchievementRow> {
  final String key;
  final DateTime unlockedAt;
  const AchievementRow({required this.key, required this.unlockedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      key: Value(key),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory AchievementRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AchievementRow(
      key: serializer.fromJson<String>(json['key']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  AchievementRow copyWith({String? key, DateTime? unlockedAt}) =>
      AchievementRow(
        key: key ?? this.key,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
  AchievementRow copyWithCompanion(AchievementsCompanion data) {
    return AchievementRow(
      key: data.key.present ? data.key.value : this.key,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AchievementRow(')
          ..write('key: $key, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AchievementRow &&
          other.key == this.key &&
          other.unlockedAt == this.unlockedAt);
}

class AchievementsCompanion extends UpdateCompanion<AchievementRow> {
  final Value<String> key;
  final Value<DateTime> unlockedAt;
  final Value<int> rowid;
  const AchievementsCompanion({
    this.key = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AchievementsCompanion.insert({
    required String key,
    required DateTime unlockedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       unlockedAt = Value(unlockedAt);
  static Insertable<AchievementRow> custom({
    Expression<String>? key,
    Expression<DateTime>? unlockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AchievementsCompanion copyWith({
    Value<String>? key,
    Value<DateTime>? unlockedAt,
    Value<int>? rowid,
  }) {
    return AchievementsCompanion(
      key: key ?? this.key,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('key: $key, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    check: () => ComparableExpr(key.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_setting';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  const AppSettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingRow copyWith({String? key, String? value}) =>
      AppSettingRow(key: key ?? this.key, value: value ?? this.value);
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImageCacheEntriesTable extends ImageCacheEntries
    with TableInfo<$ImageCacheEntriesTable, ImageCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImageCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    check: () => ComparableExpr(url.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    check: () => ComparableExpr(localPath.length).isBiggerThanValue(0),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    check: () => ComparableExpr(sizeBytes).isBiggerOrEqualValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAccessedAt =
      GeneratedColumn<DateTime>(
        'last_accessed_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    url,
    localPath,
    sizeBytes,
    createdAt,
    lastAccessedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'image_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('url')) {
      context.handle(
        _urlMeta,
        url.isAcceptableOrUnknown(data['url']!, _urlMeta),
      );
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  ImageCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageCacheRow(
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_accessed_at'],
      )!,
    );
  }

  @override
  $ImageCacheEntriesTable createAlias(String alias) {
    return $ImageCacheEntriesTable(attachedDatabase, alias);
  }
}

class ImageCacheRow extends DataClass implements Insertable<ImageCacheRow> {
  final String url;
  final String localPath;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime lastAccessedAt;
  const ImageCacheRow({
    required this.url,
    required this.localPath,
    required this.sizeBytes,
    required this.createdAt,
    required this.lastAccessedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['url'] = Variable<String>(url);
    map['local_path'] = Variable<String>(localPath);
    map['size_bytes'] = Variable<int>(sizeBytes);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt);
    return map;
  }

  ImageCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return ImageCacheEntriesCompanion(
      url: Value(url),
      localPath: Value(localPath),
      sizeBytes: Value(sizeBytes),
      createdAt: Value(createdAt),
      lastAccessedAt: Value(lastAccessedAt),
    );
  }

  factory ImageCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageCacheRow(
      url: serializer.fromJson<String>(json['url']),
      localPath: serializer.fromJson<String>(json['localPath']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastAccessedAt: serializer.fromJson<DateTime>(json['lastAccessedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<String>(url),
      'localPath': serializer.toJson<String>(localPath),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastAccessedAt': serializer.toJson<DateTime>(lastAccessedAt),
    };
  }

  ImageCacheRow copyWith({
    String? url,
    String? localPath,
    int? sizeBytes,
    DateTime? createdAt,
    DateTime? lastAccessedAt,
  }) => ImageCacheRow(
    url: url ?? this.url,
    localPath: localPath ?? this.localPath,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    createdAt: createdAt ?? this.createdAt,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
  );
  ImageCacheRow copyWithCompanion(ImageCacheEntriesCompanion data) {
    return ImageCacheRow(
      url: data.url.present ? data.url.value : this.url,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageCacheRow(')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAccessedAt: $lastAccessedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(url, localPath, sizeBytes, createdAt, lastAccessedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageCacheRow &&
          other.url == this.url &&
          other.localPath == this.localPath &&
          other.sizeBytes == this.sizeBytes &&
          other.createdAt == this.createdAt &&
          other.lastAccessedAt == this.lastAccessedAt);
}

class ImageCacheEntriesCompanion extends UpdateCompanion<ImageCacheRow> {
  final Value<String> url;
  final Value<String> localPath;
  final Value<int> sizeBytes;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastAccessedAt;
  final Value<int> rowid;
  const ImageCacheEntriesCompanion({
    this.url = const Value.absent(),
    this.localPath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImageCacheEntriesCompanion.insert({
    required String url,
    required String localPath,
    required int sizeBytes,
    required DateTime createdAt,
    required DateTime lastAccessedAt,
    this.rowid = const Value.absent(),
  }) : url = Value(url),
       localPath = Value(localPath),
       sizeBytes = Value(sizeBytes),
       createdAt = Value(createdAt),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<ImageCacheRow> custom({
    Expression<String>? url,
    Expression<String>? localPath,
    Expression<int>? sizeBytes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastAccessedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (localPath != null) 'local_path': localPath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (createdAt != null) 'created_at': createdAt,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImageCacheEntriesCompanion copyWith({
    Value<String>? url,
    Value<String>? localPath,
    Value<int>? sizeBytes,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastAccessedAt,
    Value<int>? rowid,
  }) {
    return ImageCacheEntriesCompanion(
      url: url ?? this.url,
      localPath: localPath ?? this.localPath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<DateTime>(lastAccessedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageCacheEntriesCompanion(')
          ..write('url: $url, ')
          ..write('localPath: $localPath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $GenerationsTable generations = $GenerationsTable(this);
  late final $PokemonSpeciesTable pokemonSpecies = $PokemonSpeciesTable(this);
  late final $PokemonRecordsTable pokemonRecords = $PokemonRecordsTable(this);
  late final $PokemonTypesTable pokemonTypes = $PokemonTypesTable(this);
  late final $PokemonTypeLinksTable pokemonTypeLinks = $PokemonTypeLinksTable(
    this,
  );
  late final $FavoritesTable favorites = $FavoritesTable(this);
  late final $SyncMetadataRecordsTable syncMetadataRecords =
      $SyncMetadataRecordsTable(this);
  late final $StatsTable stats = $StatsTable(this);
  late final $PokemonStatsTable pokemonStats = $PokemonStatsTable(this);
  late final $AbilitiesTable abilities = $AbilitiesTable(this);
  late final $PokemonAbilitiesTable pokemonAbilities = $PokemonAbilitiesTable(
    this,
  );
  late final $MovesTable moves = $MovesTable(this);
  late final $VersionGroupsTable versionGroups = $VersionGroupsTable(this);
  late final $PokemonMovesTable pokemonMoves = $PokemonMovesTable(this);
  late final $EggGroupsTable eggGroups = $EggGroupsTable(this);
  late final $SpeciesEggGroupsTable speciesEggGroups = $SpeciesEggGroupsTable(
    this,
  );
  late final $EvolutionsTable evolutions = $EvolutionsTable(this);
  late final $TypeEfficaciesTable typeEfficacies = $TypeEfficaciesTable(this);
  late final $TriviaResultsTable triviaResults = $TriviaResultsTable(this);
  late final $TriviaAnswersTable triviaAnswers = $TriviaAnswersTable(this);
  late final $AchievementsTable achievements = $AchievementsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $ImageCacheEntriesTable imageCacheEntries =
      $ImageCacheEntriesTable(this);
  late final Index pokemonNationalOrder = Index(
    'pokemon_national_order',
    'CREATE INDEX pokemon_national_order ON pokemon (national_number, id)',
  );
  late final Index pokemonName = Index(
    'pokemon_name',
    'CREATE INDEX pokemon_name ON pokemon (name)',
  );
  late final Index pokemonSpeciesLookup = Index(
    'pokemon_species_lookup',
    'CREATE INDEX pokemon_species_lookup ON pokemon (species_id)',
  );
  late final Index pokemonStatTotalOrder = Index(
    'pokemon_stat_total_order',
    'CREATE INDEX pokemon_stat_total_order ON pokemon (base_stat_total, id)',
  );
  late final Index pokemonTypeByType = Index(
    'pokemon_type_by_type',
    'CREATE INDEX pokemon_type_by_type ON pokemon_type (type_id, pokemon_id)',
  );
  late final Index favoriteCreationOrder = Index(
    'favorite_creation_order',
    'CREATE INDEX favorite_creation_order ON favorite (created_at, pokemon_id)',
  );
  late final Index speciesGeneration = Index(
    'species_generation',
    'CREATE INDEX species_generation ON species (generation_id, id)',
  );
  late final Index pokemonAbilityByAbility = Index(
    'pokemon_ability_by_ability',
    'CREATE INDEX pokemon_ability_by_ability ON pokemon_ability (ability_id)',
  );
  late final Index pokemonMoveByVersion = Index(
    'pokemon_move_by_version',
    'CREATE INDEX pokemon_move_by_version ON pokemon_move (pokemon_id, version_group_id, learn_method)',
  );
  late final Index evolutionToSpecies = Index(
    'evolution_to_species',
    'CREATE INDEX evolution_to_species ON evolution (to_species_id)',
  );
  late final Index triviaResultRanking = Index(
    'trivia_result_ranking',
    'CREATE INDEX trivia_result_ranking ON trivia_result (score, played_at)',
  );
  late final Index triviaAnswerByResult = Index(
    'trivia_answer_by_result',
    'CREATE INDEX trivia_answer_by_result ON trivia_answer (trivia_result_id)',
  );
  late final Index imageCacheLru = Index(
    'image_cache_lru',
    'CREATE INDEX image_cache_lru ON image_cache (last_accessed_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    generations,
    pokemonSpecies,
    pokemonRecords,
    pokemonTypes,
    pokemonTypeLinks,
    favorites,
    syncMetadataRecords,
    stats,
    pokemonStats,
    abilities,
    pokemonAbilities,
    moves,
    versionGroups,
    pokemonMoves,
    eggGroups,
    speciesEggGroups,
    evolutions,
    typeEfficacies,
    triviaResults,
    triviaAnswers,
    achievements,
    appSettings,
    imageCacheEntries,
    pokemonNationalOrder,
    pokemonName,
    pokemonSpeciesLookup,
    pokemonStatTotalOrder,
    pokemonTypeByType,
    favoriteCreationOrder,
    speciesGeneration,
    pokemonAbilityByAbility,
    pokemonMoveByVersion,
    evolutionToSpecies,
    triviaResultRanking,
    triviaAnswerByResult,
    imageCacheLru,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pokemon',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_type', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pokemon',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_stat', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pokemon',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_ability', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pokemon',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pokemon_move', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'species',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('species_egg_group', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'species',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evolution', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'species',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('evolution', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'trivia_result',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('trivia_answer', kind: UpdateKind.delete)],
    ),
  ]);
}
