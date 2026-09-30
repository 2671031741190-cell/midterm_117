import 'package:flutter/material.dart'; // อิมพอร์ต UI
import 'screens/home_screen.dart'; // ดึงหน้าหลักมาเตรียมรัน

void main() { // ฟังก์ชันหลักแรกสุดที่มือถือแอนดรอยด์/iOS จะวิ่งมาหา
  runApp(const MaintenanceApp()); // สั่งให้ Flutter เอาคลาส MaintenanceApp ไปประกอบร่างเป็นหน้าต่างแอปแล้วเปิดโชว์บนจอซะ
}

class MaintenanceApp extends StatelessWidget { // คลาสนี้เป็น Stateless เพราะหน้าที่มันแค่สั่งตั้งค่าธีมตอนเปิดแอป ไม่ได้ต้องการอัปเดตหน้าจอใดๆ ในจังหวะนี้
  const MaintenanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // เป็นตัวสร้างโครงสร้างให้แอปเราทำงานเป็นรูปแบบแอปในมือถือจริงๆ 
      debugShowCheckedModeBanner: false, // สั่งให้เส้นคาดสีแดงที่เขียนว่า DEBUG มุมบนขวา หายไปเพื่อความเนียนสวยงาม
      title: 'Maintenance Log', // ชื่อแอปหลังบ้าน
      theme: ThemeData( // ใส่สกินให้แอปทั้งแอป
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber), // สั่งให้แอปนี้ทั้งแอพคุมโทนสกินเป็น "สีส้มอำพัน (Amber)"
        useMaterial3: true, // เปิดระบบใช้งานเอฟเฟกต์/รูปทรงที่ทันสมัยเวอร์ชัน 3 ของ Google (Material Design 3)
      ),
      home: const HomeScreen(), // คำสั่งนี้เป็นการผูกว่า พอเปิดแอปมาเสร็จ ให้กระโดดโชว์ไปที่ "หน้าหลัก (HomeScreen)" เป็นหน้าแรกสุดเลยนะ!
    );
  }
}