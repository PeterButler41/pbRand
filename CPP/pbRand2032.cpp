// pbRand2032.cpp

#ifndef __PBRAND2032_hpp_
#include "pbRand2032.hpp"
#endif


#define rol(val, amt) ( val<<amt | val>>(32-amt) ) //32-bit version
typedef uint32_t seed_t;


void pbRand2032::clr(void)
{
    //printf("2032 clr\n");
    for (int i = 0; i < 20; i++) seed[i] = 0;
}

void pbRand2032::reInit(void)
{
    //printf("pbRand2032::init(void)");
    clr();
    seedItem32(0x4321);
}

// print is for debug
void pbRand2032::print(void)
{
    printf("(2032)\n");
    for (int i = 0; i < 20; i++) printf("%2u  %08X\n", i, seed[i]);
    printf("\n");
}

void pbRand2032::seedItem32(uint32_t arg)
{
    //printf("(seed2032) %08X ", arg);
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

void pbRand2032::mx()
{
    //printf("mix2032 \n");

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
    mixMac(BB, CC, DD, AA, 10)
    mixMac(AA, BB, CC, DD, 11)
    mixMac(DD, AA, BB, CC, 12)
    mixMac(CC, DD, AA, BB, 13)
    mixMac(BB, CC, DD, AA, 14)
    mixMac(AA, BB, CC, DD, 15)
    mixMac(DD, AA, BB, CC, 16)
    mixMac(CC, DD, AA, BB, 17)
    mixMac(BB, CC, DD, AA, 18)
    mixMac(AA, BB, CC, DD, 19)
    mixMac(DD, AA, BB, CC,  0)
    mixMac(CC, DD, AA, BB,  1)
    mixMac(BB, CC, DD, AA,  2)
}

seed_t pbRand2032::random32(void)
{
    mx();
    seed_t ix = seed[19];
    ix &= 15;
    seed_t t0 = seed[ix + 0];
    seed_t t1 = seed[ix + 1];
    seed_t t2 = seed[ix + 2];
    t0 = rol(t0, 1);
    t1 = rol(t1, 12);

    t2 ^= t2 >> 11;
    t2 ^= t2 << 17;
    t2 ^= t2 >> 13;

    t2 = (t0 + t1) ^ t2;
    //printf("2032 random returns %08X\n", t2);
    return t2;
}

