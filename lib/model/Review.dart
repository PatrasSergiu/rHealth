class Review {

  static const colIdDoctor = 'idDoctor';
  static const colReviewer = 'idReviewer';
  static const colContent = 'content';
  static const colStars = 'stars';
  static const colRevName = 'reviewerName';

  num? stars;
  String? idDoctor, idReviewer, content, reviewerName;
  Review({this.idDoctor, this.idReviewer, this.content, this.stars, this.reviewerName});

  Review.fromMap(Map <dynamic, dynamic> map)
  {
    idDoctor = map[colIdDoctor];
    idReviewer = map[colReviewer];
    content = map[colContent];
    stars = map[colStars];
    reviewerName = map[colRevName];
  }

  Map <String, dynamic> toMap() {
    var map = <String, dynamic> {
      'idReviewer': idReviewer,
      'doctorReviewed': idDoctor,
      'stars': stars,
      'content':content,
      'reviewerName':reviewerName
    };
    if (idReviewer != null) {
      map[colReviewer] = idReviewer;
    }
    return map;
  }
}