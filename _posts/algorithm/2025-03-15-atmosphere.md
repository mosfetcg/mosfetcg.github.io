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

p(cosθ) = (3/8Π) * (1-g²)(1+cosθ)/(2+g²)(1+g²-2gcosθ)^1.5
g = 0.76

# 左侧也是一个可选经验值。
vec3(21e-6)
```

## 积分
实践中，通常只使用黎曼积分以及单散射模型，S来源变为单条光线。  


地面点P0, 大气点P1。  
```ruby
L(p,ω) = ∫0..INF|T(p')S(p',ω)ds' 
    (1/e)^∫0..s'|σt(p'')ds''
    Le(p)+σs(p')∫S²|p(ω'->ω)L(p',ω')dω' # L = Lid+Lii
                            Li(p,ω')~= p(ω''->ω')L(p,ω'')/p(w'')

```
从视线出发采样分段P点，在P上采样阴影光线 在X每次采样阴影光线计算计算太阳光到达点X时的衰减。  
太阳光从太空射入，一路上只发生衰减（没有改变方向），直到在X点发生唯一一次碰撞，刚好改变方向射入人眼。  

地球半径很大(6300km)，大气高度很低(100KM)，我们看见的天空形状是一个很长很扁的弓形。朝着水平方向看见比完全垂直高度多得多的空间是很正常的。  

所有βE项将用于积分到`T`项。  
```ruby
Lo = ∫all_line_dx|T(p)S(p) dx #(该T沿着视线减弱)
# S(p) = σs(p)∫all_sphere|ρLi dv
```
```ruby
S(p)      =  σs(p)∫all_sphere|ρLi dv
appro_S(p)=                    ↑(C * T2) #(沿着太阳减弱)
          # 由于不再需要积分全球
          =  σs(p)ρ(C * T2(p))           # C是一个光照常数
          =  σs(p)ρ(C * ∫sun_dx_line|σs(p)dx)

# 并且我们发现T只是：
T(p) = exp(-  β(0)*∫all_line_dx|exp(-h/HR)dx)
                    ↑

# 现在合并为
Lo = C * ρ ∫all_line_dx|T(p)T2(p)βS(h)dx

# 另外我们可以合并T，T2到一个exp中
```
最后结果来自于两种散射贡献的和，可放在同一个循环中同步完成。  
```ruby
LoR + LoM
```
## 实现
```cpp
vec2 iSphere( in vec3 ro, in vec3 rd, in vec3 ce, float ra) {
  vec3 oc = ro - ce;
  float b = dot(oc, rd);
  float c = dot(oc, oc) - ra * ra;
  float h = b * b - c;
  if (h < 0.0) return vec2(-1.0); // no intersection
  h = sqrt(h);
  return vec2(-b - h, -b + h);
}
vec3 atmosphere( in vec3 ro, in vec3 rd) {
  const float sunbase = 15.0; // sunbase
  const float re = 6371e3; // unit: meter
  const float ra = 6471e3; // unit: meter
  const vec3 Rbeta0 = vec3(5.8e-6, 13.5e-6, 33.1e-6); // unit: /m
  const vec3 Mbeta0 = vec3(21e-6);
  const float hr = 8e3;
  const float hm = 1.2e3;
  const float g = 0.76;

  // 将输入位置参考到地球中心的位系中，地面处为半径高，任何ro的大气高度为ro - re
  ro += vec3(0.0, re, 0.0);
  float t = iSphere(ro, rd, vec3(0.0), ra).y; // ro -> t

  // 求解方程分解为固定段的积分
  float segement = 16.0;
  float dx = t / segement;

  // 计算常数
  vec3 sd = sun_rd; //??
  float cos_theta = dot(rd, sd);
  float Rphase = 0.0597 * (1.0 + cos_theta * cos_theta);
  float Mphase = 0.1194 * (1.0 - g * g) * (1.0 + cos_theta * cos_theta) /
    ((2.0 + g * g) * pow(1.0 + g * g - 2.0 * g * cos_theta, 1.5));

  vec3 R = vec3(0.0), M = vec3(0.0); // 重复mie
  float R_tmp = 0.0, M_tmp = 0.0; // 重复mie

  for (int i = 1; i <= int(segement); i++) {
    float h = length(ro) - re;
    // 只要光线割到地球就被大地遮挡，而这相当于length(ro) < re
    if (h < 0.0) return vec3(0.0);

    // 优化1：存储消光量的衰减部分，减少exp调用
    float Re = exp(-h / hr), Me = exp(-h / hm);
    R_tmp += Re * dx;
    M_tmp += Me * dx; // 重复mie

    // 计算T2(发射sd)
    float segement2 = 8.0;
    vec3 ro2 = ro;
    float t2 = iSphere(ro2, sd, vec3(0.0), ra).y;
    float dx2 = t2 / segement2;
    float R_tmp2, M_tmp2 = 0.0; // 重复mie
    for (int j = 1; j <= int(segement2); j++) {
      float h2 = length(ro2) - re;
      // 考虑太阳在背面是有可能割到并遮挡的，但这样会失去漂亮的黄昏
      // if (h2 < 0.0) return vec3(0.0);

      R_tmp2 += exp(-h2 / hr) * dx2;
      M_tmp2 += exp(-h2 / hm) * dx2; // 重复mie

      ro2 += sd * dx2;
    }

    vec3 RTT2 = exp(-Rbeta0 * (R_tmp + R_tmp2));
    vec3 MTT2 = exp(-Mbeta0 * (M_tmp + M_tmp2) * 1.1); // 重复mie 消光 S*1.1

    // 累积到结果，注意R只是积分项。优化2：并且我们将Rbeta0 * Re的常数部分移动到外面
    R += RTT2 * Re * dx;
    M += MTT2 * Me * dx;

    // 之后再移动
    ro += rd * dx;
  }
  return sunbase * (Rphase * R * Rbeta0 + Mphase * M * Mbeta0); // 建议在外部输出时clamp
  return sunbase * Mphase * M * Mbeta0;
  return sunbase * Rphase * R * Rbeta0;
}
```

## 截图
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item5-lg item12 pd0">
      <img src="/assets/i/6-1.png">
    </div>
  </div>
  <p>图1：地平线：雷利+米氏散射</p>
</div>