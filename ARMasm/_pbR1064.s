; _pbR1064.s

        name    _pbR1064
        col     132
        lstxrf  +

        public  init1064
        extern  _pbR64seedHead
 ;other externs defined at end of module

        rseg   .text:NOROOT:CODE(2)
        thumb

;call is with buffer address in r0
;r0 remains unchanged allowing a simple seed call
init1064
        push    {r4,lr}
        ldr     r1,=fList1064
        str     r1,[r0]         ;post fList to buffer
        mov     r1,#0
        mov     r2,#0
        adds    r3,r0,#8        ;skip fList
        mov     r4,#10          ;loop count
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
        ldm     tbl,{DDlo,DDhi}
        adds    DDlo,DDlo,AAlo
        adcs    DDhi,DDhi,AAhi
        eor     DDhi,DDhi,CChi,lsl#1
        eor     DDlo,DDlo,CClo,lsl#1
        eor     DDhi,DDhi,CClo,lsr#31
        eor     DDlo,DDlo,CChi,lsr#31
        stm     tbl!,{DDlo,DDhi}
        endm


;r0 = adrs of fList,seed[0],seed[1] ... seed[max]
;r0 is used but is restored on exit
mix
        push    {r0,r4-r9,lr}
        adds    tbl,r0,#8       ;pass over seed[-1]
        ldm     tbl!,{r0-r5}    ;AAlo..CChi
        mixMac  AAlo,AAhi, BBlo,BBhi, CClo,CChi, DDlo,DDhi, 3
        mixMac  BBlo,BBhi, CClo,CChi, DDlo,DDhi, AAlo,AAhi, 4
        mixMac  CClo,CChi, DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, 5
        mixMac  DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, CClo,CChi, 6
        mixMac  AAlo,AAhi, BBlo,BBhi, CClo,CChi, DDlo,DDhi, 7
        mixMac  BBlo,BBhi, CClo,CChi, DDlo,DDhi, AAlo,AAhi, 8
        mixMac  CClo,CChi, DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, 9
        subs    tbl,tbl,#80 ;i.e. seed[0] is changed next
        mixMac  DDlo,DDhi, AAlo,AAhi, BBlo,BBhi, CClo,CChi, 0
        mixMac  AAlo,AAhi, BBlo,BBhi, CClo,CChi, DDlo,DDhi, 1
        mixMac  BBlo,BBhi, CClo,CChi, DDlo,DDhi, AAlo,AAhi, 2
        pop     {r0,r4-r9,pc}

; on entry r0 = &seed[-1] which is &fList, unused int, seed[0..9]
; on exit r0 is returned unchanged
seedItem32
        mov     r2,#0
seed    push    {lr}
        bl      _pbR64seedHead
        bl      mix
        pop     {pc}


        extern  _pbR64randTail
random
        push    {r4-r7,lr}
        bl      mix
        adds    r6,r0,#8        ;offset past fList
        ldr     r7,[r6,#8*9]    ;seed[9]
        ands    r7,r7,#7        ;mask
        add     r6,r6,r7,lsl#3  ;(tbl adrs in r5 is changed)
        ldm     r6!,{r0-r5}     ;the 3 64-bit words used for retVal
        bl      _pbR64randTail
        pop     {r4-r7,pc}

        extern  _pbR64seedItem32
        extern  _pbR64seedSelf
        extern  _pbR64seedList64
        extern  _pbR64seedList32
        extern  _pbR64seedList
        extern  _pbR64randomList64
        extern  _pbR64randomList32
        extern  _pbR64randomList

        rseg   .text:NOROOT:CONST(2)
fList1064
        dc32    init1064           ;ofs_init         equ  0
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