/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/Dor/Dropbox/IDC/Build Your Own Computer/Projects/Mips-Pipelined-processor/GPR and ALU/MIPS_ALU_src/MIPS_ALU-empty.vhd";
extern char *IEEE_P_3620187407;
extern char *IEEE_P_2592010699;

char *ieee_p_2592010699_sub_1697423399_503743352(char *, char *, char *, char *, char *, char *);
char *ieee_p_2592010699_sub_1735675855_503743352(char *, char *, char *, char *, char *, char *);
char *ieee_p_2592010699_sub_1837678034_503743352(char *, char *, char *, char *);
char *ieee_p_2592010699_sub_795620321_503743352(char *, char *, char *, char *, char *, char *);
char *ieee_p_3620187407_sub_767668596_3965413181(char *, char *, char *, char *, char *, char *);
char *ieee_p_3620187407_sub_767740470_3965413181(char *, char *, char *, char *, char *, char *);


static void work_a_1398788329_3212880686_p_0(char *t0)
{
    char t5[16];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t6;
    char *t7;
    int t8;
    unsigned int t9;
    unsigned char t10;
    char *t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    int t17;
    int t18;
    int t19;
    int t20;
    int t22;
    char *t23;
    char *t25;
    char *t26;
    char *t27;
    char *t28;
    char *t29;

LAB0:    xsi_set_current_line(52, ng0);
    t1 = (t0 + 1032U);
    t2 = *((char **)t1);
    t1 = (t0 + 10800U);
    t3 = (t0 + 11222);
    t6 = (t5 + 0U);
    t7 = (t6 + 0U);
    *((int *)t7) = 0;
    t7 = (t6 + 4U);
    *((int *)t7) = 1;
    t7 = (t6 + 8U);
    *((int *)t7) = 1;
    t8 = (1 - 0);
    t9 = (t8 * 1);
    t9 = (t9 + 1);
    t7 = (t6 + 12U);
    *((unsigned int *)t7) = t9;
    t10 = ieee_std_logic_unsigned_equal_stdv_stdv(IEEE_P_3620187407, t2, t1, t3, t5);
    if (t10 != 0)
        goto LAB2;

LAB4:    t1 = (t0 + 1032U);
    t2 = *((char **)t1);
    t1 = (t0 + 10800U);
    t3 = (t0 + 11227);
    t6 = (t5 + 0U);
    t7 = (t6 + 0U);
    *((int *)t7) = 0;
    t7 = (t6 + 4U);
    *((int *)t7) = 1;
    t7 = (t6 + 8U);
    *((int *)t7) = 1;
    t8 = (1 - 0);
    t9 = (t8 * 1);
    t9 = (t9 + 1);
    t7 = (t6 + 12U);
    *((unsigned int *)t7) = t9;
    t10 = ieee_std_logic_unsigned_equal_stdv_stdv(IEEE_P_3620187407, t2, t1, t3, t5);
    if (t10 != 0)
        goto LAB5;

LAB6:    xsi_set_current_line(57, ng0);
    t1 = (t0 + 1192U);
    t2 = *((char **)t1);
    t1 = (t0 + 11232);
    t8 = xsi_mem_cmp(t1, t2, 6U);
    if (t8 == 1)
        goto LAB8;

LAB15:    t4 = (t0 + 11238);
    t17 = xsi_mem_cmp(t4, t2, 6U);
    if (t17 == 1)
        goto LAB9;

LAB16:    t7 = (t0 + 11244);
    t18 = xsi_mem_cmp(t7, t2, 6U);
    if (t18 == 1)
        goto LAB10;

LAB17:    t12 = (t0 + 11250);
    t19 = xsi_mem_cmp(t12, t2, 6U);
    if (t19 == 1)
        goto LAB11;

LAB18:    t14 = (t0 + 11256);
    t20 = xsi_mem_cmp(t14, t2, 6U);
    if (t20 == 1)
        goto LAB12;

LAB19:    t16 = (t0 + 11262);
    t22 = xsi_mem_cmp(t16, t2, 6U);
    if (t22 == 1)
        goto LAB13;

LAB20:
LAB14:    xsi_set_current_line(64, ng0);
    t1 = (t0 + 11286);
    t3 = (t0 + 6096);
    t4 = (t3 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t11 = *((char **)t7);
    memcpy(t11, t1, 3U);
    xsi_driver_first_trans_fast(t3);

LAB7:
LAB3:    t1 = (t0 + 5920);
    *((int *)t1) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(53, ng0);
    t7 = (t0 + 11224);
    t12 = (t0 + 6096);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    memcpy(t16, t7, 3U);
    xsi_driver_first_trans_fast(t12);
    goto LAB3;

LAB5:    xsi_set_current_line(55, ng0);
    t7 = (t0 + 11229);
    t12 = (t0 + 6096);
    t13 = (t12 + 56U);
    t14 = *((char **)t13);
    t15 = (t14 + 56U);
    t16 = *((char **)t15);
    memcpy(t16, t7, 3U);
    xsi_driver_first_trans_fast(t12);
    goto LAB3;

LAB8:    xsi_set_current_line(58, ng0);
    t23 = (t0 + 11268);
    t25 = (t0 + 6096);
    t26 = (t25 + 56U);
    t27 = *((char **)t26);
    t28 = (t27 + 56U);
    t29 = *((char **)t28);
    memcpy(t29, t23, 3U);
    xsi_driver_first_trans_fast(t25);
    goto LAB7;

LAB9:    xsi_set_current_line(59, ng0);
    t1 = (t0 + 11271);
    t3 = (t0 + 6096);
    t4 = (t3 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t11 = *((char **)t7);
    memcpy(t11, t1, 3U);
    xsi_driver_first_trans_fast(t3);
    goto LAB7;

LAB10:    xsi_set_current_line(60, ng0);
    t1 = (t0 + 11274);
    t3 = (t0 + 6096);
    t4 = (t3 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t11 = *((char **)t7);
    memcpy(t11, t1, 3U);
    xsi_driver_first_trans_fast(t3);
    goto LAB7;

LAB11:    xsi_set_current_line(61, ng0);
    t1 = (t0 + 11277);
    t3 = (t0 + 6096);
    t4 = (t3 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t11 = *((char **)t7);
    memcpy(t11, t1, 3U);
    xsi_driver_first_trans_fast(t3);
    goto LAB7;

LAB12:    xsi_set_current_line(62, ng0);
    t1 = (t0 + 11280);
    t3 = (t0 + 6096);
    t4 = (t3 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t11 = *((char **)t7);
    memcpy(t11, t1, 3U);
    xsi_driver_first_trans_fast(t3);
    goto LAB7;

LAB13:    xsi_set_current_line(63, ng0);
    t1 = (t0 + 11283);
    t3 = (t0 + 6096);
    t4 = (t3 + 56U);
    t6 = *((char **)t4);
    t7 = (t6 + 56U);
    t11 = *((char **)t7);
    memcpy(t11, t1, 3U);
    xsi_driver_first_trans_fast(t3);
    goto LAB7;

LAB21:;
}

static void work_a_1398788329_3212880686_p_1(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    unsigned char t4;
    char *t5;
    char *t6;
    char *t7;
    char *t8;
    char *t9;
    char *t10;
    static char *nl0[] = {&&LAB6, &&LAB6, &&LAB5, &&LAB6, &&LAB6, &&LAB6, &&LAB6, &&LAB6, &&LAB6};

LAB0:    t1 = (t0 + 4360U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(70, ng0);
    t2 = (t0 + 1832U);
    t3 = *((char **)t2);
    t4 = *((unsigned char *)t3);
    t2 = (char *)((nl0) + t4);
    goto **((char **)t2);

LAB4:    xsi_set_current_line(70, ng0);

LAB9:    t2 = (t0 + 5936);
    *((int *)t2) = 1;
    *((char **)t1) = &&LAB10;

LAB1:    return;
LAB5:    xsi_set_current_line(72, ng0);
    t5 = (t0 + 1512U);
    t6 = *((char **)t5);
    t5 = (t0 + 6160);
    t7 = (t5 + 56U);
    t8 = *((char **)t7);
    t9 = (t8 + 56U);
    t10 = *((char **)t9);
    memcpy(t10, t6, 32U);
    xsi_driver_first_trans_fast(t5);
    goto LAB4;

LAB6:    xsi_set_current_line(72, ng0);
    t2 = (t0 + 1672U);
    t3 = *((char **)t2);
    t2 = (t0 + 6160);
    t5 = (t2 + 56U);
    t6 = *((char **)t5);
    t7 = (t6 + 56U);
    t8 = *((char **)t7);
    memcpy(t8, t3, 32U);
    xsi_driver_first_trans_fast(t2);
    goto LAB4;

LAB7:    t3 = (t0 + 5936);
    *((int *)t3) = 0;
    goto LAB2;

LAB8:    goto LAB7;

LAB10:    goto LAB8;

}

static void work_a_1398788329_3212880686_p_2(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    xsi_set_current_line(75, ng0);

LAB3:    t1 = (t0 + 1352U);
    t2 = *((char **)t1);
    t1 = (t0 + 6224);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    memcpy(t6, t2, 32U);
    xsi_driver_first_trans_fast(t1);

LAB2:    t7 = (t0 + 5952);
    *((int *)t7) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}

static void work_a_1398788329_3212880686_p_3(char *t0)
{
    char t1[16];
    char t11[16];
    char t23[16];
    char *t2;
    char *t3;
    int t4;
    unsigned int t5;
    unsigned int t6;
    unsigned int t7;
    unsigned char t8;
    char *t9;
    char *t10;
    char *t12;
    char *t13;
    char *t14;
    char *t15;
    int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned char t20;
    char *t21;
    char *t22;
    char *t24;
    char *t25;
    char *t26;
    char *t27;
    unsigned int t28;
    unsigned int t29;
    unsigned char t30;
    char *t31;
    char *t32;
    char *t33;
    char *t34;
    char *t35;
    char *t36;

LAB0:    xsi_set_current_line(77, ng0);

LAB3:    t2 = (t0 + 2312U);
    t3 = *((char **)t2);
    t4 = (31 - 31);
    t5 = (t4 * -1);
    t6 = (1U * t5);
    t7 = (0 + t6);
    t2 = (t3 + t7);
    t8 = *((unsigned char *)t2);
    t9 = (t0 + 2312U);
    t10 = *((char **)t9);
    t12 = ((IEEE_P_2592010699) + 4024);
    t13 = (t0 + 10912U);
    t9 = xsi_base_array_concat(t9, t11, t12, (char)99, t8, (char)97, t10, t13, (char)101);
    t14 = (t0 + 2472U);
    t15 = *((char **)t14);
    t16 = (31 - 31);
    t17 = (t16 * -1);
    t18 = (1U * t17);
    t19 = (0 + t18);
    t14 = (t15 + t19);
    t20 = *((unsigned char *)t14);
    t21 = (t0 + 2472U);
    t22 = *((char **)t21);
    t24 = ((IEEE_P_2592010699) + 4024);
    t25 = (t0 + 10928U);
    t21 = xsi_base_array_concat(t21, t23, t24, (char)99, t20, (char)97, t22, t25, (char)101);
    t26 = ieee_p_3620187407_sub_767740470_3965413181(IEEE_P_3620187407, t1, t9, t11, t21, t23);
    t27 = (t1 + 12U);
    t28 = *((unsigned int *)t27);
    t29 = (1U * t28);
    t30 = (33U != t29);
    if (t30 == 1)
        goto LAB5;

LAB6:    t31 = (t0 + 6288);
    t32 = (t31 + 56U);
    t33 = *((char **)t32);
    t34 = (t33 + 56U);
    t35 = *((char **)t34);
    memcpy(t35, t26, 33U);
    xsi_driver_first_trans_fast(t31);

LAB2:    t36 = (t0 + 5968);
    *((int *)t36) = 1;

LAB1:    return;
LAB4:    goto LAB2;

LAB5:    xsi_size_not_matching(33U, t29, 0);
    goto LAB6;

}

static void work_a_1398788329_3212880686_p_4(char *t0)
{
    char *t1;
    char *t2;
    int t3;
    unsigned int t4;
    unsigned int t5;
    unsigned int t6;
    unsigned char t7;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;

LAB0:    xsi_set_current_line(78, ng0);

LAB3:    t1 = (t0 + 2792U);
    t2 = *((char **)t1);
    t3 = (32 - 32);
    t4 = (t3 * -1);
    t5 = (1U * t4);
    t6 = (0 + t5);
    t1 = (t2 + t6);
    t7 = *((unsigned char *)t1);
    t8 = (t0 + 6352);
    t9 = (t8 + 56U);
    t10 = *((char **)t9);
    t11 = (t10 + 56U);
    t12 = *((char **)t11);
    *((unsigned char *)t12) = t7;
    xsi_driver_first_trans_fast(t8);

LAB2:    t13 = (t0 + 5984);
    *((int *)t13) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}

static void work_a_1398788329_3212880686_p_5(char *t0)
{
    char t23[16];
    char t38[16];
    char t39[16];
    char t40[16];
    char *t1;
    char *t2;
    char *t3;
    int t4;
    char *t5;
    char *t6;
    int t7;
    char *t8;
    char *t9;
    int t10;
    char *t11;
    char *t12;
    int t13;
    char *t14;
    char *t15;
    int t16;
    char *t17;
    char *t18;
    int t19;
    char *t20;
    char *t21;
    int t22;
    char *t24;
    char *t25;
    char *t26;
    char *t27;
    char *t28;
    char *t29;
    unsigned int t30;
    unsigned int t31;
    unsigned char t32;
    char *t33;
    char *t34;
    char *t35;
    char *t36;
    char *t37;
    unsigned char t41;

LAB0:    xsi_set_current_line(82, ng0);
    t1 = (t0 + 2152U);
    t2 = *((char **)t1);
    t1 = (t0 + 11289);
    t4 = xsi_mem_cmp(t1, t2, 3U);
    if (t4 == 1)
        goto LAB3;

LAB11:    t5 = (t0 + 11292);
    t7 = xsi_mem_cmp(t5, t2, 3U);
    if (t7 == 1)
        goto LAB4;

LAB12:    t8 = (t0 + 11295);
    t10 = xsi_mem_cmp(t8, t2, 3U);
    if (t10 == 1)
        goto LAB5;

LAB13:    t11 = (t0 + 11298);
    t13 = xsi_mem_cmp(t11, t2, 3U);
    if (t13 == 1)
        goto LAB6;

LAB14:    t14 = (t0 + 11301);
    t16 = xsi_mem_cmp(t14, t2, 3U);
    if (t16 == 1)
        goto LAB7;

LAB15:    t17 = (t0 + 11304);
    t19 = xsi_mem_cmp(t17, t2, 3U);
    if (t19 == 1)
        goto LAB8;

LAB16:    t20 = (t0 + 11307);
    t22 = xsi_mem_cmp(t20, t2, 3U);
    if (t22 == 1)
        goto LAB9;

LAB17:
LAB10:    xsi_set_current_line(90, ng0);
    t1 = (t0 + 11310);
    t3 = (t0 + 11338);
    t8 = ((IEEE_P_2592010699) + 4024);
    t9 = (t38 + 0U);
    t11 = (t9 + 0U);
    *((int *)t11) = 0;
    t11 = (t9 + 4U);
    *((int *)t11) = 27;
    t11 = (t9 + 8U);
    *((int *)t11) = 1;
    t4 = (27 - 0);
    t30 = (t4 * 1);
    t30 = (t30 + 1);
    t11 = (t9 + 12U);
    *((unsigned int *)t11) = t30;
    t11 = (t39 + 0U);
    t12 = (t11 + 0U);
    *((int *)t12) = 0;
    t12 = (t11 + 4U);
    *((int *)t12) = 2;
    t12 = (t11 + 8U);
    *((int *)t12) = 1;
    t7 = (2 - 0);
    t30 = (t7 * 1);
    t30 = (t30 + 1);
    t12 = (t11 + 12U);
    *((unsigned int *)t12) = t30;
    t6 = xsi_base_array_concat(t6, t23, t8, (char)97, t1, t38, (char)97, t3, t39, (char)101);
    t12 = (t0 + 2952U);
    t14 = *((char **)t12);
    t32 = *((unsigned char *)t14);
    t15 = ((IEEE_P_2592010699) + 4024);
    t12 = xsi_base_array_concat(t12, t40, t15, (char)97, t6, t23, (char)99, t32, (char)101);
    t30 = (28U + 3U);
    t31 = (t30 + 1U);
    t41 = (32U != t31);
    if (t41 == 1)
        goto LAB33;

LAB34:    t17 = (t0 + 6416);
    t18 = (t17 + 56U);
    t20 = *((char **)t18);
    t21 = (t20 + 56U);
    t24 = *((char **)t21);
    memcpy(t24, t12, 32U);
    xsi_driver_first_trans_fast(t17);

LAB2:    t1 = (t0 + 6000);
    *((int *)t1) = 1;

LAB1:    return;
LAB3:    xsi_set_current_line(83, ng0);
    t24 = (t0 + 2312U);
    t25 = *((char **)t24);
    t24 = (t0 + 10912U);
    t26 = (t0 + 2472U);
    t27 = *((char **)t26);
    t26 = (t0 + 10928U);
    t28 = ieee_p_2592010699_sub_795620321_503743352(IEEE_P_2592010699, t23, t25, t24, t27, t26);
    t29 = (t23 + 12U);
    t30 = *((unsigned int *)t29);
    t31 = (1U * t30);
    t32 = (32U != t31);
    if (t32 == 1)
        goto LAB19;

LAB20:    t33 = (t0 + 6416);
    t34 = (t33 + 56U);
    t35 = *((char **)t34);
    t36 = (t35 + 56U);
    t37 = *((char **)t36);
    memcpy(t37, t28, 32U);
    xsi_driver_first_trans_fast(t33);
    goto LAB2;

LAB4:    xsi_set_current_line(84, ng0);
    t1 = (t0 + 2312U);
    t2 = *((char **)t1);
    t1 = (t0 + 10912U);
    t3 = (t0 + 2472U);
    t5 = *((char **)t3);
    t3 = (t0 + 10928U);
    t6 = ieee_p_2592010699_sub_1735675855_503743352(IEEE_P_2592010699, t23, t2, t1, t5, t3);
    t8 = (t23 + 12U);
    t30 = *((unsigned int *)t8);
    t31 = (1U * t30);
    t32 = (32U != t31);
    if (t32 == 1)
        goto LAB21;

LAB22:    t9 = (t0 + 6416);
    t11 = (t9 + 56U);
    t12 = *((char **)t11);
    t14 = (t12 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t6, 32U);
    xsi_driver_first_trans_fast(t9);
    goto LAB2;

LAB5:    xsi_set_current_line(85, ng0);
    t1 = (t0 + 2312U);
    t2 = *((char **)t1);
    t1 = (t0 + 10912U);
    t3 = (t0 + 2472U);
    t5 = *((char **)t3);
    t3 = (t0 + 10928U);
    t6 = ieee_p_3620187407_sub_767668596_3965413181(IEEE_P_3620187407, t23, t2, t1, t5, t3);
    t8 = (t23 + 12U);
    t30 = *((unsigned int *)t8);
    t31 = (1U * t30);
    t32 = (32U != t31);
    if (t32 == 1)
        goto LAB23;

LAB24:    t9 = (t0 + 6416);
    t11 = (t9 + 56U);
    t12 = *((char **)t11);
    t14 = (t12 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t6, 32U);
    xsi_driver_first_trans_fast(t9);
    goto LAB2;

LAB6:    xsi_set_current_line(86, ng0);
    t1 = (t0 + 2312U);
    t2 = *((char **)t1);
    t1 = (t0 + 10912U);
    t3 = (t0 + 2472U);
    t5 = *((char **)t3);
    t3 = (t0 + 10928U);
    t6 = ieee_p_2592010699_sub_1697423399_503743352(IEEE_P_2592010699, t23, t2, t1, t5, t3);
    t8 = (t23 + 12U);
    t30 = *((unsigned int *)t8);
    t31 = (1U * t30);
    t32 = (32U != t31);
    if (t32 == 1)
        goto LAB25;

LAB26:    t9 = (t0 + 6416);
    t11 = (t9 + 56U);
    t12 = *((char **)t11);
    t14 = (t12 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t6, 32U);
    xsi_driver_first_trans_fast(t9);
    goto LAB2;

LAB7:    xsi_set_current_line(87, ng0);
    t1 = (t0 + 2312U);
    t2 = *((char **)t1);
    t1 = (t0 + 10912U);
    t3 = (t0 + 2472U);
    t5 = *((char **)t3);
    t3 = (t0 + 10928U);
    t6 = ieee_p_2592010699_sub_795620321_503743352(IEEE_P_2592010699, t38, t2, t1, t5, t3);
    t8 = ieee_p_2592010699_sub_1837678034_503743352(IEEE_P_2592010699, t23, t6, t38);
    t9 = (t23 + 12U);
    t30 = *((unsigned int *)t9);
    t31 = (1U * t30);
    t32 = (32U != t31);
    if (t32 == 1)
        goto LAB27;

LAB28:    t11 = (t0 + 6416);
    t12 = (t11 + 56U);
    t14 = *((char **)t12);
    t15 = (t14 + 56U);
    t17 = *((char **)t15);
    memcpy(t17, t8, 32U);
    xsi_driver_first_trans_fast(t11);
    goto LAB2;

LAB8:    xsi_set_current_line(88, ng0);
    t1 = (t0 + 2312U);
    t2 = *((char **)t1);
    t1 = (t0 + 10912U);
    t3 = (t0 + 2472U);
    t5 = *((char **)t3);
    t3 = (t0 + 10928U);
    t6 = ieee_p_2592010699_sub_1735675855_503743352(IEEE_P_2592010699, t38, t2, t1, t5, t3);
    t8 = ieee_p_2592010699_sub_1837678034_503743352(IEEE_P_2592010699, t23, t6, t38);
    t9 = (t23 + 12U);
    t30 = *((unsigned int *)t9);
    t31 = (1U * t30);
    t32 = (32U != t31);
    if (t32 == 1)
        goto LAB29;

LAB30:    t11 = (t0 + 6416);
    t12 = (t11 + 56U);
    t14 = *((char **)t12);
    t15 = (t14 + 56U);
    t17 = *((char **)t15);
    memcpy(t17, t8, 32U);
    xsi_driver_first_trans_fast(t11);
    goto LAB2;

LAB9:    xsi_set_current_line(89, ng0);
    t1 = (t0 + 2312U);
    t2 = *((char **)t1);
    t1 = (t0 + 10912U);
    t3 = (t0 + 2472U);
    t5 = *((char **)t3);
    t3 = (t0 + 10928U);
    t6 = ieee_p_3620187407_sub_767740470_3965413181(IEEE_P_3620187407, t23, t2, t1, t5, t3);
    t8 = (t23 + 12U);
    t30 = *((unsigned int *)t8);
    t31 = (1U * t30);
    t32 = (32U != t31);
    if (t32 == 1)
        goto LAB31;

LAB32:    t9 = (t0 + 6416);
    t11 = (t9 + 56U);
    t12 = *((char **)t11);
    t14 = (t12 + 56U);
    t15 = *((char **)t14);
    memcpy(t15, t6, 32U);
    xsi_driver_first_trans_fast(t9);
    goto LAB2;

LAB18:;
LAB19:    xsi_size_not_matching(32U, t31, 0);
    goto LAB20;

LAB21:    xsi_size_not_matching(32U, t31, 0);
    goto LAB22;

LAB23:    xsi_size_not_matching(32U, t31, 0);
    goto LAB24;

LAB25:    xsi_size_not_matching(32U, t31, 0);
    goto LAB26;

LAB27:    xsi_size_not_matching(32U, t31, 0);
    goto LAB28;

LAB29:    xsi_size_not_matching(32U, t31, 0);
    goto LAB30;

LAB31:    xsi_size_not_matching(32U, t31, 0);
    goto LAB32;

LAB33:    xsi_size_not_matching(32U, t31, 0);
    goto LAB34;

}

static void work_a_1398788329_3212880686_p_6(char *t0)
{
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t7;

LAB0:    xsi_set_current_line(94, ng0);

LAB3:    t1 = (t0 + 2632U);
    t2 = *((char **)t1);
    t1 = (t0 + 6480);
    t3 = (t1 + 56U);
    t4 = *((char **)t3);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    memcpy(t6, t2, 32U);
    xsi_driver_first_trans_fast_port(t1);

LAB2:    t7 = (t0 + 6016);
    *((int *)t7) = 1;

LAB1:    return;
LAB4:    goto LAB2;

}


extern void work_a_1398788329_3212880686_init()
{
	static char *pe[] = {(void *)work_a_1398788329_3212880686_p_0,(void *)work_a_1398788329_3212880686_p_1,(void *)work_a_1398788329_3212880686_p_2,(void *)work_a_1398788329_3212880686_p_3,(void *)work_a_1398788329_3212880686_p_4,(void *)work_a_1398788329_3212880686_p_5,(void *)work_a_1398788329_3212880686_p_6};
	xsi_register_didat("work_a_1398788329_3212880686", "isim/MIPS_ALU_TB_isim_beh.exe.sim/work/a_1398788329_3212880686.didat");
	xsi_register_executes(pe);
}
