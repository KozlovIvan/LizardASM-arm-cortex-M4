.syntax unified
.cpu cortex-m4

.align 2
.global some_function
.type some_function, %function
some_function:

    bx lr
