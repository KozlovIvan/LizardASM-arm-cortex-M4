#include "stm32wrapper.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>


// STM32F407  stack  is from 0x20020000  to 0x20000000 , growing  down
//#define  MIN_STACK_ADDR 0x20000000
//#define  MAX_STACK_ADDR 0x20020000
#define  MAX_SIZE 0x15000

volatile  unsigned  char *p;
unsigned  int c;
const  uint8_t  canary = 0x42;

#define  FILL_STACK()          \
p = &a;                         \
while (p > &a - MAX_SIZE)       \
    *(p--) = canary;

#define  CHECK_STACK()          \
c = MAX_SIZE;                    \
p = &a - MAX_SIZE + 1;           \
while  (*p ==  canary  && p < &a) {  \
    p++;     \
    c--;     \
}        \
char  outs [120];      \
if (c >= MAX_SIZE) {   \
    send_USART_str("Stack  usage  exceeds  MAX_SIZE.");  \
} else {  \
    snprintf(outs , 120,   "This  took %u stack  bytes.", c); \
    send_USART_str(outs);  \
} 




#define KEYSTREAM_SIZE 128



void mixing(void);
void _construct(uint8_t*, uint8_t*);
char* binArray2hex(uint8_t*); //not part of stream
void hex2binArray(char* , uint8_t*); //not part of the stream
uint8_t hex2int(char); // not part of the stream
void test(void); //not part of the stream
void test1(void); //not part of the stream
void test2(void); //not part of the stream
void test3(void); // not part of the stream
void test4(void); //not part of the stream


extern uint8_t NFSR1_asm(void);
extern uint8_t NFSR2_asm(void);
extern void keystreamGeneration_asm(int);
extern uint8_t* keystreamGenerationSpecification_asm(int);
extern uint8_t a_asm(void);
extern void _initialization_phase1(uint8_t*, uint8_t*);
extern void _initialization_phase2(void);
extern void _initialization_phase3_B(void);
extern void _initialization_phase3_S(void);
extern void _initialization_phase4(void);
extern void keyadd_S_1(void);
extern void _construct_z(void);
extern void mixing_p1(void);

//for asm
uint32_t keystream_size = KEYSTREAM_SIZE;
//for asm

uint8_t keystream[KEYSTREAM_SIZE];
uint8_t a257 = 0;
int t = 0;
uint8_t K[120];
uint8_t IV[64];
uint8_t z[128];
uint8_t L[KEYSTREAM_SIZE+128];
uint8_t Q[KEYSTREAM_SIZE+128];
uint8_t T[KEYSTREAM_SIZE+128];
uint8_t Ttilde[KEYSTREAM_SIZE+259];
uint8_t B[KEYSTREAM_SIZE+259][90];
uint8_t S[KEYSTREAM_SIZE+259][31];



void _construct(uint8_t  *key, uint8_t *iv){
    volatile  unsigned  char a;
    //FILL_STACK();
    _construct_z();
    for(int i = 0; i <KEYSTREAM_SIZE+128; ++i){
        L[i] = 0;
        Q[i] = 0;
        T[i] = 0;
        Ttilde[i] = 0;
    }
    _initialization_phase1(key, iv);
    //Phase 2
    for(;t<=127; ++t){
        mixing();
    }
    _initialization_phase3_B();
    _initialization_phase3_S();
    keyadd_S_1();
    _initialization_phase4();
    keystreamGeneration_asm(KEYSTREAM_SIZE);
    CHECK_STACK();
}



void mixing(){

    z[t] = a_asm();
    mixing_p1();
    for(int i = 0; i<=88; ++i) {
        B[t + 1][i] = B[t][i + 1];
    }

    B[t+1][89] = z[t] ^ NFSR2_asm();

    for(int i = 0; i <= 29; ++i){
        S[t+1][i] = S[t][i+1];
    }
    S[t+1][30] = z[t] ^ NFSR1_asm();
}


char* binArray2hex(uint8_t * bin) {
    char * str = calloc(KEYSTREAM_SIZE/4, sizeof(char));
    unsigned int val = 0;
    for (uint8_t i = 0; i < KEYSTREAM_SIZE/4; i++) {
        val = bin[i*4]*8 + bin[i*4+1]*4 + bin[i*4+2]*2 + bin[i*4+3]*1;
        sprintf(str+i, "%x", val);
    }
    return str;
}

uint8_t hex2int(char ch) {
    if (ch >= '0' && ch <= '9')
        return (uint8_t) (ch - '0');
    if (ch >= 'A' && ch <= 'F')
        return (uint8_t) (ch - 'A' + 10);
    if (ch >= 'a' && ch <= 'f')
        return (uint8_t) (ch - 'a' + 10);
    return (uint8_t) 0;
}

void hex2binArray(char* hex, uint8_t * bin) {
    for (uint8_t i = 0; i < strlen(hex); ++i){
        uint8_t val = hex2int(hex[i]);

        bin[i*4 + 3] = (uint8_t) (val & 1);
        bin[i*4 + 2] = (uint8_t) ((val >> 1) & 1);
        bin[i*4 + 1] = (uint8_t) ((val >> 2) & 1);
        bin[i*4 + 0] = (uint8_t) ((val >> 3) & 1);

    }
}
void test1(){
    char str[100];
    sprintf(str,"Test 1\n");
    send_USART_str(str);
    char *Kstr = "0000000000000000ffffffffffffff";
    char *IVstr = "ffffffffffffffff";
    uint8_t Kbin[122];
    char* test= "4d190941816f942358f0d164f4eceb09";
    hex2binArray(Kstr, Kbin);
    uint8_t IVbin[66];
    hex2binArray(IVstr, IVbin);
    _construct(Kbin, IVbin);
    for(int i = 0; i< 120; i++){
        sprintf(str+i, "%x",K[i]);
    }
    send_USART_str(str);
    send_USART_str("\n");
    char* result = binArray2hex(keystream);
    sprintf(str,"Generated keystream: %s\n", result);
    send_USART_str(str);
    free(result);
    sprintf(str,"Correct keystream:   %s\n", test);
    send_USART_str(str);
    send_USART_str("\n\n");
    t=0;
}

void test2(){
    char str[100];
    sprintf(str,"Test 2\n");
    send_USART_str(str);
    char *Kstr = "7893257383493a0b0f030939409205";
    char *IVstr = "6969696969696969";
    uint8_t Kbin[122];
    char* test= "50161073d0e2cb919f09707b98ceea99";
    hex2binArray(Kstr, Kbin);
    uint8_t IVbin[66];
    hex2binArray(IVstr, IVbin);

    _construct(Kbin, IVbin);
    for(int i = 0; i< 120; i++){
        sprintf(str+i, "%x",K[i]);
    }
    send_USART_str(str);
    send_USART_str("\n");
    char* result = binArray2hex(keystream);
    sprintf(str,"Generated keystream: %s\n", result);
    send_USART_str(str);
    free(result);
    sprintf(str,"Correct keystream:   %s\n", test);
    send_USART_str(str);
    send_USART_str("\n\n");
    t=0;
}

void test3(){
    char str[100];
    sprintf(str,"Test 3\n");
    send_USART_str(str);
    char *Kstr = "000000000000000000000000000000";
    char *IVstr = "0000000000000000";
    uint8_t Kbin[122];
    char* test= "b6304ca4ca276b3355ec2e10968e84b3";
    hex2binArray(Kstr, Kbin);
    uint8_t IVbin[66];
    hex2binArray(IVstr, IVbin);
    _construct(Kbin, IVbin);
    for(int i = 0; i< 120; i++){
        sprintf(str+i, "%x",K[i]);
    }
    send_USART_str(str);
    send_USART_str("\n");
    char* result = binArray2hex(keystream);
    sprintf(str,"Generated keystream: %s\n", result);
    send_USART_str(str);
    free(result);
    sprintf(str,"Correct keystream:   %s\n", test);
    send_USART_str(str);
    send_USART_str("\n\n");
    t=0;
}

void test4(){
    char str[150];
    sprintf(str,"Test 4\n");
    send_USART_str(str);
    char *Kstr = "0123456789abcdef0123456789abcd";
    char *IVstr = "abcdef0123456789";
    uint8_t Kbin[122];
    char* test= "983311a97831586548209dafbf26fc93";
    hex2binArray(Kstr, Kbin);
    uint8_t IVbin[66];
    hex2binArray(IVstr, IVbin);
    _construct(Kbin, IVbin);
    for(int i = 0; i< 120; i++){
        sprintf(str+i, "%x",K[i]);
    }
    send_USART_str(str);
    send_USART_str("\n");
    char* result = binArray2hex(keystream);
    sprintf(str,"Generated keystream: %s\n", result);
    send_USART_str(str);
    free(result);
    sprintf(str,"Correct keystream:   %s\n", test);
    send_USART_str(str);
    send_USART_str("\n");
    t=0;
}



int main(void)
{
    clock_setup();
    gpio_setup();
    usart_setup(115200);
    char str[150];
    send_USART_str("\n\n\n\n");
    sprintf(str, "╦  ╦╔═╗╔═╗╦═╗╔╦╗\n║  ║╔═╝╠═╣╠╦╝ ║║\n╩═╝╩╚═╝╩ ╩╩╚══╩╝");
    send_USART_str(str);
    sprintf(str, "by Ivan Kozlov, 2018");
    send_USART_str(str);
    sprintf(str, "https://github.com/KozlovIvan/LizardASM-arm-cortex-M4\n");
    send_USART_str(str);
    send_USART_str("\n");
    test1();
    test2();
    test3();
    test4();

    send_USART_str("Done!\n─────────────────────────────────────────────────────────");

    while(1);
    return 0;
}
