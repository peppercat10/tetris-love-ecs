# tetris-love-ecs
Tetris implemented in love2d using ECS

The board is a 20x10 matrix. 
Cells can be:
0: empty
1: color #1
2: color #2
3: color #3
4: color #4
5: color #5
6: color #6
7: color #7
8: color #8 (grey/trash)

Pieces are also defined through matrices, usually 3x3. Cells can be 0 or 1, with a component that defines color.

Pieces may be moved by the player, they may be shown on a list of upcoming pieces, and they may be held for future usage.

With this in mind, for now, these are the components:

### Components

#### Grid
* cellSize
* matrix


#### Position
* x
* y

#### Rotation
* Rotation list
* Rotation index 

#### Controllable:
* Bool

#### Input:
* KeyCode

#### Tile:
* png

#### Color:
* int

#### TimeFrozen:
* int
