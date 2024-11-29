// already defined with ShaderMaterial
// precision mediump float;

// we did receive this from vertex shader, because we did send it (not done by ShaderMaterial)
varying vec2 vUv;


// #define PI 3.1415926535897932384626433832795


// we copied this since function bellow, uses is as depndancy
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}

// we copied this from mentioned gist
// https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83#classic-perlin-noise
//	Classic Perlin 2D Noise 
//	by Stefan Gustavson (https://github.com/stegu/webgl-noise)
//
vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec2 P){
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 * 
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}



void main() {

  // float strength = step(0.9, sin(cnoise(vUv * 10.0) * 20.0));

  float strengthX = mod(vUv.x * 10.0, 1.0);
  float strengthY = mod(vUv.y * 10.0, 1.0);

  float strength = step(0.8, strengthX) + step(0.8, strengthY);

  // problem occusr since above strength can be above 1.0
  // after we did addition as you can see

  // we know that at the end in final vector, values get clamped
  // things bellow zero get clamped to zero
  // things above one, get clamped to one

  // but next mix function should get only values in between 0.0 and 1.0
  // since we want color and if we would pass things above one
  // it can happen that we get gray color
  // so we need to clamp it beforehand before passing it to mix

  strength = clamp(strength, 0.0, 1.0); // if strength is above 1.0
  //                                   it will be clamped to 1.0
  //                                   and if strength is bellow
  //                                   0.0, it will be clamped to 0.0

  // comment out upper clamp call to see how it looks without it
  // you would see unexpected gray segments


  vec3 blackColor = vec3(0.0);
  vec3 uvColor = vec3(vUv, 1.0);

  vec3 mixedColor = mix(blackColor, uvColor, strength);

  gl_FragColor = vec4(mixedColor, 1.0);

  // black and white version
  // gl_FragColor = vec4(vec3(strength), 1.0);

}