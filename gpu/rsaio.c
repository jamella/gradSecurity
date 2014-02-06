/* Brady Thomas & Kim Paterson
 * CSC 419/556 Cuda-RSA 
 * Feb, 2014
 * 
 * Cuda-rsa code licensed from https://github.com/dmatlack/cuda-rsa
 */
#include "rsaio.h"
//#include "/home/clupo/gmp/mpz.h"
#include <gmp.h>
#define NUM_KEYS 200000
#define BITS_PER_INT 32

void outputKeys(int *bit_arr, FILE *outfile, int byte_array_size) {
  //read in keys
  FILE *keys_file = fopen("keys.txt", "r");
  mpz_t arr[NUM_KEYS];
  int i = 0, j = 0;

  mpz_t rop;
  mpz_init(rop);

  while(mpz_inp_str(rop, keys_file, BASE_10) && i < NUM_KEYS) {
    mpz_init(arr[i]);
    mpz_set(arr[i], rop);
    i++;
  }
  fclose(keys_file);

  int k, key_ndx, byte_ndx;
  char mask = 1;
  mpz_t privateKey;
  //go through array and get pairs
  for (i=0; i < byte_array_size; i++) {
    for (j=i+1; j < byte_array_size; j++) {
      //index is i*NUM_KEYS + j -- index of byte
      byte_ndx = i*byte_array_size + j;
      char byte = bit_arr[byte_ndx];

      for (k=0; k < BITS_PER_INT; i++) {
        key_ndx = j * BITS_PER_INT + k;
        mask = 1 << k;
        if (byte & mask) {
          //arr[i*BYTES_PER_CHAR+k], arr[key_ndx]
          generateKeys(arr[i * BYTES_PER_INT + k], arr[key_ndx], privateKey);
          outputPrivateKey(privateKey, file);
          fprintf(file, "\n");
        }
      }
    }
  }
}

void outputPrivateKey(mpz_t privateKey, FILE *file) {
  mpz_out_str(file, 10, privateKey);
}

void generateKeys(mpz_t modulii1, mpz_t modulii2, mpz_t privateKey) {
  //comput gcd
  mpz_t gcd;
  mpz_init(gcd);
  mpz_gcd (gcd, modulii1, modulii2);

  //set public key
  mpz_t publicKey;
  mpz_init(publicKey);
  
  getPrivateKey(gcd, modulii1, publicKey, privateKey);
  
}

void getPrivateKey(mpz_t p, mpz_t modulii, mpz_t publicKey, mpz_t privateKey) {
  mpz_t q;
  mpz_init(q);
  
  mpz_cdiv_q(q, modulii, p);
  //q is now other prime

  //get keys
  getKeysWithPrimes(p, q, publicKey, privateKey);

}


void getKeysWithPrimes(mpz_t p, mpz_t q, mpz_t publicKey, mpz_t privateKey) {
  mpz_t n;
  mpz_init(n);
  //compute totient
  totient(p, q, n);
  
  //compute d/private key
  mpz_t neg_one;
  mpz_init(neg_one);
  mpz_set_si(neg_one, -1);

  mpz_set_ui(publicKey, E);

  //set privateKey
  modExponentMPZ(publicKey, neg_one, n, privateKey);
}

void totient(mpz_t prime1, mpz_t prime2, mpz_t n) {
  //totient(n) = totient(p)*totient(q) = (p-1)(q-1)
  unsigned long int one = 1;
  mpz_t p, q;
  mpz_init(p);
  mpz_init(q);

  //subtract one from each 
  mpz_sub_ui(p, prime1, one);
  mpz_sub_ui(q, prime2, one);

  //(p-1)(q-1)
  mpz_mul(n, p, q);
  
}

void modExponentMPZ(mpz_t base, mpz_t exp, mpz_t mod, mpz_t result) {
  mpz_powm (result, base, exp, mod);
}
