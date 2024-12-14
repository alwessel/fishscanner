from functools import partial
from glob import glob
from queue import Queue
from threading import Thread
from typing import List, Optional, Callable
import os

import OpenGL.GL as gl
import OpenGL.GLUT as glut
import cv2
import numpy as np
from pillow_heif import register_heif_opener
from PIL import Image

from engine.drawing import Drawing
from engine.renderer import Renderer
from engine.simplescanner import SimpleScanner
from ocean.drawingfish import DrawingFish, FISH_SHADER_CODE
from ocean.drawingseaweed import DrawingSeaweed, SEAWEED_SHADER_CODE
from ocean.drawingstatic import DrawingStatic

# Register HEIF opener for HEIC support
register_heif_opener()


def create_back_layer(
        filename: str,
        z: float,
        shader: int = 0,
) -> DrawingStatic:
    """
    Create sprite for the scene background
    :param filename: Path to the background image
    :param z: Depth position of the sprite
    :param shader: Shader ID for the background
    :return: Sprite object for the background
    """
    drawing_back = DrawingStatic(Renderer.create_texture_from_file(filename), shader=shader)
    drawing_back.position = np.array([0, 0., z])
    drawing_back.scale = np.array([3.6, 2.0, 1.0])
    return drawing_back


def draw_sails(
        drawings_list: List[Drawing],
        shader: int,
) -> None:
    """
    Support function to draw sails
    :param drawings_list: List of sprites to draw
    :param shader: Shader to animate the sails
    :return:
    """
    drawing = DrawingSeaweed(Renderer.create_texture_from_file('ocean/images/sail_1.png'), shader=shader)
    drawing.position = np.array([1.2, -0.43, -0.77])
    drawing.scale = np.array([0.6, 0.4, 1.0])
    drawings_list.append(drawing)

    drawing = DrawingSeaweed(Renderer.create_texture_from_file('ocean/images/sail_2.png'), shader=shader)
    drawing.position = np.array([1.6, -0.34, -0.77])
    drawing.scale = np.array([0.3, 0.5, 1.0])
    drawings_list.append(drawing)

    drawing = DrawingSeaweed(Renderer.create_texture_from_file('ocean/images/sail_3.png'), shader=shader)
    drawing.position = np.array([1.7, -0.71, -0.77])
    drawing.scale = np.array([0.2, 0.3, 1.0])
    drawings_list.append(drawing)


def draw_ocean(drawings_list: List[Drawing]) -> None:
    """
    Draw all the sprites in the ocean scene
    :param drawings_list: Lists of sprites to draw
    :return:
    """
    seaweed_shader_program = Renderer.create_shader(gl.GL_VERTEX_SHADER, SEAWEED_SHADER_CODE)

    drawings_list.append(create_back_layer('ocean/images/back_down.png', -0.8))
    drawings_list.append(create_back_layer('ocean/images/back_middle.png', -0.78))
    drawings_list.append(create_back_layer('ocean/images/back_reef.png', 0.8))

    draw_sails(drawings_list, seaweed_shader_program)

    seaweed_texture = Renderer.create_texture_from_file('ocean/images/seaweed_2.png')
    # Draw seaweed under the ship
    drawing = DrawingSeaweed(seaweed_texture, shader=seaweed_shader_program)
    drawing.position = np.array([1.2, 0.4, -0.75])
    drawing.scale = np.array([0.8, 0.4, 1.0])
    drawings_list.append(drawing)

    seaweed_texture = Renderer.create_texture_from_file('ocean/images/seaweed_1.png')
    # Draw seaweed in the right corner
    drawing = DrawingSeaweed(seaweed_texture, shader=seaweed_shader_program)
    drawing.position = np.array([1.2, 1.0, 0.9])
    drawing.scale = np.array([0.8, 1.4, 1.0])
    # drawing.color = np.array([0.5, 0.5, 1.0])
    drawings_list.append(drawing)

    # Draw seaweed in the front of the rock
    drawing = DrawingSeaweed(seaweed_texture, shader=seaweed_shader_program)
    drawing.position = np.array([0.2, 0.15, -0.7])
    drawing.scale = np.array([0.4, 0.4, 1.0])
    # drawing.color = np.array([0.6, 0.6, 1.0])
    drawings_list.append(drawing)

    seaweed_texture = Renderer.create_texture_from_file('ocean/images/seaweed_3.png')
    # Draw seaweed in the left corner
    drawing = DrawingSeaweed(seaweed_texture, shader=seaweed_shader_program)
    drawing.position = np.array([-1.2, 0.6, 0.9])
    drawing.scale = np.array([0.3, 1.0, 1.0])
    # drawing.color = np.array([0.5, 0.5, 1.0])
    drawings_list.append(drawing)

    # Draw seaweed on the background
    drawing = DrawingSeaweed(seaweed_texture, shader=seaweed_shader_program)
    drawing.position = np.array([-0.8, -0.5, -0.795])
    drawing.scale = np.array([0.3, 1.0, 1.0])
    drawing.color = np.array([0.3, 0.3, 0.8])
    drawings_list.append(drawing)

    drawing = DrawingSeaweed(seaweed_texture, shader=seaweed_shader_program)
    drawing.position = np.array([0.0, -0.2, -0.795])
    drawing.scale = np.array([-0.3, 1.0, 1.0])
    drawing.color = np.array([0.3, 0.3, 0.8])
    drawings_list.append(drawing)

    drawing = DrawingSeaweed(seaweed_texture, shader=seaweed_shader_program)
    drawing.position = np.array([-0.4, -0.2, -0.795])
    drawing.scale = np.array([0.1, 0.3, 1.0])
    drawing.color = np.array([0.1, 0.1, 0.4])
    drawings_list.append(drawing)


def scan_from_frame(
        frame: np.ndarray,
        scanner: SimpleScanner,
) -> Optional[np.ndarray]:
    """
    Process a fish from an image file
    :param frame: BGR photo of the fish drawing
    :param scanner: Object of scanner to process photo
    :return: Processed frame with a fish selected from the background
    """
    frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    try:
        processed_frame = scanner.scan(frame)
    except ValueError as e:
        print(e)
        return None
    processed_frame = scanner.remove_background(processed_frame)
    return processed_frame


def load_fish_from_files(
        scanner: SimpleScanner,
        drawings_list: List[Drawing],
        fish_queue: Queue,
        fish_shader_program: int = 0,
        bubble_texture: int = 0,
) -> None:
    """
    Load all the predrawing fish from the folder
    :param scanner: Object of scanner to process photos
    :param drawings_list: Lists of sprites to add fish in it
    :param fish_queue: Queue to maintain order of fish
    :param fish_shader_program: ID of fish shader
    :param bubble_texture: ID of bubble texture
    :return:
    """
    # Load both JPG and HEIC files
    jpg_files = glob('./photos/*.jpg')
    heic_files = glob('./photos/*.heic')
    files = jpg_files + heic_files

    for filename in files:
        try:
            if filename.lower().endswith('.heic'):
                # Load HEIC files using pillow-heif
                heif_file = Image.open(filename)
                # Convert to RGB format that OpenCV expects
                rgb_image = heif_file.convert('RGB')
                # Convert PIL image to OpenCV format
                frame = cv2.cvtColor(np.array(rgb_image), cv2.COLOR_RGB2BGR)
            else:
                # Load JPG files using OpenCV directly
                frame = cv2.imread(filename)

            if frame is None:
                print(f'Error reading image with filename: {filename}')
                continue

            scanned_fish = scan_from_frame(frame, scanner)
            if scanned_fish is not None:
                drawing = DrawingFish(Renderer.create_texture(scanned_fish),
                                    shader=fish_shader_program,
                                    bubble_texture_id=bubble_texture)
                drawings_list.append(drawing)
                fish_queue.put(drawing)
        except Exception as e:
            print(f'Error processing {filename}: {str(e)}')
            continue


def create_key_processor(
        scanner: SimpleScanner,
        scanned_fish_queue: Queue,
) -> Callable:
    """
    Wrapper for keys processor function
    :param scanner: Object of scanner to process photos
    :param scanned_fish_queue: Queue with scanning results
    :return: Function in the format for the GLUT
    """
    def keys_processor(key, x, y):
        if key == b'\x1b':  # esc
            exit(0)
    return keys_processor


def create_animation_function(
        renderer: Renderer,
        drawings_list: List[Drawing],
        scanned_fish_queue: Queue,
        fish_queue: Queue,
        fish_limit: int,
        timer_msec: int,
        fish_shader_program: int = 0,
        bubble_texture: int = 0,
) -> Callable:
    """
    Wrapper for animation function
    :param renderer: Object of the Engine to draw all the objects
    :param drawings_list: Lists of sprites to draw
    :param scanned_fish_queue: Queue with scanning results
    :param fish_queue: Queue to maintain order of fish
    :param fish_limit: Maximum amount of fish to draw
    :param timer_msec: Timer interval value for animation
    :param fish_shader_program: ID of fish shader
    :param bubble_texture: ID of bubble texture
    :return: Function in the format for the GLUT
    """
    def animate(value):
        renderer.animate(drawings_list)
        glut.glutTimerFunc(timer_msec, animate, 0)

        # Get fish scan from scanner thread
        if scanned_fish_queue.qsize() > 0:
            scanned_fish = scanned_fish_queue.get()
            drawing = DrawingFish(Renderer.create_texture(scanned_fish),
                                  shader=fish_shader_program,
                                  bubble_texture_id=bubble_texture)
            drawings_list.append(drawing)
            fish_queue.put(drawing)

        if fish_queue.qsize() > fish_limit:
            fish = fish_queue.get()
            fish.go_away()

        # Remove dead fish from drawing list
        for drawing in drawings_list:
            if isinstance(drawing, DrawingFish) and not drawing.is_alive:
                drawings_list.remove(drawing)
    return animate


def main():
    # Initialize GLUT
    glut.glutInit()
    glut.glutInitDisplayMode(glut.GLUT_DOUBLE | glut.GLUT_RGB | glut.GLUT_DEPTH)
    
    # Request OpenGL 3.3 core profile
    glut.glutInitContextVersion(3, 3)
    glut.glutInitContextProfile(glut.GLUT_CORE_PROFILE)
    
    glut.glutInitWindowSize(800, 600)
    glut.glutCreateWindow(b"FishScanner")
    
    # Initialize OpenGL
    gl.glEnable(gl.GL_DEPTH_TEST)
    gl.glEnable(gl.GL_BLEND)
    gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)

    # Initialize OpenGL context
    gl.glClearColor(0.1, 0.1, 0.2, 1.0)
    gl.glViewport(0, 0, 800, 600)
    gl.glMatrixMode(gl.GL_PROJECTION)
    gl.glLoadIdentity()
    gl.glOrtho(-1, 1, -1, 1, -1, 1)
    gl.glMatrixMode(gl.GL_MODELVIEW)
    gl.glLoadIdentity()
    
    scanner = SimpleScanner()

    timer_msec = int(1000 / 60) # 60 times per second
    renderer = Renderer()
    drawings_list = []
    fish_queue = Queue() # Queue to maintain order of the fish and kill the oldest ones
    fish_limit = 10 # Maximum amount of fish to draw
    scanned_fish_queue = Queue()
    
    # Create display function first
    glut.glutDisplayFunc(partial(renderer.render, drawings_list))
    
    # Then initialize the scene
    draw_ocean(drawings_list)

    fish_shader_program = Renderer.create_shader(gl.GL_VERTEX_SHADER, FISH_SHADER_CODE)
    bubble_texture = Renderer.create_texture_from_file('ocean/images/bubble.png')
    load_fish_from_files(scanner, drawings_list, fish_queue, fish_shader_program, bubble_texture)

    glut.glutIgnoreKeyRepeat(True)
    glut.glutKeyboardFunc(create_key_processor(scanner, scanned_fish_queue))
    glut.glutTimerFunc(timer_msec, create_animation_function(renderer, drawings_list, scanned_fish_queue,
                                                             fish_queue, fish_limit, timer_msec,
                                                             fish_shader_program, bubble_texture), 0)

    # Start the main loop
    glut.glutMainLoop()


if __name__ == '__main__':
    main()
