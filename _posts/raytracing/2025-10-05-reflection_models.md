---
layout: page
title:  "反射模型"
author: mosfet
category: raytracing
tags:
---

<style>code:not(pre code) {color:green!important}</style>

## 反射的属性
反射（Reflection）是指入射到表面上的光与该表面发生相互作用，从而在不改变频率的情况下离开入射侧的过程。  

光谱反射（Spectral Reflection）  
物体的最终颜色是由光源的光谱分布与材质的反射光谱在各个波长上相乘决定的。如果光源是均匀的白光，所以结果完全取决于材质本身的反射特性。这个物体最终在视觉上会呈现出蓝色。
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item5-md item6 sk bgw mgb3">
      <img src="/assets/m/pt1-11.png">
    </div>
  </div>
</div>

## 反射方程(reflection Equation)
回忆，计算入辐照度时我们知道每条入辐射度带来的dEi。  
BRDF查询了将该功率反射到特定方向辐射度(部分值dLo)的反射率，我们可以得到著名的反射方程。回答，在光照条件下，该辐射度一共是多少？
```ruby
                dEi(p,ω) = Li(p,ω)cosθdω
Lo(p,ωo) = ∫Ω²|fr(p,ωi->ωo)Li(p,ωi)cosθidωi
fr(p,ωi->ωo) = dLo(ωo)/dEi(ωi)             # 其他符号：ρ
```
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item5-md item6 sk bgw mgb3">
      <img src="/assets/m/pt1-12.png">
    </div>
  </div>
</div>

`▼`注意，如果图例只标注了Li，但本质需要计算dEi。通常符号是Li以及dLo。  
BRDF的单位是1/sr。  

## BRDF属性
线性（Linearity）复杂的反射现象可以通过多个简单反射成分的叠加（相加）来组合表达。以合并反射瓣。  
亥姆霍兹光路可逆性（Helmholtz Reciprocity）fr(ωi->ωo) = fr(ωo->ωi)。  
能量守恒（Energy Conservation）物体表面反射的能量最大只能是 100%（全反射)。  

对于第三点的公式描述是出入辐照度之比**ρ**(Φo/Φi=∫/∫)小于1。即使BRDF是其子结构，也应该符合该条件。  

---
## TYPES1 
#### 反射
镜子只在镜面方向反射全部光。δ函数检查反射方向(从眼睛)是否接近光方向。除以cos以抵消方程中的余弦修正，因为镜子不会随着角度降低亮度。  
实现中，直接以该方向反射。  
```ruby
fr(ωo->ωi) = δ(ωi-R(ωo,n)) / cosθi
∫ = Li(ωi)
```

#### 反射+透射
可穿透光线、以及反射的材料。折射方向遵循斯涅尔法，发生全内反射时，只会反射。两者比例遵循菲涅尔方程(Schlick)。  
```ruby
frTrans = δ(ωi-T(ωo,n)) / cosθi
fr = Fresel * frMirror + (1-Fresel) frTrans
∫ = FrLi(p,R(ωo,n)) + (1-Fresel)Li(p,T(ωo,n))
```

这种公式写法很好，我们可以清晰看到一部分反射来自于反射，一部分来自于透射。  
色散更有趣，因为折射率与波长相关性（Wavelength-Dependent IOR），在光谱中更改折射率以实现。  

`▼`为了估值此积分，在估值器中，我们要将两个表达式离散抽样，解决积分项爆炸的困境。这看起来可能和单个函数/pdf的形式有点不同，总之，我们估值两个表达式之一就好。   
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item5-md item6 sk bgw mgb3">
      <img src="/assets/m/pt1-13.png">
    </div>
  </div>
</div>

#### 漫射
将接受辐照度向所有方向均匀发出的材料。BRDF是一个常数。结合第二条反射率方程，  
我们发现fr与其本身的**反射率ρ**(见上)有关。通常写为RGB分数。  
```ruby
Lo(ωo) = ∫frLi(ωi)cosθidωi = frE
ρ = LoΠ / E = (frE)Π / E = Πfr
   #积分辐照度  根据BRDF定义dlo/de替换Lo也可以
fr = ρ/Π
```

现实生活中的漫反射其实包含了更深层的物理机制，且几乎没有一种材质是完美的理想漫反射体。  
特殊的微表面分布：Bouguer理论认为，漫反射本质上也是由无数个极度粗糙、杂乱无章的微小镜面（Micro-facets）反射拼凑出来的宏观视觉效果。  
次表面反射：Seeliger理论更接近大多数绝缘体的本质。光线其实不是在表面直接弹开的，而是穿透进了材质内部（比如皮肤、塑料、大理石），在内部微粒之间发生无数次杂乱跳跃、散射后，才重新从表面弹射回空气中。  
多重表面或次表面反射：不论是微观表面的多次弹跳，还是内部微粒的多次散射，这些“多重碰撞”才是把光线的方向彻底打乱、形成均匀漫反射的幕后推手。  

压制的氧化镁粉末是目前在物理上最接近理想朗伯漫反射的材质。
在大入射角下几乎从不成立。即使是看起来再粗糙、再哑光的墙面或纸张，在入射角很大（即光线几乎擦着表面贴过来，或者你几乎贴着表面平视）的时候，它都会表现出明显的镜面反射（高光/反光）。  
