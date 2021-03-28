// pbRandXX64.cpp

#ifndef __PBRANDXX64_HPP_
#include "pbRandxx64.hpp"
#endif

/*
  This module contains most pbRand code for 64-bit seed words.
  The mix() and randomness extraction operations
    are in pcRand1064.cpp and pbRand2064.cpp
*/

// 64-bit version of rotate left
#define rol(val, amt) ( val<<amt | val>>(64-amt) )

typedef  uint64_t seed_t;

uint32_t pbRandXX64::random32() { return (uint32_t)random64(); }

void pbRandXX64::randomList64(uint64_t *dest, int count)
{
    while(count--) *dest++ = random64();
}

void pbRandXX64::randomList32(uint32_t *dest, int count)
{
    while (count--)
    {
        *dest++ = random32();
    }
}


void pbRandXX64::randomList(void *dest, int byteCount)
{
    union {
        void *v;
        uint64_t *p64;
        uint32_t *p32;
        uint16_t *p16;
        uint8_t  *p8;
    };
    v = dest;
    while (byteCount>=8)
    {
        *p64++ = random64();
        byteCount -= 8;
    }
    if (byteCount == 0)  return;
    uint64_t temp = random64();
    while (byteCount--)
    {
        *p8++ = (uint8_t)temp;
        temp >>= 8;
    }
}

////////////////////////////////////////////////////////////////////
// Seedings...
//
//
// self seeding
void pbRandXX64::seedSelf(void)
{
    seedItem64(random64());
}

// Seed single items
//
void pbRandXX64::seedItem32(uint32_t item)
{
    seedItem64(item); //(auto upcast)
}

////////////////////////////////////////////////////////////////////
//
// seedList... seed from contigous memory locations
//
//

void pbRandXX64::seedList64(const uint64_t* src, int longWordCount)
{
    union {
        unsigned long long the64;
        uint32_t the32[2];
    };
    while (longWordCount--) seedItem64(*src++);
}

void pbRandXX64::seedList32(const uint32_t *src, int wordCount)
{
    while (wordCount--) seedItem64(*src++);
}

void pbRandXX64::seedList(const void *src, int nBytes)
{
    union {
        const void     *v;
        const uint64_t *p64;
        const uint32_t *p32;
        const uint16_t *p16;
        const uint8_t  *p8;
    };
    v = src;

    while (nBytes >= 8)
    {
        seedItem64(*p64++);
        nBytes -= 8;
    }
    if (nBytes)
    {
        seed_t temp = *p64;
        signed long long m = 0xFF00000000000000;
        m >>= (7-nBytes)*8;
        temp &= ~m;
        seedItem64(temp);
    }
}

// end whatever


