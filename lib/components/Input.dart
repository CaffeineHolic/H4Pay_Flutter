import 'package:flutter/material.dart';
import 'package:h4pay/Util/mp.dart';

enum H4PayInputType { next, done }

class H4PayInput extends StatefulWidget {
  final bool? isPassword;
  final bool? isNumber;
  final String title;
  final TextEditingController controller;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool? isMultiLine;
  final H4PayInputType type;
  final String? Function(String?)? validator;
  final int? minLines;
  final Function()? onEditingComplete;
  final List<MultiMaskedTextInputFormatter>? inputFormatters;

  const H4PayInput({
    Key? key,
    this.isPassword,
    this.isNumber,
    required this.title,
    required this.controller,
    this.backgroundColor,
    this.borderColor,
    this.isMultiLine,
    required this.validator,
    this.minLines,
    this.onEditingComplete,
    this.inputFormatters,
  })  : type = H4PayInputType.next,
        super(key: key);

  const H4PayInput.done({
    Key? key,
    this.isPassword,
    this.isNumber,
    required this.title,
    required this.controller,
    this.backgroundColor,
    this.borderColor,
    this.isMultiLine,
    required this.validator,
    this.minLines,
    this.onEditingComplete,
    this.inputFormatters,
  })  : type = H4PayInputType.done,
        super(key: key);

  @override
  H4PayInputState createState() => H4PayInputState();
}

class H4PayInputState extends State<H4PayInput> {
  Color defaultBackgroundColor = Colors.grey[200]!;
  Color defaultBorderColor = Colors.grey[400]!;

  @override
  Widget build(BuildContext context) {
    InputDecoration roundDecoration = InputDecoration(
      fillColor: widget.backgroundColor ?? defaultBackgroundColor,
      filled: true,
      border: new OutlineInputBorder(
        borderRadius: const BorderRadius.all(const Radius.circular(23.0)),
      ),
      contentPadding:
          new EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
    );
    Container titleText = Container(
      margin: EdgeInsets.only(bottom: 10),
      child: Text(
        widget.title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleText,
          TextFormField(
            obscureText: widget.isPassword ?? false,
            controller: widget.controller,
            decoration: roundDecoration,
            textInputAction: widget.isMultiLine ?? false
                ? TextInputAction.newline
                : widget.type == H4PayInputType.done
                    ? TextInputAction.done
                    : TextInputAction.next,
            keyboardType: widget.isNumber ?? false
                ? TextInputType.phone
                : widget.isMultiLine ?? false
                    ? TextInputType.multiline
                    : TextInputType.text,
            maxLines: widget.isMultiLine ?? false ? null : 1,
            minLines: widget.isMultiLine ?? false ? widget.minLines : null,
            validator: widget.validator,
            onEditingComplete: widget.onEditingComplete,
            inputFormatters: widget.inputFormatters,
          ),
        ],
      ),
    );
  }
}
