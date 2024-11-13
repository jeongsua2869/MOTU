// ignore_for_file: dead_code

import 'package:flutter/material.dart';
import 'package:motu/src/features/login/service/auth_service.dart';
import 'package:motu/src/features/login/view/register_success.dart';
import 'package:motu/src/design/color_theme.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController passwordConfirmController =
      TextEditingController();

  final TextEditingController nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    AuthService service = Provider.of<AuthService>(context);

    // Email Validation
    final FocusNode emailFocus = FocusNode();
    String? emailErrorText;
    bool isEmailValid = true;

    const String privacyPolicyUrl =
        "https://amused-power-1c0.notion.site/5704c05a8fdb471a8b23f38b3ecb77f1";

    void launchURL() async {
      if (!await launchUrl(Uri.parse(privacyPolicyUrl))) {
        throw Exception('Could not launch $privacyPolicyUrl');
      }
    }

    GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('회원가입'),
        ),
        body: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Consumer<AuthService>(builder: (context, service, child) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: size.height * 0.06),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          SizedBox(height: size.height * 0.05),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '이메일',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.63,
                                child: TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    // 이메일 형식 검사 및 도메인 검사
                                    final emailRegex = RegExp(
                                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                                    if (!emailRegex.hasMatch(value!)) {
                                      return emailErrorText;
                                    }
                                    return null;
                                  },
                                  focusNode: emailFocus,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: ColorTheme.Grey1,
                                    hintText: '이메일을 입력하세요',
                                    hintStyle: const TextStyle(
                                      color: ColorTheme.Black5,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: isEmailValid
                                          ? BorderSide.none
                                          : const BorderSide(
                                              color: Colors.red,
                                              width: 0.5,
                                            ),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                    ),
                                    errorText: emailErrorText,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '비밀번호',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.63,
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: ColorTheme.Grey1,
                                    hintText: '비밀번호를 입력하세요',
                                    hintStyle: TextStyle(
                                      color: ColorTheme.Black5,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '비밀번호 확인',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.63,
                                child: TextFormField(
                                  obscureText: true,
                                  controller: passwordConfirmController,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: ColorTheme.Grey1,
                                    hintText: '비밀번호를 다시 입력하세요',
                                    hintStyle: TextStyle(
                                      color: ColorTheme.Black5,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '이름',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(
                                width: size.width * 0.63,
                                child: TextFormField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    filled: true,
                                    fillColor: ColorTheme.Grey1,
                                    hintText: '이름을 입력하세요',
                                    hintStyle: TextStyle(
                                      color: ColorTheme.Black5,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Column(
                        children: [
                          SizedBox(
                            width: size.width * 0.75,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    service.setPrivacyPolicyChecked();
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check,
                                        color: service.isPrivacyPolicyChecked
                                            ? ColorTheme.Purple1
                                            : ColorTheme.Black4,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        '개인정보 처리방침 동의',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: launchURL,
                                  child: const Text(
                                    '보기',
                                    style: TextStyle(
                                      color: ColorTheme.Purple1,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                          TextButton(
                            onPressed: (emailController.text.isNotEmpty &&
                                    passwordController.text.isNotEmpty &&
                                    passwordConfirmController.text.isNotEmpty &&
                                    nameController.text.isNotEmpty &&
                                    service.isPrivacyPolicyChecked)
                                ? () {
                                    if (formKey.currentState!.validate()) {
                                      final authService =
                                          Provider.of<AuthService>(context,
                                              listen: false);
                                      authService.registerWithEmailAndPassword(
                                          emailController.text,
                                          passwordController.text,
                                          nameController.text);

                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterSuccessPage(),
                                          ));
                                    }
                                  }
                                : null,
                            style: TextButton.styleFrom(
                              backgroundColor:
                                  (emailController.text.isNotEmpty &&
                                          passwordController.text.isNotEmpty &&
                                          passwordConfirmController
                                              .text.isNotEmpty &&
                                          nameController.text.isNotEmpty &&
                                          service.isPrivacyPolicyChecked)
                                      ? ColorTheme.Purple1
                                      : ColorTheme.Black5,
                              foregroundColor: ColorTheme.White,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              minimumSize: Size(size.width * 0.8, 55),
                            ),
                            child: const Text(
                              '회원가입',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
