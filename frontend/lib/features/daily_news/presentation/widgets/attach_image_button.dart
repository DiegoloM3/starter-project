import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../config/theme/app_design_tokens.dart';

class AttachImageButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AttachImageButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 179,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.lilac,
        borderRadius: AppRadius.standard,
        boxShadow: AppShadows.raisedButton,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppRadius.standard,
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/icons/attach_image.svg', width: 24, height: 24),
              const SizedBox(width: 10),
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Attach Image',
                    style: TextStyle(fontFamily: AppFonts.inter, fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
