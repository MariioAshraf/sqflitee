import 'package:shared_preferences/shared_preferences.dart';

final class SyncMetaService {
  static const _areasLastGetSyncKey = 'areas_last_get_sync_date';
  static const _areasLastPostSyncKey = 'areas_last_post_sync_date';
  static const _streetsLastGetSyncKey  = 'streets_last_get_sync_date';
  static const _streetsLastPostSyncKey = 'streets_last_post_sync_date';

  final SharedPreferences _prefs;

  const SyncMetaService(this._prefs);

  Future<String?> getAreasLastGetSyncDate() async =>
      _prefs.getString(_areasLastGetSyncKey);

  Future<void> setAreasLastGetSyncDate(String date) async =>
      _prefs.setString(_areasLastGetSyncKey, date);

  Future<String?> getAreasLastPostSyncDate() async =>
      _prefs.getString(_areasLastPostSyncKey);

  Future<void> setAreasLastPostSyncDate(String date) async =>
      _prefs.setString(_areasLastPostSyncKey, date);

  Future<String?> getStreetsLastGetSyncDate() async =>
      _prefs.getString(_streetsLastGetSyncKey);

  Future<void> setStreetsLastGetSyncDate(String date) async =>
      _prefs.setString(_streetsLastGetSyncKey, date);

  Future<String?> getStreetsLastPostSyncDate() async =>
      _prefs.getString(_streetsLastPostSyncKey);

  Future<void> setStreetsLastPostSyncDate(String date) async =>
      _prefs.setString(_streetsLastPostSyncKey, date);
}
