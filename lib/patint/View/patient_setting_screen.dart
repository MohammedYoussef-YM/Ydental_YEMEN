
import 'package:flutter/material.dart';
import 'package:ydental_application/patint/View/change_password_screen.dart';
import '../../ThemeNotifier.dart';
import '../../colors.dart';
import 'package:provider/provider.dart';


class PatientSettingsScreen extends StatefulWidget {
  @override
  State<PatientSettingsScreen > createState() => _PatientSettingsScreenState();
}

class _PatientSettingsScreenState extends State<PatientSettingsScreen > {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Center(child: Text('الإعدادات',style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: -.4,
          ),)),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,color: AppColors.primaryColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            ExpansionTile(
              title: Text('خيارات الاعدادات',style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,

              )),
              children: <Widget>[
                ListTile(
                  title: Text('تغيير اللغة'),
                  leading: Icon(
                    Icons.language,

                  ),
                  onTap: () {
                    // Handle change language action
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('تغيير اللغة'),
                          content: Text('اختر اللغة .'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('عربي'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('English'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: Text('تغيير كلمة المرور'),
                  leading: Icon(
                    Icons.lock_open,

                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PasswordForm(),
                        ));

                  },
                ),
                // ListTile(
                //   title: Text('نسيت كلمة المرور'),
                //   leading: Icon(
                //     Icons.question_mark,
                //
                //   ),
                //   onTap: () {},
                // ),
                ListTile(
                  title: Text('تفعيل الوضع الليلي'),
                  trailing: Switch(
                    value: themeNotifier.isDarkMode,
                    onChanged: (value) {
                      themeNotifier.toggleTheme(); // Toggle the theme
                    },
                    activeTrackColor: AppColors.secondaryColor,
                    activeColor: primary,
                  ),
                  leading: Icon(
                    Icons.dark_mode,

                  ),
                  onTap: () {},
                ),
                Divider(
                  color: Colors.grey,
                  indent: 40,
                  endIndent: 40,
                ),
                ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: AppColors.errorColor,
                  ),
                  title: Text('تسجيل الخروج'),
                  hoverColor: AppColors.primaryColor,
                  onTap: () {
                    // تنفيذ إجراء عند الضغط على هذا العنصر (مثل فتح صفحة الاتصال)
                    Navigator.pop(context);
                    // ...
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );

  }
}
