import 'package:flutter/material.dart';
import 'package:memogenerator/blocs/main_bloc.dart';
import 'package:memogenerator/pages/create_meme_page.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late MainBloc bloc = MainBloc();

  @override
  void initState() {
    super.initState();
    bloc = MainBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Мемогенератор',
            style: GoogleFonts.seymourOne(
                fontSize: 24, fontWeight: FontWeight.w400),
          ),
          centerTitle: true,
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkgray,
        ),
        backgroundColor: Colors.white,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const CreateMemePage(),
              ),
            );
          },
          label: const Text(
            'Создать',
          ),
          backgroundColor: AppColors.fuchsia,
          foregroundColor: AppColors.white,
          icon: const Icon(Icons.add),
        ),
        body: const SafeArea(
          child: MainPageContent(),
        ),
      ),
    );
  }
}

class MainPageContent extends StatefulWidget {
  const MainPageContent({super.key});

  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  late FocusNode textFieldSearchFocusNode;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
