import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zockblock_app/core/consent/crash_report_consent.dart';
import 'package:zockblock_app/core/consent/crash_report_consent_provider.dart';

/// Schaltet Crashlytics passend zur Einwilligung scharf und liefert, ob
/// gerade gesammelt werden darf.
///
/// Einzige Stelle, die `setCrashlyticsCollectionEnabled` aufruft. Sie liegt
/// bewusst nicht im [crashReportConsentProvider]: der bleibt reine
/// Speicherung und damit ohne initialisiertes Firebase testbar.
final crashReportingProvider = Provider<bool>((ref) {
  final consent = ref.watch(crashReportConsentProvider).value;
  final granted = consent == CrashReportConsent.granted;

  unawaited(
    FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(granted),
  );

  return granted;
});
