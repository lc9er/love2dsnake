# SNAKE 
## SimplegameTutorial's Snake example for Love2D

## Rules

1. Eating food makes the snake grow.
2. When food is eaten, a new food appears at a random position.
3. Game ends when it crashes into itself.
4. Game ends if snake crashes into the wall.
5. Direction changes at 90 degree angles.

## Controls

1. Arrow keys change direction.

## Overview

1. Snake is represented by a sequence of X and Y positions.
    a. Starts out as 3 segments.
2. When the snake moves, the last item (tail position) is removed, and an item is added to the front
(new head position) in the direction the snake is going.
3. If the new head position is at the same position as the food's position, then the snake's tail is
not removed, and the food is moved to a random position not occupied by the snake.
4. If the new head position is at the same position as any of the snake's other segments, then the
game is over.

Original version derived from tutorial here:
https://simplegametutorials.github.io/love/snake/
