import 'package:flutter/material.dart'; // อิมพอร์ต UI พื้นฐานของ Flutter
import '../models/maintenance.dart'; // อิมพอร์ตโมเดลข้อมูล
import '../repository/database_repository.dart'; // อิมพอร์ตเครื่องมือฐานข้อมูล
import 'home_screen.dart'; // อิมพอร์ตหน้าหลักเพื่อจะใช้สลับหน้ากลับ

class AddMaintenanceScreen extends StatefulWidget { // สร้าง State แบบ StateFul เพื่อให้จอมันรับค่าเปลี่ยนแปลงตอนพิมพ์ได้
  const AddMaintenanceScreen({super.key});
  @override
  State<AddMaintenanceScreen> createState() => _AddMaintenanceScreenState();
}

class _AddMaintenanceScreenState extends State<AddMaintenanceScreen> {
  final _formKey = GlobalKey<FormState>(); // กุญแจสำคัญ! เอาไว้ใช้ล็อกและเช็คว่า ฟอร์มทั้งหมดกรอกข้อมูลครบตามเงื่อนไขหรือยัง

  String _device = ''; // ตัวแปรเปล่ารอรับชื่อเครื่องจักร
  String _issue = ''; // ตัวแปรเปล่ารอรับอาการเสีย
  String _urgency = 'ปกติ'; // ตั้งค่าระดับความด่วนแรกสุดไว้ที่คำว่า 'ปกติ'

  final List<String> _urgencyOptions = ['ปกติ', 'ด่วน', 'ด่วนที่สุด']; // สร้างลิสต์เตรียมคำให้เมนู Dropdown

  // ฟังก์ชันนี้จะทำงานเมื่อผู้ใช้กดปุ่ม "บันทึกการแจ้งซ่อม" ด้านล่างสุด
  _saveForm() async {
    if (_formKey.currentState!.validate()) { // คำสั่งนี้ไปตรวจว่า ช่องพิมพ์ทั้งหน้ามีข้อความครบถ้วนใช่หรือไม่? (ตามเงื่อนไข validator)
      _formKey.currentState!.save(); // ถ้ากรอกครบ ให้สั่ง save เพื่อดูดข้อความจากช่องพิมพ์ วิ่งไปเข้าตัวแปร String 3 ตัวด้านบน

      // เรียกช่างเครื่อง (DatabaseRepository) ให้ยัดข้อมูล (insert) ลง SQLite
      await DatabaseRepository.insert(
        maintenance: Maintenance( // ส่งแพ็กเกจข้อมูลออบเจกต์ไป
          device: _device, // ใส่ชื่อเครื่องที่ดูดมาได้
          issue: _issue, // ใส่อาการที่ดูดมาได้
          urgency: _urgency, // ใส่ความด่วนจากดรอปดาวน์
          createdAt: DateTime.now(), // ดึงวันเวลาของเครื่องมือถือ "ณ วินาทีที่กดปุ่มเซฟนี้เลย" มาบันทึก
        ),
      );

      // ถ้าบันทึกเสร็จ ให้ทำสิ่งนี้ต่อ
        if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) { // ส่วนเริ่มวาดหน้าจอ UI
    return Scaffold( // วาดโครงจอ
      appBar: AppBar( // แถบบน
        title: const Text("แจ้งซ่อมอุปกรณ์ 🛠️"),
        backgroundColor: Colors.amber.shade800, // ส้มอำพันเข้มๆ (อารมณ์วิศวะ)
        foregroundColor: Colors.white, // อักษรขาว
      ),
      body: SingleChildScrollView( // ป้องกันคีย์บอร์ดมือถือเด้งขึ้นมาบังจอแล้วเกิด Error สีเหลืองดำ
        padding: const EdgeInsets.all(20), // ขอบห่าง 20
        child: Form( // ประกาศบอกว่าก้อนนี้คือแบบฟอร์ม
          key: _formKey, // ผูกกุญแจไว้ให้ _saveForm เช็คได้
          child: Column( // เรียงจากบนลงล่าง
            children: [
              // 1. วาดช่องกรอกชื่ออุปกรณ์
              TextFormField(
                decoration: const InputDecoration( // ตกแต่งช่องพิมพ์
                  labelText: "ชื่ออุปกรณ์ / เครื่องจักร", // ข้อความลอยๆ
                  prefixIcon: Icon(Icons.build_rounded), // ใส่ไอคอนรูปประแจหน้าช่อง
                  border: OutlineInputBorder(), // ให้ช่องเป็นกรอบสี่เหลี่ยมรอบทิศ
                ),
                // เช็คว่า ถ้าผู้ใช้ไม่ได้พิมพ์อะไรเลย (null หรือ ค่าว่าง) ให้โชว์คำเตือนสีแดง "กรุณาป้อน..." ถ้าพิมพ์แล้วให้ตอบผ่าน (null)
                validator: (value) => (value == null || value.isEmpty) ? "กรุณาป้อนชื่ออุปกรณ์" : null,
                onSaved: (value) => _device = value!, // ถ้าผ่านแล้ว ตอนสั่ง save ให้เอาข้อความ (value) มาใส่ตัวแปร _device
              ),
              const SizedBox(height: 15), // กล่องล่องหนเว้นช่องไฟ 15

              // 2. วาดช่องอาการเสีย (ทำตามโจทย์เป๊ะคือ maxLines: 4)
              TextFormField(
                maxLines: 4, // 💡 บังคับให้เป็นช่องพิมพ์ความสูง 4 บรรทัดตามโจทย์
                decoration: const InputDecoration(
                  labelText: "อาการเสีย / ปัญหาที่พบ",
                  alignLabelWithHint: true, // ดันคำบรรยาย Label ให้ลอยอยู่ขอบบนสุดของกล่อง (ไม่ให้อยู่ตรงกลางเพราะกล่องมันสูง)
                  prefixIcon: Icon(Icons.report_problem_rounded), // รูปสามเหลี่ยมเตือน
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || value.isEmpty) ? "กรุณาป้อนอาการเสีย" : null, // เช็คห้ามเว้นว่างเหมือนเดิม
                onSaved: (value) => _issue = value!, // เซฟลงตัวแปร _issue
              ),
              const SizedBox(height: 15),

              // 3. วาดช่อง Dropdown เลือกความเร่งด่วน
              DropdownButtonFormField<String>( // บอกว่าดรอปดาวน์นี้ข้อมูลข้างในคือตัวหนังสือ (String)
                value: _urgency, // โชว์คำแรกให้เป็นคำว่า "ปกติ" (ตามที่ตั้งค่าไว้ในตัวแปร _urgency)
                decoration: const InputDecoration(
                  labelText: "ระดับความเร่งด่วน",
                  prefixIcon: Icon(Icons.speed_rounded), // รูปไมล์ความเร็ว
                  border: OutlineInputBorder(),
                ),
                items: _urgencyOptions.map((option) { // เอาลิสต์คำที่มี ('ปกติ', 'ด่วน', 'ด่วนที่สุด') มาลูปทำเป็นเมนูกด
                  return DropdownMenuItem(
                    value: option, // ซ่อนค่าไว้หลังบ้านเมื่อโดนกด
                    child: Text(option), // ข้อความที่โชว์ให้ผู้ใช้เห็น
                  );
                }).toList(), // ต้องทำเป็น list กลับไป
                onChanged: (value) => setState(() => _urgency = value!), // เมื่อคลิกเปลี่ยนด่วนที่สุด ให้เอาค่านั้นมาอัปเดตลงตัวแปรหลักทันทีด้วย setState
              ),
              const SizedBox(height: 25), // เว้น 25 ก่อนปุ่ม

              // วาดปุ่มกดเซฟ
              FilledButton.icon(
                style: FilledButton.styleFrom( // แต่งปุ่ม
                  backgroundColor: Colors.amber.shade800, // พื้นหลังปุ่มสีส้ม
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), // ความอ้วนและกว้างของปุ่ม
                ),
                icon: const Icon(Icons.save_rounded), // ใส่ไอคอนรูปเซฟ
                label: const Text("บันทึกการแจ้งซ่อม", style: TextStyle(fontSize: 18)), // ข้อความบนปุ่ม
                onPressed: _saveForm, // เมื่อคลิกปุ่ม ให้ขึ้นไปเรียกใช้ฟังก์ชันเช็คฟอร์ม _saveForm ด้านบนสุด
              ),
            ],
          ),
        ),
      ),
    );
  }
}