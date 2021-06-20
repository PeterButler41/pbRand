// pbRand2064.cpp

#ifndef __PBRAND2064_hpp_
#include "pbRand2064.hpp"
#endif

#define rol(val, amt) ( val<<amt | val>>(64-amt) ) //64-bit version
typedef uint64_t seed_t;

void pbRand2064::clr(void)
{
    //printf("2064 clr\n");
    for (int i = 0; i < 20; i++) seed[i] = 0;
}

void pbRand2064::reInit(void)
{
    //printf("pbRand2064::init(void)");
    clr();
    seedItem64(0x87654321);
}

// print is for debug
void pbRand2064::print(void)
{
    printf("(2064)\n");
    for (int i = 0; i < 20; i++) printf("%2u  %016llX\n", i, seed[i]);
    printf("\n");
}

void pbRand2064::seedItem64(uint64_t arg)
{
    //printf("(seed1064) %016llX ", arg);
    seed[0] += rol(arg,  1);
    seed[1] += rol(arg, 21);
    seed[2] += rol(arg, 42);
    //printf("%016llX %016llX %016llX\n", seed[0], seed[1], seed[2]);
    mx();
}

#define mixMac(AA, BB, CC, DD, idx) \
    AA = seed[idx];                 \
    AA += DD;                       \
    AA ^= rol(BB, 1);               \
    seed[idx] = AA;

void pbRand2064::mx(void)
{
    //printf("mix2064 \n");
    seed_t AA;
    seed_t BB = seed[2];
    seed_t CC = seed[1];
    seed_t DD = seed[0];

//        [3] [2] [1] [0]
    mixMac(AA, BB, CC, DD,  3)
    mixMac(DD, AA, BB, CC,  4)
    mixMac(CC, DD, AA, BB,  5)
    mixMac(BB, CC, DD, AA,  6)
    mixMac(AA, BB, CC, DD,  7)
    mixMac(DD, AA, BB, CC,  8)
    mixMac(CC, DD, AA, BB,  9)
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

seed_t pbRand2064::random64(void)
{
    mx();
    seed_t ix = seed[19];
    ix &= 15;
    seed_t t0 = seed[ix + 0];
    seed_t t1 = seed[ix + 1];
    seed_t t2 = seed[ix + 2];

    //printf("Pre/Post t0 %016llX  ",t0);
    t0 = rol(t0,  1);
    //printf(" %016llX\n",t0);

    //printf("Pre/Post t1 %016llX  ",t1);
    t1 = rol(t1, 21);
    //printf(" %016llX\n",t1);
#ifdef USE_XOR_RAND
    //printf("Pre %016llX\n",t2);
    t2 ^= t2 >> 15;
    //printf("(1) %016llX\n",t2);
    t2 ^= t2 << 13;
    //printf("(2) %016llX\n",t2);
    t2 ^= t2 >> 28;
    //printf("(3) %016llX\n",t2);
#else
    t2 = rol(t2, 42);
#endif    
    t2 = (t0 + t1) ^ t2;
    //printf("1064 random returns %016llX\n", t2);
    return t2;
}

