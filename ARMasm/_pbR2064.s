; _pbR2064.s

        name    _pbR1064
        col     132
        lstxrf  +

        public  init2064

        extern   _pbR64seedHead

        rseg   .text:NOROOT:CODE(2)
        thumb

;call is with buffer address in r0
;r0 remains unchanged allowing a simple mix call
init2064
        push    {r4,lr}
        ldr     r1,=fList2064
        str     r1,[r0]         ;post fList to buffer
        movs    r1,#0
        movs    r2,#0
        adds    r3,r0,#8        ;advance past fList adrs
        movs    r4,#20          ;loop count
init1
        stm     r3!,{r1,r2}
        subs    r4,r4,#1
        bne     init1           ;if not done

        ldr     r1,=0x87654321
        mov     r2,#0           ;sVal is 0:0x87654321
        bl      seed
        pop     {r4,pc}

; defines for mix
#define AAlo r0
#define AAhi r1
#define BBlo r2
#define BBhi r3
#define CClo r4
#define CChi r5
#define DDlo r6
#define tbl  r7
#define DDhi r8

mixMac  macro   AAlo,AAhi,BBlo,BBhi,CClo,CChi,DDlo,DDhi,idx
        ldm     tbl!,{DDlo,DDhi}
        adds    DDlo,DDlo,AAlo
        adcs    DDhi,DDhi,AAhi
        eor     DDhi,DDhi,CChi,lsl#1
        eor     DDlo,DDlo,CClo,lsl#1
        eor     DDhi,DDhi,CClo,lsr#31
        eor     DDlo,DDlo,CChi,lsr#31
        stmdb   tbl,{DDlo,DDhi}
        endm


;r0 = adrs of fList,seed[0],seed[1] ... seed[max]
;r0 is used but is restored on exit
mix
        push    {r0,r4-r9,lr}
        adds    tbl,r0,#8       ;pass over seed[-1]
        ldm     tbl!,{r0-r5}    ;AAlo..CChi
#if 1
        bl      do4 ;3 4 5 6
        bl      do4 ;7 8 9 10
        bl      do4 ;11 12 13 14
        bl      do4 ;15 16 17 18
        mixMac  AAlo,AAhi, BBlo,BBhi, CClo,CChi, DDlo,DDhi, 19
        subs    tbl,tbl,#160 ;i.e. seed[0] is changed next
        bl      do3 ;0 1 2
        pop     {r0,r4-r9,pc}

do4     mixMac  AAlo,AAhi, BBlo,BBhi, CClo,CChi, DDlo,DDhi, 3
do3     mixMac  BBlo,BBhi, CClo,CChi, DDlo,DDhi, AAlo,AAhi, 4
        mixMac  CClo,CChi, DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, 5
        mixMac  DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, CClo,CChi, 6
        bx      lr
#if 0
        mixMac  AAlo,AAhi, BBlo,BBhi, CClo,CChi, DDlo,DDhi, 3
        mixMac  BBlo,BBhi, CClo,CChi, DDlo,DDhi, AAlo,AAhi, 4
        mixMac  CClo,CChi, DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, 5
        mixMac  DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, CClo,CChi, 6
        mixMac  AAlo,AAhi, BBlo,BBhi, CClo,CChi, DDlo,DDhi, 7
        mixMac  BBlo,BBhi, CClo,CChi, DDlo,DDhi, AAlo,AAhi, 8
        mixMac  CClo,CChi, DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, 9
        mixMac  DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, CClo,CChi, 10
        mixMac  AAlo,AAhi, BBlo,BBhi, CClo,CChi, DDlo,DDhi, 11
        mixMac  BBlo,BBhi, CClo,CChi, DDlo,DDhi, AAlo,AAhi, 12
        mixMac  CClo,CChi, DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, 13
        mixMac  DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, CClo,CChi, 14
        mixMac  AAlo,AAhi, BBlo,BBhi, CClo,CChi, DDlo,DDhi, 15
        mixMac  BBlo,BBhi, CClo,CChi, DDlo,DDhi, AAlo,AAhi, 16
        mixMac  CClo,CChi, DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, 17
        mixMac  DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, CClo,CChi, 18
        mixMac  AAlo,AAhi, BBlo,BBhi, CClo,CChi, DDlo,DDhi, 19
        subs    tbl,tbl,#80 ;i.e. seed[0] is changed next
        mixMac  BBlo,BBhi, CClo,CChi, DDlo,DDhi, AAlo,AAhi, 0
        mixMac  CClo,CChi, DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, 1
        mixMac  DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, CClo,CChi, 2
        pop     {r0,r4-r9,pc}
#endif

; on entry r0 = &seed[-1] which is &fList, unused int, seed[0..9]
; on exit r0 is returned unchanged
seedItem32
        mov     r2,#0
seed    push    {lr}
        bl      _pbR64seedHead
        bl      mix
        pop     {pc}

; in random, fearful coder used a few defines
;  to maintain what little sanity he possessed
#define t0lo r0
#define t0hi r1
#define t1lo r2
#define t1hi r3
#define t2lo r4
#define t2hi r5
#define Atemp r6
#define Btemp r7
#define TEMP r6

        extern  _pbR64randTail
random
        push    {r4-r7,lr}
        bl      mix
        adds    r6,r0,#8        ;offset past fList
        ldr     r7,[r6,#8*19]  ;seed[19]
        ands    r7,r7,#15       ;mask
        add     r6,r6,r7,lsl#3  ;(tbl adrs in r5 is changed)
        ldm     r6!,{r0-r5}     ;the 3 64-bit words used for retVal
        bl      _pbR64randTail
        pop     {r4-r7,pc}


        extern  _pbR64seedItem32
        extern  _pbR64seedSelf
        extern  _pbR64random32
        extern  _pbR64seedList64
        extern  _pbR64seedList32
        extern  _pbR64seedList
        extern  _pbR64randomList64
        extern  _pbR64randomList32
        extern  _pbR64randomList

        rseg   .text:NOROOT:CONST(2)
fList2064
        dc32    init2064           ;ofs_init         equ  0
        dc32    seed               ;ofs_seedItem64   equ  4
        dc32    seedItem32         ;ofs_seedItem32   equ  8
        dc32    _pbR64seedSelf     ;ofs_seedSelf     equ 12
        dc32    mix                ;ofs_mix          equ 16
        dc32    random             ;ofs_random64     equ 20
        dc32    random             ;ofs_random32     equ 24
        dc32    _pbR64seedList64   ;ofs_seedList64   equ 28
        dc32    _pbR64seedList32   ;ofs_seedList32   equ 32
        dc32    _pbR64seedList     ;ofs_seedList     equ 36
        dc32    _pbR64randomList64 ;ofs_randomList64 equ 40
        dc32    _pbR64randomList32 ;ofs_randomList32 equ 44
        dc32    _pbR64randomList   ;ofs_randomList   equ 48

        end