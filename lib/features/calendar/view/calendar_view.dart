import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/models/calendar_event.dart';

/// Calendar view for managing events and schedule.
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  final CalendarRepository _repository = CalendarRepository();
  final RxList<CalendarEvent> _events = <CalendarEvent>[].obs;
  final RxBool _isLoading = true.obs;
  final Rx<DateTime> _selectedDate = DateTime.now().obs;
  final Rx<DateTime> _focusedMonth = DateTime.now().obs;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  /// Loads events from storage.
  Future<void> _loadEvents() async {
    _isLoading.value = true;
    try {
      _events.value = await _repository.getEvents();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Shows the add event bottom sheet.
  void _showAddEventSheet() {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _AddEventSheet(
            initialDate: _selectedDate.value,
            onSave: _createEvent,
          ),
        );
      },
    );
  }

  /// Shows the edit event bottom sheet.
  void _showEditEventSheet(CalendarEvent event) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _AddEventSheet(
            initialDate: event.date,
            event: event,
            onSave: _updateEvent,
          ),
        );
      },
    );
  }

  /// Creates a new event.
  Future<void> _createEvent(CalendarEvent event) async {
    await _repository.saveEvent(event);
    await _loadEvents();
    if (mounted) {
      Get.snackbar(
        'Event Created',
        'Your event has been saved.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Updates an existing event.
  Future<void> _updateEvent(CalendarEvent event) async {
    await _repository.saveEvent(event);
    await _loadEvents();
    if (mounted) {
      Get.snackbar(
        'Event Updated',
        'Your changes have been saved.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Deletes an event.
  Future<void> _deleteEvent(CalendarEvent event) async {
    await _repository.deleteEvent(event.id);
    await _loadEvents();
    if (mounted) {
      Get.snackbar(
        'Event Deleted',
        'The event has been removed.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Returns events for the selected date.
  List<CalendarEvent> get _eventsForSelectedDate {
    final DateTime selected = _selectedDate.value;
    return _events
        .where((CalendarEvent e) =>
            e.date.year == selected.year &&
            e.date.month == selected.month &&
            e.date.day == selected.day,)
        .toList();
  }

  /// Returns events for a specific date.
  List<CalendarEvent> _eventsForDate(DateTime date) {
    return _events
        .where((CalendarEvent e) =>
            e.date.year == date.year &&
            e.date.month == date.month &&
            e.date.day == date.day,)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddEventSheet,
            tooltip: 'Add Event',
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (_isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Month header.
                _CalendarHeader(
                  focusedMonth: _focusedMonth.value,
                  onPreviousMonth: () {
                    _focusedMonth.value = DateTime(
                      _focusedMonth.value.year,
                      _focusedMonth.value.month - 1,
                    );
                  },
                  onNextMonth: () {
                    _focusedMonth.value = DateTime(
                      _focusedMonth.value.year,
                      _focusedMonth.value.month + 1,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Calendar grid.
                _CalendarGrid(
                  focusedMonth: _focusedMonth.value,
                  selectedDate: _selectedDate.value,
                  eventsForDate: _eventsForDate,
                  onDateSelected: (DateTime date) {
                    _selectedDate.value = date;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Selected date events section.
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _formatSelectedDate(_selectedDate.value),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              '${_eventsForSelectedDate.length} event${_eventsForSelectedDate.length == 1 ? '' : 's'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showAddEventSheet,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('New Event'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Events list for selected date.
                _EventsList(
                  events: _eventsForSelectedDate,
                  onEdit: _showEditEventSheet,
                  onDelete: _deleteEvent,
                ),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddEventSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Event'),
      ),
    );
  }

  /// Formats the selected date for display.
  String _formatSelectedDate(DateTime date) {
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

/// Calendar header with month navigation.
class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.focusedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  final DateTime focusedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  @override
  Widget build(BuildContext context) {
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: <Widget>[
          // Month icon.
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.categoryCalendar,
                  AppColors.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.categoryCalendar.withValues(alpha: 0.30),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '${months[focusedMonth.month - 1]} ${focusedMonth.year}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'Plan your month ahead',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: onPreviousMonth,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: onNextMonth,
          ),
        ],
      ),
    );
  }
}

/// Calendar grid for the month view.
class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.focusedMonth,
    required this.selectedDate,
    required this.eventsForDate,
    required this.onDateSelected,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final List<CalendarEvent> Function(DateTime) eventsForDate;
  final ValueChanged<DateTime> onDateSelected;

  static const List<String> _weekdayLabels = <String>[
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int daysInMonth = DateTime(
      focusedMonth.year,
      focusedMonth.month + 1,
      0,
    ).day;
    final int firstWeekday = DateTime(
      focusedMonth.year,
      focusedMonth.month,
      1,
    ).weekday;

    // Adjust for Monday-based week (weekday 1 = Monday).
    final int leadingEmpty = firstWeekday - 1;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: AppShadows.soft,
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: <Widget>[
          // Weekday labels.
          Row(
            children: <Widget>[
              for (final String label in _weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Calendar days grid.
          ..._buildWeeks(context, daysInMonth, leadingEmpty),
        ],
      ),
    );
  }

  /// Builds the weeks for the calendar grid.
  List<Widget> _buildWeeks(
      BuildContext context, int daysInMonth, int leadingEmpty,) {
    final List<Widget> weeks = <Widget>[];
    int dayCounter = 1;

    // Calculate total cells needed.
    final int totalCells = leadingEmpty + daysInMonth;
    final int totalWeeks = (totalCells / 7).ceil();

    for (int week = 0; week < totalWeeks; week++) {
      final List<Widget> dayCells = <Widget>[];
      for (int day = 0; day < 7; day++) {
        final int cellIndex = (week * 7) + day;
        if (cellIndex < leadingEmpty || dayCounter > daysInMonth) {
          dayCells.add(const Expanded(child: SizedBox(height: 36)));
        } else {
          final DateTime cellDate = DateTime(
            focusedMonth.year,
            focusedMonth.month,
            dayCounter,
          );
          final bool isSelected = cellDate.year == selectedDate.year &&
              cellDate.month == selectedDate.month &&
              cellDate.day == selectedDate.day;
          final bool isToday = cellDate.year == DateTime.now().year &&
              cellDate.month == DateTime.now().month &&
              cellDate.day == DateTime.now().day;
          final List<CalendarEvent> events = eventsForDate(cellDate);

          dayCells.add(
            Expanded(
              child: _DayCell(
                day: dayCounter,
                isToday: isToday || isSelected,
                hasEvents: events.isNotEmpty,
                onTap: () => onDateSelected(cellDate),
              ),
            ),
          );
          dayCounter++;
        }
      }
      weeks.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(children: dayCells),
        ),
      );
    }

    return weeks;
  }
}

/// Single day cell in the calendar grid.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isToday,
    required this.hasEvents,
    required this.onTap,
  });

  final int day;
  final bool isToday;
  final bool hasEvents;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isToday ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              '$day',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isToday ? Colors.white : scheme.onSurfaceVariant,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
            if (hasEvents && !isToday)
              Positioned(
                bottom: 4,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.categoryCalendar,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Events list for the selected date.
class _EventsList extends StatelessWidget {
  const _EventsList({
    required this.events,
    required this.onEdit,
    required this.onDelete,
  });

  final List<CalendarEvent> events;
  final ValueChanged<CalendarEvent> onEdit;
  final ValueChanged<CalendarEvent> onDelete;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
            ),
          ),
          child: Column(
            children: <Widget>[
              Icon(
                Icons.event_note_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No events for this day',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Tap the + button to create your first event.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: <Widget>[
          for (int i = 0; i < events.length; i++) ...<Widget>[
            _EventCard(
              event: events[i],
              onEdit: () => onEdit(events[i]),
              onDelete: () => onDelete(events[i]),
            ),
            if (i < events.length - 1) const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

/// Single event card.
class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.onEdit,
    required this.onDelete,
  });

  final CalendarEvent event;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final Color eventColor = Color(event.colorValue);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant.withValues(
                    alpha: 0.3,
                  ),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: eventColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (event.description.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        event.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                    if (event.startTime != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _formatTime(event.startTime!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: eventColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 20),
                onSelected: (String value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_rounded, size: 20),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_rounded,
                          size: 20, color: AppColors.error,),
                      title: Text('Delete',
                          style: TextStyle(color: AppColors.error),),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Formats a time for display.
  String _formatTime(DateTime time) {
    final int hour = time.hour > 12 ? time.hour - 12 : time.hour;
    final String period = time.hour >= 12 ? 'PM' : 'AM';
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

/// Add/edit event bottom sheet content.
class _AddEventSheet extends StatefulWidget {
  const _AddEventSheet({
    required this.initialDate,
    required this.onSave,
    this.event,
  });

  final DateTime initialDate;
  final ValueChanged<CalendarEvent> onSave;
  final CalendarEvent? event;

  @override
  State<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<_AddEventSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.event?.description ?? '');
    _locationController =
        TextEditingController(text: widget.event?.location ?? '');
    _selectedDate = widget.event?.date ?? widget.initialDate;
    _startTime = widget.event?.startTime != null
        ? TimeOfDay.fromDateTime(widget.event!.startTime!)
        : null;
    _endTime = widget.event?.endTime != null
        ? TimeOfDay.fromDateTime(widget.event!.endTime!)
        : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  /// Validates and saves the event.
  Future<void> _saveEvent() async {
    final String title = _titleController.text.trim();
    if (title.isEmpty) {
      Get.snackbar(
        'Title Required',
        'Please enter an event title.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (title.length > 100) {
      Get.snackbar(
        'Title Too Long',
        'Event title must be 100 characters or less.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Validate end time is after start time.
    if (_startTime != null && _endTime != null) {
      final int startMinutes = _startTime!.hour * 60 + _startTime!.minute;
      final int endMinutes = _endTime!.hour * 60 + _endTime!.minute;
      if (endMinutes <= startMinutes) {
        Get.snackbar(
          'Invalid Time',
          'End time must be after start time.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    DateTime? startDateTime;
    DateTime? endDateTime;

    if (_startTime != null) {
      startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime!.hour,
        _startTime!.minute,
      );
    }

    if (_endTime != null) {
      endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime!.hour,
        _endTime!.minute,
      );
    }

    final CalendarEvent event = CalendarEvent(
      id: widget.event?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim(),
      date: _selectedDate,
      startTime: startDateTime,
      endTime: endDateTime,
      location: _locationController.text.trim(),
      createdAt: widget.event?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    widget.onSave(event);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  /// Shows the date picker.
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Shows the start time picker.
  Future<void> _pickStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  /// Shows the end time picker.
  Future<void> _pickEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.event != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            isEditing ? 'Edit Event' : 'New Event',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Event Title',
              hintText: 'e.g. Team Meeting',
              prefixIcon: Icon(Icons.title_rounded),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Add details...',
              prefixIcon: Icon(Icons.notes_rounded),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: 'Location',
              hintText: 'e.g. Office, Room 101',
              prefixIcon: Icon(Icons.location_on_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text(
                    '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickStartTime,
                  icon: const Icon(Icons.schedule_rounded, size: 18),
                  label: Text(_startTime != null
                      ? 'Start: ${_startTime!.format(context)}'
                      : 'Start Time',),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickEndTime,
                  icon: const Icon(Icons.schedule_rounded, size: 18),
                  label: Text(_endTime != null
                      ? 'End: ${_endTime!.format(context)}'
                      : 'End Time',),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(isEditing ? 'Save Changes' : 'Save Event'),
            ),
          ),
        ],
      ),
    );
  }
}
