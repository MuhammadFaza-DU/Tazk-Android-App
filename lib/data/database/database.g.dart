// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TaskPriority, int> priority =
      GeneratedColumn<int>(
        'priority',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TaskPriority>($TasksTable.$converterpriority);
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    date,
    time,
    priority,
    isCompleted,
    location,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      ),
      priority: $TasksTable.$converterpriority.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}priority'],
        )!,
      ),
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TaskPriority, int, int> $converterpriority =
      const EnumIndexConverter<TaskPriority>(TaskPriority.values);
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final DateTime date;
  final DateTime? time;
  final TaskPriority priority;
  final bool isCompleted;
  final String? location;
  final DateTime createdAt;
  const Task({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    required this.priority,
    required this.isCompleted,
    this.location,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || time != null) {
      map['time'] = Variable<DateTime>(time);
    }
    {
      map['priority'] = Variable<int>(
        $TasksTable.$converterpriority.toSql(priority),
      );
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      date: Value(date),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      priority: Value(priority),
      isCompleted: Value(isCompleted),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      createdAt: Value(createdAt),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<DateTime>(json['date']),
      time: serializer.fromJson<DateTime?>(json['time']),
      priority: $TasksTable.$converterpriority.fromJson(
        serializer.fromJson<int>(json['priority']),
      ),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      location: serializer.fromJson<String?>(json['location']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<DateTime>(date),
      'time': serializer.toJson<DateTime?>(time),
      'priority': serializer.toJson<int>(
        $TasksTable.$converterpriority.toJson(priority),
      ),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'location': serializer.toJson<String?>(location),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    DateTime? date,
    Value<DateTime?> time = const Value.absent(),
    TaskPriority? priority,
    bool? isCompleted,
    Value<String?> location = const Value.absent(),
    DateTime? createdAt,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    date: date ?? this.date,
    time: time.present ? time.value : this.time,
    priority: priority ?? this.priority,
    isCompleted: isCompleted ?? this.isCompleted,
    location: location.present ? location.value : this.location,
    createdAt: createdAt ?? this.createdAt,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      time: data.time.present ? data.time.value : this.time,
      priority: data.priority.present ? data.priority.value : this.priority,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      location: data.location.present ? data.location.value : this.location,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('priority: $priority, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    date,
    time,
    priority,
    isCompleted,
    location,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.date == this.date &&
          other.time == this.time &&
          other.priority == this.priority &&
          other.isCompleted == this.isCompleted &&
          other.location == this.location &&
          other.createdAt == this.createdAt);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<DateTime> date;
  final Value<DateTime?> time;
  final Value<TaskPriority> priority;
  final Value<bool> isCompleted;
  final Value<String?> location;
  final Value<DateTime> createdAt;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.priority = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.location = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required DateTime date,
    this.time = const Value.absent(),
    required TaskPriority priority,
    this.isCompleted = const Value.absent(),
    this.location = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : title = Value(title),
       date = Value(date),
       priority = Value(priority);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? date,
    Expression<DateTime>? time,
    Expression<int>? priority,
    Expression<bool>? isCompleted,
    Expression<String>? location,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (priority != null) 'priority': priority,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (location != null) 'location': location,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<DateTime>? date,
    Value<DateTime?>? time,
    Value<TaskPriority>? priority,
    Value<bool>? isCompleted,
    Value<String?>? location,
    Value<DateTime>? createdAt,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(
        $TasksTable.$converterpriority.toSql(priority.value),
      );
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('priority: $priority, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SubtasksTable extends Subtasks with TableInfo<$SubtasksTable, Subtask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubtasksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, taskId, title, isCompleted];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subtasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subtask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subtask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subtask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $SubtasksTable createAlias(String alias) {
    return $SubtasksTable(attachedDatabase, alias);
  }
}

class Subtask extends DataClass implements Insertable<Subtask> {
  final int id;
  final int taskId;
  final String title;
  final bool isCompleted;
  const Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    required this.isCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['title'] = Variable<String>(title);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  SubtasksCompanion toCompanion(bool nullToAbsent) {
    return SubtasksCompanion(
      id: Value(id),
      taskId: Value(taskId),
      title: Value(title),
      isCompleted: Value(isCompleted),
    );
  }

  factory Subtask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subtask(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      title: serializer.fromJson<String>(json['title']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'title': serializer.toJson<String>(title),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  Subtask copyWith({int? id, int? taskId, String? title, bool? isCompleted}) =>
      Subtask(
        id: id ?? this.id,
        taskId: taskId ?? this.taskId,
        title: title ?? this.title,
        isCompleted: isCompleted ?? this.isCompleted,
      );
  Subtask copyWithCompanion(SubtasksCompanion data) {
    return Subtask(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      title: data.title.present ? data.title.value : this.title,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subtask(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, taskId, title, isCompleted);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subtask &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.title == this.title &&
          other.isCompleted == this.isCompleted);
}

class SubtasksCompanion extends UpdateCompanion<Subtask> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<String> title;
  final Value<bool> isCompleted;
  const SubtasksCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.title = const Value.absent(),
    this.isCompleted = const Value.absent(),
  });
  SubtasksCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required String title,
    this.isCompleted = const Value.absent(),
  }) : taskId = Value(taskId),
       title = Value(title);
  static Insertable<Subtask> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? title,
    Expression<bool>? isCompleted,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (title != null) 'title': title,
      if (isCompleted != null) 'is_completed': isCompleted,
    });
  }

  SubtasksCompanion copyWith({
    Value<int>? id,
    Value<int>? taskId,
    Value<String>? title,
    Value<bool>? isCompleted,
  }) {
    return SubtasksCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubtasksCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('title: $title, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<HabitFrequency, int> frequency =
      GeneratedColumn<int>(
        'frequency',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<HabitFrequency>($HabitsTable.$converterfrequency);
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledTime =
      GeneratedColumn<DateTime>(
        'scheduled_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _hasProgressMeta = const VerificationMeta(
    'hasProgress',
  );
  @override
  late final GeneratedColumn<bool> hasProgress = GeneratedColumn<bool>(
    'has_progress',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_progress" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _targetMinutesMeta = const VerificationMeta(
    'targetMinutes',
  );
  @override
  late final GeneratedColumn<int> targetMinutes = GeneratedColumn<int>(
    'target_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _customDaysOfWeekMeta = const VerificationMeta(
    'customDaysOfWeek',
  );
  @override
  late final GeneratedColumn<int> customDaysOfWeek = GeneratedColumn<int>(
    'custom_days_of_week',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customIntervalMeta = const VerificationMeta(
    'customInterval',
  );
  @override
  late final GeneratedColumn<int> customInterval = GeneratedColumn<int>(
    'custom_interval',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customDayOfMonthMeta = const VerificationMeta(
    'customDayOfMonth',
  );
  @override
  late final GeneratedColumn<int> customDayOfMonth = GeneratedColumn<int>(
    'custom_day_of_month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customFrequencyTypeMeta =
      const VerificationMeta('customFrequencyType');
  @override
  late final GeneratedColumn<int> customFrequencyType = GeneratedColumn<int>(
    'custom_frequency_type',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    frequency,
    scheduledTime,
    hasProgress,
    targetMinutes,
    isActive,
    createdAt,
    customDaysOfWeek,
    customInterval,
    customDayOfMonth,
    customFrequencyType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
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
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    }
    if (data.containsKey('has_progress')) {
      context.handle(
        _hasProgressMeta,
        hasProgress.isAcceptableOrUnknown(
          data['has_progress']!,
          _hasProgressMeta,
        ),
      );
    }
    if (data.containsKey('target_minutes')) {
      context.handle(
        _targetMinutesMeta,
        targetMinutes.isAcceptableOrUnknown(
          data['target_minutes']!,
          _targetMinutesMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('custom_days_of_week')) {
      context.handle(
        _customDaysOfWeekMeta,
        customDaysOfWeek.isAcceptableOrUnknown(
          data['custom_days_of_week']!,
          _customDaysOfWeekMeta,
        ),
      );
    }
    if (data.containsKey('custom_interval')) {
      context.handle(
        _customIntervalMeta,
        customInterval.isAcceptableOrUnknown(
          data['custom_interval']!,
          _customIntervalMeta,
        ),
      );
    }
    if (data.containsKey('custom_day_of_month')) {
      context.handle(
        _customDayOfMonthMeta,
        customDayOfMonth.isAcceptableOrUnknown(
          data['custom_day_of_month']!,
          _customDayOfMonthMeta,
        ),
      );
    }
    if (data.containsKey('custom_frequency_type')) {
      context.handle(
        _customFrequencyTypeMeta,
        customFrequencyType.isAcceptableOrUnknown(
          data['custom_frequency_type']!,
          _customFrequencyTypeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      frequency: $HabitsTable.$converterfrequency.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}frequency'],
        )!,
      ),
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_time'],
      ),
      hasProgress: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_progress'],
      )!,
      targetMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_minutes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      customDaysOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_days_of_week'],
      ),
      customInterval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_interval'],
      ),
      customDayOfMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_day_of_month'],
      ),
      customFrequencyType: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}custom_frequency_type'],
      ),
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HabitFrequency, int, int> $converterfrequency =
      const EnumIndexConverter<HabitFrequency>(HabitFrequency.values);
}

class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String name;
  final HabitFrequency frequency;
  final DateTime? scheduledTime;
  final bool hasProgress;
  final int? targetMinutes;
  final bool isActive;
  final DateTime createdAt;
  final int? customDaysOfWeek;
  final int? customInterval;
  final int? customDayOfMonth;
  final int? customFrequencyType;
  const Habit({
    required this.id,
    required this.name,
    required this.frequency,
    this.scheduledTime,
    required this.hasProgress,
    this.targetMinutes,
    required this.isActive,
    required this.createdAt,
    this.customDaysOfWeek,
    this.customInterval,
    this.customDayOfMonth,
    this.customFrequencyType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['frequency'] = Variable<int>(
        $HabitsTable.$converterfrequency.toSql(frequency),
      );
    }
    if (!nullToAbsent || scheduledTime != null) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime);
    }
    map['has_progress'] = Variable<bool>(hasProgress);
    if (!nullToAbsent || targetMinutes != null) {
      map['target_minutes'] = Variable<int>(targetMinutes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || customDaysOfWeek != null) {
      map['custom_days_of_week'] = Variable<int>(customDaysOfWeek);
    }
    if (!nullToAbsent || customInterval != null) {
      map['custom_interval'] = Variable<int>(customInterval);
    }
    if (!nullToAbsent || customDayOfMonth != null) {
      map['custom_day_of_month'] = Variable<int>(customDayOfMonth);
    }
    if (!nullToAbsent || customFrequencyType != null) {
      map['custom_frequency_type'] = Variable<int>(customFrequencyType);
    }
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      frequency: Value(frequency),
      scheduledTime: scheduledTime == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledTime),
      hasProgress: Value(hasProgress),
      targetMinutes: targetMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(targetMinutes),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      customDaysOfWeek: customDaysOfWeek == null && nullToAbsent
          ? const Value.absent()
          : Value(customDaysOfWeek),
      customInterval: customInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(customInterval),
      customDayOfMonth: customDayOfMonth == null && nullToAbsent
          ? const Value.absent()
          : Value(customDayOfMonth),
      customFrequencyType: customFrequencyType == null && nullToAbsent
          ? const Value.absent()
          : Value(customFrequencyType),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      frequency: $HabitsTable.$converterfrequency.fromJson(
        serializer.fromJson<int>(json['frequency']),
      ),
      scheduledTime: serializer.fromJson<DateTime?>(json['scheduledTime']),
      hasProgress: serializer.fromJson<bool>(json['hasProgress']),
      targetMinutes: serializer.fromJson<int?>(json['targetMinutes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      customDaysOfWeek: serializer.fromJson<int?>(json['customDaysOfWeek']),
      customInterval: serializer.fromJson<int?>(json['customInterval']),
      customDayOfMonth: serializer.fromJson<int?>(json['customDayOfMonth']),
      customFrequencyType: serializer.fromJson<int?>(
        json['customFrequencyType'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'frequency': serializer.toJson<int>(
        $HabitsTable.$converterfrequency.toJson(frequency),
      ),
      'scheduledTime': serializer.toJson<DateTime?>(scheduledTime),
      'hasProgress': serializer.toJson<bool>(hasProgress),
      'targetMinutes': serializer.toJson<int?>(targetMinutes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'customDaysOfWeek': serializer.toJson<int?>(customDaysOfWeek),
      'customInterval': serializer.toJson<int?>(customInterval),
      'customDayOfMonth': serializer.toJson<int?>(customDayOfMonth),
      'customFrequencyType': serializer.toJson<int?>(customFrequencyType),
    };
  }

  Habit copyWith({
    int? id,
    String? name,
    HabitFrequency? frequency,
    Value<DateTime?> scheduledTime = const Value.absent(),
    bool? hasProgress,
    Value<int?> targetMinutes = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    Value<int?> customDaysOfWeek = const Value.absent(),
    Value<int?> customInterval = const Value.absent(),
    Value<int?> customDayOfMonth = const Value.absent(),
    Value<int?> customFrequencyType = const Value.absent(),
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    frequency: frequency ?? this.frequency,
    scheduledTime: scheduledTime.present
        ? scheduledTime.value
        : this.scheduledTime,
    hasProgress: hasProgress ?? this.hasProgress,
    targetMinutes: targetMinutes.present
        ? targetMinutes.value
        : this.targetMinutes,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    customDaysOfWeek: customDaysOfWeek.present
        ? customDaysOfWeek.value
        : this.customDaysOfWeek,
    customInterval: customInterval.present
        ? customInterval.value
        : this.customInterval,
    customDayOfMonth: customDayOfMonth.present
        ? customDayOfMonth.value
        : this.customDayOfMonth,
    customFrequencyType: customFrequencyType.present
        ? customFrequencyType.value
        : this.customFrequencyType,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      hasProgress: data.hasProgress.present
          ? data.hasProgress.value
          : this.hasProgress,
      targetMinutes: data.targetMinutes.present
          ? data.targetMinutes.value
          : this.targetMinutes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      customDaysOfWeek: data.customDaysOfWeek.present
          ? data.customDaysOfWeek.value
          : this.customDaysOfWeek,
      customInterval: data.customInterval.present
          ? data.customInterval.value
          : this.customInterval,
      customDayOfMonth: data.customDayOfMonth.present
          ? data.customDayOfMonth.value
          : this.customDayOfMonth,
      customFrequencyType: data.customFrequencyType.present
          ? data.customFrequencyType.value
          : this.customFrequencyType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('frequency: $frequency, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('hasProgress: $hasProgress, ')
          ..write('targetMinutes: $targetMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('customDaysOfWeek: $customDaysOfWeek, ')
          ..write('customInterval: $customInterval, ')
          ..write('customDayOfMonth: $customDayOfMonth, ')
          ..write('customFrequencyType: $customFrequencyType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    frequency,
    scheduledTime,
    hasProgress,
    targetMinutes,
    isActive,
    createdAt,
    customDaysOfWeek,
    customInterval,
    customDayOfMonth,
    customFrequencyType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.frequency == this.frequency &&
          other.scheduledTime == this.scheduledTime &&
          other.hasProgress == this.hasProgress &&
          other.targetMinutes == this.targetMinutes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.customDaysOfWeek == this.customDaysOfWeek &&
          other.customInterval == this.customInterval &&
          other.customDayOfMonth == this.customDayOfMonth &&
          other.customFrequencyType == this.customFrequencyType);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<String> name;
  final Value<HabitFrequency> frequency;
  final Value<DateTime?> scheduledTime;
  final Value<bool> hasProgress;
  final Value<int?> targetMinutes;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int?> customDaysOfWeek;
  final Value<int?> customInterval;
  final Value<int?> customDayOfMonth;
  final Value<int?> customFrequencyType;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.frequency = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.hasProgress = const Value.absent(),
    this.targetMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.customDaysOfWeek = const Value.absent(),
    this.customInterval = const Value.absent(),
    this.customDayOfMonth = const Value.absent(),
    this.customFrequencyType = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required HabitFrequency frequency,
    this.scheduledTime = const Value.absent(),
    this.hasProgress = const Value.absent(),
    this.targetMinutes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.customDaysOfWeek = const Value.absent(),
    this.customInterval = const Value.absent(),
    this.customDayOfMonth = const Value.absent(),
    this.customFrequencyType = const Value.absent(),
  }) : name = Value(name),
       frequency = Value(frequency);
  static Insertable<Habit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? frequency,
    Expression<DateTime>? scheduledTime,
    Expression<bool>? hasProgress,
    Expression<int>? targetMinutes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? customDaysOfWeek,
    Expression<int>? customInterval,
    Expression<int>? customDayOfMonth,
    Expression<int>? customFrequencyType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (frequency != null) 'frequency': frequency,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (hasProgress != null) 'has_progress': hasProgress,
      if (targetMinutes != null) 'target_minutes': targetMinutes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (customDaysOfWeek != null) 'custom_days_of_week': customDaysOfWeek,
      if (customInterval != null) 'custom_interval': customInterval,
      if (customDayOfMonth != null) 'custom_day_of_month': customDayOfMonth,
      if (customFrequencyType != null)
        'custom_frequency_type': customFrequencyType,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<HabitFrequency>? frequency,
    Value<DateTime?>? scheduledTime,
    Value<bool>? hasProgress,
    Value<int?>? targetMinutes,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int?>? customDaysOfWeek,
    Value<int?>? customInterval,
    Value<int?>? customDayOfMonth,
    Value<int?>? customFrequencyType,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      hasProgress: hasProgress ?? this.hasProgress,
      targetMinutes: targetMinutes ?? this.targetMinutes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      customDaysOfWeek: customDaysOfWeek ?? this.customDaysOfWeek,
      customInterval: customInterval ?? this.customInterval,
      customDayOfMonth: customDayOfMonth ?? this.customDayOfMonth,
      customFrequencyType: customFrequencyType ?? this.customFrequencyType,
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
    if (frequency.present) {
      map['frequency'] = Variable<int>(
        $HabitsTable.$converterfrequency.toSql(frequency.value),
      );
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<DateTime>(scheduledTime.value);
    }
    if (hasProgress.present) {
      map['has_progress'] = Variable<bool>(hasProgress.value);
    }
    if (targetMinutes.present) {
      map['target_minutes'] = Variable<int>(targetMinutes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (customDaysOfWeek.present) {
      map['custom_days_of_week'] = Variable<int>(customDaysOfWeek.value);
    }
    if (customInterval.present) {
      map['custom_interval'] = Variable<int>(customInterval.value);
    }
    if (customDayOfMonth.present) {
      map['custom_day_of_month'] = Variable<int>(customDayOfMonth.value);
    }
    if (customFrequencyType.present) {
      map['custom_frequency_type'] = Variable<int>(customFrequencyType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('frequency: $frequency, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('hasProgress: $hasProgress, ')
          ..write('targetMinutes: $targetMinutes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('customDaysOfWeek: $customDaysOfWeek, ')
          ..write('customInterval: $customInterval, ')
          ..write('customDayOfMonth: $customDayOfMonth, ')
          ..write('customFrequencyType: $customFrequencyType')
          ..write(')'))
        .toString();
  }
}

class $HabitLogsTable extends HabitLogs
    with TableInfo<$HabitLogsTable, HabitLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _progressMinutesMeta = const VerificationMeta(
    'progressMinutes',
  );
  @override
  late final GeneratedColumn<int> progressMinutes = GeneratedColumn<int>(
    'progress_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    date,
    isCompleted,
    progressMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('progress_minutes')) {
      context.handle(
        _progressMinutesMeta,
        progressMinutes.isAcceptableOrUnknown(
          data['progress_minutes']!,
          _progressMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, date},
  ];
  @override
  HabitLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      progressMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}progress_minutes'],
      )!,
    );
  }

  @override
  $HabitLogsTable createAlias(String alias) {
    return $HabitLogsTable(attachedDatabase, alias);
  }
}

class HabitLog extends DataClass implements Insertable<HabitLog> {
  final int id;
  final int habitId;
  final DateTime date;
  final bool isCompleted;
  final int progressMinutes;
  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.isCompleted,
    required this.progressMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['date'] = Variable<DateTime>(date);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['progress_minutes'] = Variable<int>(progressMinutes);
    return map;
  }

  HabitLogsCompanion toCompanion(bool nullToAbsent) {
    return HabitLogsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      date: Value(date),
      isCompleted: Value(isCompleted),
      progressMinutes: Value(progressMinutes),
    );
  }

  factory HabitLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitLog(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      date: serializer.fromJson<DateTime>(json['date']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      progressMinutes: serializer.fromJson<int>(json['progressMinutes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'date': serializer.toJson<DateTime>(date),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'progressMinutes': serializer.toJson<int>(progressMinutes),
    };
  }

  HabitLog copyWith({
    int? id,
    int? habitId,
    DateTime? date,
    bool? isCompleted,
    int? progressMinutes,
  }) => HabitLog(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    date: date ?? this.date,
    isCompleted: isCompleted ?? this.isCompleted,
    progressMinutes: progressMinutes ?? this.progressMinutes,
  );
  HabitLog copyWithCompanion(HabitLogsCompanion data) {
    return HabitLog(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      date: data.date.present ? data.date.value : this.date,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      progressMinutes: data.progressMinutes.present
          ? data.progressMinutes.value
          : this.progressMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitLog(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('progressMinutes: $progressMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, habitId, date, isCompleted, progressMinutes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitLog &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.date == this.date &&
          other.isCompleted == this.isCompleted &&
          other.progressMinutes == this.progressMinutes);
}

class HabitLogsCompanion extends UpdateCompanion<HabitLog> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<DateTime> date;
  final Value<bool> isCompleted;
  final Value<int> progressMinutes;
  const HabitLogsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.date = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.progressMinutes = const Value.absent(),
  });
  HabitLogsCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required DateTime date,
    this.isCompleted = const Value.absent(),
    this.progressMinutes = const Value.absent(),
  }) : habitId = Value(habitId),
       date = Value(date);
  static Insertable<HabitLog> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<DateTime>? date,
    Expression<bool>? isCompleted,
    Expression<int>? progressMinutes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (date != null) 'date': date,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (progressMinutes != null) 'progress_minutes': progressMinutes,
    });
  }

  HabitLogsCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<DateTime>? date,
    Value<bool>? isCompleted,
    Value<int>? progressMinutes,
  }) {
    return HabitLogsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
      progressMinutes: progressMinutes ?? this.progressMinutes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (progressMinutes.present) {
      map['progress_minutes'] = Variable<int>(progressMinutes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitLogsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('progressMinutes: $progressMinutes')
          ..write(')'))
        .toString();
  }
}

class $StreakStateTable extends StreakState
    with TableInfo<$StreakStateTable, StreakStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StreakStateTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _currentStreakMeta = const VerificationMeta(
    'currentStreak',
  );
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
    'current_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestStreakMeta = const VerificationMeta(
    'longestStreak',
  );
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
    'longest_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _freezeCountMeta = const VerificationMeta(
    'freezeCount',
  );
  @override
  late final GeneratedColumn<int> freezeCount = GeneratedColumn<int>(
    'freeze_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _freezeProgressDaysMeta =
      const VerificationMeta('freezeProgressDays');
  @override
  late final GeneratedColumn<int> freezeProgressDays = GeneratedColumn<int>(
    'freeze_progress_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastActiveDateMeta = const VerificationMeta(
    'lastActiveDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastActiveDate =
      GeneratedColumn<DateTime>(
        'last_active_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currentStreak,
    longestStreak,
    freezeCount,
    freezeProgressDays,
    lastActiveDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streak_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<StreakStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('current_streak')) {
      context.handle(
        _currentStreakMeta,
        currentStreak.isAcceptableOrUnknown(
          data['current_streak']!,
          _currentStreakMeta,
        ),
      );
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
        _longestStreakMeta,
        longestStreak.isAcceptableOrUnknown(
          data['longest_streak']!,
          _longestStreakMeta,
        ),
      );
    }
    if (data.containsKey('freeze_count')) {
      context.handle(
        _freezeCountMeta,
        freezeCount.isAcceptableOrUnknown(
          data['freeze_count']!,
          _freezeCountMeta,
        ),
      );
    }
    if (data.containsKey('freeze_progress_days')) {
      context.handle(
        _freezeProgressDaysMeta,
        freezeProgressDays.isAcceptableOrUnknown(
          data['freeze_progress_days']!,
          _freezeProgressDaysMeta,
        ),
      );
    }
    if (data.containsKey('last_active_date')) {
      context.handle(
        _lastActiveDateMeta,
        lastActiveDate.isAcceptableOrUnknown(
          data['last_active_date']!,
          _lastActiveDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StreakStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StreakStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currentStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_streak'],
      )!,
      longestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak'],
      )!,
      freezeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}freeze_count'],
      )!,
      freezeProgressDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}freeze_progress_days'],
      )!,
      lastActiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_active_date'],
      ),
    );
  }

  @override
  $StreakStateTable createAlias(String alias) {
    return $StreakStateTable(attachedDatabase, alias);
  }
}

class StreakStateData extends DataClass implements Insertable<StreakStateData> {
  final int id;
  final int currentStreak;
  final int longestStreak;
  final int freezeCount;
  final int freezeProgressDays;
  final DateTime? lastActiveDate;
  const StreakStateData({
    required this.id,
    required this.currentStreak,
    required this.longestStreak,
    required this.freezeCount,
    required this.freezeProgressDays,
    this.lastActiveDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    map['freeze_count'] = Variable<int>(freezeCount);
    map['freeze_progress_days'] = Variable<int>(freezeProgressDays);
    if (!nullToAbsent || lastActiveDate != null) {
      map['last_active_date'] = Variable<DateTime>(lastActiveDate);
    }
    return map;
  }

  StreakStateCompanion toCompanion(bool nullToAbsent) {
    return StreakStateCompanion(
      id: Value(id),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      freezeCount: Value(freezeCount),
      freezeProgressDays: Value(freezeProgressDays),
      lastActiveDate: lastActiveDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveDate),
    );
  }

  factory StreakStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StreakStateData(
      id: serializer.fromJson<int>(json['id']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      freezeCount: serializer.fromJson<int>(json['freezeCount']),
      freezeProgressDays: serializer.fromJson<int>(json['freezeProgressDays']),
      lastActiveDate: serializer.fromJson<DateTime?>(json['lastActiveDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'freezeCount': serializer.toJson<int>(freezeCount),
      'freezeProgressDays': serializer.toJson<int>(freezeProgressDays),
      'lastActiveDate': serializer.toJson<DateTime?>(lastActiveDate),
    };
  }

  StreakStateData copyWith({
    int? id,
    int? currentStreak,
    int? longestStreak,
    int? freezeCount,
    int? freezeProgressDays,
    Value<DateTime?> lastActiveDate = const Value.absent(),
  }) => StreakStateData(
    id: id ?? this.id,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    freezeCount: freezeCount ?? this.freezeCount,
    freezeProgressDays: freezeProgressDays ?? this.freezeProgressDays,
    lastActiveDate: lastActiveDate.present
        ? lastActiveDate.value
        : this.lastActiveDate,
  );
  StreakStateData copyWithCompanion(StreakStateCompanion data) {
    return StreakStateData(
      id: data.id.present ? data.id.value : this.id,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      freezeCount: data.freezeCount.present
          ? data.freezeCount.value
          : this.freezeCount,
      freezeProgressDays: data.freezeProgressDays.present
          ? data.freezeProgressDays.value
          : this.freezeProgressDays,
      lastActiveDate: data.lastActiveDate.present
          ? data.lastActiveDate.value
          : this.lastActiveDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StreakStateData(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('freezeCount: $freezeCount, ')
          ..write('freezeProgressDays: $freezeProgressDays, ')
          ..write('lastActiveDate: $lastActiveDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    currentStreak,
    longestStreak,
    freezeCount,
    freezeProgressDays,
    lastActiveDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StreakStateData &&
          other.id == this.id &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.freezeCount == this.freezeCount &&
          other.freezeProgressDays == this.freezeProgressDays &&
          other.lastActiveDate == this.lastActiveDate);
}

class StreakStateCompanion extends UpdateCompanion<StreakStateData> {
  final Value<int> id;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<int> freezeCount;
  final Value<int> freezeProgressDays;
  final Value<DateTime?> lastActiveDate;
  const StreakStateCompanion({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.freezeCount = const Value.absent(),
    this.freezeProgressDays = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
  });
  StreakStateCompanion.insert({
    this.id = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.freezeCount = const Value.absent(),
    this.freezeProgressDays = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
  });
  static Insertable<StreakStateData> custom({
    Expression<int>? id,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<int>? freezeCount,
    Expression<int>? freezeProgressDays,
    Expression<DateTime>? lastActiveDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (freezeCount != null) 'freeze_count': freezeCount,
      if (freezeProgressDays != null)
        'freeze_progress_days': freezeProgressDays,
      if (lastActiveDate != null) 'last_active_date': lastActiveDate,
    });
  }

  StreakStateCompanion copyWith({
    Value<int>? id,
    Value<int>? currentStreak,
    Value<int>? longestStreak,
    Value<int>? freezeCount,
    Value<int>? freezeProgressDays,
    Value<DateTime?>? lastActiveDate,
  }) {
    return StreakStateCompanion(
      id: id ?? this.id,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      freezeCount: freezeCount ?? this.freezeCount,
      freezeProgressDays: freezeProgressDays ?? this.freezeProgressDays,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (freezeCount.present) {
      map['freeze_count'] = Variable<int>(freezeCount.value);
    }
    if (freezeProgressDays.present) {
      map['freeze_progress_days'] = Variable<int>(freezeProgressDays.value);
    }
    if (lastActiveDate.present) {
      map['last_active_date'] = Variable<DateTime>(lastActiveDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreakStateCompanion(')
          ..write('id: $id, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('freezeCount: $freezeCount, ')
          ..write('freezeProgressDays: $freezeProgressDays, ')
          ..write('lastActiveDate: $lastActiveDate')
          ..write(')'))
        .toString();
  }
}

class $BadgeUnlocksTable extends BadgeUnlocks
    with TableInfo<$BadgeUnlocksTable, BadgeUnlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BadgeUnlocksTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<StreakRank, int> rank =
      GeneratedColumn<int>(
        'rank',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<StreakRank>($BadgeUnlocksTable.$converterrank);
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  @override
  late final GeneratedColumn<DateTime> unlockedAt = GeneratedColumn<DateTime>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, rank, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'badge_unlocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<BadgeUnlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {rank},
  ];
  @override
  BadgeUnlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BadgeUnlock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rank: $BadgeUnlocksTable.$converterrank.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}rank'],
        )!,
      ),
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $BadgeUnlocksTable createAlias(String alias) {
    return $BadgeUnlocksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<StreakRank, int, int> $converterrank =
      const EnumIndexConverter<StreakRank>(StreakRank.values);
}

class BadgeUnlock extends DataClass implements Insertable<BadgeUnlock> {
  final int id;
  final StreakRank rank;
  final DateTime unlockedAt;
  const BadgeUnlock({
    required this.id,
    required this.rank,
    required this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['rank'] = Variable<int>(
        $BadgeUnlocksTable.$converterrank.toSql(rank),
      );
    }
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  BadgeUnlocksCompanion toCompanion(bool nullToAbsent) {
    return BadgeUnlocksCompanion(
      id: Value(id),
      rank: Value(rank),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory BadgeUnlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BadgeUnlock(
      id: serializer.fromJson<int>(json['id']),
      rank: $BadgeUnlocksTable.$converterrank.fromJson(
        serializer.fromJson<int>(json['rank']),
      ),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rank': serializer.toJson<int>(
        $BadgeUnlocksTable.$converterrank.toJson(rank),
      ),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  BadgeUnlock copyWith({int? id, StreakRank? rank, DateTime? unlockedAt}) =>
      BadgeUnlock(
        id: id ?? this.id,
        rank: rank ?? this.rank,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
  BadgeUnlock copyWithCompanion(BadgeUnlocksCompanion data) {
    return BadgeUnlock(
      id: data.id.present ? data.id.value : this.id,
      rank: data.rank.present ? data.rank.value : this.rank,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BadgeUnlock(')
          ..write('id: $id, ')
          ..write('rank: $rank, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rank, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BadgeUnlock &&
          other.id == this.id &&
          other.rank == this.rank &&
          other.unlockedAt == this.unlockedAt);
}

class BadgeUnlocksCompanion extends UpdateCompanion<BadgeUnlock> {
  final Value<int> id;
  final Value<StreakRank> rank;
  final Value<DateTime> unlockedAt;
  const BadgeUnlocksCompanion({
    this.id = const Value.absent(),
    this.rank = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  });
  BadgeUnlocksCompanion.insert({
    this.id = const Value.absent(),
    required StreakRank rank,
    this.unlockedAt = const Value.absent(),
  }) : rank = Value(rank);
  static Insertable<BadgeUnlock> custom({
    Expression<int>? id,
    Expression<int>? rank,
    Expression<DateTime>? unlockedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rank != null) 'rank': rank,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
    });
  }

  BadgeUnlocksCompanion copyWith({
    Value<int>? id,
    Value<StreakRank>? rank,
    Value<DateTime>? unlockedAt,
  }) {
    return BadgeUnlocksCompanion(
      id: id ?? this.id,
      rank: rank ?? this.rank,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rank.present) {
      map['rank'] = Variable<int>(
        $BadgeUnlocksTable.$converterrank.toSql(rank.value),
      );
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BadgeUnlocksCompanion(')
          ..write('id: $id, ')
          ..write('rank: $rank, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }
}

class $UserProfileTable extends UserProfile
    with TableInfo<$UserProfileTable, UserProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _avatarIdMeta = const VerificationMeta(
    'avatarId',
  );
  @override
  late final GeneratedColumn<String> avatarId = GeneratedColumn<String>(
    'avatar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('default'),
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, avatarId, xp, level];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileData> instance, {
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
    }
    if (data.containsKey('avatar_id')) {
      context.handle(
        _avatarIdMeta,
        avatarId.isAcceptableOrUnknown(data['avatar_id']!, _avatarIdMeta),
      );
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      avatarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_id'],
      )!,
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
    );
  }

  @override
  $UserProfileTable createAlias(String alias) {
    return $UserProfileTable(attachedDatabase, alias);
  }
}

class UserProfileData extends DataClass implements Insertable<UserProfileData> {
  final int id;
  final String name;
  final String avatarId;
  final int xp;
  final int level;
  const UserProfileData({
    required this.id,
    required this.name,
    required this.avatarId,
    required this.xp,
    required this.level,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['avatar_id'] = Variable<String>(avatarId);
    map['xp'] = Variable<int>(xp);
    map['level'] = Variable<int>(level);
    return map;
  }

  UserProfileCompanion toCompanion(bool nullToAbsent) {
    return UserProfileCompanion(
      id: Value(id),
      name: Value(name),
      avatarId: Value(avatarId),
      xp: Value(xp),
      level: Value(level),
    );
  }

  factory UserProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      avatarId: serializer.fromJson<String>(json['avatarId']),
      xp: serializer.fromJson<int>(json['xp']),
      level: serializer.fromJson<int>(json['level']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'avatarId': serializer.toJson<String>(avatarId),
      'xp': serializer.toJson<int>(xp),
      'level': serializer.toJson<int>(level),
    };
  }

  UserProfileData copyWith({
    int? id,
    String? name,
    String? avatarId,
    int? xp,
    int? level,
  }) => UserProfileData(
    id: id ?? this.id,
    name: name ?? this.name,
    avatarId: avatarId ?? this.avatarId,
    xp: xp ?? this.xp,
    level: level ?? this.level,
  );
  UserProfileData copyWithCompanion(UserProfileCompanion data) {
    return UserProfileData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      avatarId: data.avatarId.present ? data.avatarId.value : this.avatarId,
      xp: data.xp.present ? data.xp.value : this.xp,
      level: data.level.present ? data.level.value : this.level,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarId: $avatarId, ')
          ..write('xp: $xp, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, avatarId, xp, level);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileData &&
          other.id == this.id &&
          other.name == this.name &&
          other.avatarId == this.avatarId &&
          other.xp == this.xp &&
          other.level == this.level);
}

class UserProfileCompanion extends UpdateCompanion<UserProfileData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> avatarId;
  final Value<int> xp;
  final Value<int> level;
  const UserProfileCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarId = const Value.absent(),
    this.xp = const Value.absent(),
    this.level = const Value.absent(),
  });
  UserProfileCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.avatarId = const Value.absent(),
    this.xp = const Value.absent(),
    this.level = const Value.absent(),
  });
  static Insertable<UserProfileData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? avatarId,
    Expression<int>? xp,
    Expression<int>? level,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (avatarId != null) 'avatar_id': avatarId,
      if (xp != null) 'xp': xp,
      if (level != null) 'level': level,
    });
  }

  UserProfileCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? avatarId,
    Value<int>? xp,
    Value<int>? level,
  }) {
    return UserProfileCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarId: avatarId ?? this.avatarId,
      xp: xp ?? this.xp,
      level: level ?? this.level,
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
    if (avatarId.present) {
      map['avatar_id'] = Variable<String>(avatarId.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('avatarId: $avatarId, ')
          ..write('xp: $xp, ')
          ..write('level: $level')
          ..write(')'))
        .toString();
  }
}

class $CosmeticUnlocksTable extends CosmeticUnlocks
    with TableInfo<$CosmeticUnlocksTable, CosmeticUnlock> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CosmeticUnlocksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _levelMilestoneMeta = const VerificationMeta(
    'levelMilestone',
  );
  @override
  late final GeneratedColumn<int> levelMilestone = GeneratedColumn<int>(
    'level_milestone',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [id, levelMilestone, unlockedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cosmetic_unlocks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CosmeticUnlock> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('level_milestone')) {
      context.handle(
        _levelMilestoneMeta,
        levelMilestone.isAcceptableOrUnknown(
          data['level_milestone']!,
          _levelMilestoneMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_levelMilestoneMeta);
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {levelMilestone},
  ];
  @override
  CosmeticUnlock map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CosmeticUnlock(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      levelMilestone: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level_milestone'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}unlocked_at'],
      )!,
    );
  }

  @override
  $CosmeticUnlocksTable createAlias(String alias) {
    return $CosmeticUnlocksTable(attachedDatabase, alias);
  }
}

class CosmeticUnlock extends DataClass implements Insertable<CosmeticUnlock> {
  final int id;
  final int levelMilestone;
  final DateTime unlockedAt;
  const CosmeticUnlock({
    required this.id,
    required this.levelMilestone,
    required this.unlockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['level_milestone'] = Variable<int>(levelMilestone);
    map['unlocked_at'] = Variable<DateTime>(unlockedAt);
    return map;
  }

  CosmeticUnlocksCompanion toCompanion(bool nullToAbsent) {
    return CosmeticUnlocksCompanion(
      id: Value(id),
      levelMilestone: Value(levelMilestone),
      unlockedAt: Value(unlockedAt),
    );
  }

  factory CosmeticUnlock.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CosmeticUnlock(
      id: serializer.fromJson<int>(json['id']),
      levelMilestone: serializer.fromJson<int>(json['levelMilestone']),
      unlockedAt: serializer.fromJson<DateTime>(json['unlockedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'levelMilestone': serializer.toJson<int>(levelMilestone),
      'unlockedAt': serializer.toJson<DateTime>(unlockedAt),
    };
  }

  CosmeticUnlock copyWith({
    int? id,
    int? levelMilestone,
    DateTime? unlockedAt,
  }) => CosmeticUnlock(
    id: id ?? this.id,
    levelMilestone: levelMilestone ?? this.levelMilestone,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );
  CosmeticUnlock copyWithCompanion(CosmeticUnlocksCompanion data) {
    return CosmeticUnlock(
      id: data.id.present ? data.id.value : this.id,
      levelMilestone: data.levelMilestone.present
          ? data.levelMilestone.value
          : this.levelMilestone,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CosmeticUnlock(')
          ..write('id: $id, ')
          ..write('levelMilestone: $levelMilestone, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, levelMilestone, unlockedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CosmeticUnlock &&
          other.id == this.id &&
          other.levelMilestone == this.levelMilestone &&
          other.unlockedAt == this.unlockedAt);
}

class CosmeticUnlocksCompanion extends UpdateCompanion<CosmeticUnlock> {
  final Value<int> id;
  final Value<int> levelMilestone;
  final Value<DateTime> unlockedAt;
  const CosmeticUnlocksCompanion({
    this.id = const Value.absent(),
    this.levelMilestone = const Value.absent(),
    this.unlockedAt = const Value.absent(),
  });
  CosmeticUnlocksCompanion.insert({
    this.id = const Value.absent(),
    required int levelMilestone,
    this.unlockedAt = const Value.absent(),
  }) : levelMilestone = Value(levelMilestone);
  static Insertable<CosmeticUnlock> custom({
    Expression<int>? id,
    Expression<int>? levelMilestone,
    Expression<DateTime>? unlockedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (levelMilestone != null) 'level_milestone': levelMilestone,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
    });
  }

  CosmeticUnlocksCompanion copyWith({
    Value<int>? id,
    Value<int>? levelMilestone,
    Value<DateTime>? unlockedAt,
  }) {
    return CosmeticUnlocksCompanion(
      id: id ?? this.id,
      levelMilestone: levelMilestone ?? this.levelMilestone,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (levelMilestone.present) {
      map['level_milestone'] = Variable<int>(levelMilestone.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<DateTime>(unlockedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CosmeticUnlocksCompanion(')
          ..write('id: $id, ')
          ..write('levelMilestone: $levelMilestone, ')
          ..write('unlockedAt: $unlockedAt')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<AppThemeMode, int> themeMode =
      GeneratedColumn<int>(
        'theme_mode',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<AppThemeMode>($AppSettingsTable.$converterthemeMode);
  @override
  late final GeneratedColumnWithTypeConverter<AppLanguage, int> language =
      GeneratedColumn<int>(
        'language',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<AppLanguage>($AppSettingsTable.$converterlanguage);
  static const VerificationMeta _notifyTasksMeta = const VerificationMeta(
    'notifyTasks',
  );
  @override
  late final GeneratedColumn<bool> notifyTasks = GeneratedColumn<bool>(
    'notify_tasks',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_tasks" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyHabitsMeta = const VerificationMeta(
    'notifyHabits',
  );
  @override
  late final GeneratedColumn<bool> notifyHabits = GeneratedColumn<bool>(
    'notify_habits',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_habits" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyStreakWarningMeta =
      const VerificationMeta('notifyStreakWarning');
  @override
  late final GeneratedColumn<bool> notifyStreakWarning = GeneratedColumn<bool>(
    'notify_streak_warning',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_streak_warning" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notifyFreezeUsedMeta = const VerificationMeta(
    'notifyFreezeUsed',
  );
  @override
  late final GeneratedColumn<bool> notifyFreezeUsed = GeneratedColumn<bool>(
    'notify_freeze_used',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notify_freeze_used" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    language,
    notifyTasks,
    notifyHabits,
    notifyStreakWarning,
    notifyFreezeUsed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('notify_tasks')) {
      context.handle(
        _notifyTasksMeta,
        notifyTasks.isAcceptableOrUnknown(
          data['notify_tasks']!,
          _notifyTasksMeta,
        ),
      );
    }
    if (data.containsKey('notify_habits')) {
      context.handle(
        _notifyHabitsMeta,
        notifyHabits.isAcceptableOrUnknown(
          data['notify_habits']!,
          _notifyHabitsMeta,
        ),
      );
    }
    if (data.containsKey('notify_streak_warning')) {
      context.handle(
        _notifyStreakWarningMeta,
        notifyStreakWarning.isAcceptableOrUnknown(
          data['notify_streak_warning']!,
          _notifyStreakWarningMeta,
        ),
      );
    }
    if (data.containsKey('notify_freeze_used')) {
      context.handle(
        _notifyFreezeUsedMeta,
        notifyFreezeUsed.isAcceptableOrUnknown(
          data['notify_freeze_used']!,
          _notifyFreezeUsedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      themeMode: $AppSettingsTable.$converterthemeMode.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}theme_mode'],
        )!,
      ),
      language: $AppSettingsTable.$converterlanguage.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}language'],
        )!,
      ),
      notifyTasks: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_tasks'],
      )!,
      notifyHabits: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_habits'],
      )!,
      notifyStreakWarning: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_streak_warning'],
      )!,
      notifyFreezeUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notify_freeze_used'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AppThemeMode, int, int> $converterthemeMode =
      const EnumIndexConverter<AppThemeMode>(AppThemeMode.values);
  static JsonTypeConverter2<AppLanguage, int, int> $converterlanguage =
      const EnumIndexConverter<AppLanguage>(AppLanguage.values);
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final int id;
  final AppThemeMode themeMode;
  final AppLanguage language;
  final bool notifyTasks;
  final bool notifyHabits;
  final bool notifyStreakWarning;
  final bool notifyFreezeUsed;
  const AppSetting({
    required this.id,
    required this.themeMode,
    required this.language,
    required this.notifyTasks,
    required this.notifyHabits,
    required this.notifyStreakWarning,
    required this.notifyFreezeUsed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['theme_mode'] = Variable<int>(
        $AppSettingsTable.$converterthemeMode.toSql(themeMode),
      );
    }
    {
      map['language'] = Variable<int>(
        $AppSettingsTable.$converterlanguage.toSql(language),
      );
    }
    map['notify_tasks'] = Variable<bool>(notifyTasks);
    map['notify_habits'] = Variable<bool>(notifyHabits);
    map['notify_streak_warning'] = Variable<bool>(notifyStreakWarning);
    map['notify_freeze_used'] = Variable<bool>(notifyFreezeUsed);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      language: Value(language),
      notifyTasks: Value(notifyTasks),
      notifyHabits: Value(notifyHabits),
      notifyStreakWarning: Value(notifyStreakWarning),
      notifyFreezeUsed: Value(notifyFreezeUsed),
    );
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      id: serializer.fromJson<int>(json['id']),
      themeMode: $AppSettingsTable.$converterthemeMode.fromJson(
        serializer.fromJson<int>(json['themeMode']),
      ),
      language: $AppSettingsTable.$converterlanguage.fromJson(
        serializer.fromJson<int>(json['language']),
      ),
      notifyTasks: serializer.fromJson<bool>(json['notifyTasks']),
      notifyHabits: serializer.fromJson<bool>(json['notifyHabits']),
      notifyStreakWarning: serializer.fromJson<bool>(
        json['notifyStreakWarning'],
      ),
      notifyFreezeUsed: serializer.fromJson<bool>(json['notifyFreezeUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<int>(
        $AppSettingsTable.$converterthemeMode.toJson(themeMode),
      ),
      'language': serializer.toJson<int>(
        $AppSettingsTable.$converterlanguage.toJson(language),
      ),
      'notifyTasks': serializer.toJson<bool>(notifyTasks),
      'notifyHabits': serializer.toJson<bool>(notifyHabits),
      'notifyStreakWarning': serializer.toJson<bool>(notifyStreakWarning),
      'notifyFreezeUsed': serializer.toJson<bool>(notifyFreezeUsed),
    };
  }

  AppSetting copyWith({
    int? id,
    AppThemeMode? themeMode,
    AppLanguage? language,
    bool? notifyTasks,
    bool? notifyHabits,
    bool? notifyStreakWarning,
    bool? notifyFreezeUsed,
  }) => AppSetting(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    notifyTasks: notifyTasks ?? this.notifyTasks,
    notifyHabits: notifyHabits ?? this.notifyHabits,
    notifyStreakWarning: notifyStreakWarning ?? this.notifyStreakWarning,
    notifyFreezeUsed: notifyFreezeUsed ?? this.notifyFreezeUsed,
  );
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      language: data.language.present ? data.language.value : this.language,
      notifyTasks: data.notifyTasks.present
          ? data.notifyTasks.value
          : this.notifyTasks,
      notifyHabits: data.notifyHabits.present
          ? data.notifyHabits.value
          : this.notifyHabits,
      notifyStreakWarning: data.notifyStreakWarning.present
          ? data.notifyStreakWarning.value
          : this.notifyStreakWarning,
      notifyFreezeUsed: data.notifyFreezeUsed.present
          ? data.notifyFreezeUsed.value
          : this.notifyFreezeUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('language: $language, ')
          ..write('notifyTasks: $notifyTasks, ')
          ..write('notifyHabits: $notifyHabits, ')
          ..write('notifyStreakWarning: $notifyStreakWarning, ')
          ..write('notifyFreezeUsed: $notifyFreezeUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeMode,
    language,
    notifyTasks,
    notifyHabits,
    notifyStreakWarning,
    notifyFreezeUsed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.language == this.language &&
          other.notifyTasks == this.notifyTasks &&
          other.notifyHabits == this.notifyHabits &&
          other.notifyStreakWarning == this.notifyStreakWarning &&
          other.notifyFreezeUsed == this.notifyFreezeUsed);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<int> id;
  final Value<AppThemeMode> themeMode;
  final Value<AppLanguage> language;
  final Value<bool> notifyTasks;
  final Value<bool> notifyHabits;
  final Value<bool> notifyStreakWarning;
  final Value<bool> notifyFreezeUsed;
  const AppSettingsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.language = const Value.absent(),
    this.notifyTasks = const Value.absent(),
    this.notifyHabits = const Value.absent(),
    this.notifyStreakWarning = const Value.absent(),
    this.notifyFreezeUsed = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.language = const Value.absent(),
    this.notifyTasks = const Value.absent(),
    this.notifyHabits = const Value.absent(),
    this.notifyStreakWarning = const Value.absent(),
    this.notifyFreezeUsed = const Value.absent(),
  });
  static Insertable<AppSetting> custom({
    Expression<int>? id,
    Expression<int>? themeMode,
    Expression<int>? language,
    Expression<bool>? notifyTasks,
    Expression<bool>? notifyHabits,
    Expression<bool>? notifyStreakWarning,
    Expression<bool>? notifyFreezeUsed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (language != null) 'language': language,
      if (notifyTasks != null) 'notify_tasks': notifyTasks,
      if (notifyHabits != null) 'notify_habits': notifyHabits,
      if (notifyStreakWarning != null)
        'notify_streak_warning': notifyStreakWarning,
      if (notifyFreezeUsed != null) 'notify_freeze_used': notifyFreezeUsed,
    });
  }

  AppSettingsCompanion copyWith({
    Value<int>? id,
    Value<AppThemeMode>? themeMode,
    Value<AppLanguage>? language,
    Value<bool>? notifyTasks,
    Value<bool>? notifyHabits,
    Value<bool>? notifyStreakWarning,
    Value<bool>? notifyFreezeUsed,
  }) {
    return AppSettingsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      notifyTasks: notifyTasks ?? this.notifyTasks,
      notifyHabits: notifyHabits ?? this.notifyHabits,
      notifyStreakWarning: notifyStreakWarning ?? this.notifyStreakWarning,
      notifyFreezeUsed: notifyFreezeUsed ?? this.notifyFreezeUsed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<int>(
        $AppSettingsTable.$converterthemeMode.toSql(themeMode.value),
      );
    }
    if (language.present) {
      map['language'] = Variable<int>(
        $AppSettingsTable.$converterlanguage.toSql(language.value),
      );
    }
    if (notifyTasks.present) {
      map['notify_tasks'] = Variable<bool>(notifyTasks.value);
    }
    if (notifyHabits.present) {
      map['notify_habits'] = Variable<bool>(notifyHabits.value);
    }
    if (notifyStreakWarning.present) {
      map['notify_streak_warning'] = Variable<bool>(notifyStreakWarning.value);
    }
    if (notifyFreezeUsed.present) {
      map['notify_freeze_used'] = Variable<bool>(notifyFreezeUsed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('language: $language, ')
          ..write('notifyTasks: $notifyTasks, ')
          ..write('notifyHabits: $notifyHabits, ')
          ..write('notifyStreakWarning: $notifyStreakWarning, ')
          ..write('notifyFreezeUsed: $notifyFreezeUsed')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $SubtasksTable subtasks = $SubtasksTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitLogsTable habitLogs = $HabitLogsTable(this);
  late final $StreakStateTable streakState = $StreakStateTable(this);
  late final $BadgeUnlocksTable badgeUnlocks = $BadgeUnlocksTable(this);
  late final $UserProfileTable userProfile = $UserProfileTable(this);
  late final $CosmeticUnlocksTable cosmeticUnlocks = $CosmeticUnlocksTable(
    this,
  );
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    subtasks,
    habits,
    habitLogs,
    streakState,
    badgeUnlocks,
    userProfile,
    cosmeticUnlocks,
    appSettings,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('subtasks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'habits',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('habit_logs', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      required String title,
      required DateTime date,
      Value<DateTime?> time,
      required TaskPriority priority,
      Value<bool> isCompleted,
      Value<String?> location,
      Value<DateTime> createdAt,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<DateTime> date,
      Value<DateTime?> time,
      Value<TaskPriority> priority,
      Value<bool> isCompleted,
      Value<String?> location,
      Value<DateTime> createdAt,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SubtasksTable, List<Subtask>> _subtasksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.subtasks,
    aliasName: 'tasks__id__subtasks__task_id',
  );

  $$SubtasksTableProcessedTableManager get subtasksRefs {
    final manager = $$SubtasksTableTableManager(
      $_db,
      $_db.subtasks,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subtasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TaskPriority, TaskPriority, int>
  get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> subtasksRefs(
    Expression<bool> Function($$SubtasksTableFilterComposer f) f,
  ) {
    final $$SubtasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableFilterComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TaskPriority, int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> subtasksRefs<T extends Object>(
    Expression<T> Function($$SubtasksTableAnnotationComposer a) f,
  ) {
    final $$SubtasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subtasks,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubtasksTableAnnotationComposer(
            $db: $db,
            $table: $db.subtasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({bool subtasksRefs})
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime?> time = const Value.absent(),
                Value<TaskPriority> priority = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                date: date,
                time: time,
                priority: priority,
                isCompleted: isCompleted,
                location: location,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required DateTime date,
                Value<DateTime?> time = const Value.absent(),
                required TaskPriority priority,
                Value<bool> isCompleted = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                date: date,
                time: time,
                priority: priority,
                isCompleted: isCompleted,
                location: location,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({subtasksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (subtasksRefs) db.subtasks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (subtasksRefs)
                    await $_getPrefetchedData<Task, $TasksTable, Subtask>(
                      currentTable: table,
                      referencedTable: $$TasksTableReferences
                          ._subtasksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TasksTableReferences(db, table, p0).subtasksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.taskId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({bool subtasksRefs})
    >;
typedef $$SubtasksTableCreateCompanionBuilder =
    SubtasksCompanion Function({
      Value<int> id,
      required int taskId,
      required String title,
      Value<bool> isCompleted,
    });
typedef $$SubtasksTableUpdateCompanionBuilder =
    SubtasksCompanion Function({
      Value<int> id,
      Value<int> taskId,
      Value<String> title,
      Value<bool> isCompleted,
    });

final class $$SubtasksTableReferences
    extends BaseReferences<_$AppDatabase, $SubtasksTable, Subtask> {
  $$SubtasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('subtasks__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SubtasksTableFilterComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableOrderingComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubtasksTable> {
  $$SubtasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubtasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubtasksTable,
          Subtask,
          $$SubtasksTableFilterComposer,
          $$SubtasksTableOrderingComposer,
          $$SubtasksTableAnnotationComposer,
          $$SubtasksTableCreateCompanionBuilder,
          $$SubtasksTableUpdateCompanionBuilder,
          (Subtask, $$SubtasksTableReferences),
          Subtask,
          PrefetchHooks Function({bool taskId})
        > {
  $$SubtasksTableTableManager(_$AppDatabase db, $SubtasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubtasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubtasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubtasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
              }) => SubtasksCompanion(
                id: id,
                taskId: taskId,
                title: title,
                isCompleted: isCompleted,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int taskId,
                required String title,
                Value<bool> isCompleted = const Value.absent(),
              }) => SubtasksCompanion.insert(
                id: id,
                taskId: taskId,
                title: title,
                isCompleted: isCompleted,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubtasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$SubtasksTableReferences
                                    ._taskIdTable(db),
                                referencedColumn: $$SubtasksTableReferences
                                    ._taskIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SubtasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubtasksTable,
      Subtask,
      $$SubtasksTableFilterComposer,
      $$SubtasksTableOrderingComposer,
      $$SubtasksTableAnnotationComposer,
      $$SubtasksTableCreateCompanionBuilder,
      $$SubtasksTableUpdateCompanionBuilder,
      (Subtask, $$SubtasksTableReferences),
      Subtask,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$HabitsTableCreateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      required String name,
      required HabitFrequency frequency,
      Value<DateTime?> scheduledTime,
      Value<bool> hasProgress,
      Value<int?> targetMinutes,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int?> customDaysOfWeek,
      Value<int?> customInterval,
      Value<int?> customDayOfMonth,
      Value<int?> customFrequencyType,
    });
typedef $$HabitsTableUpdateCompanionBuilder =
    HabitsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<HabitFrequency> frequency,
      Value<DateTime?> scheduledTime,
      Value<bool> hasProgress,
      Value<int?> targetMinutes,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int?> customDaysOfWeek,
      Value<int?> customInterval,
      Value<int?> customDayOfMonth,
      Value<int?> customFrequencyType,
    });

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, Habit> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HabitLogsTable, List<HabitLog>>
  _habitLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.habitLogs,
    aliasName: 'habits__id__habit_logs__habit_id',
  );

  $$HabitLogsTableProcessedTableManager get habitLogsRefs {
    final manager = $$HabitLogsTableTableManager(
      $_db,
      $_db.habitLogs,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_habitLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HabitFrequency, HabitFrequency, int>
  get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasProgress => $composableBuilder(
    column: $table.hasProgress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customDaysOfWeek => $composableBuilder(
    column: $table.customDaysOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customInterval => $composableBuilder(
    column: $table.customInterval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customDayOfMonth => $composableBuilder(
    column: $table.customDayOfMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customFrequencyType => $composableBuilder(
    column: $table.customFrequencyType,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> habitLogsRefs(
    Expression<bool> Function($$HabitLogsTableFilterComposer f) f,
  ) {
    final $$HabitLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableFilterComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasProgress => $composableBuilder(
    column: $table.hasProgress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customDaysOfWeek => $composableBuilder(
    column: $table.customDaysOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customInterval => $composableBuilder(
    column: $table.customInterval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customDayOfMonth => $composableBuilder(
    column: $table.customDayOfMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customFrequencyType => $composableBuilder(
    column: $table.customFrequencyType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HabitFrequency, int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasProgress => $composableBuilder(
    column: $table.hasProgress,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetMinutes => $composableBuilder(
    column: $table.targetMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get customDaysOfWeek => $composableBuilder(
    column: $table.customDaysOfWeek,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customInterval => $composableBuilder(
    column: $table.customInterval,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customDayOfMonth => $composableBuilder(
    column: $table.customDayOfMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customFrequencyType => $composableBuilder(
    column: $table.customFrequencyType,
    builder: (column) => column,
  );

  Expression<T> habitLogsRefs<T extends Object>(
    Expression<T> Function($$HabitLogsTableAnnotationComposer a) f,
  ) {
    final $$HabitLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.habitLogs,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.habitLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, $$HabitsTableReferences),
          Habit,
          PrefetchHooks Function({bool habitLogsRefs})
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<HabitFrequency> frequency = const Value.absent(),
                Value<DateTime?> scheduledTime = const Value.absent(),
                Value<bool> hasProgress = const Value.absent(),
                Value<int?> targetMinutes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> customDaysOfWeek = const Value.absent(),
                Value<int?> customInterval = const Value.absent(),
                Value<int?> customDayOfMonth = const Value.absent(),
                Value<int?> customFrequencyType = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                frequency: frequency,
                scheduledTime: scheduledTime,
                hasProgress: hasProgress,
                targetMinutes: targetMinutes,
                isActive: isActive,
                createdAt: createdAt,
                customDaysOfWeek: customDaysOfWeek,
                customInterval: customInterval,
                customDayOfMonth: customDayOfMonth,
                customFrequencyType: customFrequencyType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required HabitFrequency frequency,
                Value<DateTime?> scheduledTime = const Value.absent(),
                Value<bool> hasProgress = const Value.absent(),
                Value<int?> targetMinutes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int?> customDaysOfWeek = const Value.absent(),
                Value<int?> customInterval = const Value.absent(),
                Value<int?> customDayOfMonth = const Value.absent(),
                Value<int?> customFrequencyType = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                frequency: frequency,
                scheduledTime: scheduledTime,
                hasProgress: hasProgress,
                targetMinutes: targetMinutes,
                isActive: isActive,
                createdAt: createdAt,
                customDaysOfWeek: customDaysOfWeek,
                customInterval: customInterval,
                customDayOfMonth: customDayOfMonth,
                customFrequencyType: customFrequencyType,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$HabitsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({habitLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (habitLogsRefs) db.habitLogs],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (habitLogsRefs)
                    await $_getPrefetchedData<Habit, $HabitsTable, HabitLog>(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences
                          ._habitLogsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableReferences(db, table, p0).habitLogsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.habitId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, $$HabitsTableReferences),
      Habit,
      PrefetchHooks Function({bool habitLogsRefs})
    >;
typedef $$HabitLogsTableCreateCompanionBuilder =
    HabitLogsCompanion Function({
      Value<int> id,
      required int habitId,
      required DateTime date,
      Value<bool> isCompleted,
      Value<int> progressMinutes,
    });
typedef $$HabitLogsTableUpdateCompanionBuilder =
    HabitLogsCompanion Function({
      Value<int> id,
      Value<int> habitId,
      Value<DateTime> date,
      Value<bool> isCompleted,
      Value<int> progressMinutes,
    });

final class $$HabitLogsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitLogsTable, HabitLog> {
  $$HabitLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('habit_logs__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HabitLogsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get progressMinutes => $composableBuilder(
    column: $table.progressMinutes,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get progressMinutes => $composableBuilder(
    column: $table.progressMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitLogsTable> {
  $$HabitLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get progressMinutes => $composableBuilder(
    column: $table.progressMinutes,
    builder: (column) => column,
  );

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HabitLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitLogsTable,
          HabitLog,
          $$HabitLogsTableFilterComposer,
          $$HabitLogsTableOrderingComposer,
          $$HabitLogsTableAnnotationComposer,
          $$HabitLogsTableCreateCompanionBuilder,
          $$HabitLogsTableUpdateCompanionBuilder,
          (HabitLog, $$HabitLogsTableReferences),
          HabitLog,
          PrefetchHooks Function({bool habitId})
        > {
  $$HabitLogsTableTableManager(_$AppDatabase db, $HabitLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> progressMinutes = const Value.absent(),
              }) => HabitLogsCompanion(
                id: id,
                habitId: habitId,
                date: date,
                isCompleted: isCompleted,
                progressMinutes: progressMinutes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required DateTime date,
                Value<bool> isCompleted = const Value.absent(),
                Value<int> progressMinutes = const Value.absent(),
              }) => HabitLogsCompanion.insert(
                id: id,
                habitId: habitId,
                date: date,
                isCompleted: isCompleted,
                progressMinutes: progressMinutes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$HabitLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.habitId,
                                referencedTable: $$HabitLogsTableReferences
                                    ._habitIdTable(db),
                                referencedColumn: $$HabitLogsTableReferences
                                    ._habitIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$HabitLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitLogsTable,
      HabitLog,
      $$HabitLogsTableFilterComposer,
      $$HabitLogsTableOrderingComposer,
      $$HabitLogsTableAnnotationComposer,
      $$HabitLogsTableCreateCompanionBuilder,
      $$HabitLogsTableUpdateCompanionBuilder,
      (HabitLog, $$HabitLogsTableReferences),
      HabitLog,
      PrefetchHooks Function({bool habitId})
    >;
typedef $$StreakStateTableCreateCompanionBuilder =
    StreakStateCompanion Function({
      Value<int> id,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<int> freezeCount,
      Value<int> freezeProgressDays,
      Value<DateTime?> lastActiveDate,
    });
typedef $$StreakStateTableUpdateCompanionBuilder =
    StreakStateCompanion Function({
      Value<int> id,
      Value<int> currentStreak,
      Value<int> longestStreak,
      Value<int> freezeCount,
      Value<int> freezeProgressDays,
      Value<DateTime?> lastActiveDate,
    });

class $$StreakStateTableFilterComposer
    extends Composer<_$AppDatabase, $StreakStateTable> {
  $$StreakStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freezeCount => $composableBuilder(
    column: $table.freezeCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get freezeProgressDays => $composableBuilder(
    column: $table.freezeProgressDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StreakStateTableOrderingComposer
    extends Composer<_$AppDatabase, $StreakStateTable> {
  $$StreakStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freezeCount => $composableBuilder(
    column: $table.freezeCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get freezeProgressDays => $composableBuilder(
    column: $table.freezeProgressDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StreakStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $StreakStateTable> {
  $$StreakStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
    column: $table.currentStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<int> get freezeCount => $composableBuilder(
    column: $table.freezeCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get freezeProgressDays => $composableBuilder(
    column: $table.freezeProgressDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => column,
  );
}

class $$StreakStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StreakStateTable,
          StreakStateData,
          $$StreakStateTableFilterComposer,
          $$StreakStateTableOrderingComposer,
          $$StreakStateTableAnnotationComposer,
          $$StreakStateTableCreateCompanionBuilder,
          $$StreakStateTableUpdateCompanionBuilder,
          (
            StreakStateData,
            BaseReferences<_$AppDatabase, $StreakStateTable, StreakStateData>,
          ),
          StreakStateData,
          PrefetchHooks Function()
        > {
  $$StreakStateTableTableManager(_$AppDatabase db, $StreakStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StreakStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StreakStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StreakStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<int> freezeCount = const Value.absent(),
                Value<int> freezeProgressDays = const Value.absent(),
                Value<DateTime?> lastActiveDate = const Value.absent(),
              }) => StreakStateCompanion(
                id: id,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                freezeCount: freezeCount,
                freezeProgressDays: freezeProgressDays,
                lastActiveDate: lastActiveDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> currentStreak = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<int> freezeCount = const Value.absent(),
                Value<int> freezeProgressDays = const Value.absent(),
                Value<DateTime?> lastActiveDate = const Value.absent(),
              }) => StreakStateCompanion.insert(
                id: id,
                currentStreak: currentStreak,
                longestStreak: longestStreak,
                freezeCount: freezeCount,
                freezeProgressDays: freezeProgressDays,
                lastActiveDate: lastActiveDate,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StreakStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StreakStateTable,
      StreakStateData,
      $$StreakStateTableFilterComposer,
      $$StreakStateTableOrderingComposer,
      $$StreakStateTableAnnotationComposer,
      $$StreakStateTableCreateCompanionBuilder,
      $$StreakStateTableUpdateCompanionBuilder,
      (
        StreakStateData,
        BaseReferences<_$AppDatabase, $StreakStateTable, StreakStateData>,
      ),
      StreakStateData,
      PrefetchHooks Function()
    >;
typedef $$BadgeUnlocksTableCreateCompanionBuilder =
    BadgeUnlocksCompanion Function({
      Value<int> id,
      required StreakRank rank,
      Value<DateTime> unlockedAt,
    });
typedef $$BadgeUnlocksTableUpdateCompanionBuilder =
    BadgeUnlocksCompanion Function({
      Value<int> id,
      Value<StreakRank> rank,
      Value<DateTime> unlockedAt,
    });

class $$BadgeUnlocksTableFilterComposer
    extends Composer<_$AppDatabase, $BadgeUnlocksTable> {
  $$BadgeUnlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<StreakRank, StreakRank, int> get rank =>
      $composableBuilder(
        column: $table.rank,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BadgeUnlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $BadgeUnlocksTable> {
  $$BadgeUnlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BadgeUnlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BadgeUnlocksTable> {
  $$BadgeUnlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<StreakRank, int> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$BadgeUnlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BadgeUnlocksTable,
          BadgeUnlock,
          $$BadgeUnlocksTableFilterComposer,
          $$BadgeUnlocksTableOrderingComposer,
          $$BadgeUnlocksTableAnnotationComposer,
          $$BadgeUnlocksTableCreateCompanionBuilder,
          $$BadgeUnlocksTableUpdateCompanionBuilder,
          (
            BadgeUnlock,
            BaseReferences<_$AppDatabase, $BadgeUnlocksTable, BadgeUnlock>,
          ),
          BadgeUnlock,
          PrefetchHooks Function()
        > {
  $$BadgeUnlocksTableTableManager(_$AppDatabase db, $BadgeUnlocksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BadgeUnlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BadgeUnlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BadgeUnlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<StreakRank> rank = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
              }) => BadgeUnlocksCompanion(
                id: id,
                rank: rank,
                unlockedAt: unlockedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required StreakRank rank,
                Value<DateTime> unlockedAt = const Value.absent(),
              }) => BadgeUnlocksCompanion.insert(
                id: id,
                rank: rank,
                unlockedAt: unlockedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BadgeUnlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BadgeUnlocksTable,
      BadgeUnlock,
      $$BadgeUnlocksTableFilterComposer,
      $$BadgeUnlocksTableOrderingComposer,
      $$BadgeUnlocksTableAnnotationComposer,
      $$BadgeUnlocksTableCreateCompanionBuilder,
      $$BadgeUnlocksTableUpdateCompanionBuilder,
      (
        BadgeUnlock,
        BaseReferences<_$AppDatabase, $BadgeUnlocksTable, BadgeUnlock>,
      ),
      BadgeUnlock,
      PrefetchHooks Function()
    >;
typedef $$UserProfileTableCreateCompanionBuilder =
    UserProfileCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> avatarId,
      Value<int> xp,
      Value<int> level,
    });
typedef $$UserProfileTableUpdateCompanionBuilder =
    UserProfileCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> avatarId,
      Value<int> xp,
      Value<int> level,
    });

class $$UserProfileTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarId => $composableBuilder(
    column: $table.avatarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UserProfileTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarId => $composableBuilder(
    column: $table.avatarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserProfileTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileTable> {
  $$UserProfileTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get avatarId =>
      $composableBuilder(column: $table.avatarId, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);
}

class $$UserProfileTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserProfileTable,
          UserProfileData,
          $$UserProfileTableFilterComposer,
          $$UserProfileTableOrderingComposer,
          $$UserProfileTableAnnotationComposer,
          $$UserProfileTableCreateCompanionBuilder,
          $$UserProfileTableUpdateCompanionBuilder,
          (
            UserProfileData,
            BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>,
          ),
          UserProfileData,
          PrefetchHooks Function()
        > {
  $$UserProfileTableTableManager(_$AppDatabase db, $UserProfileTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> avatarId = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> level = const Value.absent(),
              }) => UserProfileCompanion(
                id: id,
                name: name,
                avatarId: avatarId,
                xp: xp,
                level: level,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> avatarId = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<int> level = const Value.absent(),
              }) => UserProfileCompanion.insert(
                id: id,
                name: name,
                avatarId: avatarId,
                xp: xp,
                level: level,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserProfileTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserProfileTable,
      UserProfileData,
      $$UserProfileTableFilterComposer,
      $$UserProfileTableOrderingComposer,
      $$UserProfileTableAnnotationComposer,
      $$UserProfileTableCreateCompanionBuilder,
      $$UserProfileTableUpdateCompanionBuilder,
      (
        UserProfileData,
        BaseReferences<_$AppDatabase, $UserProfileTable, UserProfileData>,
      ),
      UserProfileData,
      PrefetchHooks Function()
    >;
typedef $$CosmeticUnlocksTableCreateCompanionBuilder =
    CosmeticUnlocksCompanion Function({
      Value<int> id,
      required int levelMilestone,
      Value<DateTime> unlockedAt,
    });
typedef $$CosmeticUnlocksTableUpdateCompanionBuilder =
    CosmeticUnlocksCompanion Function({
      Value<int> id,
      Value<int> levelMilestone,
      Value<DateTime> unlockedAt,
    });

class $$CosmeticUnlocksTableFilterComposer
    extends Composer<_$AppDatabase, $CosmeticUnlocksTable> {
  $$CosmeticUnlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get levelMilestone => $composableBuilder(
    column: $table.levelMilestone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CosmeticUnlocksTableOrderingComposer
    extends Composer<_$AppDatabase, $CosmeticUnlocksTable> {
  $$CosmeticUnlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get levelMilestone => $composableBuilder(
    column: $table.levelMilestone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CosmeticUnlocksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CosmeticUnlocksTable> {
  $$CosmeticUnlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get levelMilestone => $composableBuilder(
    column: $table.levelMilestone,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );
}

class $$CosmeticUnlocksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CosmeticUnlocksTable,
          CosmeticUnlock,
          $$CosmeticUnlocksTableFilterComposer,
          $$CosmeticUnlocksTableOrderingComposer,
          $$CosmeticUnlocksTableAnnotationComposer,
          $$CosmeticUnlocksTableCreateCompanionBuilder,
          $$CosmeticUnlocksTableUpdateCompanionBuilder,
          (
            CosmeticUnlock,
            BaseReferences<
              _$AppDatabase,
              $CosmeticUnlocksTable,
              CosmeticUnlock
            >,
          ),
          CosmeticUnlock,
          PrefetchHooks Function()
        > {
  $$CosmeticUnlocksTableTableManager(
    _$AppDatabase db,
    $CosmeticUnlocksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CosmeticUnlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CosmeticUnlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CosmeticUnlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> levelMilestone = const Value.absent(),
                Value<DateTime> unlockedAt = const Value.absent(),
              }) => CosmeticUnlocksCompanion(
                id: id,
                levelMilestone: levelMilestone,
                unlockedAt: unlockedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int levelMilestone,
                Value<DateTime> unlockedAt = const Value.absent(),
              }) => CosmeticUnlocksCompanion.insert(
                id: id,
                levelMilestone: levelMilestone,
                unlockedAt: unlockedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CosmeticUnlocksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CosmeticUnlocksTable,
      CosmeticUnlock,
      $$CosmeticUnlocksTableFilterComposer,
      $$CosmeticUnlocksTableOrderingComposer,
      $$CosmeticUnlocksTableAnnotationComposer,
      $$CosmeticUnlocksTableCreateCompanionBuilder,
      $$CosmeticUnlocksTableUpdateCompanionBuilder,
      (
        CosmeticUnlock,
        BaseReferences<_$AppDatabase, $CosmeticUnlocksTable, CosmeticUnlock>,
      ),
      CosmeticUnlock,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<AppThemeMode> themeMode,
      Value<AppLanguage> language,
      Value<bool> notifyTasks,
      Value<bool> notifyHabits,
      Value<bool> notifyStreakWarning,
      Value<bool> notifyFreezeUsed,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<int> id,
      Value<AppThemeMode> themeMode,
      Value<AppLanguage> language,
      Value<bool> notifyTasks,
      Value<bool> notifyHabits,
      Value<bool> notifyStreakWarning,
      Value<bool> notifyFreezeUsed,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AppThemeMode, AppThemeMode, int>
  get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<AppLanguage, AppLanguage, int> get language =>
      $composableBuilder(
        column: $table.language,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<bool> get notifyTasks => $composableBuilder(
    column: $table.notifyTasks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyHabits => $composableBuilder(
    column: $table.notifyHabits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyStreakWarning => $composableBuilder(
    column: $table.notifyStreakWarning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notifyFreezeUsed => $composableBuilder(
    column: $table.notifyFreezeUsed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyTasks => $composableBuilder(
    column: $table.notifyTasks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyHabits => $composableBuilder(
    column: $table.notifyHabits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyStreakWarning => $composableBuilder(
    column: $table.notifyStreakWarning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notifyFreezeUsed => $composableBuilder(
    column: $table.notifyFreezeUsed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppThemeMode, int> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AppLanguage, int> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<bool> get notifyTasks => $composableBuilder(
    column: $table.notifyTasks,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyHabits => $composableBuilder(
    column: $table.notifyHabits,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyStreakWarning => $composableBuilder(
    column: $table.notifyStreakWarning,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notifyFreezeUsed => $composableBuilder(
    column: $table.notifyFreezeUsed,
    builder: (column) => column,
  );
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<AppThemeMode> themeMode = const Value.absent(),
                Value<AppLanguage> language = const Value.absent(),
                Value<bool> notifyTasks = const Value.absent(),
                Value<bool> notifyHabits = const Value.absent(),
                Value<bool> notifyStreakWarning = const Value.absent(),
                Value<bool> notifyFreezeUsed = const Value.absent(),
              }) => AppSettingsCompanion(
                id: id,
                themeMode: themeMode,
                language: language,
                notifyTasks: notifyTasks,
                notifyHabits: notifyHabits,
                notifyStreakWarning: notifyStreakWarning,
                notifyFreezeUsed: notifyFreezeUsed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<AppThemeMode> themeMode = const Value.absent(),
                Value<AppLanguage> language = const Value.absent(),
                Value<bool> notifyTasks = const Value.absent(),
                Value<bool> notifyHabits = const Value.absent(),
                Value<bool> notifyStreakWarning = const Value.absent(),
                Value<bool> notifyFreezeUsed = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                id: id,
                themeMode: themeMode,
                language: language,
                notifyTasks: notifyTasks,
                notifyHabits: notifyHabits,
                notifyStreakWarning: notifyStreakWarning,
                notifyFreezeUsed: notifyFreezeUsed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$SubtasksTableTableManager get subtasks =>
      $$SubtasksTableTableManager(_db, _db.subtasks);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitLogsTableTableManager get habitLogs =>
      $$HabitLogsTableTableManager(_db, _db.habitLogs);
  $$StreakStateTableTableManager get streakState =>
      $$StreakStateTableTableManager(_db, _db.streakState);
  $$BadgeUnlocksTableTableManager get badgeUnlocks =>
      $$BadgeUnlocksTableTableManager(_db, _db.badgeUnlocks);
  $$UserProfileTableTableManager get userProfile =>
      $$UserProfileTableTableManager(_db, _db.userProfile);
  $$CosmeticUnlocksTableTableManager get cosmeticUnlocks =>
      $$CosmeticUnlocksTableTableManager(_db, _db.cosmeticUnlocks);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
