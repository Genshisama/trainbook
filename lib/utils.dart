import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


 String processDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('dd MMM EEEE').format(dateTime);
    return formattedDate;  
  }

  List<String> processTime(String time){
    List<String> times = time.split(" - ");
    return times;
  }

  Size screenSize(BuildContext context){
    return MediaQuery.of(context).size;
  }