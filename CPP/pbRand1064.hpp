// pbRand1064.hpp

#ifndef __PBRANDXX64_HPP_
#include "pbRandXX64.hpp"
#endif

#ifndef __PBRAND1064_HPP_
#define __PBRAND1064_HPP_


class pbRand1064 : virtual public pbRandXX64
{
public:

uint64_t seed[10];  //seed should be private

pbRand1064()
{
//    printf("pbRand1064::pbRand1064(-in .hpp)\n");
    clr();
    seedItem64(0x87654321);
}

void init();  //setup mix tbl
void clr(void);  // zeros seed table
void print(void); //prints seed array for debug

uint64_t random64();     //returns random 64-bit value
void seedItem64(uint64_t arg);
void mx(void);

};
#endif //__PBRAND1064_HPP_
