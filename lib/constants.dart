import 'package:flutter/material.dart';

const kPrimaryColor = Color.fromARGB(255, 242, 101, 34);
const kAnimationDuration = Duration(milliseconds: 200);
const kTextColor = Color(0xFF757575);
const kSecondaryColor = Color(0xFF979797);

const apiAddress = 'http://192.168.0.33/api/';
const assetsAddress = 'http://192.168.0.33/';
const Map<String, String> headers = {
  'Content-type': 'application/json',
  'Accept': 'application/json',
};

const errInvalidUsername = 'INVALID_USERNAME';
const errInvalidPassword = 'INVALID_PASSWORD';

const Map<int, String> languages = {
  0: "Polski",
  1: "Angielski",
  2: "Niemiecki",
  3: "Hiszpański",
  4: "Włoski",
  5: "Rumuński"
};

const Map<int, int> voltages = {
  0: 400,
  1: 480,
};

const Map<int, String> colors = {
  0: "RAL3020 - RAL1023",
  1: "RAL5015 - RAL1023",
  2: "RAL5015 - RAL7037",
  3: "RAL7001 - RAL3020",
  4: "RAL7004 - RAL3020",
  5: "RAL7035 - RAL7015 - RAL2008",
  6: "Inny"
};

const Map<int, int> frequencies = {
  0: 50,
  1: 60,
};

const Map<int, String> taskStatus = {
  0: "Utworzone",
  1: "W realizacji",
  2: "Ukończone"
};

Map<int, Color?> priorityColor = {
  1: Colors.greenAccent[400],
  2: Colors.yellowAccent[400],
  3: Colors.amberAccent[400],
  4: Colors.deepOrangeAccent[400],
  5: Colors.redAccent[400]
};

Map<int, String> topicPriorities = {
  0: 'Niski',
  1: 'Średni',
  2: 'Wysoki',
};
