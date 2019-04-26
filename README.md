## Thought process

This implementation of Tetris uses the Entity-Component-System pattern.
 
One issue that arises is how exactly we decide what to define as a component, what to define as an entity and which systems do we need.

One possible approach is to consider what can be done in-game, both for the player and for the game.

In this version of Tetris, the player is able to:

- Move a piece left, right, down and "instantly" down
- Rotate a piece clockwise and counter-clockwise
- Hold a piece and switch it with the active piece later
- Pause the game
- Save the game
- Restart the game

Conversely, the game is able to:
- Draw itself to the player
- Limit the movement speed of the pieces according to tetris rules (DAS, ARR)
- Limit the freedom of movement and rotation of the pieces to the board and empty spaces in it
- Kick a piece away from the sides when it is rotated near them
- Push a piece down every X seconds of inactivity
- "Freeze" a piece into place once it has a filled square under it, if there is no movement for a while or space is pressed
- Clear full lines
- Award score points depending on number of lines cleared in a row
- Show current score
- Show time passed
- Show lines cleared
- Stop the game when the player places a piece and part of it ends up outside the top-end of the board


With these actions/requirements in mind, we should now define the data that we need to store in order to satisfy them.

One clear entity is the board. It has to contain data for at least:

- Position
- Square size
- Internal representation
- Line color
- Limits

There are some other variables that may fit nicely on the board, such as the current score or number of lines cleared. Since systems act upon components and not entities, it really is up to us on where we'd like a component to be. I personally feel that it makes sense for a board to include data on what's happening inside it, so we'll add the following variables:

- Current score
- Number of lines cleared
- Time passed
- ARR, DAS
- Pressed keys

We may wish to add any other variables to the board in the future, or take them away into another entity that might make more sense. ECS gives us the freedom of simply creating a new component and adding it to the entity with no need to make any changes to it.


Another entity that seems self-explanatory is that of a piece. Let's see what we could include on a piece:

- Relative position to the board
- Internal representation
- Possible rotations
- Wall-kicking tests
- current DAS value
- current ARR value
- is active piece
- is held piece
- time spent inactive
- current rotation
- (...)

There is a lot of data that needs to be stored. However, we don't need to consider it all now. Again, thanks to ECS, we can just add new components as time goes by and apply new systems to them.

One thing to consider is that, whenever a new entity is created with a set of components, each component will need to be generated too. It wouldn't hurt to ship every component that is equal on every piece to some entity that isn't being instanced every other second, such as the board.


Step #1: Draw a board
