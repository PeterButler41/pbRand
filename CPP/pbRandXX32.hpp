// pbRandXX32.hpp

#ifndef __PBRAND_HPP_
#include "pbRand.hpp"
#endif

#ifndef __PBRANDXX32_HPP_
#define __PBRANDXX32_HPP_


class pbRandXX32 : virtual public pbRand
{
public:
    pbRandXX32() {};

// mix tbl is zeroed then seeded with 0x4321
virtual void mx(void)=0;   //do ine mix

// RETURN RANDOM VALUES
virtual uint32_t random32()=0;
        uint64_t random64();     //returns random 64-bit value

// RETURN RANDOM VALUES into RAM...
        void randomList64(uint64_t *dest, int longWordCount); //returns random into 64-bit words
        void randomList32(uint32_t *dest, int wordCount); //returns random into 32-bit words
        void randomList(void *dest, int byteCount);
// The above stores random<seed type> then bytes as needed
//
// the seedings...
        void seedSelf(void);   //seed tbl with internally generated Random item
        void seedItem64(uint64_t item); //seed tbl with 64-bit value
virtual void seedItem32(uint32_t item)=0; //seed tbl with 32-bit value
//
// seeding from memory...
 
        void seedList64(const uint64_t* src, int longWordCount); //seed with array of 64-bit items
        void seedList32(const uint32_t* src, int wordCount); //seed with array of 32-bit items
        void seedList(  const     void* src, int nBytes); //seed byte int count w/ best method

}; //class pbRandXX32
#endif // __PBRANDXX32_HPP_
