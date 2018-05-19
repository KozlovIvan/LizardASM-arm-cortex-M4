#include "stm32wrapper.h"
#include <stdio.h>

extern void some_function(void);

int main(void)
{
    clock_setup();
    gpio_setup();
    usart_setup(115200);
    flash_setup();

    char buffer[32];

    unsigned int oldcount = DWT_CYCCNT;
    some_function();
    unsigned int cyclecount = DWT_CYCCNT - oldcount;

    snprintf(buffer, 32, "This took %u cycles.", cyclecount);
    send_USART_str(buffer);

    while(1);
    return 0;
}
