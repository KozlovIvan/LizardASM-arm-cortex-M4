.syntax unified
.cpu cortex-m4

.extern t, K, IV, z, L, Q, T, Ttilde, B, S, a257, keystream, keystream_size


// ╦  ╦╔═╗╔═╗╦═╗╔╦╗
// ║  ║╔═╝╠═╣╠╦╝ ║║
// ╩═╝╩╚═╝╩ ╩╩╚══╩╝
// by Ivan Kozlov, 2018
// https://github.com/KozlovIvan/LizardASM-arm-cortex-M4

.global lizard_asm
.type lizard_asm, %function
lizard_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
    bx lr

.global _construct_asm
.type _construct_asm, %function
_construct_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    mov r4, 0       // counter
    mov r5, 0       // zero val
    ldr r6, =z      // load extern symbol z
    ldr r7, =keystream_size

construct_z:
    str r5, [r6, r4]
    add r4, r4, 1       // increment counter
    cmp r4, r7
    blt construct_z

    ldr r6, =L          // load extern symbol L
    ldr r8, =Q          // load extern symbol Q
    ldr r9, =T          // load extern symbol T
    ldr r10, =Ttilde    // load extern symbol Ttilde
    mov r4, 0           // reset counter

construct_LQTTtilde:
    str r5, [r6, r4]
    str r5, [r8, r4]
    str r5, [r9, r4]
    str r5, [r10, r4]
    bl _initialization_asm
    add r4, r4, 1       // increment counter
    cmp r4, r7
    blt construct_LQTTtilde

    cmp r7, 0
    mov r0, r7
    bgt keystreamGeneration_asm

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
    bx lr

.global _initialization_asm
.type _initialization_asm, %function
_initialization_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    bl loadkey_asm
    bl loadIV_asm
    bl initRegisters_asm
    ldr r5, =t
    mov r4, 0
    str r4, [r5]

phase_2:
    bl mixing_asm
    add r4, r4, 1
    str r4, [r5]
    cmp r4, 127
    ble phase_2


    mov r4, 129 // counter
    ldr r5, =t
    str r4, [r5]

phase_4:
    bl diffusion_asm
    add r4, r4, 1
    str r4, [r5]
    cmp r4, 256
    ble phase_4

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
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
    cmp r4, 119         // compare to 119
    ble loadkey_loop    // if less or equal jump to the begining of the loop
    
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
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
    cmp r4, 60          // compare to 62
    ble loadiv_loop     // if less or equal jump to the begining of the loop

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
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
    cmp r4, 63
    blt init_register_B_p1

    mov r4, 64 //update counter
init_register_B_p2:
    ldr r9, [r6, r4]
    str r9, [r5, r4]
    add r4, r4, 1
    cmp r4, 89
    blt init_register_B_p2

    mov r4, 0 // reininit counter
    add r11, r4, 90 // counter offset
init_register_S:
    ldr r9, [r6, r11]
    str r9, [r8, r4]
    add r4,r4, 1
    add r11, r11, 1
    cmp r4, 28
    blt init_register_S

    ldr r9, [r6, 119]
    eor r9, 1
    str r9, [r8, 29]
    mov r9, 1
    str r9, [r8, 30]

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
    bx lr

.global mixing_asm
.type mixing_asm, %function
mixing_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    bl a_asm
    ldr r4, =K
    ldr r4, [r4]
    ldr r5, =z
    str r0, [r5, r4] //z[t] = a()
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
    bx lr

.global keyadd_asm
.type keyadd_asm, %function
keyadd_asm:
    //Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
    bx lr

.global diffusion_asm
.type diffusion_asm, %function
diffusion_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
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

    ldr r12, [r9, r5]
    add r7, r5, 2
    ldr r11, [r9, r7]
    eor r12, r12, r11

    add r7, r5, 5
    ldr r11, [r9, r7]
    eor r12, r12, r11

    add r7, r5, 6
    ldr r11, [r9, r7]
    eor r12, r12, r11

    add r7, r5, 15
    ldr r11, [r9, r7]
    eor r12, r12, r11

    add r7, r5, 17
    ldr r11, [r9, r7]
    eor r12, r12, r11

    add r7, r5, 18
    ldr r11, [r9, r7]
    eor r12, r12, r11

    add r7, r5, 20
    ldr r11, [r9, r7]
    eor r12, r12, r11

    add r7, r5, 25
    ldr r11, [r9, r7]
    eor r12, r12, r11

    add r7, r5, 8
    ldr r11, [r9, r7]
    add r7, r5, 18
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 8
    ldr r11, [r9, r7]
    add r7, r5, 20
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 12
    ldr r11, [r9, r7]
    add r7, r5, 21
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 14
    ldr r11, [r9, r7]
    add r7, r5, 19
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 17
    ldr r11, [r9, r7]
    add r7, r5, 21
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 20
    ldr r11, [r9, r7]
    add r7, r5, 22
    ldr r8, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 4
    ldr r11, [r9, r7]
    add r7, r5, 12
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 4
    ldr r11, [r9, r7]
    add r7, r5, 19
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 7
    ldr r11, [r9, r7]
    add r7, r5, 20
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 21
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 8
    ldr r11, [r9, r7]
    add r7, r5, 18
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 8
    ldr r11, [r9, r7]
    add r7, r5, 20
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 12
    ldr r11, [r9, r7]
    add r7, r5, 19
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

    add r7, r5, 20
    ldr r11, [r9, r7]
    add r7, r5, 21
    ldr r8, [r9, r7]
    and r8, r11, r8
    add r7, r5, 22
    ldr r11, [r9, r7]
    and r8, r11, r8

    eor r12, r12, r8

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

    eor r12, r12, r8

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

    eor r12, r12, r8

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

    eor r12, r12, r8

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

    eor r12, r12, r8

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

    eor r12, r12, r8

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

    eor r12, r12, r8

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

    eor r12, r12, r8

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

    eor r12, r12, r8

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

    eor r12, r12, r8

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

    eor r12, r12, r8

    mov r0, r12

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
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
    pop {r4-r12, r14}
    bx lr

.global construct_asm
.type construct_asm, %function
construct_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
    bx lr

.global keystreamGeneration_asm
.type keystreamGeneration_asm, %function
keystreamGeneration_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12, r14}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12, r14}
    bx lr

.global keystreamGenerationSpecification_asm
.type keystreamGenerationSpecification_asm, %function
keystreamGenerationSpecification_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    //Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
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

    pop {r4-r12, r14}
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
    pop {r4-r12, r14}
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

    pop {r4-r12, r14}
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

    pop {r4-r12, r14}
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


    pop {r4-r12, r14}
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
    pop {r4-r12, r14}
    bx lr
