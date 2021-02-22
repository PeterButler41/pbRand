; _pbR2032.asm
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

AAA     equ     eax
BBB     equ     r11d
CCC     equ     ecx
DDD     equ     edx
temp    equ     edi
tbl     equ     rsi

cntReg  equ     r8d ; shared between all modules
adrsReg equ     r9  ; (only used in the list functions)
funcReg equ     r10 ;only used in base

seedSize equ    4
numSeeds equ    20
rotA    equ     1
rotB    equ     12
rotC    equ     21
rndMask equ     15

        .code

        public  init2032
init2032:
        mov     rsi,rcx         ;adrs of where &fList goes
        lodsq
        lea     rdx,fList2032
        mov     [rcx],rdx
; now zero the seed[] array
        mov     rdi,rsi
        mov     ecx,20
        rep stosd
        mov     edx,4321h
        jmp     seed



        align   qword
random: ;tbl (rsi} is set to seed[0] and is never changed
; the t0, t1, and t2 are name from the docx
        call    mix
        mov     rdx,[rsi+(numSeeds-1)*seedSize]
        and     edx,rndMask
        lea     rdx,[rsi+rdx*seedSize]
        mov     AAA,[rdx]            ;t0
        rol     AAA,rotA
        mov     BBB,[rdx+seedSize]   ;t1
        rol     BBB,rotB
        add     AAA,BBB
        mov     CCC,[rdx+seedSize*2] ;t2

; in place of a silple t2 rol and add or xor...
; t2^= t2>>11; t2^= t2<<17; t2^= t2>>13

        mov     temp,CCC
        shr     temp,11
        xor     CCC,temp        ;t2^= t2>>11
        mov     temp,CCC
        shl     temp,17
        xor     CCC,temp        ;t2^= t2<<17
        mov     temp,CCC
        shr     temp,13
        xor     CCC,temp        ;t2^= t2>>13
;and finally...
        xor     eax,CCC
        ret

seed:   ;parameter is in rdx
        ;tbl (rsi} is set to seed[0] and is never changed
        rol     edx,rotA
        add     [tbl],edx
        rol     edx,rotB-rotA
        add     [tbl+seedSize],edx
        rol     edx,rotC-rotB
        add     [tbl+seedSize*2],edx
; and hey, because this is assembly simply fall into mix
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
        mov     BBB,[tbl+4]
        mov     CCC,[tbl+8]
        add     tbl,seedSize*3
        mixMac  AAA,BBB,CCC,DDD,3 ;changes seed[3]
        mixMac  BBB,CCC,DDD,AAA,4 ; ditto seed[4]
        mixMac  CCC,DDD,AAA,BBB,5 ; etc...
        mixMac  DDD,AAA,BBB,CCC,6
        mixMac  AAA,BBB,CCC,DDD,7
        mixMac  BBB,CCC,DDD,AAA,8
        mixMac  CCC,DDD,AAA,BBB,9
        mixMac  DDD,AAA,BBB,CCC,10
        mixMac  AAA,BBB,CCC,DDD,11
        mixMac  BBB,CCC,DDD,AAA,12
        mixMac  CCC,DDD,AAA,BBB,13
        mixMac  DDD,AAA,BBB,CCC,14
        mixMac  AAA,BBB,CCC,DDD,15
        mixMac  BBB,CCC,DDD,AAA,16
        mixMac  CCC,DDD,AAA,BBB,17
        mixMac  DDD,AAA,BBB,CCC,18
        mixMac  AAA,BBB,CCC,DDD,19
        sub     tbl,numSeeds*seedSize ;reset tbl back to seed[0]
        mixMac  BBB,CCC,DDD,AAA,0
        mixMac  CCC,DDD,AAA,BBB,1
        mixMac  DDD,AAA,BBB,CCC,2
        sub     tbl,seedSize*3        ;reset tbl back to seed[0]
        ret

seedSelf:
        call    random
        mov     edx,eax
        jmp     seed

seedItem64:
        push    rdx
        call    seed
        pop     rdx
        shr     rdx,32
        jmp     seed

random64:
        call    random
        push    rax     ;save low bits
        call    random
        shl     rax,32  ;move high bits up
        pop     rdx
        or      rax,rdx ;or them together
        ret


; want qword (8-byte boundry here)
; table is constant value
        .data
        align   qword
;**********************************************************************
;
; fList offsets
;
        extern  _32seedList64:abs
        extern  _32seedList32:abs
        extern  _32seedList:abs
        extern  _32randomList64:abs
        extern  _32randomList32:abs
        extern  _32randomList:abs

;        public  fList2032
fList2032:
 dq init2032        ;ofs_init         equ  0*2 ;only useful after calling initxxyy
 dq seedItem64      ;ofs_seedItem64   equ  4*2
 dq seed            ;ofs_seedItem32   equ  8*2
 dq seedSelf        ;ofs_seedSelf     equ 12*2
 dq mix             ;ofs_mix          equ 16*2
 dq random64        ;ofs_random64     equ 20*2
 dq random          ;ofs_random32     equ 24*2 ;(caller ignores bits 32..63)
 dq _32seedList64   ;ofs_seedList64   equ 28*2
 dq _32seedList32   ;ofs_seedList32   equ 32*2
 dq _32seedList     ;ofs_seedList     equ 36*2 ;byte count - best way
 dq _32randomList64 ;ofs_randomList64 equ 40*2
 dq _32randomList32 ;ofs_randomList32 equ 44*2
 dq _32randomList   ;ofs_randomList   equ 48*2

        end
