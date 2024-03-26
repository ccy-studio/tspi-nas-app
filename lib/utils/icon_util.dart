/*
 * @Description: 
 * @Author: chenzedeng
 * @Date: 2021-06-28 21:41:48
 * @LastEditTime: 2021-07-03 17:08:40
 */
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

///阿里IconFont组件
Icon iconFont({required int hex16, double? size, Color? color}) => Icon(
      IconData(hex16, fontFamily: 'iconfont'),
      color: color,
      size: size,
    );

///Svg组件工具
SvgPicture svg(
        {required String name, Color? color, double? width, double? height}) =>
    SvgPicture.asset(
      "assets/svg/$name.svg",
      colorFilter:
          color != null ? ColorFilter.mode(color, BlendMode.srcIn) : null,
      // color: color,
      width: width,
      height: height,
    );

String getFileIcon(String? mimeType, String fileName) {
  String iconPrefix = "file_types/";
  if (mimeType == null) {
    return "${iconPrefix}floder";
  }
  String fileType;
  // 从 MIME 类型中提取主类型
  String mainType = mimeType.split("/").first;

  // 根据主类型进行判断
  switch (mainType) {
    case "application":
      fileType = _getApplicationFileType(mimeType);
      break;
    case "image":
      fileType = "img";
      break;
    case "audio":
      fileType = "music";
      break;
    case "text":
      fileType = "txt";
      break;
    case "video":
      fileType = "video";
      break;
    default:
      fileType = "unknown";
  }

  // 如果类型未知，则根据文件名后缀进行判断
  if (fileType == "unknown") {
    fileType = _getFileExtensionType(fileName);
  }

  return "$iconPrefix$fileType";
}

String _getApplicationFileType(String mimeType) {
  // 根据具体的 application 子类型进行判断
  switch (mimeType) {
    case "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
      return "excel";
    case "application/pdf":
      return "pdf";
    case "application/vnd.ms-powerpoint":
      return "ppt";
    case "application/msword":
      return "doc";
    case "application/zip":
      return "zip";
    default:
      return "unknown";
  }
}

String _getFileExtensionType(String fileName) {
  List<String> fileParts = fileName.split(".");
  String fileExtension = fileParts.isNotEmpty ? fileParts.last : "";
  switch (fileExtension) {
    case "xlsx":
      return "excel";
    case "jpeg":
    case "jpg":
    case "png":
    case "gif":
      return "img";
    case "mp3":
    case "ogg":
    case "wav":
      return "music";
    case "pdf":
      return "pdf";
    case "ppt":
    case "pptx":
      return "ppt";
    case "txt":
      return "txt";
    case "html":
      return "html";
    case "mp4":
    case "mpeg":
    case "mov":
      return "video";
    case "doc":
    case "docx":
      return "doc";
    case "zip":
      return "zip";
    default:
      return "unknown";
  }
}
