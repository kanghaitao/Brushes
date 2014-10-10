
///  \file CZColor.cpp
///  \brief This is the file implement the class CZColor.
///
///		(description)
///
///  \version	1.0.0
///	 \author	Charly Zhang<chicboi@hotmail.com>
///  \date		2014-09-25
///  \note

#include "CZColor.h"

/// 采用RGB模式初始化
void CZColor::initWithRGB(float r, float g, float b, float a)
{
	red			= CZClamp(0.0f, 1.0f, r);
	green		= CZClamp(0.0f, 1.0f, g);
	blue		= CZClamp(0.0f, 1.0f, b);
	alpha		= CZClamp(0.0f, 1.0f, a);

	float h, s, v;
	RGBtoHSV(red, green, blue, h, s, v);

	hue			= CZClamp(0.0f, 1.0f, h);
	saturation	= CZClamp(0.0f, 1.0f, s);
	brightness	= CZClamp(0.0f, 1.0f, v);
	
}

/// 采用HSV模式初始化
/// 
///		\param h - 色调
///		\param s - 饱和度
///		\param v - 亮度
///		\param a - 不透明度
void CZColor::initWithHSV(float h, float s, float v, float a)
{
	hue			= CZClamp(0.0f, 1.0f, h);
	saturation	= CZClamp(0.0f, 1.0f, s);
	brightness	= CZClamp(0.0f, 1.0f, v);
	alpha		= CZClamp(0.0f, 1.0f, a);

	float r,g,b;
	HSVtoRGB(hue,saturation,brightness,r,g,b);

	red			= CZClamp(0.0f, 1.0f, r);
	green		= CZClamp(0.0f, 1.0f, g);
	blue		= CZClamp(0.0f, 1.0f, b);
}

/// 返回随机颜色 - 静态函数
CZColor CZColor::randomColor()
{
	float components[4];

	for (int i = 0; i < 4; i++) 
		components[i] = CZRandomFloat();

	components[3] = 0.5 + (components[3] * 0.5);

	CZColor color;
	color.initWithHSV(components[0], components[1], components[2], components[3]);

	return color;
}

/// 混合其他颜色
CZColor CZColor::colorBlend(const CZColor &c_, float fraction_)
{
	float r = (fraction_ * c_.red) + (1.0f - fraction_) * red;
	float g = (fraction_ * c_.green) + (1.0f - fraction_) * green;
	float b = (fraction_ * c_.blue) + (1.0f - fraction_) * blue;
	float a = (fraction_ * c_.alpha) + (1.0f - fraction_) * alpha;

	return CZColor(r,g,b,a);
}

/// 用RGB模式调整
void CZColor::balanceRGB(float rShift, float gShift, float bShift)
{
	red =	CZClamp(0, 1, red + rShift);
	green = CZClamp(0, 1, green + gShift);
	blue =	CZClamp(0, 1, blue + bShift);

	float h, s, v;
	RGBtoHSV(red, green, blue, h, s, v);

	hue			= CZClamp(0.0f, 1.0f, h);
	saturation	= CZClamp(0.0f, 1.0f, s);
	brightness	= CZClamp(0.0f, 1.0f, v);
}
/// 用HSV模式调整
void CZColor::adjustHSV(float hShift, float sShift, float bShift)
{
	hue = hue + hShift;
	bool negative = (hue < 0);
	hue = fmodf(fabs(hue), 1.0f);
	if (negative) 
	{
		hue = 1.0f - hue;
	}

	sShift = 1 + sShift;
	bShift = 1 + bShift;
	saturation = CZClamp(0, 1, saturation * sShift);
	brightness = CZClamp(0, 1, brightness * bShift);

	float r,g,b;
	HSVtoRGB(hue,saturation,brightness,r,g,b);

	red			= CZClamp(0.0f, 1.0f, r);
	green		= CZClamp(0.0f, 1.0f, g);
	blue		= CZClamp(0.0f, 1.0f, b);
}

/// 将HSV模式的值转换到一个uint32中，（分别是h,s,v,a）
uint32_t CZColor::hash2Int()
{
	uint32_t h = 256.f * hue;
	uint32_t s = 256.f * saturation;
	uint32_t b = 256.f * brightness;
	uint32_t a = 256.f * alpha;
	return (h << 24) | (s << 16) | (b << 8) | (a);
}

/// 判断是否相等
bool CZColor::operator ==( const  CZColor& c_) const
{
	if ( this->hue==c_.hue && this->saturation==c_.saturation && this->brightness==c_.brightness && this->alpha==c_.alpha )
	{
		return true;
	} 
	else
	{
		return false;
	}
}

/// 编解码
void CZColor::update(CZDecoder *decoder_, bool deep /* = false */)
{
	/*
	hue_ =  WDClamp(0.0f, 1.0f, [decoder decodeFloatForKey:WDHueKey]);
	saturation_ = WDClamp(0.0f, 1.0f, [decoder decodeFloatForKey:WDSaturationKey]);
	brightness_ = WDClamp(0.0f, 1.0f, [decoder decodeFloatForKey:WDBrightnessKey]);
	alpha_ = WDClamp(0.0f, 1.0f, [decoder decodeFloatForKey:WDAlphaKey]);
	*/
};
void CZColor::encode(CZCoder *coder_, bool deep /* = false */)
{
	/*
	[coder encodeFloat:hue_ forKey:WDHueKey];
	[coder encodeFloat:saturation_ forKey:WDSaturationKey];
	[coder encodeFloat:brightness_ forKey:WDBrightnessKey];
	[coder encodeFloat:alpha_ forKey:WDAlphaKey];
	*/
};