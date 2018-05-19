
.syntax unified
.cpu cortex-m4

.global power_5_13
.type power_5_13, %function
power_5_13:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}

    # Exercise 1 a)
    # Write a function power_5_13() to compute 5 ** 13 (i.e. 5 to the power 13)
    mov r0, #5
    mov r1, #5
    mul r0, r0
    mul r0, r0
    mul r0, r0
    mul r0, r1
    mul r0, r1
    mul r0, r1
    mul r0, r1
    mul r0, r1
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global power
.type power, %function
power:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}

    # Exercise 1 b)
    # Write a function power(x, y) that computes x ** y (i.e. x to the power y)
    mov r2, r0
    mov r3, #1
loop:    
    


    cmp r1, 0

    mov r0, r3
    mul r3, r2
    sub r1, #1
    bne loop 


    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr
