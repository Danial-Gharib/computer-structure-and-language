PUTC    MACRO   char
        PUSH    AX
        MOV     AL, char
        MOV     AH, 0Eh
        INT     10h     
        POP     AX
ENDM

PRINT   MACRO   sdat
LOCAL   next_char, s_dcl, printed, skip_dcl

PUSH    AX   
PUSH    SI     

JMP     skip_dcl       
        s_dcl DB sdat, 0

skip_dcl:
        LEA     SI, s_dcl
        
next_char:      
        MOV     AL, CS:[SI]
        CMP     AL, 0
        JZ      printed
        INC     SI
        MOV     AH, 0Eh 
        INT     10h
        JMP     next_char
printed:

POP     SI    
POP     AX      
ENDM

PRINTN   MACRO   sdat
LOCAL   next_char, s_dcl, printed, skip_dcl

PUSH    AX     
PUSH    SI     

JMP     skip_dcl      
        s_dcl DB sdat, 13, 10, 0

skip_dcl:
        LEA     SI, s_dcl
        
next_char:      
        MOV     AL, CS:[SI]
        CMP     AL, 0
        JZ      printed
        INC     SI
        MOV     AH, 0Eh
        INT     10h
        JMP     next_char
printed:

POP     SI     
POP     AX    
ENDM

DEFINE_SCAN_NUM         MACRO
LOCAL make_minus, ten, next_digit, set_minus
LOCAL too_big, backspace_checked, too_big2
LOCAL stop_input, not_minus, skip_proc_scan_num
LOCAL remove_not_digit, ok_AE_0, ok_digit, not_cr

JMP     skip_proc_scan_num

SCAN_NUM        PROC    NEAR
        PUSH    DX
        PUSH    AX
        PUSH    SI
        MOV     CX, 0
        MOV     CS:make_minus, 0

next_digit:

 
        MOV     AH, 00h
        INT     16h
        MOV     AH, 0Eh
        INT     10h
        CMP     AL, '-'
        JE      set_minus
        CMP     AL, 13
        JNE     not_cr
        JMP     stop_input
not_cr:


        CMP     AL, 8                
        JNE     backspace_checked
        MOV     DX, 0                 
        MOV     AX, CX                
        DIV     CS:ten              
        MOV     CX, AX
        PUTC    ' '              
        PUTC    8                  
        JMP     next_digit
backspace_checked:

        CMP     AL, '0'
        JAE     ok_AE_0
        JMP     remove_not_digit
ok_AE_0:        
        CMP     AL, '9'
        JBE     ok_digit
remove_not_digit:       
        PUTC    8    
        PUTC    ' '     
        PUTC    8          
        JMP     next_digit      
ok_digit:

        PUSH    AX
        MOV     AX, CX
        MUL     CS:ten             
        MOV     CX, AX
        POP     AX

        CMP     DX, 0
        JNE     too_big

        SUB     AL, 30h

        MOV     AH, 0
        MOV     DX, CX    
        ADD     CX, AX
        JC      too_big2  

        JMP     next_digit

set_minus:
        MOV     CS:make_minus, 1
        JMP     next_digit

too_big2:
        MOV     CX, DX    
        MOV     DX, 0    
too_big:
        MOV     AX, CX
        DIV     CS:ten 
        MOV     CX, AX
        PUTC    8     
        PUTC    ' '   
        PUTC    8        
        JMP     next_digit 
        
stop_input:
        CMP     CS:make_minus, 0
        JE      not_minus
        NEG     CX
not_minus:

        POP     SI
        POP     AX
        POP     DX
        RET
make_minus      DB      ?     
ten             DW      10 
SCAN_NUM        ENDP

skip_proc_scan_num:

DEFINE_SCAN_NUM         ENDM

DEFINE_PRINT_NUM        MACRO
LOCAL not_zero, positive, printed, skip_proc_print_num

JMP     skip_proc_print_num

PRINT_NUM       PROC    NEAR
        PUSH    DX
        PUSH    AX

        CMP     AX, 0
        JNZ     not_zero

        PUTC    '0'
        JMP     printed

not_zero:

        CMP     AX, 0
        JNS     positive
        NEG     AX

        PUTC    '-'

positive:
        CALL    PRINT_NUM_UNS
printed:
        POP     AX
        POP     DX
        RET
PRINT_NUM       ENDP

skip_proc_print_num:

DEFINE_PRINT_NUM        ENDM

DEFINE_PRINT_NUM_UNS    MACRO
LOCAL begin_print, calc, skip, print_zero, end_print, ten
LOCAL skip_proc_print_num_uns

JMP     skip_proc_print_num_uns

PRINT_NUM_UNS   PROC    NEAR
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        MOV     CX, 1
        MOV     BX, 10000    

        CMP     AX, 0
        JZ      print_zero

begin_print:

        CMP     BX,0
        JZ      end_print

        CMP     CX, 0
        JE      calc
        CMP     AX, BX
        JB      skip
calc:
        MOV     CX, 0 

        MOV     DX, 0
        DIV     BX    
        ADD     AL, 30h   
        PUTC    AL


        MOV     AX, DX 

skip:
        PUSH    AX
        MOV     DX, 0
        MOV     AX, BX
        DIV     CS:ten 
        MOV     BX, AX
        POP     AX

        JMP     begin_print
        
print_zero:
        PUTC    '0'
        
end_print:

        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
ten             DW      10     
PRINT_NUM_UNS   ENDP

skip_proc_print_num_uns:

DEFINE_PRINT_NUM_UNS    ENDM



.STACK 100h
.DATA
    n dw ?
    half_n dw ?
    plus db '+'
    equal db '='
    two db 2
    n_line dw 0AH,0DH,"$"
    
.CODE
        is_prime proc
           push ax
           push cx
           cmp bx, 1
           je false
           cmp bx, 2
           je true
           mov cx, 2
       lop:    
           mov dx, 0
           mov ax, bx
           div cx
           cmp dx, 0
           je false
           inc cx
           cmp cx, bx
           jl lop
       true:
            mov dx, 1
            jmp end
       false:
            mov dx, 0
       end:
            pop cx
            pop ax
            ret              
      is_prime endp
       
    MAIN proc  
       mov ax, @DATA
       mov ds, ax
       call SCAN_NUM
       PRINTN "" 
       mov n,cx
       mov ax, cx
       div two
       mov ah, 0
       inc al
       mov half_n, ax ;n / 2  + 1 ro zakhire kardam ke to is_prime estefade konam
       mov ax, 4

loop1: 

       mov bx, 2    ;from 2 up to n loop every number

loop2:              ;in loop2 we check if x and n - x are both prime
       call is_prime
       cmp dx, 0
       je continue2
       mov cx, bx
       mov bx, ax       
       sub bx, cx
       call is_prime
       cmp dx, 1
       je print
       mov bx, cx   ;bx ro barmigardoonim
       jmp continue2
print:       
       call PRINT_NUM
       PRINT " = "
       xchg ax, cx
       call PRINT_NUM
       xchg ax, cx
       PRINT " + "
       xchg ax, bx
       call PRINT_NUM
       xchg ax, bx
       PRINTN ""
       jmp continue1
        
continue2:        

       inc bx
       cmp bx, n
       jl loop2    

continue1:

       add ax, 2    ;from 4 up to n loop only even numbers 
       cmp ax, n
       jle loop1
                   
    MAIN endp
    
DEFINE_SCAN_NUM
DEFINE_PRINT_NUM
DEFINE_PRINT_NUM_UNS
END MAIN    
 
 





