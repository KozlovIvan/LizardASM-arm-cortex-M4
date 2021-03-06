.syntax unified
.cpu cortex-m4
.extern t, K, IV, z, L, Q, T, Ttilde, B, S, a257, keystream, keystream_size
.align 2

// ╦  ╦╔═╗╔═╗╦═╗╔╦╗
// ║  ║╔═╝╠═╣╠╦╝ ║║
// ╩═╝╩╚═╝╩ ╩╩╚══╩╝
// by Ivan Kozlov, 2018
// https://github.com/KozlovIvan/LizardASM-arm-cortex-M4

.global _construct_asm
.type _construct_asm, %function
_construct_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    bl _construct_z
    //TODO LOOP
    bl _initialization_phase1
    //TODO phase2
    //TODO phase3
    bl keyadd_S_1
    bl _initialization_phase4
    ldr r4, =keystream_size
    ldr r0, [r4]
    bl keystreamGeneration_asm
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr

.global _initialization_phase1
.type _initialization_phase1, %function
_initialization_phase1:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    bl loadkey_asm
    mov r0, r1
    bl loadIV_asm
    bl initRegisters_asm
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr


.global _initialization_phase3_B
.type _initialization_phase3_B, %function
_initialization_phase3_B:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}

    movs   r4, #0
loopsyloopb:
    uxtb    r0, r4
    adds    r4, #1
    bl      keyadd_B
    cmp     r4, #0x5A
    bne     loopsyloopb

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr

.global _initialization_phase3_S
.type _initialization_phase3_S, %function
_initialization_phase3_S:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r0-r12, r14}
    movs    r4, #0
loopsyloops:
    uxtb    r0, r4
    adds    r4, #1
    bl      keyadd_S
    cmp     r4, #0x1E
    bne     loopsyloops
   
    
    // Finally, we restore the callee-saved register values and branch back.
    pop {r0-r12, pc}
    bx lr


.global _initialization_phase4
.type _initialization_phase4, %function
_initialization_phase4:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    ldr r4, =t
    mov r5, 129
    str r5, [r4]
ph4lp:
    bl diffusion_asm
    cmp r5, 256
    add r5, r5, 1
    str r5, [r4]
    blt ph4lp
    
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr

.global loadkey_asm
.type loadkey_asm, %function
loadkey_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}

    mov r4, 0       // counter
    ldr r5, =K      // load extern symbol K (key array)
loadkey_loop:    
    ldr r6, [r0, r4]
    str r6, [r5, r4]
    add r4, r4, 1       // increment counter
    cmp r4, 120         // compare to 119
    ble loadkey_loop    // if less or equal jump to the begining of the loop
    
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr

.global loadIV_asm
.type loadIV_asm, %function
loadIV_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}

    mov r4, 0      // initialize loop counter 
    ldr r5, =IV    // load address of first element of IV array
loadiv_loop:
    ldr r6, [r0, r4]
    str r6, [r5, r4]
    add r4, r4, 1       // increment counter
    cmp r4, 61          // compare to 62
    ble loadiv_loop     // if less or equal jump to the begining of the loop

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr

.global initRegisters_asm
.type initRegisters_asm, %function
initRegisters_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    mov r4, 0       // counter
    ldr r5, =B      // load extern symbol B
    ldr r6, =K      // load extern symbol K
    ldr r7, =IV     // load extern symbol IV
    ldr r8, =S      // load extern symbol S

init_register_B_p1:
    ldr r9, [r6, r4] // i-th element of K
    ldr r10, [r7, r4] // i-th element of IV
    eor r11, r9, r10
    str r11, [r5, r4]
    add r4, r4, 1
    cmp r4, 62
    ble init_register_B_p1

    mov r4, 64 //update counter
init_register_B_p2:
    ldr r9, [r6, r4]
    str r9, [r5, r4]
    add r4, r4, 1
    cmp r4, 88
    ble init_register_B_p2

    mov r4, 0 // reininit counter
    add r11, r4, 90 // counter offset
init_register_S:
    ldr r9, [r6, r11]
    str r9, [r8, r4]
    add r4,r4, 1
    add r11, r11, 1
    cmp r4, 27
    ble init_register_S

    ldr r9, [r6, 119]
    eor r9, 1
    str r9, [r8, 29]
    mov r9, 1
    str r9, [r8, 30]

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr


.global keyadd_asm
.type keyadd_asm, %function
keyadd_asm:
    //Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr

.global diffusion_asm
.type diffusion_asm, %function
diffusion_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    

    ldr r4, =t
    ldr r4, [r4]
    add r5, r4, 1
    mov r9, 90
    mul r6, r4, r9 // t
    mul r7, r5, r9 // t+1


    ldr r9, =B

    mov r10 , 0 // counter

diffusion_B:
    add r8, r10, 1
    add r8, r6, r8
    ldr r11, [r9, r8]
    add r8, r7, r10
    str r11, [r9, r8]

    add r10, r10, 1
    cmp r10, 87
    ble diffusion_B

    add r8, r7, 89
    bl NFSR2_asm
    str r0, [r9, r8]

    mov r9, 31
    mul r6, r4, r9 // t
    mul r7, r5, r9 // t+1

    ldr r9, =S

    mov r10 , 0 // counter
diffusion_S:
    add r8, r10, 1
    add r8, r6, r8
    ldr r11, [r9, r8]
    add r8, r7, r10
    str r11, [r9, r8]

    add r10, r10, 1
    cmp r10, 28
    ble diffusion_S

    add r8, r7, 30
    bl NFSR1_asm
    str r0, [r9, r8]

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr

.global NFSR1_asm
.type NFSR1_asm, %function
NFSR1_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    //Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    ldr r4, =t
    ldr r4, [r4]
    mov r5, 31
    mul r5, r4, r5 // B initial offset
    ldr r9, =S // can be reused

    ldr r3, [r9, r5]
    add r7, r5, 2
    ldr r11, [r9, r7]
    eor r3, r3, r11

    add r7, r5, 5
    ldr r11, [r9, r7]
    eor r3, r3, r11

    add r7, r5, 6
    ldr r11, [r9, r7]
    eor r3, r3, r11

    add r7, r5, 15
    ldr r11, [r9, r7]
    eor r3, r3, r11

    add r7, r5, 17
    ldr r11, [r9, r7]
    eor r3, r3, r11

    add r7, r5, 18
    ldr r11, [r9, r7]
    eor r3, r3, r11

    add r7, r5, 20
    ldr r11, [r9, r7]
    eor r3, r3, r11

    add r7, r5, 25
    ldr r11, [r9, r7]
    eor r3, r3, r11

    add r7, r5, 8
    ldr r11, [r9, r7]
    add r7, r5, 18
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 8
    ldr r11, [r9, r7]
    add r7, r5, 20
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 12
    ldr r11, [r9, r7]
    add r7, r5, 21
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 14
    ldr r11, [r9, r7]
    add r7, r5, 19
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 17
    ldr r11, [r9, r7]
    add r7, r5, 21
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 20
    ldr r11, [r9, r7]
    add r7, r5, 22
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 4
    ldr r11, [r9, r7]
    add r7, r5, 12
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 4
    ldr r11, [r9, r7]
    add r7, r5, 19
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 7
    ldr r11, [r9, r7]
    add r7, r5, 20
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 8
    ldr r11, [r9, r7]
    add r7, r5, 18
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 8
    ldr r11, [r9, r7]
    add r7, r5, 20
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 12
    ldr r11, [r9, r7]
    add r7, r5, 19
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 20
    ldr r11, [r9, r7]
    add r7, r5, 21
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 4
    ldr r11, [r9, r7]
    add r7, r5, 7
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 12
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 4
    ldr r11, [r9, r7]
    add r7, r5, 7
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 19
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 4
    ldr r11, [r9, r7]
    add r7, r5, 12
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 4
    ldr r11, [r9, r7]
    add r7, r5, 19
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 7
    ldr r11, [r9, r7]
    add r7, r5, 8
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 18
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 7
    ldr r11, [r9, r7]
    add r7, r5, 8
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 20
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 7
    ldr r11, [r9, r7]
    add r7, r5, 12
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 19
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 8
    ldr r11, [r9, r7]
    add r7, r5, 18
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 8
    ldr r11, [r9, r7]
    add r7, r5, 20
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    add r7, r5, 12
    ldr r11, [r9, r7]
    add r7, r5, 19
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r3, r3, r8

    mov r0, r3
    mov r3, 0
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr

.global NFSR2_asm
.type NFSR2_asm, %function
NFSR2_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    
    ldr r4, =t
    ldr r4, [r4]
    mov r5, 31
    mul r5, r4, r5 // B initial offset
    ldr r9, =S // can be reused
    
    ldr r12, [r9, r5]
    
    mov r5, 90
    mul r5, r4, r5 // B initial offset
    ldr r9, =B // can be reused

    ldr r11, [r9, r5]

    eor r12, r12, r11

    add r7, r5, 24
    ldr r11, [r9, r7]

    eor r12, r12, r11

    add r7, r5, 49
    ldr r11, [r9, r7]

    eor r12, r12, r11

    add r7, r5, 79
    ldr r11, [r9, r7]

    eor r12, r12, r11

    add r7, r5, 84
    ldr r11, [r9, r7]

    eor r12, r12, r11

    add r7, r5, 3
    ldr r11, [r9, r7]
    add r7, r5, 59
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 10
    ldr r11, [r9, r7]
    add r7, r5, 12
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 15
    ldr r11, [r9, r7]
    add r7, r5, 16
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 25
    ldr r11, [r9, r7]
    add r7, r5, 53
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 35
    ldr r11, [r9, r7]
    add r7, r5, 42
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 55
    ldr r11, [r9, r7]
    add r7, r5, 58
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 60
    ldr r11, [r9, r7]
    add r7, r5, 74
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 20
    ldr r11, [r9, r7]
    add r7, r5, 22
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 23
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 62
    ldr r11, [r9, r7]
    add r7, r5, 68
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 72
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 77
    ldr r11, [r9, r7]
    add r7, r5, 80
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 81
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 83
    ldr r11, [r9, r7]
    and r8, r11, r8


    eor r12, r12, r8
    mov r0, r12

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr



.global keystreamGeneration_asm
.type keystreamGeneration_asm, %function
keystreamGeneration_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    ldr r4, =keystream_size
    ldr r4, [r4]
    ldr r5, =keystream
    mov r6, 0 // counter
    mov r7, 0 //value
    ldr r8, =t
    ldr r9, [r8]
keystream_init:
    str r7, [r5, r6]
    add r6, r6, 1
    cmp r6, r4
    blt keystream_init

    mov r6, 0
    sub r4, r4, 1

keystream_gen:
    bl a_asm
    str r0, [r5, r6]
    bl diffusion_asm
    add r9, r9, 1
    str r9, [r8]
    add r6, r6, 1
    cmp r6, r4
    blt keystream_gen  

    bl a_asm
    str r0, [r5, r4]
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr


.global a_asm_Lt
.type a_asm_Lt, %function
a_asm_Lt:
    push {r4-r12, r14}
    
    ldr r4, =t
    ldr r4, [r4]
    mov r5, 90
    mul r5, r4, r5 // B initial offset

    // L[t]
    ldr r9, =B // can be reused
    //ldr r10, =L
    

    add r7, r5, 7
    ldr r11, [r9, r7]
    add r7, r5, 11
    ldr r12, [r9, r7]
    eor r12, r12, r11
    add r7, r5, 30
    ldr r11, [r9, r7]
    eor r12, r12, r11
    add r7, r5, 40
    ldr r11, [r9, r7]
    eor r12, r12, r11
    add r7, r5, 45
    ldr r11, [r9, r7]
    eor r12, r12, r11
    add r7, r5, 54
    ldr r11, [r9, r7]
    eor r12, r12, r11
    add r7, r5, 71
    ldr r11, [r9, r7]
    eor r12, r12, r11
    mov r0, r12

    pop {r4-r12, pc}
    bx lr


.global a_asm_Qt
.type a_asm_Qt, %function
a_asm_Qt:
    push {r4-r12, r14}
    
    ldr r4, =t
    ldr r4, [r4]
    mov r5, 90
    mul r5, r4, r5 // B initial offset

    ldr r9, =B // can be reused
    
    add r7, r5, 4
    ldr r11, [r9, r7]
    add r7, r5, 21
    ldr r12, [r9, r7]
    and r12, r12, r11 // B[t][4]  * B[t][21]

    add r7, r5, 9
    ldr r11, [r9, r7]
    add r7, r5, 52
    ldr r8, [r9, r7]
    and r8, r11, r8 //B[t][9] * B[t][52]

    eor r12, r12, r8 //(B[t][4]  * B[t][21])^(B[t][9] * B[t][52])

    add r7, r5, 18
    ldr r11, [r9, r7]
    add r7, r5, 37
    ldr r8, [r9, r7]
    and r8, r11, r8 //B[t][18] * B[t][37]

    eor r12, r12, r8 //(B[t][4]*B[t][21])^(B[t][9]*B[t][52])^(B[t][18]*Bt][37])

    add r7, r5, 44
    ldr r11, [r9, r7]
    add r7, r5, 76
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8 //full expression
    
    
    mov r0, r12
    pop {r4-r12, pc}
    bx lr

.global a_asm_Tt
.type a_asm_Tt, %function
a_asm_Tt:
    push {r4-r12, r14}
   
    ldr r4, =t
    ldr r4, [r4]
    mov r5, 90
    mul r5, r4, r5 // B initial offset
    
    ldr r9, =B // can be reused

    add r7, r5, 5
    ldr r12, [r9, r7]
    
    add r7, r5, 8
    ldr r11, [r9, r7]
    add r7, r5, 82
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 34
    ldr r11, [r9, r7]
    add r7, r5, 67
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 73
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 2
    ldr r11, [r9, r7]
    add r7, r5, 28
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 41
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 65
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 13
    ldr r11, [r9, r7]
    add r7 ,r5, 29
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 50
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 64
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 75
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 6
    ldr r11, [r9, r7]
    add r7 ,r5, 14
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 26
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 32
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 47
    ldr r11, [r9, r7]
    and r8, r11, r8 
    add r7, r5, 61
    ldr r11, [r9, r7]
    and r8, r11, r8 

    eor r12, r12, r8

    add r7, r5, 1
    ldr r11, [r9, r7]
    add r7 ,r5, 19
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 27
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 43
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 57
    ldr r11, [r9, r7]
    and r8, r11, r8 
    add r7, r5, 66
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 78
    ldr r11, [r9, r7]
    and r8, r11, r8 

    eor r12, r12, r8

    mov r0, r12 

    pop {r4-r12, pc}
    bx lr

.global a_asm_Ttildet
.type a_asm_Ttildet, %function
a_asm_Ttildet:
    push {r4-r12, r14}
    ldr r4, =t
    ldr r4, [r4]
    mov r5, 31
    mul r5, r4, r5 // B initial offset

    ldr r9, =S // can be reused

    add r7, r5, 23
    ldr r12, [r9, r7]
    
    add r7, r5, 3
    ldr r11, [r9, r7]
    add r7, r5, 16
    ldr r8, [r9, r7]
    and r8, r11, r8 // S[t][3]*S[t][16]

    eor r12, r12, r8 //S[t][23] ^(S[t][3]*S[t][16])

    add r7, r5, 9
    ldr r11, [r9, r7]
    add r7, r5, 13
    ldr r8, [r9, r7]
    and r8, r11, r8

    ldr r9, =B // can be reused
    mov r5, 90
    mul r5, r4, r5 // B initial offset
    add r7, r5, 48
    ldr r11, [r9, r7]
    and r8, r11, r8 // S[t][9]*S[t][13]*B[t][48]

    eor r12, r12, r8 //S[t][23]^(S[t][3]*S[t][16])^(S[t][9]*S[t][13]*B[t][48])

    mov r5, 31
    mul r5, r4, r5 // B initial offset
    ldr r9, =S // can be reused

    add r7, r5, 1
    ldr r11, [r9, r7]
    add r7, r5, 24
    ldr r8, [r9, r7]
    and r8, r11, r8
    ldr r9, =B // can be reused
    mov r5, 90
    mul r5, r4, r5 // B initial offset
    add r7, r5, 38
    ldr r11, [r9, r7]
    and r8, r11, r8
    add r7, r5, 63
    ldr r11, [r9, r7]
    and r8, r11, r8 //last bit of expression

    eor r12, r12, r8

    mov r0, r12 

    pop {r4-r12, pc}
    bx lr

.global a_asm
.type a_asm, %function
a_asm:
    //Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    ldr r4, =t
    ldr r4, [r4]
    ldr r5, =L
    ldr r6, =Q
    ldr r7, =T
    ldr r8, =Ttilde

    bl a_asm_Lt
    str r0, [r5, r4]

    bl a_asm_Qt
    str r0, [r6, r4]

    bl a_asm_Tt
    str r0, [r7, r4]

    bl a_asm_Ttildet
    str r0, [r8, r4]

    bl a_return


    pop {r4-r12, pc}
    bx lr


.global a_return
.type a_return, %function
a_return:
    push {r4-r12, r14}
    //craft return value to r0
    ldr r4, =t
    ldr r4, [r4] //??
    ldr r5, =L
    ldr r5, [r5, r4]
    ldr r6, =Q
    ldr r6, [r6, r4]
    ldr r7, =T
    ldr r7, [r7, r4]
    ldr r8, =Ttilde
    ldr r8, [r8, r4]
    eor r5, r5, r6
    eor r5, r5, r7
    eor r5, r5, r8
    mov r0, r5    

    
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, pc}
    bx lr

.global keyadd_B
.type keyadd_B, %function
keyadd_B:
    push {r4-r12, r14}
    ldr r4, =B
    mov.w r6, 129
    mov.w r7, 90
    mul.w r7, r7, r6
    add.w r7, r7, r0
    bl keyadd_B_eor
    str r0, [r4, r7]
    pop {r4-r12, pc}
    bx lr

.global keyadd_B_eor
.type keyadd_B_eor, %function
keyadd_B_eor:
    push {r4-r12, r14}
    ldr r4, =B
    ldr r5, =K
    mov r6, 128
    mov r7, 90
    mul r7, r7, r6
    add r7, r0
    ldr r8, [r4, r7] // B[128][i]
    mov r7, r0
    ldr r9, [r5, r7]
    eor r0, r8, r9
    pop {r4-r12, pc}
    bx lr

.global keyadd_S
.type keyadd_S, %function
keyadd_S:
    push {r4-r12, r14}
    ldr r4, =S
    mov.w r6, 129
    mov.w r7, 31
    mul.w r7, r7, r6
    add.w r7, r7, r0
    bl keyadd_S_eor
    str r0, [r4, r7]
    pop {r4-r12, pc}
    bx lr


.global keyadd_S_full
.type keyadd_S_full, %function
keyadd_S_full:
    push {r0, r4-r12, r14}
    mov r0, 0
s_full:
    bl keyadd_S
    add r0, r0, 1
    cmp r0, 29
    ble s_full


    pop {r0, r4-r12, pc}
    bx lr

.global keyadd_S_eor
.type keyadd_S_eor, %function
keyadd_S_eor:
    push {r4-r12, r14}
    ldr r4, =S
    ldr r5, =K
    mov.w r6, 128
    mov.w r7, 31
    mul.w r7, r7, r6
    add.w r7, r0
    ldr r8, [r4, r7] // S[128][i]
    mov.w r7, 90
    add.w r7, r0
    ldr r9, [r5, r7]
    eor r0, r8, r9
    pop {r4-r12, pc}
    bx lr

.global keyadd_S_1
.type keyadd_S_1, %function
keyadd_S_1:
    push {r4-r12, r14}
    ldr r4, =S
    mov r5, 31
    mov r7, 1
    mov r8, 129
    mul r8, r8, r5
    add r8, r8, 30 
    str r7, [r4, r8]
    pop {r4-r12, pc}
    bx lr


.global _construct_z
.type _construct_z, %function
_construct_z:
    push {r4-r12, r14}

    ldr r4, =z
    ldr r5, =keystream_size
    ldr r5, [r5]
    mov r6, 0
    mov r7, 0
loopz:
    str r6, [r4, r7]
    add r7, r7, 1
    cmp r7, r5
    blt loopz
    pop {r4-r12, pc}
    bx lr

.global _construct_L
.type _construct_L, %function
_construct_L:
    MOV.W   R2, #0x100
    MOVS    R1, #0
    LDR     R0, =_edata
    B.W     memset

.global mixing_p1
.type mixing_p1, %function
mixing_p1:
    push {r4-r12, r14}
    ldr r4, =z
    ldr r5, =t
    ldr r5, [r5]
    bl a_asm
    str r0, [r4, r5]
    pop {r4-r12, pc}
    bx lr

