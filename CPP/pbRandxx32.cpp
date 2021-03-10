// pbRandXX32.cpp

#ifndef __PBRANDXX32_HPP_
#include "pbRandxx32.hpp"
#endif

/*
  This module contains most pbRand code for 32-bit seed words.
  The mix() and randomness extraction operations
    are in pcRand1032.cpp and pbRand2032.cpp
*/

// 32-bit version of rotate left
#define rol(val, amt) ( val<<amt | val>>(32-amt) )

typedef uint32_t seed_t;

uint64_t pbRandXX32::random64()
{
    union {
        uint64_t t64;
        uint32_t t32hi, t32lo;
    };
    t32lo = random32(); //low first for compatibility with randomList64()
    t32hi = random32();
    return t64;
}

void pbRandXX32::randomList64(uint64_t *dest, int count)
{
    union {
        void *v;
        uint64_t *p64;
        uint32_t       *p32;
        uint16_t  *p16;
        uint8_t      *p8;
    };
    p64 = dest;
    count *= 2;
    while (count--)
    {
        *p32++ = random32();
    }
}

void pbRandXX32::randomList32(seed_t *dest, int count)
{
    while (count--)
    {
        *dest++ = random32();
    }
}

void pbRandXX32::randomList(void *dest, int byteCount)
{
    union {
        void     *v;
        uint64_t *p64;
        uint32_t *p32;
        uint16_t *p16;
        uint8_t  *p8;
    };
    v = dest;
    while (byteCount>=4)
    {
        *p32++ = random32();
        byteCount -= 4;
    }
    if (byteCount == 0) return; 
    uint32_t temp = random32();
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
void pbRandXX32::seedSelf(void)
{
    seedItem32(random32());
}

// Seed single items
//
void pbRandXX32::seedItem64(uint64_t arg)
{
    union {
        uint64_t the64;
        uint32_t the32[2];
    };
    the64 = arg;
    seedItem32(the32[0]);
    seedItem32(the32[1]);
}


////////////////////////////////////////////////////////////////////
//
// seedList... seed from contigous memory locations
//
//

void pbRandXX32::seedList64(const unsigned long long* src, int longWordCount)
{
    union {
        uint64_t the64;
        uint32_t the32[2];
    };
    while(longWordCount--) {
        the64 = *src++;
        seedItem32(the32[0]); //low part first
        seedItem32(the32[1]);
    }
}

void pbRandXX32::seedList32(const uint32_t *src, int wordCount)
{
    while (wordCount--) seedItem32(*src++);
}


void pbRandXX32::seedList(const void *src, int nBytes)
{
    union {
        const    void  *v;
        const uint64_t *p64;
        const uint32_t *p32;
        const uint16_t *p16;
        const uint8_t  *p8;
    };
    v = src;

    while (nBytes >= 4)
    {
        seedItem32(*p32++);
        nBytes -= 4;
    }
    if (nBytes)
    {
        signed int m = 0xFF000000;
        m >>= (3-nBytes)*8;
        seed_t temp = *p32;
        temp &= ~m;
        seedItem32(temp);
    }
}


// end whatever


