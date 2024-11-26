import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

String getMessageByCode(BuildContext context, int msgCode) {
  final localizations = AppLocalizations.of(context)!;

  switch (msgCode) {
    case 100:
      return localizations.msgCode_100;
    case 101:
      return localizations.msgCode_101;
    case 102:
      return localizations.msgCode_102;
    case 103:
      return localizations.msgCode_103;
    case 104:
      return localizations.msgCode_104;
    case 105:
      return localizations.msgCode_105;
    case 200:
      return localizations.msgCode_200;
    case 201:
      return localizations.msgCode_201;
    case 202:
      return localizations.msgCode_202;
    case 203:
      return localizations.msgCode_203;
    case 204:
      return localizations.msgCode_204;
    case 205:
      return localizations.msgCode_205;
    case 206:
      return localizations.msgCode_206;
    case 207:
      return localizations.msgCode_207;
    case 208:
      return localizations.msgCode_208;
    case 209:
      return localizations.msgCode_209;
    case 210:
      return localizations.msgCode_210;
    case 211:
      return localizations.msgCode_211;
    case 212:
      return localizations.msgCode_212;
    case 213:
      return localizations.msgCode_213;
    case 214:
      return localizations.msgCode_214;
    case 215:
      return localizations.msgCode_215;
    case 216:
      return localizations.msgCode_216;
    case 217:
      return localizations.msgCode_217;
    case 500:
      return localizations.msgCode_500;
    default:
      return localizations.msgCode_default;
  }
}
