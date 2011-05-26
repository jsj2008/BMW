precision highp float;

uniform sampler2D inputImage;

varying vec2 pos;

uniform vec2 pixelSize;

void main()
{
	vec4 sum = vec4(0,0,0,1);
 
	// blur in y (vertical)
	// take nine samples, with the distance blurSize between them
	sum += texture2D(inputImage, vec2(pos.x, pos.y - 4.0*pixelSize.y)) * 0.05;
	sum += texture2D(inputImage, vec2(pos.x, pos.y - 3.0*pixelSize.y)) * 0.09;
	sum += texture2D(inputImage, vec2(pos.x, pos.y - 2.0*pixelSize.y)) * 0.12;
	sum += texture2D(inputImage, vec2(pos.x, pos.y - pixelSize.y)) * 0.15;
	sum += texture2D(inputImage, vec2(pos.x, pos.y)) * 0.16;
	sum += texture2D(inputImage, vec2(pos.x, pos.y + pixelSize.y)) * 0.15;
	sum += texture2D(inputImage, vec2(pos.x, pos.y + 2.0*pixelSize.y)) * 0.12;
	sum += texture2D(inputImage, vec2(pos.x, pos.y + 3.0*pixelSize.y)) * 0.09;
	sum += texture2D(inputImage, vec2(pos.x, pos.y + 4.0*pixelSize.y)) * 0.05;
 
	gl_FragColor = sum;
}

  