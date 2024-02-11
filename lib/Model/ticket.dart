class Ticket {
  String title;
  late String desc;
  String incidentDate;
  String incidentPic;
  String location;
  String locationLink;
  String reporterFirstName;
  String reporterUsername;
  String reporterProfilePic;

  Ticket(
      {required this.title,
      this.desc = "",
      required this.incidentDate,
      required this.location,
      required this.locationLink,
      required this.reporterFirstName,
      required this.reporterUsername,
      required this.incidentPic,
      required this.reporterProfilePic});
}
