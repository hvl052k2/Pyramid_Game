import 'package:flutter/material.dart';
import 'package:pyramid_game/src/constants/colors.dart';

class VoteFormWidget extends StatelessWidget {
  const VoteFormWidget({
    super.key,
    required this.size,
    required this.order,
    required this.attenderList,
    required this.onSelected,
  });

  final Size size;
  final String order;
  final List attenderList;
  final Function(Text?)? onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          alignment: Alignment.center,
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            border: Border.all(color: whiteColor),
            borderRadius: const BorderRadius.all(Radius.circular(5)),
          ),
          child: Text(
            order,
            style: const TextStyle(
              color: whiteColor,
              fontSize: 25,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 10),
        DropdownMenu(
          inputDecorationTheme: const InputDecorationTheme(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: whiteColor),
            ),
          ),
          requestFocusOnTap: true,
          onSelected: onSelected,
          trailingIcon: const Icon(
            Icons.arrow_drop_down,
            color: whiteColor,
          ),
          enableFilter: true,
          width: size.width / 1.7,
          textStyle: const TextStyle(color: whiteColor),
          dropdownMenuEntries: List.from(attenderList)
              .map(
                (item) => DropdownMenuEntry(
                  value: Text({
                    '"gmail": "${item["gmail"]}"',
                    '"name": "${item["name"]}"'
                  }.toString()),
                  label: item["name"].toString(),
                  labelWidget: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item["name"]),
                      Text(
                        item["gmail"],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      )
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
