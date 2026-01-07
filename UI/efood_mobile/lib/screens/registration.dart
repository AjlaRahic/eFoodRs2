import 'dart:convert';
import 'dart:io';

import 'package:efood_mobile/main.dart';
import 'package:efood_mobile/models/korisnik.dart';
import 'package:efood_mobile/models/search_result.dart';
import 'package:efood_mobile/models/uloga.dart';
import 'package:efood_mobile/models/user_insert.dart';
import 'package:efood_mobile/models/user_role_insert.dart';
import 'package:efood_mobile/models/user_role_update.dart';
import 'package:efood_mobile/providers/korisnik_provider.dart';
import 'package:efood_mobile/providers/korisnik_uloga_provider.dart';
import 'package:efood_mobile/providers/uloga_provider.dart';
import 'package:efood_mobile/screens/korisnik_profile_screen.dart';
import 'package:efood_mobile/utils/util.dart';
import 'package:efood_mobile/widgets/master_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  Korisnik? user;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordRepeatController =
      TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surenameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _korisnickoImeController =
      TextEditingController();

  RegisterScreen({super.key, this.user});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _showPassword = false;
  bool _showRepeatPassword = false;
  Color _emailColor = Colors.black;
  Color _nameColor = Colors.black;
  Color _surenameColor = Colors.black;
  Color _phoneNumberColor = Colors.black;
  Color _passwordColor = Colors.black;
  Color _korisnickoImeColor = Colors.black;

  late KorisnikProvider _userProvider;
  late KorisnikUlogaProvider _userRoleProvider;
  late UlogaProvider _roleProvider;

  SearchResult<Uloga>? result;
  SearchResult<Korisnik>? resultU;
  String? selectedRole;
  List<Uloga>? roles;
  List<Korisnik>? users; 
  bool _isLoading = true;

  bool get _isSelfReg => widget.user == null;

  bool validateEmail(TextEditingController controller) {
    final emailRegex = RegExp(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+");
    if (controller.text.isEmpty) {
      setState(() => _emailColor = Colors.red);
      return false;
    } else if (!emailRegex.hasMatch(controller.text)) {
      setState(() => _emailColor = Colors.red);
      return false;
    }
    setState(() => _emailColor = Colors.black);
    return true;
  }

  bool validateEmailExistance(TextEditingController controller) {
    if (users == null) return true; 
    if (widget.user != null) {
      users!.removeWhere((user) => user.email == widget.user!.email);
    }
    bool exists = users!.any((u) => u.email == controller.text);
    if (exists) {
      _emailColor = Colors.red;
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (_) => AlertDialog(
          title:
              const Text("Došlo je do greške", textAlign: TextAlign.center),
          content: const Text("Email adresa je već registrovana.Molim pokušajte sa drugom email adresom.",
              textAlign: TextAlign.center),
          actions: [
            ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Ok")),
          ],
        ),
      );
      return false;
    }
    setState(() => _emailColor = Colors.black);
    return true;
  }

  bool validateName(TextEditingController controller, bool isName) {
    if (controller.text.isEmpty) {
      setState(
          () => isName ? _nameColor = Colors.red : _surenameColor = Colors.red);
      return false;
    }
    if (controller.text.length < 2 || controller.text.length > 50) {
      setState(
          () => isName ? _nameColor = Colors.red : _surenameColor = Colors.red);
      return false;
    }
    setState(() =>
        isName ? _nameColor = Colors.black : _surenameColor = Colors.black);
    return true;
  }

  bool validateUserName(TextEditingController controller, bool isUserName) {
    if (controller.text.isEmpty) {
      setState(() =>
          isUserName ? _nameColor = Colors.red : _surenameColor = Colors.red);
      return false;
    }
    if (controller.text.length < 2 || controller.text.length > 50) {
      setState(() => isUserName
          ? _nameColor = Colors.red
          : _korisnickoImeColor = Colors.red);
      return false;
    }
    setState(() => isUserName
        ? _nameColor = Colors.black
        : _korisnickoImeColor = Colors.black);
    return true;
  }

  bool validatePhoneNumber(TextEditingController controller) {
    final phoneRegex = RegExp(r"^\+?[0-9]*$");
    if (controller.text.isEmpty || !phoneRegex.hasMatch(controller.text)) {
      setState(() => _phoneNumberColor = Colors.red);
      return false;
    }
    setState(() => _phoneNumberColor = Colors.black);
    return true;
  }

  bool validatePasswords(TextEditingController p1, TextEditingController p2) {
    if (p1.text.isEmpty || p1.text != p2.text) {
      setState(() => _passwordColor = Colors.red);
      return false;
    }
    setState(() => _passwordColor = Colors.black);
    return true;
  }

  @override
  void initState() {
    super.initState();
    _userProvider = context.read<KorisnikProvider>();
    _userRoleProvider = context.read<KorisnikUlogaProvider>();
    _roleProvider = context.read<UlogaProvider>();

    if (_isSelfReg) {
      _isLoading = false;
    } else {
      _loadData(); 
    }
  }

  Future<void> _loadData() async {
    final data = await _roleProvider.get();
    final dataU = await _userProvider.get();

    setState(() {
      result = data;
      roles = result?.result ?? [];

      resultU = dataU;
      users = resultU?.result ?? [];

      if (widget.user != null) {
        widget._emailController.text = widget.user!.email ?? '';
        widget._nameController.text = widget.user!.korisnickoIme ?? '';
        widget._surenameController.text = widget.user!.prezime ?? '';
        widget._phoneController.text = widget.user!.telefon ?? '';
        widget._korisnickoImeController.text = widget.user!.korisnickoIme ?? '';
      }

      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width: 400,
                child: Card(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: <Widget>[
                        Image.asset('assets/images/pizza.jpg',
                            width: 450, height: 100),
                        const SizedBox(height: 20),
                        Text(
                          (_isSelfReg)
                              ? 'Registriraj se'
                              : "Promijeni podatke za radnika ${widget.user!.korisnickoIme}",
                          style: const TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),
                        TextField(
                          controller: widget._nameController,
                          decoration: InputDecoration(
                            labelText: 'Ime',
                            prefixIcon: const Icon(Icons.info),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            errorText: _nameColor == Colors.red
                                ? 'Ime nije uredu. Ime može imati min 2 slova i max 50'
                                : null,
                          ),
                          keyboardType: TextInputType.name,
                          style: TextStyle(color: _nameColor),
                          onChanged: (_) =>
                              validateName(widget._nameController, true),
                        ),
                        if (!_isSelfReg) ...[
                          const SizedBox(height: 8),
                          Text(
                              "Ime je bilo: ${widget.user?.korisnickoIme ?? ''}"),
                        ],

                        const SizedBox(height: 10),
                        TextField(
                          controller: widget._surenameController,
                          decoration: InputDecoration(
                            labelText: 'Prezime',
                            prefixIcon: const Icon(Icons.info),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            errorText: _surenameColor == Colors.red
                                ? 'Prezime nije uredu. Prezime može imati min 2 slova i max 50'
                                : null,
                          ),
                          keyboardType: TextInputType.name,
                          style: TextStyle(color: _surenameColor),
                          onChanged: (_) =>
                              validateName(widget._surenameController, false),
                        ),
                        if (!_isSelfReg) ...[
                          const SizedBox(height: 8),
                          Text(
                              "Prezime je bilo: ${widget.user?.prezime ?? ''}"),
                        ],

                        const SizedBox(height: 16),
                        TextField(
                          controller: widget._korisnickoImeController,
                          decoration: InputDecoration(
                            labelText: 'KorisnickoIme',
                            prefixIcon: const Icon(Icons.info),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            errorText: _korisnickoImeColor == Colors.red
                                ? 'Korisnicko ime nije uredu. Ime može imati min 2 slova i max 50'
                                : null,
                          ),
                          keyboardType: TextInputType.name,
                          style: TextStyle(color: _korisnickoImeColor),
                          onChanged: (_) => validateUserName(
                              widget._korisnickoImeController, true),
                        ),
                        if (!_isSelfReg) ...[
                          const SizedBox(height: 8),
                          Text(
                              "Korisnicko ime je bilo: ${widget.user?.korisnickoIme ?? ''}"),
                        ],

                        const SizedBox(height: 10),
                        TextField(
                          controller: widget._emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            errorText: _emailColor == Colors.red
                                ? 'Email nije uredu. Format mora biti: example@email.com'
                                : null,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: _emailColor),
                          onChanged: (_) =>
                              validateEmail(widget._emailController),
                        ),
                        if (!_isSelfReg) ...[
                          const SizedBox(height: 8),
                          Text("Email je bio: ${widget.user?.email ?? ''}"),
                        ],

                        const SizedBox(height: 10),
                        TextField(
                          controller: widget._phoneController,
                          decoration: InputDecoration(
                            labelText: 'Telefon',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0)),
                            errorText: _phoneNumberColor == Colors.red
                                ? 'Broj telefona može samo imati brojeve'
                                : null,
                          ),
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: _phoneNumberColor),
                          onChanged: (_) =>
                              validatePhoneNumber(widget._phoneController),
                        ),
                        if (!_isSelfReg) ...[
                          const SizedBox(height: 8),
                          Text("Telefon je bio: ${widget.user?.telefon ?? ''}"),
                        ],

                        if (_isSelfReg) ...[
                          const SizedBox(height: 10),
                          TextField(
                            controller: widget._passwordController,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              labelText: 'Lozinka',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () => setState(
                                    () => _showPassword = !_showPassword),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              errorText: _passwordColor == Colors.red
                                  ? 'Lozinka i ponovljena lozinka moraju biti iste.'
                                  : null,
                            ),
                            style: TextStyle(color: _passwordColor),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: widget._passwordRepeatController,
                            obscureText: !_showRepeatPassword,
                            decoration: InputDecoration(
                              labelText: 'Ponovite Lozinku',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(_showRepeatPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () => setState(() =>
                                    _showRepeatPassword = !_showRepeatPassword),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0)),
                              errorText: _passwordColor == Colors.red
                                  ? 'Lozinka i ponovljena lozinka moraju biti iste.'
                                  : null,
                            ),
                            style: TextStyle(color: _passwordColor),
                          ),
                        ],

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => LoginPage()),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                surfaceTintColor:
                                     Colors.white,
                                overlayColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 15.0),
                              ),
                              child: const Text('Nazad'),
                            ),
                            const SizedBox(width: 50),

                            ElevatedButton(
                              onPressed: () async {
                                if (_isSelfReg) {
                                  if (!validateName(
                                          widget._nameController, true) ||
                                      !validateName(
                                          widget._surenameController, false) ||
                                      !validateEmail(widget._emailController) ||
                                      !validatePhoneNumber(
                                          widget._phoneController) ||
                                      !validatePasswords(
                                          widget._passwordController,
                                          widget._passwordRepeatController)) {
                                    return;
                                  }
                                  try {
                                    final korisnik = await context
                                        .read<KorisnikProvider>()
                                        .register(
                                          username: widget
                                              ._korisnickoImeController.text
                                              .trim(), 
                                          password:
                                              widget._passwordController.text,
                                          ime: widget._nameController.text
                                              .trim(),
                                          prezime: widget
                                              ._surenameController.text
                                              .trim(),
                                        );

                                    Authorization.username = widget
                                        ._korisnickoImeController.text
                                        .trim();
                                    Authorization.password =
                                        widget._passwordController.text;
                                    Authorization.korisnik = korisnik;
                                    Authorization.userId = korisnik.id;

                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Uspješno ste se registrovali!')),
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => LoginPage()),
                                    );
                                  } catch (e) {
                                    _showError('Greška pri registraciji: $e');
                                  }
                                  return;
                                }

                                if (!validateEmailExistance(
                                    widget._emailController)) return;
                                if (!validateName(
                                        widget._nameController, true) ||
                                    !validateName(
                                        widget._surenameController, false) ||
                                    !validateEmail(widget._emailController) ||
                                    !validatePhoneNumber(
                                        widget._phoneController)) {
                                  return;
                                }

                                try {
                                  if (widget.user != null) {
                                    final newUser = Korisnik(
                                      id: widget.user!.id,
                                      ime: widget._nameController.text,
                                      prezime: widget._surenameController.text,
                                      email: widget._emailController.text,
                                      telefon: widget._phoneController.text,
                                    );
                                    await _userProvider.update(
                                        widget.user!.id!, newUser);

                                    if (!mounted) return;
                                    _showRoleDialog(isEdit: true);
                                  } else {
                                    final newUser = UserInsert(
                                      widget._nameController.text,
                                      widget._surenameController.text,
                                      widget._emailController.text,
                                      widget._phoneController.text,
                                      widget._passwordController.text,
                                      widget._passwordRepeatController.text,
                                      1,
                                    );
                                    await _userProvider.insert(newUser);

                                    if (!mounted) return;
                                    _showRoleDialog(isEdit: false);
                                  }
                                } on Exception {
                                  if (!mounted) return;
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Greška u registraciji",
                                          textAlign: TextAlign.center),
                                      content: const Text(
                                          "Došlo je do greške. Pokušajte ponovo!",
                                          textAlign: TextAlign.center),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text("OK")),
                                      ],
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(86, 156, 99, 77),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                overlayColor: Colors.brown,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 15.0),
                              ),
                              child:
                                  Text(_isSelfReg ? 'Registriraj' : 'Sačuvaj'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        if (_isSelfReg)
                          TextButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage())),
                            child: const Text('Već imate račun?'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoleDialog({required bool isEdit}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(
              isEdit ? "Uspješno ažuriran radnik" : "Uspješno dodan radnik",
              textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit
                    ? "Uspješno ste ažurirali izabranog radnika! Izaberite novu ulogu za radnika:"
                    : "Uspješno ste dodali novog radnika! Izaberite ulogu za radnika:",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              DropdownButton<String>(
                value: selectedRole,
                hint: const Text("Izaberite ulogu"),
                onChanged: (String? v) => setSt(() => selectedRole = v),
                items: (roles ?? [])
                    .map((u) => DropdownMenuItem<String>(
                          value: u.naziv,
                          child: Text(u.naziv ?? ''),
                        ))
                    .toList(),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  if (roles == null || roles!.isEmpty || selectedRole == null) {
                    Navigator.pop(ctx);
                    return;
                  }
                  final role = roles!
                      .firstWhere((r) => r.naziv!.startsWith(selectedRole!));
                  if (isEdit) {
                    final update = UserRoleUpdate(role.ulogaId);
                    await _userRoleProvider.update(
                      widget.user!.korisniciUloges![0].korisnikUlogaId!,
                      update,
                    );
                  } else {
                    final userSearch = await _userProvider.get();
                    final user = userSearch.result.last;
                    final insert = UserRoleInsert(user.id!, role.ulogaId);
                    await _userRoleProvider.insert(insert);
                  }
                  if (!mounted) return;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => KorisnikProfileScreen()));
                },
                child: const Text("Ok"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Greška", textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          ElevatedButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }
}
