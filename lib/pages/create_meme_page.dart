import 'package:flutter/material.dart';
import 'package:memogenerator/blocs/create_meme_bloc.dart';
import 'package:memogenerator/resources/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateMemePage extends StatefulWidget {
  const CreateMemePage({
    super.key,
  });

  @override
  State<CreateMemePage> createState() => _CreateMemePageState();
}

class _CreateMemePageState extends State<CreateMemePage> {
  late CreateMemeBloc bloc = CreateMemeBloc();

  @override
  void initState() {
    super.initState();
    bloc = CreateMemeBloc();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: bloc,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Создаем мем',
            style:
                GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          centerTitle: true,
          backgroundColor: AppColors.lemon,
          foregroundColor: AppColors.darkgray,
          bottom: const EditTextBar(),
        ),
        backgroundColor: Colors.white,
        body: const SafeArea(
          child: CreateMemePageContent(),
        ),
      ),
    );
  }
}

class EditTextBar extends StatefulWidget implements PreferredSizeWidget {
  const EditTextBar({super.key});

  @override
  State<EditTextBar> createState() => _EditTextBarState();

  @override
  Size get preferredSize => const Size.fromHeight(68);
}

class _EditTextBarState extends State<EditTextBar> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      //height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: StreamBuilder<MemeText?>(
          stream: bloc.observeSelectedMemeText(),
          builder: (context, snapshot) {
            final MemeText? selectedMemeText =
                snapshot.hasData ? snapshot.data : null;
            if (selectedMemeText?.text != controller.text) {
              final newText = selectedMemeText?.text ?? '';
              controller.text = newText;
              controller.selection =
                  TextSelection.collapsed(offset: newText.length);
            }
            return TextField(
                enabled: selectedMemeText != null,
                controller: controller,
                onChanged: (text) {
                  if (selectedMemeText != null) {
                    bloc.changeMemeText(selectedMemeText.id, text);
                  }
                },
                onEditingComplete: () => bloc.deselectMemeText(),
                decoration: InputDecoration(
                    fillColor: AppColors.darkgray6, filled: true));
          }),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class CreateMemePageContent extends StatefulWidget {
  const CreateMemePageContent({super.key});

  @override
  State<CreateMemePageContent> createState() => _CreateMemePageContentState();
}

class _CreateMemePageContentState extends State<CreateMemePageContent> {
  late FocusNode textFieldSearchFocusNode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(
          flex: 2,
          child: MemeCanvasWidget(),
        ),
        const Divider(height: 1, color: AppColors.darkgray),
        Expanded(
          flex: 1,
          child: Container(
            color: AppColors.white,
            child: ListView(
              children: const [
                SizedBox(height: 12),
                AddNewMemeTextButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MemeCanvasWidget extends StatelessWidget {
  const MemeCanvasWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      color: AppColors.darkgray38,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          color: AppColors.white,
          child: StreamBuilder<List<MemeText>>(
              initialData: const <MemeText>[],
              stream: bloc.observeMemeTexts(),
              builder: (context, snapshot) {
                final memeTexts =
                    snapshot.hasData ? snapshot.data! : <MemeText>[];
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: memeTexts.map((element) {
                        return DraggableMemeText(
                          memeText: element,
                          parentConstraints: constraints,
                        );
                      }).toList(),
                    );
                  },
                );
              }),
        ),
      ),
    );
  }
}

class DraggableMemeText extends StatefulWidget {
  final MemeText memeText;
  final BoxConstraints parentConstraints;

  const DraggableMemeText({
    super.key,
    required this.memeText,
    required this.parentConstraints,
  });

  @override
  State<DraggableMemeText> createState() => _DraggableMemeTextState();
}

class _DraggableMemeTextState extends State<DraggableMemeText> {
  double top = 0;
  double left = 0;
  final double padding = 8;

  @override
  void initState() {
    top = widget.parentConstraints.minWidth / 2;
    left = widget.parentConstraints.minWidth / 3;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);

    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => bloc.selectMemeText(widget.memeText.id),
          onPanUpdate: (details) {
            setState(() {
              top = calculateVertical(details);
              left = calculateHorizontal(details);
            });
          },
          child: Container(
            constraints: BoxConstraints(
                maxWidth: widget.parentConstraints.maxWidth,
                maxHeight: widget.parentConstraints.maxHeight),
            padding: EdgeInsets.all(padding),
            child: Text(
              widget.memeText.text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black),
            ),
          )),
    );
  }

  double calculateHorizontal(DragUpdateDetails details) {
    final newPosition = left + details.delta.dx;
    if (newPosition < 0) {
      return 0;
    } else if (newPosition >
        widget.parentConstraints.maxWidth - padding * 2 - 10) {
      return widget.parentConstraints.maxWidth - padding * 2 - 10;
    }

    return newPosition;
  }

  double calculateVertical(DragUpdateDetails details) {
    final newPosition = top + details.delta.dy;

    if (newPosition < 0) {
      return 0;
    } else if (newPosition >
        widget.parentConstraints.maxHeight - padding * 2 - 24) {
      return widget.parentConstraints.maxHeight - padding * 2 - 24;
    }
    return newPosition;
  }
}

class AddNewMemeTextButton extends StatelessWidget {
  const AddNewMemeTextButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        bloc.addNewText();
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add,
                color: AppColors.fuchsia,
              ),
              const SizedBox(
                width: 8,
              ),
              Text(
                'Добавить текст'.toUpperCase(),
                style: const TextStyle(
                    color: AppColors.fuchsia,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              )
            ],
          ),
        ),
      ),
    );
  }
}
