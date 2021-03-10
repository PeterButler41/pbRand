
// pbRand2064.hpp

#ifndef __PBRANDXX64_HPP_
#include "pbRandXX64.hpp"
#endif

#ifndef __PBRAND2064_HPP_
#define __PBRAND2064_HPP_


class pbRand2064 : virtual public pbRandXX64
{
public:

uint64_t seed[20];  //seed should be private

pbRand2064()
{
//    printf("pbRand2064::pbRand2064(-in .hpp)\n");
    clr();
    seedItem64(0x87654321);
}

void reInit();  //setup mix tbl
void clr(void);  // zeros seed table
void print(void); //prints seed array for debug

uint64_t random64();     //returns random 64-bit value
void seedItem64(uint64_t arg);
void mx(void);

};
#endif //__PBRAND2064_HPP_



