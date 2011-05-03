varying vec2 pos;

void main()
{
    pos = gl_MultiTexCoord0.xy;

    gl_Position = gl_ProjectionMatrix * gl_ModelViewMatrix * gl_Vertex;
}