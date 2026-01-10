---
layout: page
title:  "GI优化技术"
author: mosfet
category: rendering
tags: 全局照明 优化
---

## 辐射度——下篇
辐射度基础中的一些未解释的细节(在当时无需强调)(以及少量错误)可能在这里说明，因为值得在实践中被反复强调和理解，目前暂时在本文进行补充和引导。  
笔者习惯上避免重复提及先验知识。事实证明，蒙特卡洛方法的证明链接相当复杂，您总是需要阅读大量材料才能保持知识。  
本文还是辐射度基础的正式下篇，以下内容除非有必要迁移至第一部分，则分开进行整理。  

#### Recall
下面摘录的一些公式链可能有用，尽管我们曾经给出了有关结论。事实证明，理解这些几何转换很重要。  
对于球极系的两个角，大多文献通常符号约定为`θ,φ`，笔者常用`P(olar),A(zi)`。  
选取`θ`(弧制)作为格时，您需要从圆周取一部分代表`dθ`。  
```ruby
# 4.14
θ=circ/1
σ=A/1²     # 下列记号全部使用r=1，出现1可替换为任何半径

# 要将表面积转为σ(立体角在单位球描述)，您需要除以R²
# 而dθdφ 旋转取得的(分别绕成近似矩形长、宽的曲线)面积缩放后即可得到dσ的值
# 为了积分立体角，必须转为∫∫dθdφ，我们可以简单证明该测量为4PI
dArea = (rdP)(rsinPdA) = r²sinθdθdφ
dσ    = dArea/r² = sinθ dθdφ

# 4-50 投影效应，若给出整个球面的球面度，则下面的表达式积分为PI，即投影圆的面积
AreaProject = cosθdσ
```

#### 辐射强度
`辐射强度(radiant intensity)`的定义是`I(σ) = ΔΦ/Δσ`，等于立体角上的光谱功率。在这里是一个不常用的术语。  

#### CDF
`cumulative pdf`指PDF的积分累积函数(累积单位概率)，通常用大`P(x)`表示。  

#### CDF逆方法选择事件
可以均匀地划分CDF的域，如每隔1/10，并检查每段概率的累积情况。  
考虑一个均匀随机数`ξ = rand()`落在CDF的像上，求反找出划分的域在哪里，并且进行插值近似。  
表达式上这是`select_domain = CDF^-1(ξ)`，这称为`逆方法(inversion)`(14.4, 5-28 etc)。  

#### 二分方法选择事件
递归求解CDF相等(50%)的地方，停留在合理的深度。然后递归依次产生ξ检查(>0.5)，选择一侧区域，并在该最小的细分区域随机均匀生成一个样本。  
对于复杂曲线，求解CDF中点可以使用数值估计完成任务。  

#### 圆极系采样(逆方法)
为了在极系的单位圆内均匀采样，可以采取以下方式：  
```ruby
# 5-30
# dθ小圆弧(在特定r上)，dr环距，同样以下假设r = 1
A_measure = ∫∫r0..1|rdrdθ = Pi if maxR =1  # 0..1|r²/2 * [2Pi]
prob   = p(r,θ)drdθ = (1/PI)rdrdθ  
# pdu = 1/A * rdu 
# 注解：左侧是特定du概率，右侧是实际矩形 被均分为PI份。可能有道理。即概率 = 均分面积的表达式？
p(r,θ) = r/Pi = p(r)p(θ)
# use marginal pdf to get
p(θ) = 1/2Pi  && P^-1 = 2PIξ1
p(r) = 2r     && P^-1 = sqrt(ξ2) # *R  ?
```
**Marginal Density Functions**  
```ruby
# 5-41
# sampling triangle?
ξ1a + ξ2b + ori reflect if 1-ξ1ξ2 < 0
```
更好，`边缘密度函数(marginal density functions)`。  
```ruby
p(x)   = ∫p(x,y)dy  # marginal  DF
p(y|x) = p(x,y)/p(x)# condition DF
# check examples in 5-43!
```
```ruby
# 14.4.1
P = ∫∫p(θ,φ)sinθdθdφ     # sinθ由dσ引入
Pol = acos((1-ξ1)^1/n+1) # 通常指数中n=1
Azi = 2Piξ2
dir = ... eval polar
```

#### 球位系均匀逆方法
```ruby
# 我们之前已经证明平面单位圆极系的PDF，那么球呢，必须满足
∫sphere|pdσ = 1  => 1/4PI sindxdy => p(x,y) = sinθ/4pi
# 为了得到方位角，使用margin，这只是
p(φ) = (2) * 1/4pi = 1/2pi
# 为了得到polar，使用margin，这只是
p(θ) = sinθ/2
```

#### cone
```ruby
# spherical luminaire/ cone sampling
dist = len(c-x)
sinα = R/d or cosα = sqrt(1 - sinα²)  # α最大半边角度 α = asin/ acos
# 均匀密度
q = 1/ 2Pi(1-cosα)
cosθ = 1-ξ1+ξ1cosα                    # 确定后，可知uvw中的采样位置
   φ = 2PIξ2
q = p(x2)cosθ2 / len(x, x2)           # 球面上的点
p(x2) = cosθ2 / 2PIlen(x,x2)(1-cosα)
```

#### 拒绝方法
拒绝方法：圆内点，单位方向等(14.4.2, 5-34 etc)。  

#### Metropolis(14.4)

#### 自然的度量
(请无视)选择"自然"的度量可能是棘手的部分(14.1.2)：子度量`du = d * ...`的点集不应该随着该测量单位的空间系变换而改变结果。  

---
## 参考1
熟悉[《Ray Tracing: The Rest of Your Life》](https://raytracing.github.io/books/RayTracingTheRestOfYourLife.html)这本书的读者可能记得Peter Shirley列举了几种重要性采样的实践，如朗伯的处理。除此之外第六章开始的方法似乎也不寻常，如果您理解了全局光照的问题，则可以理解各种方法的合理性。我在这里再次强调理解问题本身更重要，而不是推崇某种解决方案，读者需要自己理解可行性并决定自己的使用偏好。  
若不清楚选择PDF以及采样行为对结果的不同影响，请见光线追踪一文。  

朗伯体的常数反射率告诉我们它本质是一个公平的光源。  
这不影响渲染方程，剩下的投影效应引入了光照衰减，积分的形状带有cos项，为了找出更匹配该形状的PDF，  
我们推导：  
```ruby
EST = [R/PI Licos dvi] / ?p
∫hs|Ccosdu = 1 thus C = 1/Pi thus pdf = cosvi / Pi
EST = Li * R
```
注意，为了匹配PDF，您的样本(反射方向)必须按照该分布产生。  

<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item3-lg item12 pd0">
      <img src="/assets/i/4-1.png">
    </div>
  </div>
  <p>图1：结果(也许会更新)</p>
</div>

第七章研究了遵循PDF在半球上生成对应分布方向的方法，利用一个非平行表面N的向量取两次Cross构成子空间系可以从任何表面参考发送此类随机数。  
第十章开头编写了PDF类，一是生成遵循了PDF的随机方向，二为查询特定结果的密度。这两者分别用于弹射dvi以及计算/pvi。  
对于灯光(或任何需要直接采样的东西)的PDF，则单独为其几何表面编写采样随机样本和pdf。  

混合密度方法使用以下公式：  
```ruby
pMix = w0p0 + w1p1 + ……
     #  ΣW = 1
# say
pM1 = 0.5pCos =+ 0.5pLight
```
正确使用的方式是，方向根据产生一个ξ并根据w的比重来随机选择一个即可。PDF的值由该具体方向询问两个PDF并进行W的配重混合得到。  
但我们的估值器是什么呢？"不想用阴影光线来解决任何给定点的直接照明问题，只使用向光源发送更多光线。"在这里是有道理的。  
因此只是渲染方程，这里有个微妙的细节，为了最后一项，在计算灯光时，`pdf2 = r²/cos/A`，而不是`1/A`。  