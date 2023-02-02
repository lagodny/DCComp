unit uDCStrResource;

interface

resourcestring
//7100, "OK"
//7101, "Cancel"
//7102, "Help"
  dcResS_OK = 'OK';
  dcResS_Cancel = 'Cancel';
  dcResS_Help = 'Help';
//
//7001, "Stream not created"
//8001, "Operation canceled by user"
  dcResS_StreamNotCreated = 'Stream not created';
  dcResS_OperationCanceledByUser = 'Operation canceled by user';
//
//9001, "Authorization %s (%s:%d)"
//9002, "Load namespace %s (%s:%d)"
//9003, "Load lookups %s (%s:%d)"
  dcResS_AuthorizationOnServerFmt = 'Authorization %s (%s:%d)';
  dcResS_LoadNamespaceFmt = 'Load namespace %s (%s:%d)';
  dcResS_LoadLookupsFmt = 'Load lookups %s (%s:%d)';
//
//9010, "Authorization %s"
//9011, "User"
//9012, "Password"
//9013, "Change password..."
  dcResS_AuthorizationFmt = 'Authorization %s';
  dcResS_User = 'User';
  dcResS_Password = 'Password';
  dcResS_ChangePasswordDlg = 'Change password...';
//
//9020, "Change password"
//9021, "User"
//9022, "Old password"
//9023, "New password"
//9024, "Confirmation"
  dcResS_ChangePassword = 'Change password';
//  dcResS_ = '';
  dcResS_OldPassword = 'Old password';
  dcResS_NewPassword = 'New password';
  dcResS_Confirmation = 'Confirmation';
//
//9030, "The passwords do not match."
//9031, "Password changed successfully"
//9032, "Unable to change password: %s"
  dcResS_PasswordsNotMatch = 'The passwords do not match.';
  dcResS_PasswordChangedSuccessfully = 'Password changed successfully';
  dcResS_UnableChangePasswordFmt = 'Unable to change password: %s';
//
//9100, "Today"
//9101, "Yesterday"
//9102, "Beginning of the week"
//9103, "Last Week"
//9104, "Beginning of the month"
//9105, "Last Month"
//9106, "Tomorrow"
//9107, "Next Week"
//9108, "Next 12 hours,"
//9109, "Next day"
//9110, "%s last hours"
//9111, "%s last days"
//9112, "This year"
//9113, "Last year"
  dcResS_Today = 'Today';
  dcResS_Yesterday = 'Yesterday';
  dcResS_BeginningOfTheWeek = 'Beginning of the week';
  dcResS_LastWeek = 'Last Week';
  dcResS_BeginningOfTheMonth = 'Beginning of the month';
  dcResS_LastMonth = 'Last Month';
  dcResS_Tomorrow = 'Tomorrow';
  dcResS_NextWeek = 'Next Week';
  dcResS_Next12Hours = 'Next 12 hours';
  dcResS_NextDay = 'Next day';
  dcResS_N_LastHoursFmt = '%s last hours';
  dcResS_N_LastDaysFmt = '%s last days';
  dcResS_ThisYear = 'This year';
  dcResS_LastYear = 'Last year';
//
//9120, "hour"
//9121, "day"
  dcResS_Hour = 'hour';
  dcResS_Day = 'day';
//
//9150, "for last"
//9151, "for day"
//9152, "for month"
//9153, "for period"
  dcResS_ForLast = 'for last';
  dcResS_ForDay = 'for day';
  dcResS_ForMonth = 'for month';
  dcResS_ForPeriod = 'for period';
//
//9160, "From"
//9161, "to"
  dcResS_From = 'From';
  dcResS_to = 'to';
//
//9162, "Period"
  dcResS_Period = 'Period';
//
//9180, "Period"
//  dcResS_ = '';
//
//10000, "A new version of the program available: %d. Install?"
//10001, "No update available"
//10002, "Unable to download the new version of the program."
//10003, "Setup successfully loaded to %sStart it?"
//10004, "Downloading... %s"
  dcResS_NewVersionAvailableFmt = 'A new version of the program available: %d. Install?';
  dcResS_NoUpdateAvailable = 'No update available';
  dcResS_UnableToDownloadNewVersion = 'Unable to download the new version of the program.';
  dcResS_ConfirmStartSetupFmt = 'Setup successfully loaded to %s. Start it?';
  dcResS_DownloadingFmt = 'Downloading... %s';



implementation

end.
