---
layout: page
title:  "像素画"
author: mosfet
category: miscellaneous
tags: 像素画
---

```
https://pixeljoint.com/forum/forum_posts.asp?TID=11299
```

### 理论1
`色調`是指该顏色（反射光）的身份。`飽和度`是顏色身份的強度。飽和度越低，顏色越接近灰色。使用过飽和的顏色，顏色就會像光谱開始**灼傷**眼睛，因为屏幕亮像素并不像绘画油漆那样看起来柔和。  
`發光度`（值，亮度）是顏色的光反射亮度。在給定的調色板中，您會希望擁有廣泛的亮度，高光，中间和暗区对差异范围称为对比度。發光與像素藝術尤其相關，相对亮度差异解释了三分照明结果的部分或绝大部分影响。（其他情况下，例如还应该乘光源使色相，饱和度对偏向也改变）

人眼色调感知取决于环境颜色而不是hue本身，例如，多种灰色中也可能使灰色的树木呈现绿色感觉，但我们只是推移了亮度。
对于亮度而言，亮度感知會根據其背景而顯得更亮或更暗。因此不會總是希望在每個亮點上使用最亮的顏色。一種可以在一個物體上形成良好亮點的顏色可能太亮而不能用在較暗的物體上。此外，亮度影响直线的粗细感知，在单位直线上具有渐变亮度的边缘看起来更细。
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item3-lg item6 pd0">
      <img src="/assets/g/2-1.gif">
    </div>
    <div class="x la item3-lg item6 pd0">
      <img src="/assets/g/2-2.png" style="height: 200px; width: auto ">
    </div>
   <div class="x la item3-lg item6 pd0">
      <img src="/assets/g/2-3.png">
    </div>
  </div>
  <p>图1：色彩</p>
</div>

### 理论2
像素画的重点在于像素——就这么简单。从小的画幅和调色板处着手，如果你不能用4种颜色制作出好的精灵图，那么使用40种颜色也无济于事。  
那么怎么开始图像呢？这完全取决于你。线条法+上色或者斑块覆盖两种方式都可以勾勒形状。覆盖并精炼附近区域。

### 理论3
①AA（抗锯齿）和抖动（dither）如下图。  
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item3-lg item4 pd0">
      <img src="/assets/g/2-4.jpg">
    </div>
    <div class="x la item3-lg item4 pd0">
      <img src="/assets/g/2-5.jpg">
    </div>
    <div class="x la item3-lg item4 pd0">
      <img src="/assets/g/2-6.jpg">
    </div>
  </div>
  <p>图2：抖动</p>
</div>

②`ramps`色板。一种可选技术，将不同材料颜色的高亮和暗色连接到一起，它们仅在中间形成差异因此可形成环状结构。  
有些艺术家发现该模型很有用。但重要的还是您要了解您的颜色关系是什么。  
③`hue shifting`色调偏移变换。色调变换是指对ramps的色调变换。没有偏移的ramp称为直ramp，只有亮度发生变化，而在色调转换的渐变中，色调和发光通常都会发生变化。色调转换时，将高光弯曲向某种颜色（在上面的例子中为黄色），并将较暗的颜色移向第二种颜色（蓝色）。色调转换可以在渐变中添加微妙的色彩对比度。
<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item4-lg item6 pd0">
      <img src="/assets/g/2-7.png">
    </div>
    <div class="x la item4-lg item6 pd0">
      <img src="/assets/g/2-8.png">
    </div>
  </div>
  <p>图3：Ramps和偏移</p>
</div>

---
## 绘制瓷砖
就大致过程而言，与计算渲染的着色相当类似。必须存在材质、表面以及光源和光反射的行为，场景光源可能是简单的单向光。  
在像素艺术领域，由于尺寸和色板限制，分布光照结果可能是三分的。  
通常会从线条开始找出暗边界。有时不会想到中间颜色的概念，只有二分着色，直接绘制另一种面表示"不暗/亮"的补集地方，再逐步添加细节即可。  

有一些尚不明确的原理经常被应用，如hsv色调变换，注意其合理性(对比)。  
在极简单情况下，纹理通常不存在，因为根本没有颜色表示它们，通常双色抖动变换被认为是其领域的一种唯一纹理，完成棋盘，格子。  
否则，需要在光照之外指定另一些自身的颜色。  
我建议瓷砖的绘制介于两者之间，将纹理降级为某些颜色的组合，如果表面特别粗糙，也可以直接将三分光照降级为颜色组合形成纹理。  

<div class="x gr txac">
  <div class="x la flex mg0">
    <div class="x la item3-lg item6 pd0">
      <img src="/assets/g/2-9.jpg">
    </div>
    <div class="x la item3-lg item6 pd0">
      <img src="/assets/g/2-10.jpg">
    </div>
  </div>
  <p>图1：</p>
</div>
你可能需要掌握一些技巧来绘制。  

