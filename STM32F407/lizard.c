#include "stm32wrapper.h"
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#define KEYSTREAM_SIZE 128
#define LENGTH_TEST 128


uint8_t K[120];
uint8_t IV[64];
uint8_t z[KEYSTREAM_SIZE];
uint8_t L[KEYSTREAM_SIZE+128];
uint8_t Q[KEYSTREAM_SIZE+128];
uint8_t T[KEYSTREAM_SIZE+128];
uint8_t Ttilde[KEYSTREAM_SIZE+128];
uint8_t B[KEYSTREAM_SIZE+258][90];
uint8_t S[KEYSTREAM_SIZE+258][31];
uint8_t a257 = 0;
int t = 0;
uint8_t keystream[KEYSTREAM_SIZE];

void loadkey(uint8_t*);
void loadIV(uint8_t*);
void initRegisters(void);
void mixing(void);
void keyadd(void);
void diffusion(void);
uint8_t NFSR1(void);
uint8_t NFSR2(void);
void _construct(uint8_t*, uint8_t*, int );
void _initialization(uint8_t*, uint8_t*);
void keysteamGeneration(int);
uint8_t* keystreamGenerationSpecification(int);
uint8_t a(void);
char* binArray2hex(uint8_t*);
void hex2binArray(char* , uint8_t*);
uint8_t hex2int(char);
uint8_t* getKeystream(void);
void test(void);
void test1(void);
void test2(void);
void test3(void);

extern void lizard_asm(void);
//extern uint32_t power_5_13(void);
//extern uint32_t power(uint32_t x, uint32_t e);
extern void _construct_asm(uint8_t*, uint8_t*, int);
extern void _initialization_asm(uint8_t*, uint8_t*);
extern void loadkey_asm(uint8_t*);
extern void loadIV_asm(uint8_t*);
extern void initRegister_asm(void);
extern void mixing_asm(void);
extern void keyadd_asm(void);
extern void diffusion_asm(void);
extern uint8_t NFSR1_asm(void);
extern uint8_t NFSR2_asm(void);
extern void keystreamGeneration_asm(int);
extern uint8_t* keystreamGenerationSpecification_asm(int);
extern uint8_t a_asm(void);

void _construct(uint8_t  *key, uint8_t *iv, int length){
    for (int i =0;i<128; ++i){
        z[i]=0;
    }
    for(int i = 0; i < 256; ++i){
        L[i] = 0;
        Q[i] = 0;
        T[i] = 0;
        Ttilde[i] = 0;
        _initialization(key, iv);
    }
    if(length > 0){
        keysteamGeneration(length);
    }
}

void _initialization(uint8_t *key, uint8_t *iv){

    //Phase 1
    loadkey(key);
    loadIV(iv);
    initRegisters();

    //Phase 2
    for(;t<=127; ++t){
        mixing();
    }

    //Phase 3
    keyadd();

    //Phase 4
    t=129;
    for(; t<=256; ++t){
        diffusion();
    }

}

void loadkey(uint8_t *key){

    for (int i = 0; i <= 119; ++i){
        K[i] = key[i];
    }
}

void loadIV(uint8_t *iv){
    for (int i = 0; i <= 63; ++i){
        IV[i] = iv[i];
    }
}

void initRegisters(){

    for(int i = 0; i <=63; ++i){
       B[0][i] = K[i]^IV[i];
    }

    for(int i = 64; i<=89; ++i){
        B[0][i] = K[i];
    }

    for(int i = 0; i <=28; ++i){
       S[0][i] = K[i+90];
    }

   S[0][29] = K[119] ^ (uint8_t )1;
   S[0][30] = 1;
}

void mixing(){

    z[t] = a();
    for(int i = 0; i<=88; ++i) {
        B[t + 1][i] = B[t][i + 1];
    }

    B[t+1][89] = z[t] ^ NFSR2();

    for(int i = 0; i <= 29; ++i){
        S[t+1][i] = S[t][i+1];
    }
    S[t+1][30] = z[t] ^ NFSR1();
}

uint8_t a(){

    L[t] = B[t][7]  ^ B[t][11] ^ \
             B[t][30] ^ B[t][40] ^ \
             B[t][45] ^ B[t][54] ^ \
             B[t][71];

    Q[t] = B[t][4]  * B[t][21] ^ \
           B[t][9]  * B[t][52] ^ \
           B[t][18] * B[t][37] ^ \
           B[t][44] * B[t][76];

    T[t] = B[t][5]  ^ B[t][8]  * \
           B[t][82] ^ B[t][34] * \
           B[t][67] * B[t][73] ^ \
           B[t][2]  * B[t][28] * \
           B[t][41] * B[t][65] ^ \
           B[t][13] * B[t][29] * \
           B[t][50] * B[t][64] * \
           B[t][75] ^ B[t][6]  * \
           B[t][14] * B[t][26] * \
           B[t][32] * B[t][47] * \
           B[t][61] ^ B[t][1]  * \
           B[t][19] * B[t][27] * \
           B[t][43] * B[t][57] * \
           B[t][66] * B[t][78];

    Ttilde[t] = S[t][23] ^ S[t][3]  * \
                S[t][16] ^ S[t][9]  * \
                S[t][13] * B[t][48] ^ \
                S[t][1]  * S[t][24] * \
                B[t][38] * B[t][63];

        return L[t] ^ Q[t] ^ T[t] ^ Ttilde[t];
}

uint8_t NFSR2(){

    return \
    S[t][0]  ^ B[t][0]  ^ \
    B[t][24] ^ B[t][49] ^ \
    B[t][79] ^ B[t][84] ^ \
    B[t][3]  * B[t][59] ^ \
    B[t][10] * B[t][12] ^ \
    B[t][15] * B[t][16] ^ \
    B[t][25] * B[t][53] ^ \
    B[t][35] * B[t][42] ^ \
    B[t][55] * B[t][58] ^ \
    B[t][60] * B[t][74] ^ \
    B[t][20] * B[t][22] * \
    B[t][23] ^ B[t][62] * \
    B[t][68] * B[t][72] ^ \
    B[t][77] * B[t][80] * \
    B[t][81] * B[t][83];
}

uint8_t NFSR1(){

    return \
    S[t][0]  ^ S[t][2]  ^ \
    S[t][5]  ^ S[t][6]  ^ \
    S[t][15] ^ S[t][17] ^ \
    S[t][18] ^ S[t][20] ^ \
    S[t][25] ^ S[t][8]  * \
    S[t][18] ^ S[t][8]  * \
    S[t][20] ^ S[t][12] * \
    S[t][21] ^ S[t][14] * \
    S[t][19] ^ S[t][17] * \
    S[t][21] ^ S[t][20] * \
    S[t][22] ^ S[t][4]  * \
    S[t][12] * S[t][22] ^ \
    S[t][4]  * S[t][19] * \
    S[t][22] ^ S[t][7]  * \
    S[t][20] * S[t][21] ^ \
    S[t][8]  * S[t][18] * \
    S[t][22] ^ S[t][8]  * \
    S[t][20] * S[t][22] ^ \
    S[t][12] * S[t][19] * \
    S[t][22] ^ S[t][20] * \
    S[t][21] * S[t][22] ^ \
    S[t][4]  * S[t][7]  * \
    S[t][12] * S[t][21] ^ \
    S[t][4]  * S[t][7]  * \
    S[t][19] * S[t][21] ^ \
    S[t][4]  * S[t][12] * \
    S[t][21] * S[t][22] ^ \
    S[t][4]  * S[t][19] * \
    S[t][21] * S[t][22] ^ \
    S[t][7]  * S[t][8]  * \
    S[t][18] * S[t][21] ^ \
    S[t][7]  * S[t][8]  * \
    S[t][20] * S[t][21] ^ \
    S[t][7]  * S[t][12] * \
    S[t][19] * S[t][21] ^ \
    S[t][8]  * S[t][18] * \
    S[t][21] * S[t][22] ^ \
    S[t][8]  * S[t][20] * \
    S[t][21] * S[t][22] ^ \
    S[t][12] * S[t][19] * \
    S[t][21] * S[t][22];
}


void keyadd(){

    for(int i = 0; i <= 89; ++i){
        B[129][i] =  B[128][i] ^ K[i];
    }

    for(int i = 0; i <= 29; ++i){
        S[129][i] = S[128][i] ^ K[i+90];
    }

    S[129][30] = 1;
}

void diffusion(){

    for(int i = 0; i <= 88; ++i){
        B[t+1][i] = B[t][i+1];
    }

    B[t+1][89] = NFSR2();

    for(int i = 0; i <= 29; ++i){
        S[t+1][i] = S[t][i+1];
    }

    S[t+1][30] = NFSR1();

}

void keysteamGeneration(int length){

    for(int i = 0 ; i <KEYSTREAM_SIZE; ++i){
        keystream[i] = 0;
    }

    for(int i = 0; i <= length; ++i){
        keystream[i] = a();
        diffusion();
        ++t;
    }
}

uint8_t* keystreamGenerationSpecification(int length){

    if(length <= 0){
        return  NULL;
    }
    int length_t = length - 1;
    if (!a257){
        z[t] = a();
        a257 = 1;
        --length_t;
    }
    for(int i = 0; i <= length_t; ++i){
        diffusion();
        ++t;
        z[t] = a();
    }
    uint8_t* ret_slice = calloc(length, sizeof(uint8_t));

    for(int i = 0; i<length; ++i){
        ret_slice[i] = z[257 - (length-1) + i];
    }

    return ret_slice;
}

uint8_t* getKeystream(){
    return keystream;
}

char* binArray2hex(uint8_t * bin) {
    char * str = malloc(KEYSTREAM_SIZE/4);
    for (int i = 0; i < (KEYSTREAM_SIZE/4); i++) {
        int val = bin[i*4]*8 + bin[i*4+1]*4 + bin[i*4+2]*2 + bin[i*4+3]*1;
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
    return (uint8_t) -1;
}

void hex2binArray(char* hex, uint8_t * bin) {
    for (uint8_t i = 0; i < strlen(hex); ++i){
        int val = hex2int(hex[i]);

        bin[i*4 + 3] = (uint8_t) (val & 1);
        bin[i*4 + 2] = (uint8_t) ((val >> 1) & 1);
        bin[i*4 + 1] = (uint8_t) ((val >> 2) & 1);
        bin[i*4 + 0] = (uint8_t) ((val >> 3) & 1);
    }
}
void test1(){
    char str[500];
    sprintf(str,"Test 1\n");
    send_USART_str(str);
    char *Kstr = "0000000000000000FFFFFFFFFFFFFF";
    char *IVstr = "FFFFFFFFFFFFFFFF";
    uint8_t Kbin[120];
    char* test= "4d190941816f942358f0d164f4eceb09";
    hex2binArray(Kstr, Kbin);
    uint8_t IVbin[64];
    hex2binArray(IVstr, IVbin);
    _construct(Kbin, IVbin, KEYSTREAM_SIZE);
    char* result = binArray2hex(keystream);
    sprintf(str,"Generated keystream: %s\n", result);
    send_USART_str(str);
    free(result);
    sprintf(str,"Correct keystream:   %s\n", test);
    send_USART_str(str);
    t=0;
}

void test2(){
    char str[500];
    sprintf(str,"Test 2\n");
    send_USART_str(str);
    char *Kstr = "7893257383493a0b0f030939409205";
    char *IVstr = "6969696969696969";
    uint8_t Kbin[120];
    char* test= "50161073d0e2cb919f09707b98ceea99";
    hex2binArray(Kstr, Kbin);
    uint8_t IVbin[64];
    hex2binArray(IVstr, IVbin);
    _construct(Kbin, IVbin, KEYSTREAM_SIZE);
    char* result = binArray2hex(keystream);
    sprintf(str,"Generated keystream: %s\n", result);
    send_USART_str(str);
    free(result);
    sprintf(str,"Correct keystream:   %s\n", test);
    send_USART_str(str);
    t=0;
}

void test3(){
    char str[500];
    sprintf(str,"Test 3\n");
    send_USART_str(str);
    char *Kstr = "12342f5f1234f23f234f5f234f1f41";
    char *IVstr = "8498723987987f91";
    uint8_t Kbin[120];
    char* test= "e9eac69c4871f44edb1885e00270e5cc";
    hex2binArray(Kstr, Kbin);
    uint8_t IVbin[64];
    hex2binArray(IVstr, IVbin);
    _construct(Kbin, IVbin, KEYSTREAM_SIZE);
    char* result = binArray2hex(keystream);
    sprintf(str,"Generated keystream: %s\n", result);
    send_USART_str(str);
    free(result);
    sprintf(str,"Correct keystream:   %s\n", test);
    send_USART_str(str);
    t=0;
}



int main(void)
{
    clock_setup();
    gpio_setup();
    usart_setup(115200);

    uint32_t x = 0;
    
    char str[100];

    //Tests
    test1();
    test2();
    test3();

   // x = power_5_13();

    sprintf(str, "Output: %010lu ", x);
    send_USART_str(str);

    if (x == 1220703125) {
        send_USART_str(" .. and that's correct!");
    }
    else {
        send_USART_str(" .. and that's incorrect!");
    }


    send_USART_str("Done!");

    while(1);
    return 0;
}