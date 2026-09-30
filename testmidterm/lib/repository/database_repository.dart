import 'package:path/path.dart'; // อิมพอร์ตแพ็กเกจ path สำหรับหาตำแหน่งโฟลเดอร์ในเครื่องมือถือ
import 'package:sqflite/sqflite.dart'; // อิมพอร์ตแพ็กเกจ sqflite เพื่อใช้เครื่องมือทำงานกับ SQLite
import '../models/maintenance.dart'; // อิมพอร์ตคลาสโมเดลจากไฟล์ maintenance.dart เข้ามาใช้งาน

class DatabaseRepository { // ประกาศคลาสชื่อ DatabaseRepository
  static const _dbName = 'maintenance_log.db'; // สร้างตัวแปรคงที่ (const) เก็บชื่อไฟล์ฐานข้อมูล (นามสกุล .db)
  static const _tableName = 'maintenances'; // สร้างตัวแปรคงที่เก็บชื่อ "ตาราง" ในฐานข้อมูล

  // ฟังก์ชันภายในสำหรับเปิดหรือสร้างไฟล์ฐานข้อมูล
  static Future<Database> _database() async { // เป็น async เพราะต้องรอเครื่องมือถือทำงานประมวลผลหาโฟลเดอร์
    return openDatabase( // ใช้คำสั่งเปิดฐานข้อมูล
      join(await getDatabasesPath(), _dbName), // join คือการเอาเส้นทางโฟลเดอร์ลึกๆ ในมือถือ มารวมกับชื่อไฟล์ 'maintenance_log.db'
      onCreate: (db, version) { // กรณีที่แอปเพิ่งโหลดมาติดตั้งครั้งแรก ยังไม่มีฐานข้อมูล ให้ทำฟังก์ชันนี้
        return db.execute( // สั่งให้ฐานข้อมูลรันคำสั่ง SQL สร้างตาราง
          // รัน SQL สร้างตาราง ประกอบด้วยคอลัมน์ id (รันเลข 1,2,3 อัตโนมัติ), ชื่อ, อาการ, ความด่วน, วันเวลา
          'CREATE TABLE $_tableName(id INTEGER PRIMARY KEY AUTOINCREMENT, device TEXT, issue TEXT, urgency TEXT, createdAt TEXT)',
        );
      },
      version: 1, // กำหนดเวอร์ชันของโครงสร้างฐานข้อมูล
    ); // ปิด openDatabase
  } // ปิดฟังก์ชัน

  // 1. ฟังก์ชันเพิ่มข้อมูลแจ้งซ่อมใหม่ (รับค่าออบเจกต์ Maintenance เข้ามา)
  static Future<void> insert({required Maintenance maintenance}) async {
    final db = await _database(); // รอให้ฟังก์ชันด้านบนไปเชื่อมต่อฐานข้อมูลให้เสร็จก่อน แล้วเก็บใส่ตัวแปร db
    await db.insert( // สั่งให้ยัดข้อมูล (insert) ลงไปในตาราง
      _tableName, // ยัดลงตารางชื่อ 'maintenances'
      maintenance.toMap(), // แปลงออบเจกต์เป็น Map ตามที่เราเขียนไว้ในไฟล์แรก
      conflictAlgorithm: ConflictAlgorithm.replace, // หากเกิดข้อผิดพลาดคีย์ซ้ำ ให้เขียนทับข้อมูลเก่าไปเลย (replace)
    ); 
  }

  // 2. ฟังก์ชันดึงรายการแจ้งซ่อมทั้งหมด (คืนค่ากลับไปเป็น List ของกล่อง Maintenance)
  static Future<List<Maintenance>> getMaintenances() async {
    final db = await _database(); // เปิดการเชื่อมต่อฐานข้อมูล
    final List<Map<String, dynamic>> maps = await db.query(_tableName); // ดึงข้อมูลทุกแถวจากตาราง มาเก็บเป็นกล่อง Map ในรูปแบบ List
    return List.generate(maps.length, (i) { // ใช้ Loop วนสร้างออบเจกต์ Maintenance ตามจำนวนข้อมูลที่ดึงมาได้
      return Maintenance( // ส่งค่าคืนออกไปเป็นออบเจกต์ Maintenance คืนค่าใส่หน้าจอ
        id: maps[i]['id'] as int, // ดึงค่าช่อง id มาบอกว่าเป็นตัวเลข (int)
        device: maps[i]['device'] as String, // ดึงข้อความชื่ออุปกรณ์
        issue: maps[i]['issue'] as String, // ดึงข้อความอาการเสีย
        urgency: maps[i]['urgency'] as String, // ดึงระดับความเร่งด่วน
        createdAt: DateTime.parse(maps[i]['createdAt']), // ดึงข้อความ String แล้วใช้ DateTime.parse แปลงร่างกลับให้เป็นวันเวลาเหมือนเดิม
      );
    });
  }

  // 3. ฟังก์ชันลบรายการแจ้งซ่อมเมื่อซ่อมเสร็จแล้ว
  static Future<void> delete({required Maintenance maintenance}) async {
    final db = await _database(); // เปิดการเชื่อมต่อฐานข้อมูล
    await db.delete( // ใช้คำสั่งลบ
      _tableName, // ลบจากตารางนี้
      where: 'id = ?', // เงื่อนไขคือ "ให้ลบแถวที่คอลัมน์ id มีค่าเท่ากับตัวแปรที่ส่งมา" (? เพื่อป้องกันการโดนแฮกฐานข้อมูล)
      whereArgs: [maintenance.id], // เอาเลข id จากของที่ต้องการจะลบ ไปใส่แทนที่เครื่องหมาย ? ในบรรทัดบน
    );
  }
}