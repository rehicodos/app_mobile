class Pwds {
  final String pwdChefCh, pwdAd, pwdSAd;

  Pwds({required this.pwdChefCh, required this.pwdAd, required this.pwdSAd});

  factory Pwds.fromJson(Map<String, dynamic> e) => Pwds(
    pwdChefCh: e['pwd_chef_ch'],
    pwdAd: e['pwd_adm'],
    pwdSAd: e['pwd_super_adm'],
  );
}
