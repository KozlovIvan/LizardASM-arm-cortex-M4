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
    bl a_asm
    ldr r4, =K
    ldr r4, [r4]
    ldr r5, =z
    str r0, [r5, r4] //z[t] = a()
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

.global a_asm_Lt
.type a_asm_Lt, %function
a_asm_Lt:
    push {r4-r12}
    
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

    pop {r4-r12}
    bx lr


.global a_asm_Qt
.type a_asm_Qt, %function
a_asm_Qt:
    push {r4-r12}
    
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
    pop {r4-r12}
    bx lr

.global a_asm
.type a_asm, %function
a_asm:
    //Remember the ABI: we must not destroy the values in r4 to r12.
    // Arguments are placed in r0 and r1, the return value should go in r0.
    // To be certain, we just push all of them onto the stack.
    push {r4-r12}
    

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
    pop {r4-r12}
    bx lr


.global a_return
.type a_return, %function
a_return:
    push {r4-r12}
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
    pop {r4-r12}
    bx lr
