.data 
                n: .word 
                space: .asciiz " "
                plus: .asciiz  " + "
                plus2: .asciiz " + "
                equal: .asciiz   " = "
                new_line: .asciiz  "\n"
                .text 
                .globl main
          
              main:

             li $v0, 5
             syscall 
             sw $v0, n
             move $t8, $v0
             li  $t1, 4
         loop1:
             li $t2, 2
         loop2:
             jal is_prime
             li $t5, 0
             beq $t9, $t5, continue2
             move $t6, $t2
             sub $t2, $t1, $t2
             jal is_prime
             li $t5, 1
             beq $t9, $t5, print                            #dovomi ham dar oomad
             move $t2, $t6
             j continue2
         print:
             li $v0, 1
             move $a0, $t1
             syscall                 # adad avval print shod
             li $v0, 4
             la $a0, equal
             syscall        # mosavi = = print shod
             li $v0, 1
             move $a0, $t2
             syscall         #adad dovom print shod
             li $v0, 4
             la $a0, plus2
             syscall      #plus  print shod
             li $v0, 1
             move $a0, $t6
             syscall       #adad sevvom print shod
             li $v0, 4
             la $a0, new_line
             syscall     #raftim khat baad
             j  continue1
             
                 
         continue2:
             addi $t2, $t2, 1
             blt $t2, $t8, loop2
         continue1:
             addi $t1, $t1, 2
             ble $t1, $t8, loop1
             
             li $v0, 10
             syscall                                                         
               
             
        is_prime:
            li $t3, 2
            beq $t2, $t3, true
            li $t5, 0
        lop:
            div $t2, $t3
            mfhi $t4
            beq $t4, $t5, false
            addi $t3, $t3, 1
            blt $t3, $t2, lop    
                     
        true:
            li $t9, 1
            b end
        false:
            li $t9, 0
        end:
            jr  $ra