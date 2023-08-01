#include <stdio.h>

void loop (int* n, int* r) {

  int m = *n;

  if ( m == 0 ) {
    *r = 1;
  } else {
    *n = *n - 1;
    loop (n, r);
    *n = m;
    *r = m * *r;
  }
}

int fact (int n) {
  int r;
  int m;
  m = n;
  loop (&m, &r);
  printf ("m = %d", m);
  return (r);
}

int main () {

  printf ("fact 10=%d", fact (10));

}

