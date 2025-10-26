from engine.drawing import Drawing

SEAWEED_SHADER_CODE = """
uniform float timer;

void main() {
    vec4 v = gl_Vertex;
    
    // Create swaying motion - top waves more than bottom (anchored at base)
    // The wave amplitude increases from bottom (-0.5) to top (0.5) of the seaweed
    float wave_strength = (v.y + 0.5);  // 0.0 at bottom, 1.0 at top
    
    // Gentle swaying effect for natural underwater seaweed movement
    float wave = sin(v.y * 20.0 + timer * 25.0) * 0.032 * wave_strength;
    
    // Apply wave primarily to x (horizontal sway), with slight y movement
    v.x += wave;
    v.y += wave * 0.1;
    
    // Transform to screen space
    gl_Position = gl_ModelViewProjectionMatrix * v;
    
    // Pass through color and texture coordinates
    gl_FrontColor = gl_Color;
    gl_TexCoord[0] = gl_MultiTexCoord0;
}
"""


class DrawingSeaweed(Drawing):
    """
    Sprite for seaweed
    """

    def __init__(
            self,
            texid: int,
            grid_x: int = 5,
            grid_y: int = 5,
            shader: int = 0,
    ):
        """
        Initialize seaweed as default sprite. All the magic happens in the shader
        :param texid: ID of texture
        :param grid_x: Mesh elements along axis X
        :param grid_y: Mesh elements along axis Y
        :param shader: ID of shader. Select 0 if you need no shader
        """
        super(DrawingSeaweed, self).__init__(texid, grid_x, grid_y, shader)
