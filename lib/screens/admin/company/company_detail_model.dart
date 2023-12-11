class CompanyDetailsModel {
  String companyId ='';
  String companyName ='';
  String companyProfileImg ='';
  String businessType ='';
  String companyAddress ='';
  String gstNumber ='';
  String udayamRegNum ='';


  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'businessType': businessType,
      'gstNumber': gstNumber,
      'companyProfileImg': companyProfileImg,
      'udayamRegNum': udayamRegNum,
    };
  }

}
