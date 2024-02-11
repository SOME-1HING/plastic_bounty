class Ticket {
  String title;
  String uid;
  int id;
  late String desc;
  String incidentDate;
  String incidentPic;
  String location;
  String locationLink;
  String reporterFirstName;
  String reporterProfilePic;
  String status;

  Ticket(
      {required this.title,
      required this.id,
      this.uid = '',
      this.desc = "",
      this.status = "active",
      required this.incidentDate,
      required this.location,
      required this.locationLink,
      this.reporterFirstName = "",
      required this.incidentPic,
      this.reporterProfilePic = ""});
}
