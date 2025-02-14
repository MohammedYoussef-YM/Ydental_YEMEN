import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:ydental_application/city_Provider.dart';
import 'package:ydental_application/constant.dart';
import 'package:ydental_application/student/View/Widget/custom_dialog.dart';
import 'package:ydental_application/student/View/bottom_navigation_screen.dart';
import '../Model/city_model.dart';
import '../colors.dart';
import 'package:http/http.dart' as http;

class SignUpScreen extends StatefulWidget {
  final String userType;
  SignUpScreen({required this.userType});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _configPassController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _universityIdController = TextEditingController();
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _idSController = TextEditingController();
  final TextEditingController _profilePictureController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  TextEditingController _date_of_birthController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _university_card_numberController = TextEditingController();
  final TextEditingController _id_cardController = TextEditingController();
  TextEditingController _userTypeController = TextEditingController();
  final TextEditingController _idcardController = TextEditingController();
  final ProfileProvider profileProvider = ProfileProvider();
  bool _obscureText = true; // حالة إظهار كلمة المرور
  bool _isLoading = false; // Add loading state
  String _selectedGender = 'ذكر';
  String? _selectedUniversity;
  String? _selectedCity;
  String? _selectedLevel;
  bool passToggle = true;
  File? _profileImage;
  File? _idImage;
  DateTime? _selectedDate;
  final ImagePicker _picker = ImagePicker();
  final List<String> _genders = ['ذكر', 'أنثى'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<ProfileProvider>(context, listen: false).fetchCities());
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        // يتم تعيين تاريخ الميلاد في حقل التحكم
        _date_of_birthController .text = "${picked.toLocal()}".split(' ')[0]; // تنسيق التاريخ
      });
    }
  }

  void _onCitySelected(String? cityId) {
    setState(() {
      _selectedCity = cityId;
      _selectedUniversity = null; // Reset university when city changes
    });
  }

  void _onUniversitySelected(String? universityId) {
    setState(() {
      _selectedUniversity = universityId;
    });
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final url = widget.userType == 'patient'
            ? Uri.parse('$api_local/patients/')
            : Uri.parse('$api_local/students/');

        // Create multipart request for file upload
        var request = http.MultipartRequest('POST', url);

        // Add text fields
        request.fields.addAll({
          'name': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'confirmPassword': _configPassController.text,
          'phone_number': _phoneController.text,
          'gender': _selectedGender,
          'level': _selectedLevel ?? '',
          'university_card_number': _idcardController.text,
          'city_id': _selectedCity ?? '',
          'university_id': _selectedUniversity ?? '',
          'isBlocked': '0',
          'userType': widget.userType,
        });

        // Add image files
        if (_idImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'university_card_image',
            _idImage!.path,
          ));
        }

        if (_profileImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'student_image',
            _profileImage!.path,
          ));
        }

        var response = await request.send();
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);

        if (response.statusCode == 200 || response.statusCode == 201) {
          var data = jsonDecode(responseString);
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('patient', jsonEncode(data));

          showSuccessDialog('تم إنشاء الحساب بنجاح',context);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => StudentBottomNavigation()),
          );
          // Handle successful response
        } else {

          // Handle error
        }
      } catch (e) {

        // Handle exception
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage(bool isIdImage) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isIdImage) {
          _idImage = File(pickedFile.path);
        } else {
          _profileImage = File(pickedFile.path);
        }
      });
    } else {
      print('No image selected.');
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText; // تغيير حالة إظهار كلمة المرور
    });
  }
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _configPassController.dispose();
    _universityIdController.dispose();
    _date_of_birthController.dispose(); // إضافة هذا السطر

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80.0),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            title: Center(
              child: Text(
                'إنشاء حساب كـ ${widget.userType == 'student' ? 'طبيب' : 'مريض'}',
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -.4,
                ),
              ),
            ),
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.primaryColor,
                )),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 250,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'اسم المستخدم',
                          // border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),

                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          // تعبير نمطي للبحث عن أربعة كلمات مفصولة بمسافات
                          final nameRegex = RegExp(r"^[a-zA-Z]+\s[a-zA-Z]+\s[a-zA-Z]+\s[a-zA-Z]+$");
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الاسم';
                          }
                          if (!nameRegex.hasMatch(value)) {
                            return 'الرجاء إدخال اسم رباعي كامل (أحرف فقط)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'البريد الإلكتروني',
                          // border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value){
                          bool emailValid =RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_'{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value!);
                          if(value!.isEmpty){
                            return "Enter Email";
                          }
                          else if(!emailValid){
                            return "Enter Valid Email";
                          }
                        },                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscureText,
                        // إخفاء/إظهار النص بناءً على الحالة
                        decoration: InputDecoration(
                          labelText: 'كلمة المرور',
                          // border: OutlineInputBorder(),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText ? Icons.visibility : Icons
                                  .visibility_off, // تغيير الأيقونة
                            ),
                            onPressed: _togglePasswordVisibility, // وظيفة الضغط
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "يرجى إدخال كلمة المرور";
                          } else if (value.length < 8) {
                            return "يجب أن تكون كلمة المرور أكثر من 8 أحرف";
                          } else if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(
                              value)) {
                            return "يجب أن تحتوي كلمة المرور على أحرف وأرقام";
                          }
                          return null; // إذا كانت التحقق ناجحة
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        keyboardType: TextInputType.visiblePassword,
                        controller: _configPassController,
                        obscureText: passToggle,
                        decoration: const InputDecoration(
                          labelText: "تأكيد كلمة المرور",
                          // border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "يرجى إدخال تأكيد كلمة المرور";
                          } else if (value != _passwordController.text) {
                            return "كلمة المرور غير متطابقة";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'الجنس',
                          // border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          prefixIcon: Icon(Icons.transgender),
                        ),
                        items: _genders.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value!;
                          });
                        },
                        validator: (value) => value == null ? 'يرجى اختيار الجنس' : null,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        keyboardType: TextInputType.phone,
                        controller:  _phoneController,
                        decoration: const InputDecoration(
                          labelText: "رقم الهاتف",
                          // border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رقم الهاتف';
                          }
                          // تعبيرات نمطية للأرقام التي تبدأ بـ 7، 0، أو 2
                          final phoneRegex7 = RegExp(r'^7\d{8}$');
                          final phoneRegex0 = RegExp(r'^0\d{7}$');
                          final phoneRegex2 = RegExp(r'^2\d{5}$');

                          if (value.startsWith('7') && !phoneRegex7.hasMatch(value)) {
                            return 'رقم الهاتف الذي يبدأ بـ 7 يجب أن يكون 9 أرقام';
                          } else if (value.startsWith('0') && !phoneRegex0.hasMatch(value)) {
                            return 'رقم الهاتف الذي يبدأ بـ 0 يجب أن يكون 8 أرقام';
                          } else if (value.startsWith('2') && !phoneRegex2.hasMatch(value)) {
                            return 'رقم الهاتف الذي يبدأ بـ 2 يجب أن يكون 6 أرقام';
                          } else if (!value.startsWith('7') && !value.startsWith('0') && !value.startsWith('2')) {
                            return 'رقم الهاتف يجب أن يبدأ بـ 7 أو 0 أو 2';
                          }
                          return null;
                        },),
                      const SizedBox(height: 16),
                      if (widget.userType == 'patient') ...[
                        TextFormField(
                          controller: _date_of_birthController,
                          decoration: const InputDecoration(
                            labelText: 'تاريخ الميلاد',
                            // border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: () => _selectBirthDate(context),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال تاريخ الميلاد';
                            }

                            // تحويل النص إلى DateTime
                            DateTime? birthDate = DateTime.tryParse(value);
                            if (birthDate == null) {
                              return 'يرجى إدخال تاريخ صحيح';
                            }

                            // حساب العمر
                            DateTime today = DateTime.now();
                            int age = today.year - birthDate.year;

                            // تصحيح العمر إذا لم يكن قد أكمل السنة بعد
                            if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
                              age--;
                            }

                            // تحقق من أن العمر بين 2 و130
                            if (age < 2 || age > 130) {
                              return 'يجب أن يكون العمر بين سنتين و130 سنة';
                            }

                            return null; // التحقق ناجح
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'العنوان',
                            // border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                            prefixIcon: Icon(Icons.home),
                          ),
                          validator: (value) => value!.isEmpty ? 'يرجى إدخال العنوان' : null,
                        ),
                        const SizedBox(height: 16),


                      ] else ...[
                        SingleChildScrollView(
                          child: Consumer<ProfileProvider>(
                            builder: (context, provider, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // DropdownButtonFormField<String>(
                                  //   value: _selectedCity,
                                  //   decoration: const InputDecoration(labelText: 'المدينة',border: OutlineInputBorder() ,
                                  //     // focusedBorder: OutlineInputBorder(
                                  //     // borderSide: BorderSide(
                                  //     //   color: AppColors.primaryColor,
                                  //     // ),
                                  //     // ),
                                  //   ),
                                  //   items: provider.cities.map((city) {
                                  //     return DropdownMenuItem(
                                  //       value: city.name,
                                  //       child: Text(city.name),
                                  //     );
                                  //   }).toList(),
                                  //   onChanged: (cityName) {
                                  //     provider.updateCity(cityName);
                                  //   },
                                  //   validator: (value) => value == null ? 'اختر المدينة' : null,
                                  // ),
                                  // const SizedBox(height: 20),
                                  // DropdownButtonFormField<University>(
                                  //   decoration: const InputDecoration(labelText: 'الجامعة ',border: OutlineInputBorder(),
                                  //     // focusedBorder: OutlineInputBorder(
                                  //     //   borderSide: BorderSide(
                                  //     //     color: AppColors.primaryColor,
                                  //     //   ),
                                  //     // ),
                                  //   ),
                                  //   items: provider.universities.map((university) {
                                  //     return DropdownMenuItem(
                                  //       value: university,
                                  //       child: Text(university.name),
                                  //     );
                                  //   }).toList(),
                                  //   value: provider.selectedUniversity,
                                  //   onChanged: (university) {
                                  //     provider.updateUniversity(university);
                                  //   },
                                  //   validator: (value) => value == null ? 'ادخل جامعتك' : null,
                                  // ),
                                  const SizedBox(height: 20),
                                  DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: 'المدينة',
                                      focusedBorder: OutlineInputBorder(),
                                    ),
                                    onChanged: (value) {
                                      provider.updateCity(value);
                                      _onCitySelected(value); // Should be string ID
                                    },
                                    items: provider.cities.isNotEmpty
                                        ? provider.cities.map((city) {
                                      return DropdownMenuItem(
                                        value: city.id,
                                        child: Text(city.name),
                                      );
                                    }).toList()
                                        : [],
                                  ),
                                  const SizedBox(height: 20),
                                  DropdownButtonFormField<University>(
                                    decoration: const InputDecoration(
                                      labelText: 'الجامعة',
                                      focusedBorder: OutlineInputBorder(),
                                    ),
                                    items: provider.universities.map<DropdownMenuItem<University>>((university) {
                                      return DropdownMenuItem<University>(
                                        value: university,
                                        child: Text(university.name),
                                      );
                                    }).toList(),
                                    onChanged: (university) {
                                      provider.updateUniversity(university);
                                      _onUniversitySelected(university?.id.toString());
                                    },
                                    validator: (value) => value == null ? 'ادخل جامعتك' : null,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _selectedLevel,
                          items: [
                            'الثاني',
                            'الثالث',
                            'الرابع',
                            'الخامس',
                            'امتياز',
                            'ماجستير',
                            'دكتوراه',
                          ].map((String level) {
                            return DropdownMenuItem<String>(
                              value: level,
                              child: Text('المستوى $level'), // Add "المستوى" prefix only for display
                            );
                          }).toList(),
                          decoration: const InputDecoration(
                            labelText: 'المستوى',
                            // border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedLevel = value;
                            });
                          },
                          validator: (value) => value == null ? 'يرجى اختيار المستوى' : null,                        ),
                        // DropdownButtonFormField<String>(
                        //   value: _selectedLevel,
                        //   decoration: const InputDecoration(
                        //     labelText: 'المستوى',
                        //     // border: OutlineInputBorder(),
                        //     focusedBorder: OutlineInputBorder(
                        //       borderSide: BorderSide(
                        //         color: AppColors.primaryColor,
                        //       ),
                        //     ),
                        //   ),
                        //   items: [
                        //     ' المستوى الثاني',
                        //     'المستوى الثالث',
                        //     'المستوى الرابع',
                        //     'المستوى الخامس',
                        //     'امتياز',
                        //     'ماجستير',
                        //     'دكتوراه',
                        //   ].map((String level) {
                        //     return DropdownMenuItem<String>(
                        //       value: level,
                        //       child: Text(level),
                        //     );
                        //   }).toList(),
                        //   onChanged: (value) {
                        //     setState(() {
                        //       _selectedLevel = value;
                        //     });
                        //   },
                        //   validator: (value) => value == null ? 'يرجى اختيار المستوى' : null,
                        // ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _idcardController,
                          decoration: const InputDecoration(
                            labelText: 'الرقم الاكاديمي',
                            // border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.phone, // إظهار لوحة مفاتيح الأرقام
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال الرقم الأكاديمي';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _pickImage(true),
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'إرفاق صورة البطاقة الشخصية (إجباري)',
                              // border: OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              prefixIcon: const Icon(Icons.image),
                              suffixIcon: _idImage != null
                                  ? IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  setState(() {
                                    _idImage = null; // Remove the selected image
                                  });
                                },
                              )
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(

                          onTap: () => _pickImage(false),
                          child: TextFormField(
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'إرفاق الصورة الشخصية (اختياري)',
                              // border: OutlineInputBorder(),
                              focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              prefixIcon: const Icon(Icons.image),
                              suffixIcon: _profileImage != null
                                  ? IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  setState(() {
                                    _profileImage = null; // Remove the selected image
                                  });
                                },
                              )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 150,
                        height: 40,
                        child:ElevatedButton(
                          onPressed: _register, // استدعاء دالة التسجيل
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                          ),
                          child: _isLoading // Show loading indicator if _isLoading is true
                              ? const Center(child: CircularProgressIndicator()) // Center the indicator
                              : const Text(
                            'إنشاء حساب',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}