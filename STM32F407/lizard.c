#include "stm32wrapper.h"
#include <stdio.h>
#include <stdint.h>

extern uint32_t power_5_13(void);
extern uint32_t power(uint32_t x, uint32_t e);

int main(void)
{
    clock_setup();
    gpio_setup();
    usart_setup(115200);

    uint32_t x, y;
    int i, j, k;
    int failures = 0;
    char str[100];

    x = power_5_13();

    sprintf(str, "Output: %010lu ", x);
    send_USART_str(str);

    if (x == 1220703125) {
        send_USART_str(" .. and that's correct!");
    }
    else {
        send_USART_str(" .. and that's incorrect!");
    }

    send_USART_str("Testing pow(i, j) for i, j in [0-9]..");
    for (i = 0; i < 10; i++) {
        for (j = 0; j < 10; j++) {
            x = power(i, j);
            y = 1;
            for (k = 0; k < j; k++) {
                y *= i;
            }
            if (x != y) {
                failures += 1;
                if (failures <= 10) {
                    sprintf(str, "  Failed for pow(%u, %u); got %lu instead of %lu", i, j, x, y);
                    send_USART_str(str);
                }
            }
        }
    }
    if (failures == 0) {
        send_USART_str(" .. all tests passed!");
    }
    if (failures > 10) {
        sprintf(str, "  [.. and for %u more test cases]", failures - 10);
        send_USART_str(str);
    }
    send_USART_str("Done!");

    while(1);
    return 0;
}
