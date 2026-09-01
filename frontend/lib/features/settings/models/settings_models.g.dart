// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalSettingsCollection on Isar {
  IsarCollection<LocalSettings> get localSettings => this.collection();
}

const LocalSettingsSchema = CollectionSchema(
  name: r'LocalSettings',
  id: 1193626822998393387,
  properties: {
    r'aiModel': PropertySchema(id: 0, name: r'aiModel', type: IsarType.string),
    r'aiProvider': PropertySchema(
      id: 1,
      name: r'aiProvider',
      type: IsarType.string,
    ),
    r'fontSize': PropertySchema(id: 2, name: r'fontSize', type: IsarType.long),
    r'homepageUrl': PropertySchema(
      id: 3,
      name: r'homepageUrl',
      type: IsarType.string,
    ),
    r'language': PropertySchema(
      id: 4,
      name: r'language',
      type: IsarType.string,
    ),
    r'persistSession': PropertySchema(
      id: 5,
      name: r'persistSession',
      type: IsarType.bool,
    ),
    r'privacyTrackingProtection': PropertySchema(
      id: 6,
      name: r'privacyTrackingProtection',
      type: IsarType.bool,
    ),
    r'searchEngine': PropertySchema(
      id: 7,
      name: r'searchEngine',
      type: IsarType.string,
    ),
    r'synced': PropertySchema(id: 8, name: r'synced', type: IsarType.bool),
    r'theme': PropertySchema(id: 9, name: r'theme', type: IsarType.string),
  },

  estimateSize: _localSettingsEstimateSize,
  serialize: _localSettingsSerialize,
  deserialize: _localSettingsDeserialize,
  deserializeProp: _localSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _localSettingsGetId,
  getLinks: _localSettingsGetLinks,
  attach: _localSettingsAttach,
  version: '3.3.2',
);

int _localSettingsEstimateSize(
  LocalSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aiModel.length * 3;
  bytesCount += 3 + object.aiProvider.length * 3;
  bytesCount += 3 + object.homepageUrl.length * 3;
  bytesCount += 3 + object.language.length * 3;
  bytesCount += 3 + object.searchEngine.length * 3;
  bytesCount += 3 + object.theme.length * 3;
  return bytesCount;
}

void _localSettingsSerialize(
  LocalSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiModel);
  writer.writeString(offsets[1], object.aiProvider);
  writer.writeLong(offsets[2], object.fontSize);
  writer.writeString(offsets[3], object.homepageUrl);
  writer.writeString(offsets[4], object.language);
  writer.writeBool(offsets[5], object.persistSession);
  writer.writeBool(offsets[6], object.privacyTrackingProtection);
  writer.writeString(offsets[7], object.searchEngine);
  writer.writeBool(offsets[8], object.synced);
  writer.writeString(offsets[9], object.theme);
}

LocalSettings _localSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalSettings();
  object.aiModel = reader.readString(offsets[0]);
  object.aiProvider = reader.readString(offsets[1]);
  object.fontSize = reader.readLong(offsets[2]);
  object.homepageUrl = reader.readString(offsets[3]);
  object.id = id;
  object.language = reader.readString(offsets[4]);
  object.persistSession = reader.readBool(offsets[5]);
  object.privacyTrackingProtection = reader.readBool(offsets[6]);
  object.searchEngine = reader.readString(offsets[7]);
  object.synced = reader.readBool(offsets[8]);
  object.theme = reader.readString(offsets[9]);
  return object;
}

P _localSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readBool(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localSettingsGetId(LocalSettings object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localSettingsGetLinks(LocalSettings object) {
  return [];
}

void _localSettingsAttach(
  IsarCollection<dynamic> col,
  Id id,
  LocalSettings object,
) {
  object.id = id;
}

extension LocalSettingsQueryWhereSort
    on QueryBuilder<LocalSettings, LocalSettings, QWhere> {
  QueryBuilder<LocalSettings, LocalSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalSettingsQueryWhere
    on QueryBuilder<LocalSettings, LocalSettings, QWhereClause> {
  QueryBuilder<LocalSettings, LocalSettings, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension LocalSettingsQueryFilter
    on QueryBuilder<LocalSettings, LocalSettings, QFilterCondition> {
  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiModelEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiModelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiModelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiModelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aiModel',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiModelStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'aiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiModelEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'aiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiModelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'aiModel',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiModelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'aiModel',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'aiModel', value: ''),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'aiModel', value: ''),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiProviderEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aiProvider',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiProviderGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aiProvider',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiProviderLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aiProvider',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiProviderBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aiProvider',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiProviderStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'aiProvider',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiProviderEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'aiProvider',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiProviderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'aiProvider',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiProviderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'aiProvider',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiProviderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'aiProvider', value: ''),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  aiProviderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'aiProvider', value: ''),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  fontSizeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'fontSize', value: value),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  fontSizeGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'fontSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  fontSizeLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'fontSize',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  fontSizeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'fontSize',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  homepageUrlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'homepageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  homepageUrlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'homepageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  homepageUrlLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'homepageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  homepageUrlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'homepageUrl',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  homepageUrlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'homepageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  homepageUrlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'homepageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  homepageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'homepageUrl',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  homepageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'homepageUrl',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  homepageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'homepageUrl', value: ''),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  homepageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'homepageUrl', value: ''),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition> idEqualTo(
    Id value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  idGreaterThan(Id value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  languageEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  languageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  languageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  languageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'language',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  languageStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  languageEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'language',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  languageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'language',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'language', value: ''),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  persistSessionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'persistSession', value: value),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  privacyTrackingProtectionEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'privacyTrackingProtection',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  searchEngineEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'searchEngine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  searchEngineGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'searchEngine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  searchEngineLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'searchEngine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  searchEngineBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'searchEngine',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  searchEngineStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'searchEngine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  searchEngineEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'searchEngine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  searchEngineContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'searchEngine',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  searchEngineMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'searchEngine',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  searchEngineIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'searchEngine', value: ''),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  searchEngineIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'searchEngine', value: ''),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  syncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'synced', value: value),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  themeEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  themeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  themeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  themeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'theme',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  themeStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  themeEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  themeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'theme',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  themeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'theme',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  themeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'theme', value: ''),
      );
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterFilterCondition>
  themeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'theme', value: ''),
      );
    });
  }
}

extension LocalSettingsQueryObject
    on QueryBuilder<LocalSettings, LocalSettings, QFilterCondition> {}

extension LocalSettingsQueryLinks
    on QueryBuilder<LocalSettings, LocalSettings, QFilterCondition> {}

extension LocalSettingsQuerySortBy
    on QueryBuilder<LocalSettings, LocalSettings, QSortBy> {
  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> sortByAiModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> sortByAiModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> sortByAiProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiProvider', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  sortByAiProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiProvider', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> sortByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  sortByFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> sortByHomepageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homepageUrl', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  sortByHomepageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homepageUrl', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  sortByPersistSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistSession', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  sortByPersistSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistSession', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  sortByPrivacyTrackingProtection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privacyTrackingProtection', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  sortByPrivacyTrackingProtectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privacyTrackingProtection', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  sortBySearchEngine() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchEngine', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  sortBySearchEngineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchEngine', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> sortBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> sortBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> sortByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> sortByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }
}

extension LocalSettingsQuerySortThenBy
    on QueryBuilder<LocalSettings, LocalSettings, QSortThenBy> {
  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenByAiModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenByAiModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenByAiProvider() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiProvider', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  thenByAiProviderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiProvider', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  thenByFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenByHomepageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homepageUrl', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  thenByHomepageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'homepageUrl', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  thenByPersistSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistSession', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  thenByPersistSessionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'persistSession', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  thenByPrivacyTrackingProtection() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privacyTrackingProtection', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  thenByPrivacyTrackingProtectionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'privacyTrackingProtection', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  thenBySearchEngine() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchEngine', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy>
  thenBySearchEngineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'searchEngine', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenBySyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'synced', Sort.desc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenByTheme() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.asc);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QAfterSortBy> thenByThemeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'theme', Sort.desc);
    });
  }
}

extension LocalSettingsQueryWhereDistinct
    on QueryBuilder<LocalSettings, LocalSettings, QDistinct> {
  QueryBuilder<LocalSettings, LocalSettings, QDistinct> distinctByAiModel({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiModel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QDistinct> distinctByAiProvider({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiProvider', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QDistinct> distinctByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fontSize');
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QDistinct> distinctByHomepageUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'homepageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QDistinct> distinctByLanguage({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QDistinct>
  distinctByPersistSession() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'persistSession');
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QDistinct>
  distinctByPrivacyTrackingProtection() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'privacyTrackingProtection');
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QDistinct> distinctBySearchEngine({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'searchEngine', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QDistinct> distinctBySynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'synced');
    });
  }

  QueryBuilder<LocalSettings, LocalSettings, QDistinct> distinctByTheme({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'theme', caseSensitive: caseSensitive);
    });
  }
}

extension LocalSettingsQueryProperty
    on QueryBuilder<LocalSettings, LocalSettings, QQueryProperty> {
  QueryBuilder<LocalSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalSettings, String, QQueryOperations> aiModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiModel');
    });
  }

  QueryBuilder<LocalSettings, String, QQueryOperations> aiProviderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiProvider');
    });
  }

  QueryBuilder<LocalSettings, int, QQueryOperations> fontSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fontSize');
    });
  }

  QueryBuilder<LocalSettings, String, QQueryOperations> homepageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'homepageUrl');
    });
  }

  QueryBuilder<LocalSettings, String, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<LocalSettings, bool, QQueryOperations> persistSessionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'persistSession');
    });
  }

  QueryBuilder<LocalSettings, bool, QQueryOperations>
  privacyTrackingProtectionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'privacyTrackingProtection');
    });
  }

  QueryBuilder<LocalSettings, String, QQueryOperations> searchEngineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'searchEngine');
    });
  }

  QueryBuilder<LocalSettings, bool, QQueryOperations> syncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'synced');
    });
  }

  QueryBuilder<LocalSettings, String, QQueryOperations> themeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'theme');
    });
  }
}
