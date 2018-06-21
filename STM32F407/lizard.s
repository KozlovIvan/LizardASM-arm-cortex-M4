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
    push {r4-r12}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global _construct_asm
.type _construct_asm, %function
_construct_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
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
    pop {r4-r12}
    bx lr

.global _initialization_asm
.type _initialization_asm, %function
_initialization_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
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
    pop {r4-r12}
    bx lr

.global loadkey_asm
.type loadkey_asm, %function
loadkey_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}

    mov r4, 0       // counter
    ldr r5, =K      // load extern symbol K (key array)
loadkey_loop:    
    ldr r6, [r0, r4]
    str r6, [r5, r4]
    add r4, r4, 1       // increment counter
    cmp r4, 119         // compare to 119
    ble loadkey_loop    // if less or equal jump to the begining of the loop
    
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global loadIV_asm
.type loadIV_asm, %function
loadIV_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}

    mov r4, 0      // initialize loop counter 
    ldr r5, =IV    // load address of first element of IV array
loadiv_loop:
    ldr r6, [r0, r4]
    str r6, [r5, r4]
    add r4, r4, 1       // increment counter
    cmp r4, 60          // compare to 62
    ble loadiv_loop     // if less or equal jump to the begining of the loop

    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global initRegisters_asm
.type initRegisters_asm, %function
initRegisters_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
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
    pop {r4-r12}
    bx lr

.global mixing_asm
.type mixing_asm, %function
mixing_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global keyadd_asm
.type keyadd_asm, %function
keyadd_asm:
    //Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global diffusion_asm
.type diffusion_asm, %function
diffusion_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global NFSR1_asm
.type NFSR1_asm, %function
NFSR1_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    //Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global NFSR2_asm
.type NFSR2_asm, %function
NFSR2_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global construct_asm
.type construct_asm, %function
construct_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global keystreamGeneration_asm
.type keystreamGeneration_asm, %function
keystreamGeneration_asm:
    // Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
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

.global a_asm
.type a_asm, %function
a_asm:
    //Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
    
    ldr r4, =t              // load extern symbol t
    ldr r8, =keystream_size // load extern symbol keystream_size
    add r9, r8, 89          // offset for B
    mul r9, r9, r4          // total offset for B
    add r10, r8, 30         // offset for S
    mul r10, r10, r4        // total offset for S
    
    ldr r5, =L              // load extern symbol L NOTE it will switch to Q, T and last to Ttilde
    ldr r6, =B              // load extern symbol B
    ldr r7, =S              // load extern symbol S
    ldr r8, [r6, r9]        // get t-th array from multidimensional array
    ldr r9, [r7, r10]
    // L[t]
    ldr r10, [r8, 7]
    ldr r11, [r8, 11]
    eor r11, r11, r10
    ldr r10, [r8, 30]
    eor r11, r11, r10
    ldr r10, [r8, 40]
    eor r11, r11, r10
    ldr r10, [r8, 45]
    eor r11, r11, r10
    ldr r10, [r8, 54]
    eor r11, r11, r10
    ldr r8, [r8, 71]
    eor r11, r11, r10
    str r11, [r5, r4]
    //end of L[t]

    //Q[t]
    ldr r5, =Q          //load extern symbol Q
    ldr r8, [r6, r9]    //B[t] might be redundant
    ldr r10, [r8, 4]
    ldr r11, [r8, 21]
    and r11, r11, r10
    ldr r10, [r8, 9]
    eor r11, r11, r10
    ldr r10, [r8, 52]
    and r11, r11, r10
    ldr r10, [r8, 18]
    eor r11, r11, r10
    ldr r10, [r8, 37]
    and r11, r11, r10
    ldr r10, [r8, 44]
    eor r11, r11, r10
    ldr r10, [r8, 76]
    and r11, r11, r10
    str r11, [r5, r4]
    //end of Q[t]

    //T[t]
    ldr r5, =T              // load extern symbol T
    ldr r8, [r6, r9]        // might be redundant
    ldr r10, [r8, 5]
    ldr r11, [r8, 8]
    eor r11, r11, r10
    ldr r10, [r8, 82]
    and r11, r11, r10
    ldr r10, [r8, 34]
    eor r11, r11, r10
    ldr r10, [r8, 67]
    and r11, r11, r10
    ldr r10, [r8, 73]
    and r11, r11, r10
    ldr r10, [r8, 2]
    eor r11, r11, r10
    ldr r10, [r8, 28]
    and r11, r11, r10
    ldr r10, [r8, 41]
    and r11, r11, r10
    ldr r10, [r8, 65]
    and r11, r11, r10
    ldr r10, [r8, 13]
    eor r11, r11, r10
    ldr r10, [r8, 29]
    and r11, r11, r10
    ldr r10, [r8, 50]
    and r11, r11, r10
    ldr r10, [r8, 64]
    and r11, r11, r10
    ldr r10, [r8, 75]
    and r11, r11, r10
    ldr r10, [r8, 6]
    eor r11, r11, r10
    ldr r10, [r8, 14]
    and r11, r11, r10
    ldr r10, [r8, 26]
    and r11, r11, r10
    ldr r10, [r8, 32]
    and r11, r11, r10
    ldr r10, [r8, 47]
    and r11, r11, r10
    ldr r10, [r8, 61]
    and r11, r11, r10
    ldr r10, [r8, 1]
    eor r11, r11, r10
    ldr r10, [r8, 19]
    and r11, r11, r10
    ldr r10, [r8, 27]
    and r11, r11, r10
    ldr r10, [r8, 43]
    and r11, r11, r10
    ldr r10, [r8, 57]
    and r11, r11, r10
    ldr r10, [r8, 66]
    and r11, r11, r10
    ldr r10, [r8, 78]
    and r11, r11, r10
    str r11, [r5, r4]
    //end of T[t]

    //Ttilde
    ldr r5, =Ttilde         // load extern symbol Ttilde
    ldr r8, [r6, r9]        // B[t] might be redundant
    ldr r9, [r7, r10]       // S[t] might be redundant
    ldr r10, [r9, 23]
    ldr r11, [r9, 3]
    eor r11, r11, r10
    ldr r10, [r9, 16]
    and r11, r11, r10
    ldr r10, [r9, 9]
    eor r11, r11, r10
    ldr r10, [r9, 13]
    and r11, r11, r10
    ldr r10, [r8, 48]
    and r11, r11, r10
    ldr r10, [r9, 1]
    eor r11, r11, r10
    ldr r10, [r9, 24]
    and r11, r11, r10
    ldr r10, [r8, 38]
    and r11, r11, r10
    ldr r10, [r8, 63]
    and r11, r11, r10
    str r11, [r5, r4]
    //end of Ttilde[t]
    //craft return value to r0
    //TODO
    // Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr
