enum DrivingLicenceType {
  J,
  A,
  B,
  C,
  D,
  EB,
  EC,
  ED,
}

extension DrivingLicenceTypeExtension on DrivingLicenceType {
  int get questionNumbers {
    switch (this) {
      case DrivingLicenceType.B:
        return 40;
      case DrivingLicenceType.J:
      case DrivingLicenceType.A:
      case DrivingLicenceType.C:
      case DrivingLicenceType.D:
      case DrivingLicenceType.EB:
      case DrivingLicenceType.EC:
      case DrivingLicenceType.ED:
        return 46;
    }
  }

  int get winMinScore {
    switch (this) {
      case DrivingLicenceType.B:
        return 32;
      case DrivingLicenceType.J:
      case DrivingLicenceType.A:
      case DrivingLicenceType.C:
      case DrivingLicenceType.D:
      case DrivingLicenceType.EB:
      case DrivingLicenceType.EC:
      case DrivingLicenceType.ED:
        return 38;
    }
  }
}
