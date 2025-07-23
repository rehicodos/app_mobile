class Pwds {
  final String entreprise, pwdChefCh, pwdAd, pwdSAd, pwdPortail;

  Pwds({
    required this.pwdChefCh,
    required this.pwdAd,
    required this.pwdSAd,
    required this.pwdPortail,
    required this.entreprise,
  });

  factory Pwds.fromJson(Map<String, dynamic> e) => Pwds(
    pwdChefCh: e['pwd_chef_ch'],
    pwdAd: e['pwd_adm'],
    pwdSAd: e['pwd_super_adm'],
    pwdPortail: e['pwd_users'],
    entreprise: e['nom_entreprise'],
  );
}
