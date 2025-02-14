import 'package:flutter/material.dart';
import 'colors.dart';

class AboutUsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Center(
              child: Text(
                'من نحن',
                style: TextStyle(
                  color: AppColors.iconColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -.4,// لون النص

                ),
              ),
            ),
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.iconColor,
                )),

          ),

        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحبًا بكم في Ydentel',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'تطبيق Ydentel هو المنصة المثالية التي تربط بين طلاب طب الأسنان والمرضى. '
                    'نهدف إلى تسهيل عملية الحجز وجعلها أكثر سلاسة وفعالية. من خلال تطبيقنا، يمكن للمرضى '
                    'تحديد مواعيد مع طلاب طب الأسنان الذين يتلقون التدريب العملي في عيادات الأسنان.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'مميزات التطبيق:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '- حجز مواعيد بسهولة.\n'
                    '- اختيار طبيب الأسنان المناسب.\n'
                    '- متابعة حالة الحجز عبر التطبيق.\n'
                    '- تقييم الخدمات المقدمة.\n',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'نحن نسعى لتقديم تجربة مميزة ومريحة لكل من الطلاب والمرضى. '
                    'انضموا إلينا اليوم واستمتعوا بخدمات طبية عالية الجودة.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// استخدام الشاشة في أيقونة "من نحن"
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ydentel'),
        actions: [
          IconButton(
            icon: Icon(Icons.info),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('مرحبا بكم في Ydentel!'),
      ),
    );
  }
}
