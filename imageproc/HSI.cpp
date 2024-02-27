#define _CRT_SECURE_NO_WARNINGS 1

#include <math.h>
#include "stdafx.h"
#include "HSI.h"

#define DEGREES_PER_RADIAN (180.0 / 3.14159265358979)
#define UNDEFINED_HUE 0.000
#define ZERO_SATURATION 0.0

//RGB to HSI
int RgbtoHsi(RGB* pRgb, HSI* pHsi)
{
	//double R, G, B, Sum;
	//double MinValue, MaxValue;
	//double TempDouble1, TempDouble2, Quotient;
	//double Radians, Angle;


	//R = ((double)pRgb->r) / 255.0;
	//G = ((double)pRgb->g) / 255.0;
	//B = ((double)pRgb->b) / 255.0;

	//Sum = R + G + B;

	//pHsi->Intensity = Sum / 3.0;
	//
	//MinValue = (R < G) ? R : G;             
	//MinValue = (B < MinValue) ? B : MinValue; 
	//MaxValue = (R > G) ? R : G;
	//MaxValue = (B > MaxValue) ? B : MaxValue; 

	//if (pHsi->Intensity < 0.00001)
	//	pHsi->Saturation = ZERO_SATURATION;
	//else
	//{
	//	pHsi->Saturation = 1.0 - (3 * MinValue) / Sum;
	//}

	//if (MinValue == MaxValue)
	//{
	//	pHsi->Hue = UNDEFINED_HUE;
	//	pHsi->Saturation = ZERO_SATURATION;
	//	return 0;
	//}

	//TempDouble1 = (((R - G) + (R - B)) / 2.0);
	//
	//TempDouble2 = ((R - G) * (R - G) + (R - B) * (G - B));
	//
	//Quotient = (TempDouble1 / sqrt(TempDouble2));

	//if (Quotient > 0.9999999999999999)
	//	Radians = 0.0;
	//else if (Quotient < -0.9999999999999999)
	//	Radians = 3.1415926535;
	//else
	//{
	//	//ACOS函数中的参数是-1到 l 之间的值
	//	//ACOS函数的功能是计算参数的反余弦值，返回的角度值以弧度表示
	//	//转换成角度的话就乘180 / PI
	//	//Radians = acos(TempDouble1 / sqrt(TempDouble2));
	//	Radians = acos(Quotient);
	//}
	////转换成角度的话就乘180 / PI
	//Angle = Radians * DEGREES_PER_RADIAN;

	//if (B > G)
	//{
	//	pHsi->Hue = 360.0 - Angle;
	//}
	//else
	//{
	//	pHsi->Hue = Angle;
	//}

	double R, G, B;

	R = ((double)pRgb->r) / 255.0;
	G = ((double)pRgb->g) / 255.0;
	B = ((double)pRgb->b) / 255.0;


	int p;
	p = (pRgb->r < pRgb->g) ? pRgb->r : pRgb->g;
	p = (pRgb->b < p) ? pRgb->b : p;


	pHsi->Intensity = ((double)(pRgb->r + pRgb->g + pRgb->b)) / 255.0 / 3;
	pHsi->Saturation = 1 - 3.0 / (pRgb->r + pRgb->g + pRgb->b) * p;
	if (pRgb->g >= pRgb->b)
		pHsi->Hue = 180.0 / 3.14159 * acos(((double)(pRgb->r - pRgb->g) + (pRgb->r - pRgb->b)) / 2 / sqrt((double)(pRgb->r - pRgb->g) * (pRgb->r - pRgb->g) + (pRgb->r - pRgb->b) * (pRgb->g - pRgb->b)));
	else
		pHsi->Hue = 360 - 180.0 / 3.14159 * acos(((double)(pRgb->r - pRgb->g) + (pRgb->r - pRgb->b)) / 2 / sqrt((double)(pRgb->r - pRgb->g) * (pRgb->r - pRgb->g) + (pRgb->r - pRgb->b) * (pRgb->g - pRgb->b)));




	return 0;

}


