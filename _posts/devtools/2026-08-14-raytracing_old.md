---
layout: page
title:  "RT旧文"
author: mosfet
category: devtools
tags:
---

本文需要修改。目前最重要的依赖理论已基本被转移，各个部分可能直接从引用它们开始，当然也会引入一些专有术语，这些术语仍然被唯一地首次定义。除此之外，下文的介绍侧重点在于代码以及解释其数学计算。  

---
#### 光学基础
**光的本质和辐射**  
基本粒子`光子(photon)(意味光)`无质量且以光速移动。光子是典型显示`波粒双重性(wave–particle duality)`的粒子。  
`能量(energy)`以任何双重性之一形式在空间或媒介物质中`发射和传输(emission or transmission)`称为`辐射(radiation)`。  
有几种辐射类型。`电磁辐射(electromagnetic)`是大多数光子的类型，区别是波长和能量不同(注意它们只是光子)。例如无线电，可见光，不可见光、X-Y射线等。第二是其他粒子运动构成的粒子辐射，二重性的优先性与其能量有关。声辐射完全依赖于介质，例如声波。最后是引力辐射。  
高能量的粒子会导致一个或多个电子脱离原子，称为电离，这一动作需要这些辐射提供相对较高的能量。较低能量确实分解分子而不是原子；引起振动，从而被感知为热量。无线电波长及以下波长通常不被认为对生物系统有害。  
**辐射一词源自波从源辐射(即向各个方向向外传播)的现象**。这方面导致了适用于所有类型辐射的测量和物理单位系统。由于这种辐射在穿过空间时会膨胀，并且由于其能量守恒，辐射强度都会遵循衰减规律。  
**光学**  
`光学(optics)`分为两个主要分支`几何光学(geometrical(ray) optics)`、`波动光学(physical(wave) optics)`。  
几何光学总结了光的经验发现和几何特征(在大尺度上)。光线沿直线传播，受不同介质界面处的`law of 反射(reflection)和折射(refraction)`支配。例如，镜面反射描述了镜子等表面的光泽度，它以简单、可预测的方式反射光。漫反射描述的是无光泽的材料，例如纸张或岩石。这些表面的反射只能用统计方法描述，反射光的精确分布取决于材料的微观结构。  
另一种研究光的波动。几何光学无法解释的现象。因波的相互作用波形增亮变暗的`干扰(superposition interference)`和`衍射(diffraction)`；  

现代物理学认为光是质量与能量的转换介质，并且存在极限。光子甚至从由正反粒子的湮灭现象产生。光子可以产生物质。  
照相的图像或者视觉通过感知这类辐射量转换为信号产生。  

---
#### 1. 渲染方程
请先检查辐射度理论。并理解为何用光线积分它们。本文将路径追踪、光线追踪等等术语视为等同。  
渲染方程很好，积分入射光线并反射到相机，并通过递归寻找入射光线的实际值直到发现光源。  

另一种程序上的代替方式是循环和散射。即通常从`albedo(1.0)`开始的原因。首先是堆栈递归受到硬件限制，第二是光路是双向的，意义取决于上下文，这其实不会带来太大问题(尽管两个方向不应该具有相同的辐射度)。  
因此，我们总是提到的散射模型仍然表达同一个渲染方程，但解释可能略有所不同。例如，我们可以说积分入射，是积分散射，采样散射。  
如果你问这有什么区别以及是否相同，我也不能回答这个问题。  
```ruby
# 可以暂时使用此模型。注意其双向。
L = ∫sphere|  ρ(i,o)    Lcosθ             dv 
                   等待求解或直接发出    入射或散射
  ~= g/p
# ρ充当光线过滤器，L项是我们乘以上一个表面颜色的原因
```
`散射(scattered)`是辐射由于介质不均匀被迫偏离轨迹(或者某种偏差)的物理过程。  

---
#### 2. 路径追踪
`材质(materials)`提供表面的BRDF类型以及着色用属性。一个核心属性是`反照率/白度(albedo)`，白度第一在路径追踪时充当光源`L`的波长，另外也在特定的BRDF中视为影响**其**`反射率(Reflectance)`的因子，因此反射后光的波长会改变并呈现不同的颜色。  
基本的三种材质包括金属、漫反射以及电介质。请见材料。  
```cpp
vec3 transport( in vec3 ray_origin, in vec3 ray_path) {
  // 初始反照率
  vec3 albedo = vec3(1.0);
  int i, id;

  for (i = 1; i <= RT_RECURSION; i++) {
    vec3 normal;
    float k = scene(ray_origin, ray_path, id, normal);

    if (k < INF) {
      vec3 p = ray_origin + k * ray_path;
      bool front_face = H_set_faced_normal(ray_path, normal);
      Material material = object_mat(id, p, normal);

      if (material.mid == M_LAMBERTIAN) {
        Lambertian(material, normal, ray_path, albedo);
      } else if (material.mid == M_METAL) {
        Metal(material, normal, ray_path, albedo);
      } else if (material.mid == M_FUZZMETAL) {
        FuzzMetal(material, normal, ray_path, albedo);
      } else if (material.mid == M_DIELECTRIC) {
        Dielectric(material, normal, ray_path, front_face);
      } else if (material.mid == M_LIGHT) {
        Light(material, albedo);
        break;
      }
      ray_origin = p;
    } else {
      // 未命中对象退出
      albedo *= sky(ray_path) * ENV_LIGHTSOURCE;
      break;
    }

  }
  // 标记超过堆栈大小的光线
  if (i == RT_RECURSION) return vec3(0.0);
  return albedo;
}
```

---
#### 3. 场景相交测试
```cpp
float k = scene(ray_origin, ray_path, id, normal);
if (k < INF) {
  vec3 p = ray_origin + k * ray_path;
  bool front_face = H_set_faced_normal(ray_path, normal);
  Material material = object_mat(id, p, normal);
}
bool H_set_faced_normal( in vec3 ray_in, out vec3 outward_normal) {
  bool front_face = dot(ray_in, outward_normal) < 0.0;
  outward_normal = front_face ? outward_normal : -outward_normal;
  return front_face;
}
```
##### 3.1. 光线移动
光线交叉测试使用特定曲线(直线)的一般参数形式`p(k) = o+kd`。  
它与其他几何体的交集表明交点存在的`k`，对于某些立体形状产生两个解。实际处理时，必须小心忽略负值(光线后方的交点)、以及找出所有对象中最小的值，并且应该避免EPS精度问题(见下)。  
找到特定几何体的解析`k`很简单，假设`p(k)`运行到表面上并寻找相应的解析表达式来计算每个`k`。  

**例子：球体推导**  
由于本质上只有`k`是未知的。因此几乎总是可以轻松解析表达式，只是需要大量变量。  
```ruby
length(P) = r
  (P)·(P) = r²
  && P = ray(k)
# k是一个二次表达式
root = -b ± sqrt( discriminant=b*b-4ac )   /2a

# 回忆判别式：
# + 存在两个值
# 0 存在一个非常特殊的值
# - 不相交
```
```cpp
float iSphere( in vec3 ro, in vec3 rd, in vec2 B, inout vec3 normal, in float radius) {
  // r*r = dot(rayp,rayp) -> A=k^2B+2kC+D where A=r^2,B=dot(rd,rd),C=dot(ro,rd),D=dot(ro,ro)

  float a = radius * radius;
  float b = dot(rd, rd);
  float c = dot(ro, rd);
  float d = dot(ro, ro);

  float discriminant = (2.0 * c) * (2.0 * c) - 4.0 * b * (d - a);
  if (discriminant < 0.0) return INF;

  // By default, choose the nearer solution in front of any ray
  float root_part = sqrt(discriminant);
  float root = (-2.0 * c - root_part) / 2.0 / b;
  // Not available, try another one, while checking B of both of them
  if (root < B.x || root > B.y) {
    root = (-2.0 * c + root_part) / 2.0 / b;
    if (root < B.x || root > B.y) return INF;
  }

  normal = (ro + root * rd) / radius;
  return root;
}
```
##### 3.2. 处理标准向量
由于我们找到了`k`，则表面交点已知，为了产生着色用的外标准向量，直接标准化`P-0`即可。  
为了使着色模型有效，理由请见材料。请为`out_n`在与`v`同向时(通常是内部)，翻转`n`以符合着色模型。就像上面的代码所做的那样。  
##### 3.3. 阴影痤疮(Shadow Acne)
当射线与表面相交时，它将尝试准确计算交点。这种计算很容易受到浮点精度的影响导致交点稍微偏离(从偏移位置反射)。  
假设光线落在表面上下偏移处，这将导致一些奇怪的命中情况。  
由于这种精度问题不可避免，并且这种情况下的参数值不是我们想要的，所以忽略它们。  

---
#### 4. 采样
这里的关键是视口中的点真的只是一个点，我们应该为整个像素平均生成光线。  
渲染图像中边缘的粗糙阶梯性质称为`aliasing`。真正的相机拍摄照片时，通常不会出现，因为边缘像素是一些前景和一些背景的混合。世界的真实图像是连续的。世界（以及它的任何真实图像）实际上具有无限的分辨率。我们可以通过对每个像素的一堆样本进行平均来获得相同的效果。  
```cpp
void main() {
  vec4 integral = texture(u_self, vec2(tex.x, 1.0 - tex.y));
  vec4 frame = vec4(clamp(linear_to_gamma(eval_pixel(tex, u_time)), 0.0, 1.0), 1.);
  fragColor = integral + frame;
}

vec3 eval_pixel( in vec2 st, in float t) {
  // 先在本地设置好(包括采样光线)，再在追踪光路前应用
  camera_rotation = rotate(u_angle);

  // 散焦 - 镜片视点 - 焦长 - 角度
  const float focus_dist = 2.0; // 同时作为焦距
  const float lens_angle = 0.0;
  float lens_radius = tan(H_radian(0.5 * lens_angle)) * focus_dist; // XY

  st = st * 2.0 - 1.0;
  if (VIEWPORT_AMEND) st.x *= u_res.x / u_res.y;

  const float vfov = 40.0;
  vec3 camera = vec3(0.0, 0.0, -20.0 + u_z);
  float viewport_y = tan(H_radian(0.5 * vfov)) * focus_dist;
  float viewport_x = viewport_y;

  st *= vec2(viewport_x, viewport_y);
  vec2 half_pixel = vec2(viewport_x, viewport_y) / u_res;

  // 分层采样(多个样本)
  const float RT_JIT_GRID = 3.0;
  st -= half_pixel;
  half_pixel *= 2.0 / RT_JIT_GRID;
  vec3 pixel; // sample corner to corner
  for (float x = 0.0; x < RT_JIT_GRID; x++) {
    for (float y = 0.0; y < RT_JIT_GRID; y++) {
      vec3 lens_origin = camera + vec3(lens_radius * H_disk_random(), 0.0);
      vec3 viep_hole = camera + vec3(st + vec2(x * half_pixel.x * rand(), y * half_pixel.y * rand()), focus_dist);
      vec3 rd = normalize(vec3(viep_hole - lens_origin));
      rd = camera_rotation * rd;
      lens_origin = camera_rotation * lens_origin;
      pixel += transport(lens_origin, rd);
    }
  }
  return pixel / (RT_JIT_GRID * RT_JIT_GRID);
}

vec2 H_disk_random() {
  return vec2(rand(), rand()) * 2.0 - 1.0;
}
float H_radian( in float angle) {
  return C_PI * angle / 180.0;
}
```

##### 4.1 散焦模糊
请务必仅在光线追踪中使用**场深**术语`散焦模糊(Defocus Blur)`。  
真实相机中出现散焦模糊的原因是因为它们需要一个大孔，而不仅仅是`针孔(pinhole)`来收集光线。大孔会使所有东西都散焦，但是如果我们将透镜放在`胶片/传感器(film/sensor)`前面，就会有一定的距离让所有东西都聚焦。放置在该距离处的物体将出现在焦点上，并且距离该距离越远，就会线性地显得越模糊。
可以这样考虑光线：此距离到透镜之间产生的光线一定准确弯曲到传感器上的某个位置。  
**焦长**描述完美对焦距离，含义通常与焦距不同，但如果我们只想把视口创建在焦平面上，则两种距离实际上相等。  
`薄镜片近似(Thin Lens Approximation)`可以用来模拟散焦，无限薄的圆形镜片发出光线，视口上的所有内容都处于完美对焦状态。光线两端都从镜片上随机采样。  

在没有散焦模糊的情况下，所有场景光线均源自视点。为了实现散焦模糊，我们构建一个以视点为中心的圆盘。半径越大，散焦模糊程度越大。原始相机是具有半径为零的散焦盘(没有模糊)，因此所有光线都源自盘中心。  
散焦盘应该多大呢？它控制获得多少散焦模糊，因此可以将圆盘的半径作为相机参数，但模糊效果会根据投影距离而变化。一个稍微简单的参数是指定锥体角度，其顶点位于视口中心，底部的散焦盘位于视点。当改变给定镜头的焦长时，这应该会带来更一致的结果。我们从散焦盘中选择随机点，以便相机从散焦盘发出光线。
##### 4.2. 成像颜色校正
一个问题是颜色。球体现在吸收每次反射的一半能量，这在现实生活中应该看起来非常明亮才对。如果把不同反射率的结果一起看，中间的渲染太暗，而70%的反射器更接近中灰色。  
原因是几乎所有计算机程序都**假设**图像在写入图像文件之前经过`伽玛校正(gamma corrected)`。即值在存储为字节之前会应用一些变换。  
写入图像未经变换的数据称为`线性空间(linear space)`数据，否则在`伽马空间(gamma space)`中。  
图像查看器可能期望伽玛空间中的图像，但我们使用前者。这就是我们的图像显得不准确的黑暗的原因。  
图像应该存储在伽玛空间中有很多充分的理由，但现在我们要把数据转换成伽马空间，以便查看器更准确地显示。使用伽玛校正后黑暗到明亮更加一致。  
```cpp
vec3 linear_to_gamma(vec3 v) {
  return pow(v, vec3(1.0 / 2.2));
}
```

---
#### 5. 材料
经典照明模型考虑光线从交点指向光源、并且标准向量与其同半球向构成的表面结构上。我们的设计也是有道理的，我们可以将光路中最后散射到的表面指向当作光源，因此光线朝着标准向量进入某种程度上正确的，但最好从辐射度角度来看。  
```cpp
struct Material {
  int mid;
  vec3 albedo;
  float refraction_index;
  float fuzz;
};
bool H_nearlly_zero( in vec3 vec) {
  const float limit = 1e-6;
  return (abs(vec.x) < limit) && (abs(vec.y) < limit) && (abs(vec.z) < limit);
}
vec3 H_random_on_hemisphere( in vec3 normal) {
  vec3 unit_sphere = H_random_unit_vector();
  if (dot(unit_sphere, normal) > 0.0) { // In the same hemisphere as the normal
    return unit_sphere;
  } else {
    return -unit_sphere;
  }
}
```

##### 5.1. 半球漫反射
`漫反射/漫射/扩散/哑光(diffuse/diffuse materials/matte)`物体表面大多是粗糙的。其微型结构可能导致光线以任何方向进行随机散射。或者被转化到热能吸收。  
若三束光线发送到两个漫反射表面之间的裂缝中，它们将具有不同的随机行为。吸收或反射多少，完全取决于漫射物体。  

最简单的漫射使照射到表面的光线在*远离*表面的任何方向上都有相同的概率反弹。  
```cpp
rayd = H_random_on_hemisphere(rec_n);
```
##### 5.2. 朗伯漫反射(9.4)
再次回忆提醒朗伯着色指出这样一个情况。物体表面被照亮的强度随着远离垂直方向而衰减，直面处光亮最大，反之，平行平面的光都消散了。
同时参考我们的辐射度理论，这是完全有道理的！  
我们同样可以实现不均匀的漫反射，而不是半球漫射。这种反射模型更加符合现实情况。  

现在我们要让散射到每个方向的概率呈现它们的余弦正比概率分布。即相对地更有可能选择到接近标准向量方向(=1)的散射方向，减少平行方向的概率。简单地通过向标准向量顶端上的一个单位球进行二次位移获得。您可以检查下图来验证这一点。  
```
\ |1
 \|----0.0
    
  / 1 \
 s--n  | scat = n + rand = s-p
  \ 1 /
----.p---
```
注意散射向量长度取决于此图形上的距离`s-p`。  
```cpp
void Lambertian( in Material self, in vec3 rec_n, out vec3 rayd, out vec3 albedo) {
  rayd = rec_n + H_random_unit_vector();
  if (H_nearlly_zero(rayd)) rayd = rec_n;
  albedo *= self.albedo;
}
```
由于光集中反射到垂直方向，反射到相机的可能更少，上看去更暗。球体下方的阴影更明显，因为更多地"被遮挡了"。并且球体顶部应该更呈现天空颜色。  
但是没有很多常见的日常物体是完全漫射的，通过了解更多不同漫反射方法对场景照明的影响，可以获得宝贵的见解。  

##### 5.3. 镜面反射(Mirrored Light Reflection)
`抛光金属(polished)`不会随机散射。因此关键问题是如何从金属镜反射。我们以入射相对标准向量完全相同的角度对称射出。  
我们将标准向量缩放到与其入射光线齐平，即使标准向量的长度成为其投影值，在这个比例构成的三角形内，反射光线很容易计算出来。两倍投影标准向量加上入射光线射线。  
```
\ray_in       |      v\
 \ | /ray_out |      | \
  \|/         |b     |  \
---.p---               n-\
   n\  |b            cos = v·n/len(v) = proj/hypo
    v\ |             proj= v·n/len(v)*len(v) = v·n
      \|             ray_out = v- 2proj n
```
```cpp
// v - 2dot(v,n)n
vec3 M_reflect( in vec3 v, in vec3 n) {
  return v - 2.0 * dot(v, n) * n;
}
void Metal( in Material self, in vec3 rec_n, out vec3 rayd, out vec3 albedo) {
  vec3 reflected = M_reflect(rayd, rec_n);
  rayd = reflected;
  albedo *= self.albedo;
}
```
##### 5.4. 模糊镜面反射(Fuzzy Reflection)
镜面反射可以添加一些随机性偏移，在散射光线终端向一个单位球体移动。因此会导致眩晕。  
散射光线的长度非常不一样，如果要使用该效果，则对它们统一归一。  
一般来说，球体越大，反射就越模糊。  
```cpp
void FuzzMetal( in Material self, in vec3 rec_n, out vec3 rayd, out vec3 albedo) {
  vec3 reflected = M_reflect(rayd, rec_n);
  reflected = normalize(reflected) + H_random_unit_vector() * self.fuzz;
  rayd = reflected;
  if (dot(rayd, rec_n) > 0.0) albedo *= self.albedo;
}
```
##### 5.5. 电介质
我们提供了一个手工计算折射角度的方式。接下来，应用一些菲涅尔的反射率，概率会自动处理结果的分配，这里使用的是石里克近似(Schlick Approximation)。  
当然，我们知道，如果选择的折射不可用，则必须选择反射。  
```ruby
sinv*rfrom = sinV*rto
#-----------
 v\ |
   \|     n
  ---
    |\V   N
# 将V分解为垂直和平行于N的部分
Vperp = ratio(v+cosv*n) | cosv=dot(-v,n)
Vpara = -sqrt(1.0 - Vperp²) *n
V     = Vperp + Vpara
```
```cpp
// ...
vec3 M_refract( in vec3 v, in vec3 n, in float ratio) {
  float cos_v = min(dot(-v, n), 1.0);
  vec3 perp = ratio * v + ratio * cos_v * n;
  vec3 para = (-sqrt(abs(1.0 - dot(perp, perp)))) * n;
  return perp + para;
}
float M_schlick_reflectance( in float cos_v, in float from, in float to) {
  float r0 = (from - to) / (from + to);
  r0 *= r0;
  return r0 + (1.0 - r0) * pow((1.0 - cos_v), 5.0);
}
void Dielectric( in Material self, in vec3 rec_n, out vec3 rayd, in bool rec_front_face) {
  float from = rec_front_face ? 1.0 : self.refraction_index;
  float to = rec_front_face ? self.refraction_index : 1.0;
  float ratio = from / to;

  float cos_v = min(dot(-rayd, rec_n), 1.0);
  float sin_v = sqrt(1.0 - cos_v * cos_v);
  // vec3 refracted_or_reflected = ratio * sin_v > 1.0 ? M_reflect(rayd, rec_n) : M_refract(normalize(rayd), rec_n, ratio);
  vec3 refracted_or_reflected = (ratio * sin_v > 1.0 || M_schlick_reflectance(cos_v, from, to) > rand()) ? M_reflect(rayd, rec_n) : M_refract(normalize(rayd), rec_n, ratio);

  rayd = refracted_or_reflected;
}
```
**模拟水环境**  
对于折射率大于空气的球体，无论如何不存在会产生完全内反射的入射角。这是由于球体的几何形状造成的，因为扫视角的入射光线总是会弯曲到较小的角度，然后在退出时弯曲回原始角度。那么我们如何说明完全内反射呢？如果球体的折射率小于其所在介质的折射率，那么我们可以用浅扫视角撞击它，获得完全外反射。这应该足以观察效果了。  
我们将模拟一个充满水的世界(`1.33`)，并将球体材质更改为空气(`1.00`)，一个气泡！  
可以看到或多或少的直射光线发生折射，而扫视光线则发生反射。  
```cpp
glass.refraction_index = 1.0 / 1.33;
```
**空心玻璃球**  
空心玻璃球是一个具有一定厚度的球体，如果你考虑一下光线穿过这样一个物体的路径，它会撞击外球体，折射，撞击内球体（假设我们确实击中它），第二次折射，然后穿过内部的空气。然后它将继续前进，撞击内球体的内表面，折射回来，然后撞击外球体的内表面，最后折射并退出回到场景大气中。  
外球体仅使用标准玻璃球进行建模，折射率约为`1.50`（模拟从外部空气到玻璃的折射），内球体有点不同，因为它的折射率应该相对于周围外球体的材料，从而模拟从玻璃到内部空气的过渡。  
这实际上很容易指定，因为材料参数可以解释为物体的折射率除以封闭介质的折射率的比率。内球体的空气（内球体材料）的折射率高于玻璃（封闭介质）的折射率，即`1.00/1.50=0.67`；  

---
#### 6. 灯和纹理
纹理，不需要介绍。集成在材料中。  
```cpp
vec2 TXRM_spherical( in vec3 n) {
  float polar = acos(-n.y);
  float azimuthal = atan(-n.z, n.x) + C_PI;
  return vec2(azimuthal / (2.0 * C_PI), polar / C_PI);
}
```
早期的简单光线追踪器使用抽象`光源(lighting)`，例如空间中的点或方向。  
现代方法通常将`发光材料(emissive materials)`视为相同的几何对象，命中时它告诉我们最初的光线是什么样子并停止，就好像"发光"。  
```cpp
void Light( in Material self, out vec3 albedo) {
  albedo *= self.albedo;
}

// 击中灯具时结束散射
Light(material, albedo);
break;
```

---
#### 7. 高级
##### 7.1. 加速结构
请见图形数据结构。  
##### 7.2. 全局光照
请见渲染方程和`蒙特卡洛(Monte Carlo)`积分、混合密度可平衡全局光照。  
##### 7.3. 运动模糊
不考虑。  
##### 7.4. 四边形
找到包含该四边形的平面，求解光线与包含四边形平面的交点，然后确定击中点是否位于四边形内部。  
```ruby
# QUAD- CENTER, SIDEU, SIDEV
n = normalize(cross(sideu, sidev))
v = Ray(k) - C
dot(n,v) = 0
    -> nx * (Rx + kDx - Cx) +... = 0
    -> kDx nx = Cxnx - Rxnx
        dot(C-R, n) = kdot(n, D)
    -> k = dot(C-R, n) / dot(n, D)

# 接下来用两个基础定位交点来限制四边形(或者其他图形)
w = N / dot(N, N) # 这个n不是单位
plane_loc_p = P - C;
a = dot(w, cross(plane_loc_p, sidev))
b = dot(w, cross(sideu, plane_loc_p))
```
##### 7.5. 仿射注意事项
请使用`kmin()`添加对象。在本地计算完成的外标准向量要通过逆变换返回。  
```cpp
```
##### 7.6. 萤火虫
漫反射的异常像素点伪像可能是一种数值不稳定导致的称为`萤火虫(fireflies)`的现象。我唯一可以确定的是它出现在漫射材料中。  
```cpp
vec4(clamp(linear_to_gamma(eval_pixel(tex, u_time)), 0.0, 1.0), 1.);
```
##### 7.7. 参与介质
见参与介质。  
##### 7.8. 阴影光线
请见阴影光线路径追踪。  