precision highp float;

float RH_MIN1 = 0.0;
float RH_MAX1 = 40.0;


//float RH_MIN2 = 350.0;
float RH_MIN2 = 340.0;
float RH_MAX2 = 360.0;

//float RS_THRESHOLD = .13;
float RS_THRESHOLD = .08;

float GH_MIN = 0.0;
float GH_MAX = 180.0;

float GS_THRESHOLD = .25;

float YH_MIN = 20.0;
float YH_MAX = 60.0;
float YS_THRESHOLD = .5;

float I_THRESHOLD = 100.0;
float RI_THRESHOLD = 80.0;
float GI_THRESHOLD = 90.0;

float R_THRESHOLD = 120.0;
float G_THRESHOLD = 100.0;
//float G_THRESHOLD = 0.0;
float Y_THRESHOLD = 150.0;

float GB_THRESHOLD = 55.0;
float RB_THRESHOLD = 100.0;
float RY_THRESHOLD = 100.0;

uniform sampler2D inputImage;
varying vec2 pos;

float Intensity(float r, float g, float b)
{
    return (r + g + b)/3.0;
}

float colorMax(float r, float g, float b)
{
    float m = r;
    if (g > m) m = g;
    if (b > m) m = b;
    return m;
}

float colorMin(float r, float g, float b)
{
    float m = r;
    if (g < m) m = g;
    if (b < m) m = b;
    return m;
}

float Hue(float r, float g, float b)
{    
    float theta = (180.0/3.0)*acos(((r+r-b-g)*.5)/(pow(pow(r - g, 2.0) + (r - b)*(g - b), .5)));
    if (b <= g) return theta;
    return 360.0 - theta;
    
    
}

float percentRed(float r, float g, float b)
{
    return r/(r + g +b);
}

float Saturation(float r, float g, float b)
{
    return 1.0 - 3.0*colorMin(r, g, b)/(r + g + b);
}

void main()
{
    vec4 pixel = texture2D(inputImage, pos);
    pixel *= 255.0;
    float ins = Intensity(pixel.r, pixel.g, pixel.b);
    float sat = Saturation(pixel.r, pixel.g, pixel.b);
    float hue = Hue(pixel.r, pixel.g, pixel.b);

    //if (((hue >= RH_MIN1 && hue <= RH_MAX1) || (hue >= RH_MIN2 && hue <= RH_MAX2)) && sat >= RS_THRESHOLD && ins >= I_THRESHOLD){
    //} else if (hue >= GH_MIN && hue <= GH_MAX && sat >= GS_THRESHOLD && ins >= I_THRESHOLD){
    
    
    //Check for red traffic lights
    // if (((hue >= RH_MIN1 && hue <= RH_MAX1) || (hue >= RH_MIN2 && hue <= RH_MAX2)) && sat >= RS_THRESHOLD && ins > I_THRESHOLD){
    
    
    if (((hue >= RH_MIN1 && hue <= RH_MAX1) || (hue >= RH_MIN2 && hue <= RH_MAX2)) && sat >= RS_THRESHOLD && ins > RI_THRESHOLD) {
        if (pixel.r > R_THRESHOLD && pixel.g < GB_THRESHOLD && pixel.b < GB_THRESHOLD) {
        //if (percentRed(pixel.r, pixel.g, pixel.b) > .5) {
            gl_FragColor = vec4(1, 0, 0, 1);
        } else gl_FragColor = vec4(0,0,0,1);

    //Check for green traffic lights
    /*
    } else 
    
    
    if (hue >= GH_MIN && hue <= GH_MAX && ins >= GI_THRESHOLD && sat >= GS_THRESHOLD ){
 
        if (pixel.g > G_THRESHOLD && pixel.r < RB_THRESHOLD) {
            gl_FragColor = vec4(0, 1, 0, 1);
        } else gl_FragColor = vec4(0,0,1,1);	
    */
    }  else gl_FragColor = vec4(0,0,0,1);
    
    //Check for yellow traffic lights
    /*
    else if (hue >= YH_MIN && hue <= YH_MAX && sat >= YS_THRESHOLD && ins >= I_THRESHOLD) {

    if (pixel.r > Y_THRESHOLD && pixel.g > Y_THRESHOLD && pixel.b < RY_THRESHOLD) {
        gl_FragColor = vec4(1, 1, 0, 1);
    } else gl_FragColor = vec4(0,0,0,1);

    } else gl_FragColor = vec4(0,1,0,1);	
    */
}
