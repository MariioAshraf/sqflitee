class FamilyTable {
  static const String tableName = 'families';

  static const String colId = 'id';
  static const String colTenantId = 'tenant_id';
  static const String colStreetId = 'street_id';
  static const String colFamilyName = 'family_name';
  static const String colBuildingNumber = 'building_number';
  static const String colApartmentNumber = 'apartment_number';
  static const String colLatitude = 'latitude';
  static const String colLongitude = 'longitude';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';

  static const String create = '''
    CREATE TABLE $tableName (
      $colId                TEXT PRIMARY KEY,
      $colTenantId          TEXT NOT NULL,
      $colStreetId          TEXT NOT NULL,
      $colFamilyName        TEXT NOT NULL,
      $colBuildingNumber    TEXT,
      $colApartmentNumber   TEXT,
      $colLatitude          REAL,
      $colLongitude         REAL,
      $colCreatedAt         TEXT NOT NULL DEFAULT (datetime('now')),
      $colUpdatedAt         TEXT NOT NULL DEFAULT (datetime('now')),
      FOREIGN KEY ($colTenantId) REFERENCES tenants(id) ON DELETE CASCADE,
      FOREIGN KEY ($colStreetId) REFERENCES streets(id) ON DELETE CASCADE
    )
  ''';
}
