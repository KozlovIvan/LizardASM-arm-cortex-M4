.syntax unified
.cpu cortex-m4

.global lizard
.type lizard, %function
lizard:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global loadkey
.type loadkey, %function
loadkey:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global loadIV
.type loadIV, %function
loadIV:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global initRegisters
.type initRegisters, %function
initRegisters:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global mixing
.type mixing, %function
mixing:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global keyadd
.type keyadd, %function
keyadd:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global diffusion
.type diffusion, %function
diffusion:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global NFSR1
.type NFSR1, %function
NFSR1:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global NFSR2
.type NFSR2, %function
NFSR2:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global construct
.type construct, %function
construct:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global initialization
.type initialization, %function
initialization:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global keystreamGeneration
.type keystreamGeneration, %function
keystreamGeneration:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global keystreamGenerationSpecification
.type keystreamGenerationSpecification, %function
keystreamGenerationSpecification:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global a
.type a, %function
a:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr

.global a
.type a, %function
a:
    # Remember the ABI: we must not destroy the values in r4 to r12.
    # Arguments are placed in r0 and r1, the return value should go in r0.
    # To be certain, we just push all of them onto the stack.
    push {r4-r12}
    #TODO
    # Finally, we restore the callee-saved register values and branch back.
    pop {r4-r12}
    bx lr
    