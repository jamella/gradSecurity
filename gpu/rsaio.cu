/* Brady Thomas & Kim Paterson
 * CSC 419/556 Cuda-RSA 
 * Feb, 2014
 * 
 * Cuda-rsa code licensed from https://github.com/dmatlack/cuda-rsa
 */
//#include "/home/clupo/gmp/mpz.h"
#include <gmp.h>
#include <stdint.h>
#include "rsaio.h"
#include "cuda-rsa.h"

void outputKeys(uint32_t *bit_arr, FILE *outfile, int byte_array_size, mpz_t *arr/*, int num_bad_keys*/) {
  //read in keys
//  FILE *badkeys_file = fopen("200k-badkeys.txt", "r");
  int i = 0, j = 0;
  mpz_t gcd;
  mpz_init(gcd);
  uint32_t cur_int;
  int m, k, key_i_ndx, key_j_ndx;
  char mask_i= 1, mask_j = 1;
  mpz_t privateKey;
  mpz_init(privateKey);
  
  int key_count = 0;
  int bad_key_ndxs[num_bad_keys];

  for (i=0; i < byte_array_size; i++) {
    //check if array is 1
    cur_int = bit_arr[i];

    //go through every bit in [i]
    for (m = 0; m < BITS_PER_INT; m++) {
       //mask off bit for i
       mask_i = 1 << m;
       if (cur_int & mask_i) {
          bad_key_ndx[key_count++] = i+m;
          
       }
    }
  }
  
    

//  mpz_t output_arr[200];
//  int num_found = 0;
  printf("Checking bit vector...\n");
  
  for (i=0; i < byte_array_size; i++) {
    //check if array is 1
    cur_int = bit_arr[i];

    //go through every bit in [i]
    for (m = 0; m < BITS_PER_INT; m++) {
       //mask off bit for i
       mask_i = 1 << m;
       if (cur_int & mask_i) {
          printf("Checking i byte\n");
    
          //go through all bytes
          //not i+1 because we have to visit all other bits in this byte
          for (j=i; j < byte_array_size; i++) {
             //if we are comparing the same byte, set the first index 
             //to be one greater than the index of i
             if (i == j) {
                k = m+1;
             } else { // otherwise start at first bit
                k = 0;
             }             
             for (; k < BITS_PER_INT; k++) {
                //mask off bit for j
                mask_j = 1 << k;
                if (bit_arr[j] & mask_j) {
                   printf("Checking j byte\n");
                   //get key indecies
                   key_i_ndx = i * BITS_PER_INT + m;
                   key_j_ndx = j * BITS_PER_INT + k;
                   printf("i: %d, j: %d, m: %d, k: %d\n", i, j, m, k);
                   printf("key_i: %d key_j: %d\n", key_i_ndx, key_j_ndx);
                   
                   //compute gcd
                   mpz_gcd (gcd, arr[key_j_ndx], arr[key_i_ndx]);
                   
                   //if it's not 1, then output
                   if (mpz_cmp_ui(gcd, 1) != 0) {
                      printf("%d and %d are bad keys\n", key_i_ndx, key_j_ndx);
                      //generate keys
                      generateKeys(gcd, arr[key_i_ndx], privateKey);
                      
                      //output i key and private key
                      outputPrivateKey(arr[key_i_ndx], outfile);
                      fprintf(outfile, ":");
                      outputPrivateKey(privateKey, outfile);
                      fprintf(outfile, "\n");

                      //get j private key
                      generateKeys(gcd, arr[key_j_ndx], privateKey);
                
                      //output j key and private key
                      outputPrivateKey(arr[key_j_ndx], outfile);
                      fprintf(outfile, ":");
                      outputPrivateKey(privateKey, outfile);
                      fprintf(outfile, "\n");
                   }
                }
             }
          }
       }
    }
  }
/*  for (i=0; i < num_found; i++) {
    outputPrivateKey(output_arr[i], badkeys_file);
    }*/

//  fclose(badkeys_file);
}

int removeDups(mpz_t *output_arr, mpz_t insert, int num_found) {
  int i;
  int found = 0;
  for (i=0; i < num_found; i++) {
    if (mpz_cmp(output_arr[i], insert) == 0) {
      found = 1;
    }
  }
  if (!found) {
    mpz_set(output_arr[num_found++], insert);
  }
  return num_found;

}


void outputPrivateKey(mpz_t privateKey, FILE *file) {
  mpz_out_str(file, 10, privateKey);
}

void generateKeys(mpz_t gcd, mpz_t modulii, mpz_t privateKey) {
  //set public key
  mpz_t publicKey;
  mpz_init(publicKey);
  mpz_set_ui(publicKey, E);  
  getPrivateKey(gcd, modulii, publicKey, privateKey);
  
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
