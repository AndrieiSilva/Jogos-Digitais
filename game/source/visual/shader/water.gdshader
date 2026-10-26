shader_type spatial;

render_mode blend_mix,
depth_draw_opaque,
cull_back,
diffuse_burley,
specular_schlick_ggx;

// === 水面基础参数 ===
uniform vec3 water_color : source_color = vec3(0.15, 0.32, 0.22); //水体基础颜色
uniform float water_metallic : hint_range(0.0, 1.0) = 0.0; //金属度
uniform float water_roughness : hint_range(0.0, 1.0) = 0.75; //粗糙度
uniform float water_specular : hint_range(0.0, 1.0) = 0.6; //高光强度

// === 波浪参数 ===
uniform float wave_speed : hint_range(0.0, 5.0) = 0.2; // 波浪流动速度
uniform float wave_scale : hint_range(1.0, 200.0) = 12.0; // 波浪缩放密集度
uniform float wave_normal_strength : hint_range(0.0, 5.0) = 1.5; // 波浪法线(凹凸)强度

// === 泡沫参数 ===
uniform float foam_amount : hint_range(0.0, 1.0) = 0.15; // 泡沫数量
uniform vec3 foam_color : source_color = vec3(0.72, 0.68, 0.52); //泡沫的颜色
uniform float foam_animation_speed : hint_range(0.0, 5.0) = 1.5; // 泡沫变形速度
uniform float foam_detail : hint_range(10.0, 200.0) = 100.0; // 泡沫细节精细度

// === 2D 随机伪随机数生成器 ===
float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

// === 2D 柏林噪声基础函数 ===
float noise(vec2 uv) {
    vec2 i = floor(uv);
    vec2 f = fract(uv);
    
    // 获取四个角的随机值
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    // 平滑插值 (Cubic Hermite Curve)
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

// === 分形布朗运动 (FBM) - 叠加多层噪声产生细节 ===
float fbm(vec2 uv) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    // 叠加 4 层噪声 (Octaves)
    for(int i = 0; i < 4; i++) {
        value += amplitude * noise(uv * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    
    return value;
}

// === 波浪高度计算 ===
float wave_noise(vec2 uv, float time) {
    float t = time * wave_speed;
    
    // 生成两个不同方向流动的 UV，模拟水流交错
    vec2 uv1 = uv * wave_scale + vec2(t * 0.3, t * 0.2);
    vec2 uv2 = uv * wave_scale * 1.3 + vec2(-t * 0.25, t * 0.35);
    
    float noise1 = fbm(uv1);
    float noise2 = fbm(uv2);
    
    // 混合两层噪声并将结果映射到 -1.0 到 1.0 之间
    return (noise1 + noise2) - 1.0;
}

// === 动态计算水面法线 ===
vec3 calculate_water_normal(vec2 uv, float time) {
    float offset = 0.01; // 采样偏移量，影响法线锐度
    
    // 获取当前点及相邻点的波浪高度
    float h_c = wave_noise(uv, time);
    float h_r = wave_noise(uv + vec2(offset, 0.0), time);
    float h_u = wave_noise(uv + vec2(0.0, offset), time);
    
    // 通过高度差计算法线向量 (Godot 3D空间中 Y 轴向上)
    vec3 normal;
    normal.x = (h_c - h_r) / offset;
    normal.z = (h_c - h_u) / offset;
    normal.y = 1.0;
    
    return normalize(normal);
}

void fragment() {
    // 1. 动态生成法线贴图
    vec3 water_normal = calculate_water_normal(UV, TIME);
    water_normal *= vec3(wave_normal_strength, 1.0, wave_normal_strength);
    NORMAL_MAP = normalize(water_normal);
    
    // 2. 获取当前像素的波浪高度值 (-1 到 1)
    float wave = wave_noise(UV, TIME);
    
    // 3. 基础水体颜色
    vec3 final_color = water_color;
    
    // 4. 程序化波峰泡沫
    // 使用独立的噪声控制泡沫的形态演变
    float foam_noise = fbm(UV * foam_detail + TIME * foam_animation_speed);
    float foam_anim = smoothstep(0.3, 0.7, foam_noise);
    
    // 提取波峰区域 (当 wave 接近最高点时生成遮罩)
    float foam_mask = smoothstep(0.5, 0.8, wave + 1.0) * foam_amount;
    
    // 混合泡沫颜色
    float foam = foam_mask * foam_anim;
    final_color = mix(final_color, foam_color, foam);
    
    // 5. 波浪光照高光微调 (使波峰略微受光变亮)
    float light_wave = wave * 0.15;
    final_color += vec3(0.05, 0.06, 0.04) * light_wave;
    
    // 6. 水体深浅颜色过渡 (波浪低谷略微偏暗偏蓝绿)
    float murk = wave * 0.05;
    final_color = mix(final_color, vec3(0.12, 0.14, 0.10), murk);
    
    // === 最终属性输出 ===
    ALBEDO = final_color;
    METALLIC = water_metallic;
    // 根据波浪起伏微调粗糙度，增加质感变化
    ROUGHNESS = water_roughness + (wave - 0.5) * 0.05; 
    SPECULAR = water_specular;
}