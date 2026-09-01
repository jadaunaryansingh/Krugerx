// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalSessionTabCollection on Isar {
  IsarCollection<LocalSessionTab> get localSessionTabs => this.collection();
}

const LocalSessionTabSchema = CollectionSchema(
  name: r'LocalSessionTab',
  id: 4612125534094202091,
  properties: {
    r'groupId': PropertySchema(id: 0, name: r'groupId', type: IsarType.string),
    r'isMuted': PropertySchema(id: 1, name: r'isMuted', type: IsarType.bool),
    r'isPinned': PropertySchema(id: 2, name: r'isPinned', type: IsarType.bool),
    r'position': PropertySchema(id: 3, name: r'position', type: IsarType.long),
    r'tabId': PropertySchema(id: 4, name: r'tabId', type: IsarType.string),
    r'timestamp': PropertySchema(
      id: 5,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(id: 6, name: r'title', type: IsarType.string),
    r'url': PropertySchema(id: 7, name: r'url', type: IsarType.string),
    r'zoomScale': PropertySchema(
      id: 8,
      name: r'zoomScale',
      type: IsarType.double,
    ),
  },

  estimateSize: _localSessionTabEstimateSize,
  serialize: _localSessionTabSerialize,
  deserialize: _localSessionTabDeserialize,
  deserializeProp: _localSessionTabDeserializeProp,
  idName: r'id',
  indexes: {
    r'tabId': IndexSchema(
      id: 1448272301247555965,
      name: r'tabId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'tabId',
          type: IndexType.hash,
          caseSensitive: true,
        ),
      ],
    ),
  },
  links: {},
  embeddedSchemas: {},

  getId: _localSessionTabGetId,
  getLinks: _localSessionTabGetLinks,
  attach: _localSessionTabAttach,
  version: '3.3.2',
);

int _localSessionTabEstimateSize(
  LocalSessionTab object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.groupId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.tabId.length * 3;
  {
    final value = object.title;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.url.length * 3;
  return bytesCount;
}

void _localSessionTabSerialize(
  LocalSessionTab object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.groupId);
  writer.writeBool(offsets[1], object.isMuted);
  writer.writeBool(offsets[2], object.isPinned);
  writer.writeLong(offsets[3], object.position);
  writer.writeString(offsets[4], object.tabId);
  writer.writeDateTime(offsets[5], object.timestamp);
  writer.writeString(offsets[6], object.title);
  writer.writeString(offsets[7], object.url);
  writer.writeDouble(offsets[8], object.zoomScale);
}

LocalSessionTab _localSessionTabDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalSessionTab();
  object.groupId = reader.readStringOrNull(offsets[0]);
  object.id = id;
  object.isMuted = reader.readBool(offsets[1]);
  object.isPinned = reader.readBool(offsets[2]);
  object.position = reader.readLong(offsets[3]);
  object.tabId = reader.readString(offsets[4]);
  object.timestamp = reader.readDateTime(offsets[5]);
  object.title = reader.readStringOrNull(offsets[6]);
  object.url = reader.readString(offsets[7]);
  object.zoomScale = reader.readDouble(offsets[8]);
  return object;
}

P _localSessionTabDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readBool(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readDateTime(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localSessionTabGetId(LocalSessionTab object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localSessionTabGetLinks(LocalSessionTab object) {
  return [];
}

void _localSessionTabAttach(
  IsarCollection<dynamic> col,
  Id id,
  LocalSessionTab object,
) {
  object.id = id;
}

extension LocalSessionTabByIndex on IsarCollection<LocalSessionTab> {
  Future<LocalSessionTab?> getByTabId(String tabId) {
    return getByIndex(r'tabId', [tabId]);
  }

  LocalSessionTab? getByTabIdSync(String tabId) {
    return getByIndexSync(r'tabId', [tabId]);
  }

  Future<bool> deleteByTabId(String tabId) {
    return deleteByIndex(r'tabId', [tabId]);
  }

  bool deleteByTabIdSync(String tabId) {
    return deleteByIndexSync(r'tabId', [tabId]);
  }

  Future<List<LocalSessionTab?>> getAllByTabId(List<String> tabIdValues) {
    final values = tabIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'tabId', values);
  }

  List<LocalSessionTab?> getAllByTabIdSync(List<String> tabIdValues) {
    final values = tabIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'tabId', values);
  }

  Future<int> deleteAllByTabId(List<String> tabIdValues) {
    final values = tabIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'tabId', values);
  }

  int deleteAllByTabIdSync(List<String> tabIdValues) {
    final values = tabIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'tabId', values);
  }

  Future<Id> putByTabId(LocalSessionTab object) {
    return putByIndex(r'tabId', object);
  }

  Id putByTabIdSync(LocalSessionTab object, {bool saveLinks = true}) {
    return putByIndexSync(r'tabId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByTabId(List<LocalSessionTab> objects) {
    return putAllByIndex(r'tabId', objects);
  }

  List<Id> putAllByTabIdSync(
    List<LocalSessionTab> objects, {
    bool saveLinks = true,
  }) {
    return putAllByIndexSync(r'tabId', objects, saveLinks: saveLinks);
  }
}

extension LocalSessionTabQueryWhereSort
    on QueryBuilder<LocalSessionTab, LocalSessionTab, QWhere> {
  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalSessionTabQueryWhere
    on QueryBuilder<LocalSessionTab, LocalSessionTab, QWhereClause> {
  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterWhereClause>
  idNotEqualTo(Id id) {
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

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterWhereClause>
  idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterWhereClause> idBetween(
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

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterWhereClause>
  tabIdEqualTo(String tabId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IndexWhereClause.equalTo(indexName: r'tabId', value: [tabId]),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterWhereClause>
  tabIdNotEqualTo(String tabId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tabId',
                lower: [],
                upper: [tabId],
                includeUpper: false,
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tabId',
                lower: [tabId],
                includeLower: false,
                upper: [],
              ),
            );
      } else {
        return query
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tabId',
                lower: [tabId],
                includeLower: false,
                upper: [],
              ),
            )
            .addWhereClause(
              IndexWhereClause.between(
                indexName: r'tabId',
                lower: [],
                upper: [tabId],
                includeUpper: false,
              ),
            );
      }
    });
  }
}

extension LocalSessionTabQueryFilter
    on QueryBuilder<LocalSessionTab, LocalSessionTab, QFilterCondition> {
  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'groupId'),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'groupId'),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'groupId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'groupId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'groupId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  groupIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'groupId', value: ''),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
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

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  idLessThan(Id value, {bool include = false}) {
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

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  idBetween(
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

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  isMutedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isMuted', value: value),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  isPinnedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'isPinned', value: value),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  positionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'position', value: value),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  positionGreaterThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'position',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  positionLessThan(int value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'position',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  positionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'position',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  tabIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'tabId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  tabIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'tabId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  tabIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'tabId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  tabIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'tabId',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  tabIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'tabId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  tabIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'tabId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  tabIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'tabId',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  tabIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'tabId',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  tabIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'tabId', value: ''),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  tabIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'tabId', value: ''),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'timestamp', value: value),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  timestampGreaterThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  timestampLessThan(DateTime value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'timestamp',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'timestamp',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'title'),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'title'),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'title',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'title',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'title',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'title', value: ''),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  urlEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  urlGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  urlLessThan(String value, {bool include = false, bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  urlBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'url',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  urlStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  urlEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  urlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'url',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  urlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'url',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  urlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  urlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'url', value: ''),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  zoomScaleEqualTo(double value, {double epsilon = Query.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'zoomScale',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  zoomScaleGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'zoomScale',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  zoomScaleLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'zoomScale',
          value: value,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterFilterCondition>
  zoomScaleBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'zoomScale',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,

          epsilon: epsilon,
        ),
      );
    });
  }
}

extension LocalSessionTabQueryObject
    on QueryBuilder<LocalSessionTab, LocalSessionTab, QFilterCondition> {}

extension LocalSessionTabQueryLinks
    on QueryBuilder<LocalSessionTab, LocalSessionTab, QFilterCondition> {}

extension LocalSessionTabQuerySortBy
    on QueryBuilder<LocalSessionTab, LocalSessionTab, QSortBy> {
  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> sortByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> sortByIsMuted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMuted', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByIsMutedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMuted', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> sortByTabId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabId', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByTabIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabId', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> sortByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> sortByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByZoomScale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zoomScale', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  sortByZoomScaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zoomScale', Sort.desc);
    });
  }
}

extension LocalSessionTabQuerySortThenBy
    on QueryBuilder<LocalSessionTab, LocalSessionTab, QSortThenBy> {
  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> thenByGroupId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByGroupIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'groupId', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> thenByIsMuted() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMuted', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByIsMutedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isMuted', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByIsPinnedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isPinned', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'position', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> thenByTabId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabId', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByTabIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tabId', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> thenByUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy> thenByUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'url', Sort.desc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByZoomScale() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zoomScale', Sort.asc);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QAfterSortBy>
  thenByZoomScaleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'zoomScale', Sort.desc);
    });
  }
}

extension LocalSessionTabQueryWhereDistinct
    on QueryBuilder<LocalSessionTab, LocalSessionTab, QDistinct> {
  QueryBuilder<LocalSessionTab, LocalSessionTab, QDistinct> distinctByGroupId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'groupId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QDistinct>
  distinctByIsMuted() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isMuted');
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QDistinct>
  distinctByIsPinned() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isPinned');
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QDistinct>
  distinctByPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'position');
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QDistinct> distinctByTabId({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tabId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QDistinct> distinctByUrl({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'url', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSessionTab, LocalSessionTab, QDistinct>
  distinctByZoomScale() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'zoomScale');
    });
  }
}

extension LocalSessionTabQueryProperty
    on QueryBuilder<LocalSessionTab, LocalSessionTab, QQueryProperty> {
  QueryBuilder<LocalSessionTab, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalSessionTab, String?, QQueryOperations> groupIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'groupId');
    });
  }

  QueryBuilder<LocalSessionTab, bool, QQueryOperations> isMutedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isMuted');
    });
  }

  QueryBuilder<LocalSessionTab, bool, QQueryOperations> isPinnedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isPinned');
    });
  }

  QueryBuilder<LocalSessionTab, int, QQueryOperations> positionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'position');
    });
  }

  QueryBuilder<LocalSessionTab, String, QQueryOperations> tabIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tabId');
    });
  }

  QueryBuilder<LocalSessionTab, DateTime, QQueryOperations>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<LocalSessionTab, String?, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<LocalSessionTab, String, QQueryOperations> urlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'url');
    });
  }

  QueryBuilder<LocalSessionTab, double, QQueryOperations> zoomScaleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'zoomScale');
    });
  }
}
