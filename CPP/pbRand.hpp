//pbRand.hpp

#ifndef __PBRAND_HPP_
#define __PBRAND_HPP_

#include <stdio.h> //if we debug using printf

typedef signed char        int8_t;
typedef short              int16_t;
typedef int                int32_t;
typedef long long          int64_t;
typedef unsigned char      uint8_t;
typedef short int          uint16_t;
typedef unsigned int       uint32_t;
typedef unsigned long long uint64_t;

class pbRand
{
/////////////////////////////////////////////////
// This base class has no methods and no data  //
//                                             //
// Use like this:                              //
// pbRand* obj = new pbRandXXYY();             //
//   where XXYY = 1032 seed is 10 32-bit words //
//                2032 seed is 20 32-bit words //
//                1064 seed is 10 64-bit words //
//                2064 seed is 20 64-bit words //
/////////////////////////////////////////////////
public:

    pbRand() {};  // no constructor for our base class

virtual void reInit(void)=0;  //[re]setup mix tbl
virtual void clr(void)=0;
virtual void print(void)=0;

#ifdef __cplusplus
void mix(int n=10);         //do a mix nTimes
#else
void mix(int);              // no default value in C
#endif
virtual void mx(void)=0;            //do one mix

// RETURN RANDOM VALUES
virtual uint64_t random64()=0;     //returns random 64-bit valu
virtual uint32_t random32()=0;     //returns random 32-bit value

// RETURN RANDOM VALUES into RAM...
virtual void randomList64(uint64_t *dest, int longWordCount)=0; //returns random into 64-bit words
virtual void randomList32(uint32_t* dest, int wordCount)=0; //returns random into 32-bit words
virtual void randomList(      void *dest, int byteCount)=0;
// The above stores random<seed type> then bytes as needed
//
// the seedings...
virtual void seedSelf(void)=0;   //seed tbl with internally generated Random item
virtual void seedItem64(uint64_t item)=0; //seed tbl with 64-bit value
virtual void seedItem32(uint32_t item)=0; //seed tbl with 32-bit value
        void seedItem16(uint16_t item); //seed tbl with 16-bit value
        void seedItem8(uint8_t item);  //seed tbl with 8-bit value
        void seedByte(uint8_t  item);  //exactly the same as above
        void seedChar(int8_t item);     //exactly the same as above
//
// seeding from memory...
// (all seedings from memory perform an extra mix() after seeding)
virtual void seedList64 (const uint64_t *src, int longWordCount)=0; //seed with array of 64-bit items
virtual void seedList32 (const uint32_t *src, int wordCount)=0; //seed with array of 32-bit items
        void seedList16 (const uint16_t *src, int itemCount); //seed with array of 16-bit items
        void seedList8  (const uint8_t  *src, int byteCount); //seed with array of 8-bit items
        void seedList8  (const int8_t   *src, int byteCount); //seed with array of 8-bit items
virtual void seedList   (const void     *src, int nBytes)   =0; //seed byte int count w/ best method
        void seedCstring(const char     *str); //seed char’s with null terminated C-string

}; // end class pbRand

#endif //#ifndef __PBRAND_HPP


