import 'package:dis_app/blocs/user/user_bloc.dart';
import 'package:dis_app/blocs/user/user_event.dart';
import 'package:dis_app/blocs/user/user_state.dart';
import 'package:dis_app/controllers/user_controller.dart';
import 'package:dis_app/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController(text: '******');

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  String? _url;

  late UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    _userBloc = UserBloc(userController: UserController());
    _userBloc.add(UserGetEvent());
    _userBloc.stream.listen((state) {
      if (state is UserSuccess && state.data != null) {
        setState(() {
          _nameController.text = state.data?['name'] ?? '';
          _emailController.text = state.data?['email'] ?? '';
          _usernameController.text = state.data?['username'] ?? '';
          _phoneController.text = state.data?['phone'] ?? '';
          _url = state.data?['photo'];
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _updateProfile() {
    _userBloc.add(UserChangeProfileEvent(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      username: _usernameController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _userBloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: DisColors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: DisColors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Edit Profile',
            style:
                TextStyle(color: DisColors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        body: BlocConsumer<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message ?? 'Success')),
              );
            } else if (state is UserFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is UserLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _url != null
                                  ? NetworkImage(_url!)
                                  : const AssetImage(
                                          'assets/images/dummies/content.jpg')
                                      as ImageProvider,
                            ),
                            GestureDetector(
                              onTap: () {
                                // Handle profile picture update
                              },
                              child: CircleAvatar(
                                backgroundColor: DisColors.primary,
                                radius: 18,
                                child: const Icon(Icons.edit,
                                    color: DisColors.black, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                            _nameController, 'Name', _nameFocusNode),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                            _emailController, 'Email', _emailFocusNode),
                        const SizedBox(height: 16),
                        _buildTextFormField(_usernameController, 'Username',
                            _usernameFocusNode),
                        const SizedBox(height: 16),
                        _buildTextFormField(
                            _phoneController, 'Phone Number', _phoneFocusNode),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextFormField(
                                _passwordController,
                                'Password',
                                _passwordFocusNode,
                                obscureText: true,
                                readOnly: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacementNamed(
                                    context, '/change-password');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DisColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Change Password',
                                style: TextStyle(color: DisColors.black),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              _showLogoutConfirmationDialog(context);
                            },
                            icon: const Icon(Icons.logout,
                                color: DisColors.error),
                            label: const Text(
                              'Log Out',
                              style: TextStyle(color: DisColors.error),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: DisColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(color: DisColors.black),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextFormField(
    TextEditingController controller,
    String labelText,
    FocusNode focusNode, {
    bool obscureText = false,
    bool readOnly = false,
  }) {
    return Focus(
      focusNode: focusNode,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: labelText,
          border:
              OutlineInputBorder(borderSide: BorderSide(color: DisColors.grey)),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: DisColors.primary, width: 2.0)),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          labelStyle: TextStyle(
            color: focusNode.hasFocus
                ? DisColors.textPrimary
                : DisColors.darkerGrey,
          ),
          fillColor: DisColors.lightGrey,
          filled: true,
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Add logout logic here
                Navigator.pop(context);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  void _showSaveConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Save'),
          content: const Text('Do you want to save the changes?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
