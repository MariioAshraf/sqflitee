import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../tables/tenant_table.dart';
import '../tables/role_table.dart';
import '../tables/user_table.dart';
import '../tables/user_church_role_table.dart';
import '../tables/area_table.dart';
import '../tables/street_table.dart';
import '../tables/family_table.dart';
import '../tables/family_member_table.dart';
import '../tables/service_table.dart';
import '../tables/class_table.dart';
import '../tables/enrollment_table.dart';
import '../tables/attendance_session_table.dart';
import '../tables/attendance_table.dart';
import '../tables/priest_family_visitation_table.dart';
import '../tables/servant_user_visitation_table.dart';
import '../tables/user_note_table.dart';
import '../tables/family_note_table.dart';

class AppDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'church_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    // Enable foreign key support in SQLite
    await db.execute('PRAGMA foreign_keys = ON');

    // ── 1. Tenancy & Auth ──────────────────────────────────────
    await db.execute(TenantTable.create);
    // await db.execute(RoleTable.create);
    await db.execute(UserTable.create);
    // await db.execute(UserChurchRoleTable.create);
    //
    // ── 2. Geographic Hierarchy ────────────────────────────────
    await db.execute(AreaTable.create);
    await db.execute(StreetTable.create);
    // await db.execute(FamilyTable.create);
    // await db.execute(FamilyMemberTable.create);

    // // ── 3. Service Management ──────────────────────────────────
    // await db.execute(ServiceTable.create);
    // await db.execute(ClassTable.create);
    // await db.execute(EnrollmentTable.create);
    //
    // // ── 4. Attendance ──────────────────────────────────────────
    // await db.execute(AttendanceSessionTable.create);
    // await db.execute(AttendanceTable.create);
    //
    // // ── 5. Visitations & Notes ─────────────────────────────────
    // await db.execute(PriestFamilyVisitationTable.create);
    // await db.execute(ServantUserVisitationTable.create);
    // await db.execute(UserNoteTable.create);
    // await db.execute(FamilyNoteTable.create);
  }
}