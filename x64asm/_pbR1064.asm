; _pbR1064.asm
; ==> must return unchanged: RBX, RBP, and R12..R15
;R8–R15 are the new 64-bit registers.
;R8D–R15D are the lowermost 32 bits of each register.
;R8W–R15W are the lowermost 16 bits of each register.
;R8B–R15B are the lowermost 8 bits of each register.

; The first four  user call arguments are in RCX, RDX, R8, R9
; (but we are never called with more than 3 arguments)
; The first parameter, rcx, is the adrs of what might
;  be called seed[-1]. That word, the fList, precedes seed[].

; User call code MUST load &seed[0] into rsi

; Internal calls always leave rsi pointing to seed[0]

AAA     equ     rax
BBB     equ     r11
CCC     equ     rcx
DDD     equ     rdx
temp    equ     rdi
tbl     equ     rsi

cntReg  equ     r8d ; shared between all modules
adrsReg equ     r9  ; (only used in the list functions)
funcReg equ     r10 ;only used in base

seedSize equ    8
numSeeds equ    10
rotA    equ     1
rotB    equ     21
rotC    equ     42
rndMask equ     7

        .code

        public  init1064
init1064:
        mov     rsi,rcx         ;adrs of where &fList goes
        lodsq
        lea     rdx,fList1064
        mov     [rcx],rdx
; now zero the seed[] arrat
        mov     rdi,rsi
        mov     ecx,numSeeds
        rep stosq
        mov     edx,87654321h
        jmp     seed

        align   qword
random: ;tbl (rsi} is set to seed[0] and is never changed
; the t0, t1, and t2 are name from the docx
        call    mix
        mov     rdx,[rsi+(numSeeds-1)*seedSize]
        and     rdx,rndMask
        lea     rdx,[rsi+rdx*seedSize]
        mov     AAA,[rdx]            ;t0
        rol     AAA,rotA
        mov     BBB,[rdx+seedSize]   ;t1
        rol     BBB,rotB
        add     AAA,BBB
        mov     CCC,[rdx+seedSize*2] ;t2
 ifdef USE_XOR_SHIFT
; in place of a silple t2 rol and add or xor...
; t2^= t2>>15; t2^= t2<<13; t2^= t2>>28;

        mov     temp,CCC
        shr     temp,15
        xor     CCC,temp        ;t2^= t2>>15

        mov     temp,CCC
        shl     temp,13
        xor     CCC,temp        ;t2^= t2<<13

        mov     temp,CCC
        shr     temp,28
        xor     CCC,temp        ;t2^= t2>>28
 else
        rol     CCC,rotC
 endif
;and finally...
        xor     rax,CCC
        ret

seedItem32:
        or      edx,edx ;:
seed:   ;parameter is in rdx
        ;tbl (rsi} is set to seed[0] and is never changed
        rol     rdx,rotA
        add     [tbl],rdx
        rol     rdx,rotB-rotA
        add     [tbl+seedSize],rdx
        rol     rdx,rotC-rotB
        add     [tbl+seedSize*2],rdx
; and hey, because this is assembly simply fall into mix1
;       ...

mixMac  macro   AA,BB,CC,DD,XX
        mov     DD,[tbl]
        add     DD,AA
        mov     temp,CC
        rol     temp,1
        xor     DD,temp
        mov     [tbl],DD
        add     tbl,seedSize
        endm

        align   qword
mix:   ;tbl (rsi) is set to seed[0] and returns unchanged
        mov     AAA,[tbl]
        mov     BBB,[tbl+8]
        mov     CCC,[tbl+16]
        add     tbl,seedSize*3
        mixMac  AAA,BBB,CCC,DDD,3 ;changes seed[3]
        mixMac  BBB,CCC,DDD,AAA,4 ; ditto seed[4]
        mixMac  CCC,DDD,AAA,BBB,5 ; etc...
        mixMac  DDD,AAA,BBB,CCC,6
        mixMac  AAA,BBB,CCC,DDD,7
        mixMac  BBB,CCC,DDD,AAA,8
        mixMac  CCC,DDD,AAA,BBB,9
        sub     tbl,numSeeds*seedSize   ;reset tbl back to seed[0]
        mixMac  DDD,AAA,BBB,CCC,0
        mixMac  AAA,BBB,CCC,DDD,1
        mixMac  BBB,CCC,DDD,AAA,2
        sub     tbl,seedSize*3          ;reset tbl back to seed[0]
        ret

seedSelf:
        call    random
        mov     rdx,rax
        jmp     seed

; want qword (8-byte boundry here)
; table is constant value
        .data
        align   qword
;**********************************************************************
;
; fList offsets
;
        extern  _64seedList64:abs
        extern  _64seedList32:abs
        extern  _64seedList:abs
        extern  _64randomList64:abs
        extern  _64randomList32:abs
        extern  _64randomList:abs

        public  fList1064
fList1064:
 dq init1064        ;ofs_init         equ  0*2 ;only useful after calling initxxyy
 dq seed            ;ofs_seedItem64   equ  4*2
 dq seedItem32      ;ofs_seedItem32   equ  8*2
 dq seedSelf        ;ofs_seedSelf     equ 12*2
 dq mix             ;ofs_mix          equ 16*2
 dq random          ;ofs_random64     equ 20*2
 dq random          ;ofs_random32     equ 24*2 (caller ignores bits 32..63)
 dq _64seedList64   ;ofs_seedList64   equ 28*2
 dq _64seedList32   ;ofs_seedList32   equ 32*2
 dq _64seedList     ;ofs_seedList     equ 36*2 ;byte count - best way
 dq _64randomList64 ;ofs_randomList64 equ 40*2
 dq _64randomList32 ;ofs_randomList32 equ 44*2
 dq _64randomList   ;ofs_randomList   equ 48*2

        end

