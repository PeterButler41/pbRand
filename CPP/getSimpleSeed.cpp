// getSimpleSeed.cpp

#include <windows.h>
#include <sysinfoapi.h>
#include <intrin.h>
#pragma intrinsic(__rdtsc)

/*
getSimpleSeed()
Generates a 16 or 24-byte random seed for random number generation.

How to call:
unsigned long long theFutureSeed[2];
getSimpleSeed(theFutureSeed); //i.e. pass the address of the future seed

It is your responsibility to seed your PRNG with all 16 bytes.

If your PRNG has a 64-bit seed your best bet is:
  yourSeed = theFutureSeed[0]
  yourSeed = yourPRNG(yourSeed) // i.e. cycle yourPRNG
  yourSeed ^= theFutureSeed[1]
  // and perhaps cycle yourPRNG again

theFutureSeed[0] is the result of getSimpleSeed(), ostensibly date & time with 100nSec resulution
getSimpleSeed[1] is the 64-bit result the rdtsc instruction. (counts CPU internal cycles -- zeroed at reset)

The high bits of theFutureSeed[0] will be 0x0D for the forseeable future
The high bits of theFutureSeed[1] are likely to be 0x000 most of the time

getSimpleSeed() does not produce crypto-grade random seeds. However, seeds it produces
  are VERY unlikely to be accidently duplicated.


*/

typedef union {
    unsigned long long stuff[4];
    FILETIME ft;
    unsigned char c[24];
} duhBuf;

void getSimpleSeed(void* rnd)
{
    duhBuf *bp = (duhBuf *)rnd;
    bp->stuff[1] = __rdtsc();
    GetSystemTimePreciseAsFileTime(&bp->ft);
#if 0 // optional
    for (signed int i = 0; i < 24; i++)
    {
        c[i] ^= __rdtsc();
    }
#endif
}

