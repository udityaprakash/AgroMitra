int getnvalue(int l, int m, int h) {
  double x = (140 * l + 420 * m + 650 * h) / 100;
  return x.round();
}

int getkvalue(int l, int m, int h) {
  double x = (60 * l + 200 * m + 320 * h) / 100;
  return x.round();
}
int getpvalue(int l, int m, int h) {
  double x = (5 * l + 18 * m + 30 * h) / 100;
  return x.round();
}

double getocvalue(int l, int m, int h) {
  double x = (0.25 * l + 0.625 * m + 0.8 * h);
  return x;
}





