part of calendar;

_AppointmentView _getAppointmentView(
    Appointment appointment, List<_AppointmentView> appointmentCollection,
    [int resourceIndex]) {
  _AppointmentView appointmentRenderer;
  for (int i = 0; i < appointmentCollection.length; i++) {
    final _AppointmentView view = appointmentCollection[i];
    if (view.appointment == null) {
      appointmentRenderer = view;
      break;
    }
  }

  if (appointmentRenderer == null) {
    appointmentRenderer = _AppointmentView();
    appointmentRenderer.appointment = appointment;
    appointmentRenderer.canReuse = false;
    appointmentRenderer.resourceIndex = resourceIndex;
    appointmentCollection.add(appointmentRenderer);
  }

  appointmentRenderer.appointment = appointment;
  appointmentRenderer.canReuse = false;
  appointmentRenderer.resourceIndex = resourceIndex;
  return appointmentRenderer;
}

void _createVisibleAppointments(
    List<_AppointmentView> appointmentCollection,
    List<Appointment> visibleAppointments,
    List<DateTime> visibleDates,
    int startIndex,
    int endIndex) {
  for (int i = 0; i < appointmentCollection.length; i++) {
    final _AppointmentView appointmentView = appointmentCollection[i];
    appointmentView.endIndex = -1;
    appointmentView.startIndex = -1;
    appointmentView.isSpanned = false;
    appointmentView.position = -1;
    appointmentView.maxPositions = 0;
    appointmentView.canReuse = true;
  }

  if (visibleAppointments == null) {
    return;
  }

  for (int i = 0; i < visibleAppointments.length; i++) {
    final Appointment appointment = visibleAppointments[i];
    if (!appointment._isSpanned &&
        appointment._actualStartTime.day == appointment._actualEndTime.day &&
        appointment._actualStartTime.month ==
            appointment._actualEndTime.month) {
      final _AppointmentView appointmentView =
          _createAppointmentView(appointmentCollection);
      appointmentView.appointment = appointment;
      appointmentView.canReuse = false;
      appointmentView.startIndex =
          _getDateIndex(appointment._actualStartTime, visibleDates);

      /// Check the index value before the view start index then assign the
      /// start index as visible start index
      /// eg., if show trailing and leading dates as disabled and recurrence
      /// appointment spanned from Aug 31 to Sep 2 then
      /// In Aug month view, visible start and end index as 6, 36 but
      /// appointment start and end index as 36, 38
      /// In Sep month view visible start and end index as 2, 31 but
      /// appointment start and end index as 1, 3
      if (appointmentView.startIndex == -1 ||
          appointmentView.startIndex < startIndex) {
        appointmentView.startIndex = startIndex;
      }

      appointmentView.endIndex =
          _getDateIndex(appointment._actualEndTime, visibleDates);

      /// Check the index value after the view end index then assign the
      /// end index as visible end index
      /// eg., if show trailing and leading dates as disabled and recurrence
      /// appointment spanned from Aug 31 to Sep 2 then
      /// In Aug month view, visible start and end index as 6, 36 but
      /// appointment start and end index as 36, 38
      /// In Sep month view visible start and end index as 2, 31 but
      /// appointment start and end index as 1, 3
      if (appointmentView.endIndex == -1 ||
          appointmentView.endIndex > endIndex) {
        appointmentView.endIndex = endIndex;
      }

      if (!appointmentCollection.contains(appointmentView)) {
        appointmentCollection.add(appointmentView);
      }
    } else {
      final _AppointmentView appointmentView =
          _createAppointmentView(appointmentCollection);
      appointmentView.appointment = appointment;
      appointmentView.canReuse = false;
      appointmentView.startIndex =
          _getDateIndex(appointment._actualStartTime, visibleDates);

      /// Check the index value before the view start index then assign the
      /// start index as visible start index
      /// eg., if show trailing and leading dates as disabled and recurrence
      /// appointment spanned from Aug 31 to Sep 2 then
      /// In Aug month view, visible start and end index as 6, 36 but
      /// appointment start and end index as 36, 38
      /// In Sep month view visible start and end index as 2, 31 but
      /// appointment start and end index as 1, 3
      if (appointmentView.startIndex == -1 ||
          appointmentView.startIndex < startIndex) {
        appointmentView.startIndex = startIndex;
      }

      appointmentView.endIndex =
          _getDateIndex(appointment._actualEndTime, visibleDates);

      /// Check the index value after the view end index then assign the
      /// end index as visible end index
      /// eg., if show trailing and leading dates as disabled and recurrence
      /// appointment spanned from Aug 31 to Sep 2 then
      /// In Aug month view, visible start and end index as 6, 36 but
      /// appointment start and end index as 36, 38
      /// In Sep month view visible start and end index as 2, 31 but
      /// appointment start and end index as 1, 3
      if (appointmentView.endIndex == -1 ||
          appointmentView.endIndex > endIndex) {
        appointmentView.endIndex = endIndex;
      }

      _createAppointmentInfoForSpannedAppointment(
          appointmentView, appointmentCollection);
    }
  }
}

void _createAppointmentInfoForSpannedAppointment(
    _AppointmentView appointmentView,
    List<_AppointmentView> appointmentCollection) {
  if (appointmentView.startIndex ~/ _kNumberOfDaysInWeek !=
      appointmentView.endIndex ~/ _kNumberOfDaysInWeek) {
    final int endIndex = appointmentView.endIndex;
    appointmentView.endIndex =
        ((((appointmentView.startIndex ~/ _kNumberOfDaysInWeek) + 1) *
                    _kNumberOfDaysInWeek) -
                1)
            .toInt();
    appointmentView.isSpanned = true;
    if (appointmentCollection != null &&
        !appointmentCollection.contains(appointmentView)) {
      appointmentCollection.add(appointmentView);
    }

    final _AppointmentView appointmentView1 =
        _createAppointmentView(appointmentCollection);
    appointmentView1.appointment = appointmentView.appointment;
    appointmentView1.canReuse = false;
    appointmentView1.startIndex = appointmentView.endIndex + 1;
    appointmentView1.endIndex = endIndex;
    _createAppointmentInfoForSpannedAppointment(
        appointmentView1, appointmentCollection);
  } else {
    appointmentView.isSpanned = true;
    if (!appointmentCollection.contains(appointmentView)) {
      appointmentCollection.add(appointmentView);
    }
  }
}

void _setAppointmentPosition(List<_AppointmentView> appointmentViewCollection,
    _AppointmentView appointmentView, int viewIndex) {
  for (int j = 0; j < appointmentViewCollection.length; j++) {
    //// Break when the collection reaches current appointment
    if (j >= viewIndex) {
      break;
    }

    final _AppointmentView prevAppointmentView = appointmentViewCollection[j];
    if (!_isInterceptAppointments(appointmentView, prevAppointmentView)) {
      continue;
    }

    if (appointmentView.position == prevAppointmentView.position) {
      appointmentView.position = appointmentView.position + 1;
      appointmentView.maxPositions = appointmentView.position;
      prevAppointmentView.maxPositions = appointmentView.position;
      _setAppointmentPosition(
          appointmentViewCollection, appointmentView, viewIndex);
      break;
    }
  }
}

bool _isInterceptAppointments(
    _AppointmentView appointmentView1, _AppointmentView appointmentView2) {
  if (appointmentView1.startIndex <= appointmentView2.startIndex &&
          appointmentView1.endIndex >= appointmentView2.startIndex ||
      appointmentView2.startIndex <= appointmentView1.startIndex &&
          appointmentView2.endIndex >= appointmentView1.startIndex) {
    return true;
  }

  if (appointmentView1.startIndex <= appointmentView2.endIndex &&
          appointmentView1.endIndex >= appointmentView2.endIndex ||
      appointmentView2.startIndex <= appointmentView1.endIndex &&
          appointmentView2.endIndex >= appointmentView1.endIndex) {
    return true;
  }

  return false;
}

/// Sort the appointment based on appointment start date, if both
/// the appointments have same start date then the appointment sorted based on
/// end date and its interval(difference between end time and start time).
int _orderAppointmentViewBySpanned(
    _AppointmentView appointmentView1, _AppointmentView appointmentView2) {
  if (appointmentView1.appointment == null ||
      appointmentView2.appointment == null) {
    return 0;
  }

  /// Calculate the both appointment start time based on isAllDay property.
  final DateTime startTime1 = appointmentView1.appointment.isAllDay
      ? _convertToStartTime(appointmentView1.appointment._exactStartTime)
      : appointmentView1.appointment._exactStartTime;
  final DateTime startTime2 = appointmentView2.appointment.isAllDay
      ? _convertToStartTime(appointmentView2.appointment._exactStartTime)
      : appointmentView2.appointment._exactStartTime;

  /// Check if both the appointments does not starts with same date then
  /// order the appointment based on its start time value.
  /// Eg., app1 start with Nov3 and app2 start with Nov4 then compare both
  /// the date value and it returns
  /// a negative value if app1 start time before of app2 start time,
  /// value 0 if app1 start time equal with app2 start time, and
  /// a positive value otherwise (app1 start time after of app2 start time).
  if (!isSameDate(startTime1, startTime2)) {
    return startTime1.compareTo(startTime2);
  }

  final DateTime endTime1 = appointmentView1.appointment.isAllDay
      ? _convertToEndTime(appointmentView1.appointment._exactEndTime)
      : appointmentView1.appointment._exactEndTime;
  final DateTime endTime2 = appointmentView2.appointment.isAllDay
      ? _convertToEndTime(appointmentView2.appointment._exactEndTime)
      : appointmentView2.appointment._exactEndTime;

  /// Check both the appointments have same start and end time then sort the
  /// appointments based on start time value.
  /// Eg., app1 start with Nov3 10AM and ends with 11AM and app2 starts with
  /// Nov3 9AM and ends with 11AM then swap the app2 before of app1.
  if (isSameDate(endTime1, endTime2)) {
    if (appointmentView1.appointment.isAllDay &&
        appointmentView2.appointment.isAllDay) {
      return 0;
    } else if (appointmentView1.appointment.isAllDay &&
        !appointmentView2.appointment.isAllDay) {
      return -1;
    } else if (appointmentView2.appointment.isAllDay &&
        !appointmentView1.appointment.isAllDay) {
      return 1;
    }

    /// Check second appointment start time after the first appointment, then
    /// swap list index value
    return startTime1.compareTo(startTime2);
  }

  /// Check second appointment occupy more cells than first appointment, then
  /// swap list index value.
  /// Eg., app1 start with Nov3 10AM and ends with Nov5 11AM and app2 starts
  /// with Nov3 9AM and ends with Nov4 11AM then swap the app1 before of app2.
  return (startTime2.difference(endTime2).inMinutes.abs())
      .compareTo(startTime1.difference(endTime1).inMinutes.abs());
}

void _updateAppointmentPosition(List<_AppointmentView> appointmentCollection,
    Map<int, List<_AppointmentView>> indexAppointments) {
  appointmentCollection.sort(_orderAppointmentViewBySpanned);

  for (int j = 0; j < appointmentCollection.length; j++) {
    final _AppointmentView appointmentView = appointmentCollection[j];
    if (appointmentView.canReuse || appointmentView.appointment == null) {
      continue;
    }

    appointmentView.position = 1;
    appointmentView.maxPositions = 1;
    _setAppointmentPosition(appointmentCollection, appointmentView, j);

    /// Add the appointment views to index appointment based on start and end
    /// index. It is used to get the visible index appointments.
    for (int i = appointmentView.startIndex;
        i <= appointmentView.endIndex;
        i++) {
      /// Check the index already have appointments, if exists then add the
      /// current appointment to that collection, else create the index and
      /// create new collection with current appointment.
      if (indexAppointments.containsKey(i)) {
        final List<_AppointmentView> existingAppointments =
            indexAppointments[i];
        existingAppointments.add(appointmentView);
        indexAppointments[i] = existingAppointments;
      } else {
        indexAppointments[i] = <_AppointmentView>[appointmentView];
      }
    }
  }
}

int _getDateIndex(DateTime date, List<DateTime> visibleDates) {
  final int count = visibleDates.length;
  DateTime dateTime = visibleDates[count - _kNumberOfDaysInWeek];
  int row = 0;
  for (int i = count - _kNumberOfDaysInWeek;
      i >= 0;
      i -= _kNumberOfDaysInWeek) {
    DateTime currentDate = visibleDates[i];
    currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day,
        currentDate.hour, currentDate.minute, currentDate.second);
    if (currentDate.isBefore(date) ||
        (currentDate.day == date.day &&
            currentDate.month == date.month &&
            currentDate.year == date.year)) {
      dateTime = currentDate;
      row = i ~/ _kNumberOfDaysInWeek;
      break;
    }
  }

  final DateTime endDateTime = addDays(dateTime, 6);
  int currentViewIndex = 0;
  while (dateTime.isBefore(endDateTime) || isSameDate(dateTime, endDateTime)) {
    if (isSameDate(dateTime, date)) {
      return ((row * _kNumberOfDaysInWeek) + currentViewIndex).toInt();
    }

    currentViewIndex++;
    dateTime = addDays(dateTime, 1);
  }

  return -1;
}

_AppointmentView _createAppointmentView(
    List<_AppointmentView> appointmentCollection) {
  _AppointmentView appointmentView;
  for (int i = 0; i < appointmentCollection.length; i++) {
    final _AppointmentView view = appointmentCollection[i];
    if (view.canReuse) {
      appointmentView = view;
      break;
    }
  }

  appointmentView ??= _AppointmentView();

  appointmentView.endIndex = -1;
  appointmentView.startIndex = -1;
  appointmentView.position = -1;
  appointmentView.maxPositions = 0;
  appointmentView.isSpanned = false;
  appointmentView.appointment = null;
  appointmentView.canReuse = true;
  return appointmentView;
}

void _updateAppointment(
    List<Appointment> visibleAppointments,
    List<_AppointmentView> appointmentCollection,
    List<DateTime> visibleDates,
    Map<int, List<_AppointmentView>> indexAppointments,
    int startIndex,
    int endIndex) {
  _createVisibleAppointments(appointmentCollection, visibleAppointments,
      visibleDates, startIndex, endIndex);
  if (visibleAppointments != null && visibleAppointments.isNotEmpty) {
    _updateAppointmentPosition(appointmentCollection, indexAppointments);
  }
}
