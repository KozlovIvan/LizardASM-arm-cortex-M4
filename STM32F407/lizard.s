.syntax unified
.cpu cortex-m4

.extern t, K, IV, z, L, Q, T, Ttilde, B, S, a257, keystream

.global lizard_asm
.type lizard_asm, %function
lizard_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    ldr r0, =t

    pop {r4-r12}
    bx lr

.global loadkey_asm
.type loadkey_asm, %function
loadkey_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}

    mov r4, 0 // counter
    ldr r5, =K // load extern symbol K (key array)
    ldr r6, [r0]
    str r6, [r5]
loadkey_loop:    
    ldr r6, [r0, #1]!
    str r6, [r5, #1]!
    add r4, r4, 1       //increment counter
    cmp r4, 118         //compare to 118
    ble loadkey_loop    //if less or equal jump to the begining of the loop
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global loadIV_asm
.type loadIV_asm, %function
loadIV_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}

    mov r4, 0      // initialize loop counter 
    ldr r5, =IV    // load address of first element of IV array
    ldr r6, [r0]
    str r6, [r5]
loadiv_loop:
    ldr r6, [r0, #1]!
    str r6, [r5, #1]!
    add r4, r4, 1       //increment counter
    cmp r4, 59         //compare to 62
    ble loadiv_loop    //if less or equal jump to the begining of the loop

    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global initRegisters_asm
.type initRegisters_asm, %function
initRegisters_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global mixing_asm
.type mixing_asm, %function
mixing_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global keyadd_asm
.type keyadd_asm, %function
keyadd_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global diffusion_asm
.type diffusion_asm, %function
diffusion_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global NFSR1_asm
.type NFSR1_asm, %function
NFSR1_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global NFSR2_asm
.type NFSR2_asm, %function
NFSR2_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global construct_asm
.type construct_asm, %function
construct_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global initialization_asm
.type initialization_asm, %function
initialization_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global keystreamGeneration_asm
.type keystreamGeneration_asm, %function
keystreamGeneration_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global keystreamGenerationSpecification_asm
.type keystreamGenerationSpecification_asm, %function
keystreamGenerationSpecification_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global a_asm
.type a_asm, %function
a_asm:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr
