---
layout: page
title:  "03calculusExt"
author: mosfet
category: math
tags: academic hidden 微积分
---

注意本文属于数学核心标准(**academic**字样)的沿续。  

---
```
Differential Calculus     不在本文范围
Integral Calculus         REST✅
Multivariable calculus    不在本文范围
```

## 表达式快速参考
```
```

## IC3. 应用
#### 不当积分(improper integrals)
形如**∫1..INF**的积分，一解法是将上限视为常数，并嵌套到lim中逼近INF，从而简化表达式。  
一个例子如下：  
```ruby
limn->INF| [∫1..n|x^-2 dx] = AD(n)-AD(1) = 1-1/n = 1
```
不同不当积分取决于图形，可能聚集收敛(convergent)，或者散化(divergent)变成INF。  

#### 积分求解其区域均值
除以(b-a)即可。  
积分均值定理(mean value)指出平均高度的点必定存在。  

#### 积分速率的直觉
我们在这里再次强调这种直觉，即积分第二定理，该积分等于原函数变化量。  
定积分旨在解决累计问题。  

---
## 通用翻译
```
不当积分|improper integrals
聚集 散化|convergent divergent
```

---
## 关于总和清单
锁定的，一定不用再看。
其他打勾的，基本上按原则检查完了。以后也不用看了。26.9.25
微积分除了DC,MC,IC其他都是重复的。  
总之，这次更新、简化之后完成了。  
```
DC MC IC✅
```