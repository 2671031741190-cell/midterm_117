import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // อิมพอร์ต intl สำหรับจัดรูปแบบเวลา (ข้อบังคับของโจทย์)
import '../models/maintenance.dart';
import '../repository/database_repository.dart';
import 'add_maintenance_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ฟังก์ชันวาดป๊อปอัปเด้งเตือน (AlertDialog) เมื่อผู้ใช้กดรูปติ๊กถูกจะเคลียร์รายการ
  _confirmDelete(Maintenance item) {
    showDialog( // สั่งวาดป๊อปอัปบนจอ
      context: context,
      builder: (context) => AlertDialog( // สร้างกล่องสนทนา
        title: const Text("ยืนยันซ่อมเสร็จสิ้น"), // หัวข้อใหญ่
        content: Text("ซ่อมอุปกรณ์ '${item.device}' เรียบร้อยแล้ว ต้องการเคลียร์รายการนี้ใช่หรือไม่?"), // ข้อความถาม ดึงชื่ออุปกรณ์มาโชว์ด้วย
        actions: [ // ปุ่มให้กดด้านล่างกล่อง
          TextButton( // ปุ่มที่ 1
            onPressed: () => Navigator.pop(context), // ถ้ายกเลิก ก็แค่ปิดป๊อปอัปนี้ไปซะ
            child: const Text("ยังไม่เสร็จ"),
          ),
          TextButton( // ปุ่มที่ 2
            onPressed: () async {
              Navigator.pop(context); // ปิดกล่องป๊อปอัปก่อนอันดับแรก
              await DatabaseRepository.delete(maintenance: item); // 💡 สั่งฐานข้อมูล SQLite ลบไอเทมนี้ออกจากฐานข้อมูลแบบถาวร
              setState(() {}); // 💡 สำคัญมาก! สั่งรีเฟรชหน้าจอทั้งหมด 1 รอบเพื่อให้กล่องรายการที่ลบไปนั้น หายวับไปจากหน้าจอทันที
            },
            child: const Text("ซ่อมเสร็จแล้ว (ลบ)", style: TextStyle(color: Colors.green)), // ทำสีเขียวเพื่อบอกว่าดีนะ ซ่อมเสร็จแล้ว
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ระบบแจ้งซ่อมบำรุง ⚙️"),
        backgroundColor: Colors.amber.shade800,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [ // ปุ่มขวาบน
          IconButton( // สร้างปุ่มวงกลมรีเฟรชด้วยมือ
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {}), // พอกดให้มันสั่ง build หน้าจอซ้ำใหม่เพื่อดึงฐานข้อมูลล่าสุดมาใหม่
          ),
        ],
      ),
      // 💡 จุดดึงข้อมูลมาแสดง: ใช้ FutureBuilder เพราะข้อมูลมาจาก SQLite ซึ่งจะใช้เวลาดึงระดับเสี้ยววินาที หน้าจอเลยต้อง "รอรับ (Future)"
      body: FutureBuilder<List<Maintenance>>(
        future: DatabaseRepository.getMaintenances(), // โทรไปบอกฐานข้อมูลให้เอาลิสต์ทั้งหมดมา
        builder: (context, snapshot) { // วาดจอตามสถานะที่รอได้
          if (snapshot.connectionState == ConnectionState.done) { // ถ้าสถานะเชื่อมต่อเสร็จสมบูรณ์แล้ว (เชื่อมข้อมูลได้ครบแล้ว)
            if (snapshot.data == null || snapshot.data!.isEmpty) { // เช็คก่อน ถ้าไม่มีงานค้างเลย (กล่องฐานข้อมูลโล่ง)
              return const Center( // ให้วาดข้อความไว้กึ่งกลางหน้าจอ
                child: Text("ไม่มีรายการแจ้งซ่อมค้างในระบบ 👍", style: TextStyle(fontSize: 18, color: Colors.grey)),
              );
            }
            // แต่ถ้ามันมีข้อมูลงานค้าง ให้วาด ListView เพื่อให้จอมันสไลด์(เลื่อน)ได้เหมือนหน้าเฟสบุ๊ค
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: snapshot.data!.length, // บอกว่าให้สไลด์สร้างกล่องเท่ากับจำนวนฐานข้อมูลที่ดึงมานะ เช่น ดึงมา 5 แถว ก็สร้าง 5 การ์ด
              itemBuilder: (context, index) { // เริ่มวาดลูปการ์ดตาม index ไปทีละแผ่น
                final item = snapshot.data![index];   // ดูดข้อมูลแถวนั้นๆ มาใส่กล่องตัวแปรชื่อ item เพื่อให้อ่านง่าย ถ้าแก้เป็น .reversed.toList() จะถ้าข้อมูลใหม่มาใส่ข้างบน
                final isUrgent = item.urgency == 'ด่วนที่สุด'; // 🚨 สร้างตัวแปรแฟล็ก (ธง) เช็คว่า แถวนั้นถูกเลือกความเร่งด่วน = "ด่วนที่สุด" ใช่ไหม ถ้าใช่ ค่านี้จะเป็น True

                return Card( // วาดแผ่นการ์ดพื้นหลัง
                  elevation: isUrgent ? 6 : 2, // 💡 ถ้าเงื่อนไขเป็นด่วนที่สุด (True) จะเงาเข้ม (6) ถ้าระดับปกติจะเงาบางๆ (2) (if-else แบบย่อ "? : ")
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    // 💡 เช็คเงื่อนไข 3 สเต็ป:
                    side: item.urgency == 'ด่วนที่สุด'
                    ? const BorderSide(color: Color.fromARGB(255, 255, 0, 0), width: 2) // 1. ถ้าด่วนที่สุด -> กรอบสีแดง หนา 2px
                    : item.urgency == 'ด่วน'
                     ? const BorderSide(color: Color.fromARGB(255, 255, 179, 2), width: 2) // 2. ถ้าด่วน -> กรอบสีเหลืองอำพัน หนา 
                      : BorderSide.none,
                     // 3. ถ้าเป็นปกติ -> ไม่ต้องมีกรอบ
                  //borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile( // เป็นแม่แบบการจัดวางแถวที่มี ไอคอนซ้าย หัวข้อ และ ไอคอนขวา
                    contentPadding: const EdgeInsets.all(12),
                    // ไอคอนหน้าสุดของการ์ด
                    leading: CircleAvatar(
                      backgroundColor: isUrgent ? Colors.red : const Color.fromRGBO(255, 224, 178, 1), // ถ้าด่วนสุดพื้นวงกลมแดง ถ้าปกติพื้นส้มอ่อน
                      child: Icon(
                        isUrgent ? Icons.warning_amber_rounded : Icons.build_rounded, // ถ้าด่วนสุดให้รูปสามเหลี่ยมเตือนเตือนภัย ถ้าปกติให้รูปประแจซ่อม
                        color: isUrgent ? Colors.white : Colors.orange.shade900,
                      ),
                    ),
                    title: Row( // หัวข้อการ์ด วาดเป็น Row ซ้ายและขวา
                      children: [
                        Expanded( // ส่วนแรกดันเนื้อหาให้ขยายเต็มที่
                          child: Text(
                            item.device, // ปริ้นชื่อเครื่องจักรลงมา
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        // ส่วนที่สองคือ แถบป้ายสี (Badge) เล็กๆ มุมบนของการ์ด
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            // 💡 เล่นสี 3 ระดับ: ด่วนที่สุด=แดง | ด่วน=ส้ม | ปกติ=เทา
                            color: isUrgent ? Colors.red : (item.urgency == 'ด่วน' ? Colors.orange : Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text( // พิมพ์คำระดับความด่วนลงไปในกล่อง Badge เล็กๆ นั้น
                            item.urgency,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column( // เนื้อหาย่อยใต้ชื่อเครื่อง
                      crossAxisAlignment: CrossAxisAlignment.start, // ชิดซ้าย
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          "อาการเสีย: ${item.issue}", 
                          style: const TextStyle(fontSize: 15),
                          maxLines: 4, // 💡 สั่งให้บนการ์ดโชว์ข้อความสูงสุดแค่ 2 หรือ 3 บรรทัดก็พอ
                          overflow: TextOverflow.ellipsis, // 💡 ถ้าข้อความมันยาวเกินบรรทัดที่กำหนด ให้ตัดทิ้งแล้วโชว์จุดไข่ปลา (...) แทน
                        ),
                        const SizedBox(height: 8),
                        Text(
                          // 💡 จัดฟอร์แมตวันเวลาด้วย DateFormat จากแพ็กเกจ intl ตามโจทย์สั่งเป๊ะ! ให้แสดงเป็น วัน เดือนย่อ ปี - เวลา น.
                          "แจ้งเมื่อ: ${DateFormat('dd MMM yyyy - HH:mm น.').format(item.createdAt)}", 
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: IconButton( // ไอคอนปุ่มทางขวาสุดของการ์ด
                      icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 30), // ปุ่มติ๊กถูกวงกลมสีเขียว
                      tooltip: "เคลียร์รายการ (ซ่อมเสร็จแล้ว)", // ข้อความลอยถ้าเอานิ้วกดแช่
                      onPressed: () => _confirmDelete(item), // เมื่อโดนกด ให้ขึ้นไปเรียกใช้ฟังก์ชันเด้ง AlertDialog ถามเพื่อเคลียร์ข้อมูล (Delete) ทิ้ง
                    ),
                  ),
                );
              },
            );
          }
          // ถ้ารอจังหวะ 0.5 วิ ตอนกำลังโหลดเข้า SQLite ให้วาดลูกข่างวงกลมสีส้มหมุนติ้วๆ ตรงกลางจอรอก่อน
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended( // ปุ่มวงกลมดักหน้ามุมล่างขวาเพื่อจะกดไปหน้าแจ้งงาน
        onPressed: () {
          // สลับหน้าไปเขียนแจ้งซ่อม
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMaintenanceScreen()),
          );
        },
        backgroundColor: Colors.amber.shade800, // สีส้ม
        foregroundColor: Colors.white, // ไอคอนสีขาว
        icon: const Icon(Icons.add_rounded), // รูปบวก
        label: const Text("แจ้งซ่อมใหม่"), // ข้อความในปุ่ม
      ),
    );
  }
}