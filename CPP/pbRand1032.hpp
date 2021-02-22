// pbRand1032.hpp

#ifndef __PBRANDXX32_HPP_
#include "pbRandXX32.hpp"
#endif

#ifndef __PBRAND1032_HPP_
#define __PBRAND1032_HPP_


class pbRand1032 : virtual public pbRandXX32
{
public:

uint32_t seed[10];  //seed should be private

pbRand1032()
{
    //printf("pbRand1032::pbRand1032(-in .hpp)\n");
    clr();
    seedItem32(0x4321);
}

void init(void);  //setup mix tbl
void clr(void);  // zeros seed table
void print(void); //prints seed array for debug

uint32_t random32();
void seedItem32(uint32_t arg);
void mx(void);

};
#endif //__PBRAND1032_HPP_
