// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:memogenerator/blocs/create_meme_bloc.dart';
import 'package:memogenerator/resources/app_colors.dart';

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
            final selected = selectedMemeText != null;
            return TextField(
              enabled: selected,
              controller: controller,
              onChanged: (text) {
                if (selected) {
                  bloc.changeMemeText(selectedMemeText.id, text);
                }
              },
              onEditingComplete: () => bloc.deselectMemeText(),
              cursorColor: AppColors.fuchsia,
              decoration: InputDecoration(
                fillColor: selected ? AppColors.fuchsia16 : AppColors.darkgray6,
                filled: true,
                hintText: selected ? 'Ввести текст' : '',
                hintStyle: TextStyle(fontSize: 16, color: AppColors.darkgray38),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.fuchsia38, width: 1),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.darkgray38, width: 1),
                ),
                focusColor: AppColors.fuchsia16,
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(width: 2),
                ),
              ),
            );
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
    return const Column(
      children: [
        Expanded(
          flex: 2,
          child: MemeCanvasWidget(),
        ),
        Divider(height: 1, color: AppColors.darkgray),
        Expanded(
          flex: 1,
          child: BottomList(),
        ),
      ],
    );
  }
}

class BottomList extends StatelessWidget {
  const BottomList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<CreateMemeBloc>(context, listen: false);
    return Container(
      color: AppColors.white,
      child: StreamBuilder<List<MemeTextWithSelection>>(
          stream: bloc.observeMemeTextWithSelection(),
          initialData: const <MemeTextWithSelection>[],
          builder: (context, snapshot) {
            final items =
                snapshot.hasData ? snapshot.data! : <MemeTextWithSelection>[];
            return ListView.separated(
              itemCount: items.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return const AddNewMemeTextButton();
                }
                final item = items[index - 1];
                return BottomMemeText(item: item);
              },
              separatorBuilder: (BuildContext context, int index) {
                if (index == 0) {
                  return const SizedBox.shrink();
                }
                return const BottomSeparator();
              },
            );
          }),
    );
  }
}

class BottomSeparator extends StatelessWidget {
  const BottomSeparator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      height: 1,
      color: AppColors.darkgray,
    );
  }
}

class BottomMemeText extends StatelessWidget {
  const BottomMemeText({
    super.key,
    required this.item,
  });

  final MemeTextWithSelection item;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: item.selected ? AppColors.darkgray16 : Colors.transparent,
      alignment: Alignment.centerLeft,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        item.memeText.text,
        style: const TextStyle(
            color: AppColors.darkgray,
            fontSize: 16,
            fontWeight: FontWeight.w400),
      ),
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
        child: GestureDetector(
          onTap: () => bloc.deselectMemeText(),
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
  late double top;
  late double left;
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
              bloc.selectMemeText(widget.memeText.id);
              top = calculateVertical(details);
              left = calculateHorizontal(details);
            });
          },
          child: StreamBuilder<MemeText?>(
              stream: bloc.observeSelectedMemeText(),
              builder: (context, snapshot) {
                final selectedItemMemeTexts =
                    snapshot.hasData ? snapshot.data : null;
                final selected = selectedItemMemeTexts != null &&
                    (widget.memeText.id == selectedItemMemeTexts.id);

                return MemeTextOnCanvas(
                  selected: selected,
                  parentConstraints: widget.parentConstraints,
                  padding: padding,
                  memeText: widget.memeText,
                );
              })),
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

class MemeTextOnCanvas extends StatelessWidget {
  const MemeTextOnCanvas({
    super.key,
    required this.selected,
    required this.parentConstraints,
    required this.padding,
    required this.memeText,
  });

  final bool selected;
  final BoxConstraints parentConstraints;
  final double padding;
  final MemeText memeText;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: selected ? AppColors.darkgray16 : null,
          border: Border.all(
              color: selected ? AppColors.fuchsia : Colors.transparent,
              width: 1)),
      constraints: BoxConstraints(
          maxWidth: parentConstraints.maxWidth,
          maxHeight: parentConstraints.maxHeight),
      padding: EdgeInsets.all(padding),
      //color: selected ? AppColors.darkgray16 : null,
      child: Text(
        memeText.text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.w400, color: AppColors.black),
      ),
    );
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
