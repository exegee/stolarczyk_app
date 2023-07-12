class MachineType {
  int? id;
  String model;
  // int coilWeight;
  // double sheetThicknessMin;
  // double sheetThicknessMax;
  // int coilMaxExtDiameter;
  // int coilInternalDiameter;
  // int coilWidth;
  // int coilHeight;
  // int mandrelAxisHeight;
  // int maxVelocity;
  // String mandrelDrive;
  // String mandrelSupportFrame;
  // String speedRegulation;
  // String jawsExtensionDrive;
  // String coilcar;
  // int coilcarPlatformStroke;
  // String pressureArm;
  // String snubberRoller;
  // int machineMass;

  String? picturePath;

  MachineType({required this.model, this.picturePath});

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'model': model});

    return result;
  }

  static MachineType fromMap(Map<String, dynamic> machineType) {
    return MachineType(model: machineType['model']);
  }
}
