---
layout: page
title:  "大气散射"
author: mosfet
category: algorithm
tags: 程序化系列 环境建模 参与介质
---

本文摘录和解释了一种广泛实用的模型。该模型需要求解类似的体积方程。  

## 大气密度指数分布公式
大气的分子和气溶胶密度随着高度h（海拔）呈指数衰减：
```ruby
density(h) = density(0)*e^-h/H
# h 当前采样的海拔高度。
# H 大气的标高（Scale Height）
# 其中瑞利散射（气体分子）的标高 HR~8km
# 米氏散射（气溶胶）的标高      HM~=1.2KM 
```

## 散射系数与相位函数公式
大气颜色由瑞利散射（Rayleigh）和米氏散射（Mie）叠加决定，各自拥有不同的散射系数β和相函数。  

瑞利散射（Rayleigh Scattering）—— 决定天空的蓝色与日落红。  
```ruby
βs(h,λ) = [8Π³(n²-1)²/3Nλ^4]e^(-h/HR)
#s散射系数  #n空气折射率1.0003 #N海平面分子密度2.545e25

p(cosθ) = [3/16Π](1+cosθ²)
# 视线-太阳光方向

# 代入λ对于红光680 绿光550 蓝光440左式为常数。去找AI算一下一下你想用哪个。
vec3(5.8e-6,13.5e-6,33.1e-6);
```
计算只剩下该常数乘以高度项，代表某处的RGB散射强度，蓝光非常强。  

米氏散射（Mie Scattering）—— 决定太阳周围的白晕与大气的白霾。  
```ruby
βs(h,λ) = βs(0,λ)e^(-h/HM)

p(cosθ) = (3/8Π) * [(1-g²)(1+cos²θ)]/[(2+g²)(1+g²-2gcosθ)^1.5] #Cornette-Shanks
g = 0.76

# 左侧也是一个可选经验值。
vec3(21e-6)
```

## 积分
实践中，通常只使用黎曼积分以及单散射模型。因此只需要计算一条视线上的常驻累积透射率，以及直接光中的单个透射率衰减光照。  
从相机出发：  
回顾方程：  
```ruby
# l1 地面从视线到大气边缘交点的路径
# l2 l1采样点沿着太阳方向到大气边缘交点的路径
Lo = ∫l1|T(p)S(p) dx #(该T沿着视线累积减弱)

T(p) = e^(-∫0..l1Pasted|σt(p)dx)    # 简化不重新采样，第一个点为100%
S(p) = σs(p)∫S²|p(ω'->ω)L(p,ω')dω'
    ~= σs(p)p(C * e^-∫l2|σt(p')dx') # 由于是定值平行光，视线角度和光线角度不变

Lo = Cp ∫l1|dx [透射率 * σs(p) * e^-∫l2|σt(p')dx']
LoRayl + LoMie # 这俩虽然分开算，但将消光的影响合在一起(exp上的值)
```
您需要一个局部坐标系来将光线转入本地计算(例如对齐到Z轴)和计算球交点的工具函数。  
并假设位于地球北极点发射。地球(6300km)，大气(100KM)。其实我们看见的天空形状是一个很宽广的球切片。  
朝着水平方向看见比完全垂直高度多得多的空间是很正常的。  

## 实现
本文提供的实现仅用于实验和验证目的，出于实用目的，请勿使用本文提供的实现代码。  
```cpp
// https://iquilezles.org/articles/intersectors/
vec2 sphIntersect( in vec3 ro, in vec3 rd, in vec3 ce, float ra) {
  vec3 oc = ro - ce;
  float b = dot(oc, rd);
  float c = dot(oc, oc) - ra * ra;
  float h = b * b - c;
  if (h < 0.0) return vec2(-1.0); // no intersection
  h = sqrt(h);
  return vec2(-b - h, -b + h);
}
vec3 atmosphere( in vec3 ro, in vec3 rd, in vec3 sd, in float C) {
  const float re = 6371e3;
  const float ra = 6471e3;
  const vec3 beta0r = vec3(5.8e-6, 13.5e-6, 33.1e-6);
  const vec3 beta0m = vec3(4e-6);
  const float hr = 8e3;
  const float hm = 1.2e3;
  const float g = 0.75;

  float costheta = dot(rd, sd);
  float pr = 0.0597 * (1.0 + costheta * costheta);
  float pm = 0.1194 * (1.0 - g * g) * (1.0 + costheta * costheta) /
    ((2.0 + g * g) * pow(1.0 + g * g - 2.0 * g * costheta, 1.5));

  ro += vec3(0.0, 0.0, re);

  float x = 16.0;
  float y = 8.0;
  float tx = sphIntersect(ro, rd, vec3(0.0), ra).y;
  if (tx < 0.0) return vec3(.0);
  float dx = tx / x;

  vec3 r = vec3(.0), m = vec3(.0);
  vec3 g1 = vec3(0.);
  for (float i = 0.; i < x; i += 1.) {
    vec3 px = ro + rd * i * dx;
    float h = length(px) - re;
    if (h < 0.) return vec3(.0);

    float ty = sphIntersect(px, sd, vec3(0.0), ra).y;
    float dy = ty / y;
    vec3 g2 = vec3(0.);
    for (float j = 0.; j < y; j += 1.) {
      vec3 py = px + sd * j * dy;
      float hy = length(py) - re;

      g2 += dy * (beta0r * exp(-hy / hr) + beta0m * exp(-hy / hm));
    }

    r += dx * exp(-g1) * beta0r * exp(-h / hr) * exp(-g2);
    m += dx * exp(-g1) * beta0m * exp(-h / hm) * exp(-g2);

    g1 += dx * (beta0r * exp(-h / hr) + beta0m * exp(-h / hm));
  }

  return C * pr * r + C * pm * m;
}
```

## 截图
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item6-lg item6 pd0">
      <img src="/assets/i/2-1.png">
    </div>
    <div class="x la item6-lg item6 pd0">
      <img src="/assets/i/2-2.png">
    </div>
    <div class="x la item6-lg item6 pd0">
      <img src="/assets/i/2-3.png">
    </div>
  </div>
  <p>图1：北极地面点的日出(视线Y=1)。图2：正午远处。图三：位于15KM处。经过伽马矫正和色调映射。</p>
</div>