#include <stdio.h>

void loop (int* n, int* r) {

  int m[10];
  int p;

  if ( *n == 0 ) {
    *r = 1;
  } else {
    m[0] = *n - 1;
    printf ("m = %d\n", m[0]);
    loop (&m[0], &p);
    *r = *n * p;
  }
}

int fact (int n) {
  int r;
  int m;
  m = n;
  loop (&m, &r);
  printf ("m = %d\n", m);
  return (r);
}

int main () {
  printf ("coucou\n");

  printf ("fact 10=%d\n", fact (10));

}

