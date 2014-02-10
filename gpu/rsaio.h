#include <gmp.h>
#include <stdio.h>
#define BITS_PER_INT 32
#define E 65537
void getPrivateKey(mpz_t p, mpz_t modulii, mpz_t publicKey, mpz_t privateKey);
void getKeysWithPrimes(mpz_t p, mpz_t q, mpz_t publicKey, mpz_t privateKey);
void totient(mpz_t prime1, mpz_t prime2, mpz_t n);
void modExponentMPZ(mpz_t base, mpz_t exp, mpz_t mod, mpz_t result);
void outputKeys(uint32_t *bit_arr, FILE *outfile, int byte_array_size, mpz_t *arr, int num_bad_keysr);
void outputPrivateKey(mpz_t privateKey, FILE *file);
void generateKeys(mpz_t gcd, mpz_t modulii, mpz_t privateKey);
int removeDups(mpz_t *output_arr, mpz_t insert, int num_found);
