; _pbR1032.s

        name    _pbR1032
        col     132
        lstxrf  +

        public  init1032

        rseg   .text:NOROOT:CODE(2)
        thumb

;call is with buffer address in r0
;r0 remains unchanged allowing a simple mix call
init1032
        push    {lr}
        ldr     r1,=fList1032
        str     r1,[r0]         ;post fList to buffer
        movs    r1,#0
        movs    r2,#0
        adds    r3,r0,#8        ;advance past fList adrs
        stm     r3!,{r1,r2}
        stm     r3!,{r1,r2}
        stm     r3!,{r1,r2}
        stm     r3!,{r1,r2}
        stm     r3!,{r1,r2}

        mov     r1,#0x4321
        bl      seed
        pop     {pc}

#define AA r1
#define BB r2
#define CC r3
#define DD r4
#define tbl r5

;                0  1  2  3
mixMac  macro   AA,BB,CC,DD,idx
        ldr     DD,[tbl,#4*idx]
        adds    DD,AA
        eor     DD,DD,CC,ror#32-1
        str     DD,[tbl,#4*idx]
        endm

;r0 = adrs of fList,not used,seed[0],seed[1] ... seed[max]
;r0 is never changed
mix
        push    {r4-r5,lr}
        adds    tbl,r0,#8       ;pass over fList to tbl
        ldm     tbl!,{AA,BB,CC}
        subs    tbl,tbl,#3*4      ;&seed[2] --> &seed[0]
        mixMac  AA,BB,CC,DD,3
        mixMac  BB,CC,DD,AA,4
        mixMac  CC,DD,AA,BB,5
        mixMac  DD,AA,BB,CC,6
        mixMac  AA,BB,CC,DD,7
        mixMac  BB,CC,DD,AA,8
        mixMac  CC,DD,AA,BB,9
        mixMac  DD,AA,BB,CC,0
        mixMac  AA,BB,CC,DD,1
        mixMac  BB,CC,DD,AA,2
        pop     {r4-r5,pc}



;r0 = adrs of fList,notUsed,seed[0],seed[1] ... seed[max]
;r0 is never changed (thus calling mix is easy)
;r1 is the 32-bit seed
seed
        push    {r4-r5,lr}
        adds    r2,r0,#8           ;r2 = &seed[0] +0 is fList, +4 not used
        ldm     r2,{r3,r4,r5}      ;seed[0]..seed[2]
        add     r3,r3,r1,ror#32-1  ;seed[0]
        add     r4,r4,r1,ror#32-12 ;seed[1]
        add     r5,r5,r1,ror#32-21 ;seed[2]
        stm     r2!,{r3,r4,r5}
        bl      mix
        pop     {r4-r5,pc}

;r0 = adrs of fList followed by seed words
; on exit r0 is the return value
random
        push    {tbl,lr}
        bl      mix
        adds    tbl,r0,#8       ;offset past fList
        ldr     r1,[tbl,#4*9]   ;seed[9]
        ands    r1,r1,#7        ;mask
;the part below could be common 14 bytes for 32-bit
; but much more for 64-bit
        add     tbl,tbl,r1,lsl#2 ;(tbl adrs in r6 is changed)
        ldm     tbl!,{r0,r1,r2}  ;fetch the 3 words used for retVal

        rors    r0,r0,#32-1        ;r0 rol 1
        add     r0,r0,r1,ror#32-12 ;r0 += r1 rol 12
#ifdef USE_XOR_RAND
        eor     r2,r2,r2,lsr#11 ;r2 >>= 11
        eor     r2,r2,r2,lsl#17 ;r2 <<= 17
        eor     r2,r2,r2,lsr#13 ;r2 >>= 13
        eors    r0,r0,r2           ;return (r0+r1)^r2_as_changed_above
#else                              
        eors    r0,r0,r2,ror#32-21 ;return (r0+r1)^r2_rotated_left_21_bits
#endif
        pop     {tbl,pc}

; this belongs in _pbRxx32
random64
        push    {r4,r5,lr}
        mov     r4,r0           ;adrs of fList
        bl      random          ;make low bits
        movs    r5,r0           ;save low bits
        movs    r0,r4           ;restore adrs of fList
        bl      random          ;make high bits
        movs    r1,r0           ;high bits
        movs    r0,r5           ;return r1:r0 high:low
        pop     {r4,r5,pc}

        public  init1032
        extern  _pbR32seedItem64
        extern  _pbR32seedSelf
        extern  _pbR32random64
        extern  _pbR32seedList64
        extern  _pbR32seedList32
        extern  _pbR32seedList
        extern  _pbR32randomList64
        extern  _pbR32randomList32
        extern  _pbR32randomList

        rseg   .text:NOROOT:CONST(2)
fList1032
        dc32    init1032           ;ofs_init         equ  0
        dc32    _pbR32seedItem64   ;ofs_seedItem64   equ  4
        dc32    seed               ;ofs_seedItem32   equ  8
        dc32    _pbR32seedSelf     ;ofs_seedSelf     equ 12
        dc32    mix                ;ofs_mix          equ 16
        dc32    _pbR32random64     ;ofs_random64     equ 20
        dc32    random             ;ofs_random32     equ 24
        dc32    _pbR32seedList64   ;ofs_seedList64   equ 28
        dc32    _pbR32seedList32   ;ofs_seedList32   equ 32
        dc32    _pbR32seedList     ;ofs_seedList     equ 36
        dc32    _pbR32randomList64 ;ofs_randomList64 equ 40
        dc32    _pbR32randomList32 ;ofs_randomList32 equ 44
        dc32    _pbR32randomList   ;ofs_randomList   equ 48

        end

