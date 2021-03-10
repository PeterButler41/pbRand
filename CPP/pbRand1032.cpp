// pbRand1032.cpp

#ifndef __PBRAND1032_hpp_
#include "pbRand1032.hpp"
#endif


#define rol(val, amt) ( val<<amt | val>>(32-amt) ) //32-bit version
typedef uint32_t seed_t;


void pbRand1032::clr(void)
{
    //printf("1032 clr\n");
    for (int i = 0; i < 10; i++) seed[i] = 0;
}

void pbRand1032::reInit(void)
{
    //printf("pbRand1032::init(void)");
    clr();
    seedItem32(0x4321);
}

// print is for debug
void pbRand1032::print(void)
{
    printf("(1032)\n");
    for (int i = 0; i < 10; i++) printf("%2u  %08X\n", i, seed[i]);
    printf("\n");
}

void pbRand1032::seedItem32(uint32_t arg)
{
    //printf("(seed1032) %08X ", arg);
    seed[0] += rol(arg,  1);
    seed[1] += rol(arg, 12);
    seed[2] += rol(arg, 21);
    //printf("%08X %08X %08X\n",seed[0],seed[1],seed[2]);
    mx();
}

#define mixMac(AA, BB, CC, DD, idx) \
    AA = seed[idx];                 \
    AA += DD;                       \
    AA ^= rol(BB, 1);               \
    seed[idx] = AA;

void pbRand1032::mx()
{
    //printf("mix1032 \n");

    seed_t AA;
    seed_t BB = seed[2];
    seed_t CC = seed[1];
    seed_t DD = seed[0];

//        [3] [2] [1] [0]
    mixMac(AA, BB, CC, DD, 3)
    mixMac(DD, AA, BB, CC, 4)
    mixMac(CC, DD, AA, BB, 5)
    mixMac(BB, CC, DD, AA, 6)
    mixMac(AA, BB, CC, DD, 7)
    mixMac(DD, AA, BB, CC, 8)
    mixMac(CC, DD, AA, BB, 9)
    mixMac(BB, CC, DD, AA, 0)
    mixMac(AA, BB, CC, DD, 1)
    mixMac(DD, AA, BB, CC, 2)










}

seed_t pbRand1032::random32(void)
{
    mx();
    seed_t ix = seed[9];
    ix &= 7;
    seed_t t0 = seed[ix + 0];
    seed_t t1 = seed[ix + 1];
    seed_t t2 = seed[ix + 2];
    t0 = rol(t0, 1);
    t1 = rol(t1, 12);

    t2 ^= t2 >> 11;
    t2 ^= t2 << 17;
    t2 ^= t2 >> 13;

    t2 = (t0 + t1) ^ t2;
    //printf("1032 random returns %08X\n", t2);
    return t2;
}

