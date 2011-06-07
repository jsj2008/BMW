varying highp vec2 pos;

uniform sampler2D image;

void main()
{
	gl_FragColor = texture2D(image, pos);
}
