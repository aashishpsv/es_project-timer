#include <LPC17xx.h>
#include <stdlib.h>
#include <stdio.h>

#define PRESCALE (3000-1)

void scan(void);
void initTimer0(void);
void delayMS(unsigned int milliseconds);
void buzzer(int tim);
void display(void);
void delay(void);

unsigned char scan_code[16] = {0X11,0X21,0X41,0X81,
                                0X12,0X22,0X42,0X82,
                                0X14,0X24,0X44,0X84,
                                0X18,0X28,0X48,0X88};

unsigned char ASCII_CODE[16] = {'0','1','2','3',
                                '4','5','6','7',
                                '8','9','A','B',
                                'C','D','E','F'};

unsigned int seg_select[4] = {0<<23, 1<<23, 2<<23, 3<<23};
int dig[4]={0,0,0,0};
unsigned char seven_seg[10]={0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F};
unsigned char row, var, flag, key;
unsigned long int i,j,var1,temp, temp1, temp2, temp3;
unsigned int time[4];

void delayMS(unsigned int milliseconds);

int main(void) {
    int i, j, k;
    LPC_GPIO2->FIODIR |= 0x00003C00; // made output P2.10 to P2.13 (rows)
    LPC_GPIO1->FIODIR &= 0xF87FFFFF; // made input P1.23 to P1.26 (cols)
    initTimer0();
    
    for(i=0; i<4; i++) {
        for(row=1; row<5; row++) {
            if(row == 1)
                var1 = 0x00000400;
            else if(row == 2)
                var1 = 0x00000800;
            else if(row == 3)
                var1 = 0x00001000;
            else if(row == 4)
                var1 = 0x00002000;
            
            temp = var1;
            LPC_GPIO2->FIOCLR = 0x00003C00;  // first clear the port and send appropriate value for
            LPC_GPIO2->FIOSET = var1;         // enabling the row
            flag = 0;
            scan();  // scan if any key pressed in the enabled row
            
            if(flag == 1)
                break;
        }
        
        for(j=0; j<16; j++) {
            if(key == scan_code[j]) {
                time[i] = ASCII_CODE[j];
                time[i] = time[i] - 48;
                break;
            }
        }
    }
    
    display();
    LPC_PINCON->PINSEL0 &= 0xFF0000FF;
    LPC_PINCON->PINSEL1 &= 0xFFC03FFF;
    LPC_PINCON->PINSEL4 &= 0xFFFFFFFC;
    LPC_GPIO0->FIODIR |= 0x00000FF0;
    LPC_GPIO0->FIODIR |= 0x07800000;
    
    while(1) {
        if(LPC_GPIO2->FIOPIN & 1) {
            for(dig[0] = time[3]; dig[0] >= 0; dig[0]--) {
                for(k=0; k<4; k++) {
                    LPC_GPIO0->FIOPIN = seg_select[i];
                    LPC_GPIO0->FIOPIN = seven_seg[dig[k]] << 4;
                    delayMS(1000);
                }
            }
            
            time[1]--;
            
            for(dig[1] = time[2]; dig[1] >= 0; dig[1]--) {
                for(dig[0] = 9; dig[0] >= 0; dig[0]--) {
                    for(int k=0; k<4; k++) {
                        LPC_GPIO0->FIOPIN = seg_select[i];
                        LPC_GPIO0->FIOPIN = seven_seg[dig[k]] << 4;
                        delayMS(1000);
                    }
                }
            }
            
            time[2]--;
            
            for(dig[2] = time[1]; dig[2] >= 0; dig[2]--) {
                for(dig[1] = 5; dig[1] >= 0; dig[1]--) {
                    for(dig[0] = 9; dig[0] >= 0; dig[0]--) {
                        for(k=0; k<4; k++) {
                            LPC_GPIO0->FIOPIN = seg_select[i];
                            LPC_GPIO0->FIOPIN = seven_seg[dig[k]] << 4;
                            delayMS(1000);
                        }
                    }
                }
            }
            
            time[3]--;
            
            for(dig[3] = time[0]; dig[3] >= 0; dig[3]--) {
                for(dig[2] = 9; dig[2] >= 0; dig[2]--) {
                    for(dig[1] = 5; dig[1] >= 0; dig[1]--) {
                        for(dig[0] = 9; dig[0] >= 0; dig[0]--) {
                            for(k=0; k<4; k++) {
                                LPC_GPIO0->FIOPIN = seg_select[i];
                                LPC_GPIO0->FIOPIN = seven_seg[dig[k]] << 4;
                                delayMS(1000);
                            }
                        }
                    }
                }
            }
            
            buzzer(2000);
        }
    }
}

void scan(void) {
    temp3 = LPC_GPIO1->FIOPIN;
    temp3 &= 0x07800000;   // check if any key pressed in the enabled row
    
    if(temp3 != 0x00000000) {
        flag = 1;
        temp3 >>= 19;  // Shifted to come at HN of byte
        temp >>= 10;   // shifted to come at LN of byte
        key = temp3 | temp;  // get SCAN_CODE
    }
}

void initTimer0(void) {
    /* Assuming that PLL0 has been setup with CCLK = 100Mhz and PCLK = 25Mhz. */
    LPC_SC->PCONP |= (1 << 1);  // Power up TIM0. By default TIM0 and TIM1 are enabled.
    LPC_SC->PCLKSEL0 &= ~(0x3 << 3);  // Set PCLK for timer = CCLK/4 = 100/4 (default)
    LPC_TIM0->CTCR = 0x0;
    LPC_TIM0->PR = PRESCALE;  // Increment LPC_TIM0->TC at every 24999+1 clock cycles // 25000 clock cycles @25Mhz = 1 mS
    LPC_TIM0->TCR = 0x02;  // Reset Timer
}

void delayMS(unsigned int milliseconds) {  // Using Timer0
    LPC_TIM0->TCR = 0x02;  // Reset Timer
    LPC_TIM0->TCR = 0x01;  // Enable timer
    
    while(LPC_TIM0->TC < milliseconds);  // wait until timer counter reaches the desired delay
    
    LPC_TIM0->TCR = 0x00;  // Disable timer
}

void buzzer(int tim) {
    LPC_PINCON->PINSEL9 = 0x00000000;
    LPC_GPIO4->FIODIR = 1 << 28;
    LPC_GPIO0->FIOSET = 1 << 28;
    
    for(i = 0; i < tim; i++);
    
    LPC_GPIO0->FIOCLR = 1 << 28;
    
    for(i = 0; i < tim; i++);
}

void delay(void) {
    int b;
    
    for(b = 0; b < 5000; b++);
    
    return;
}

void display(void) {
    int a;
    
    for(a = 0; a < 4; a++) {
        LPC_GPIO0->FIOPIN = a << 23;
        LPC_GPIO0->FIOPIN = seven_seg[dig[a]] << 4;
        delay();
    }
    
    return;
}
