Links: [[_progress-kanban|TODO]]
***
# 2024-12-04 
Making Terrain Sets for Autotiling.
Set up Wall and Dirt Terrain Set for Autotiling. Works well enough. Will need to update all adjacent tiles when dirt is dug.
Tile offset (`texture_origin.y`) for walls and dirt is 24. This makes the walls overlap at the top.

**Next Problem:** when handling "walkable" and "diggable" in one logic layer. will need to update tiles in logic layer form dirt to floor if is dug.
1. *Get the Tile's Data:* Use the `TileMap.get_cell_tile_data()` method to retrieve the tile's data:
```python
func is_walkable(position: Vector2) -> bool:
    var cell_id = logic_layer.get_cell(position)
    if cell_id == TileMap.INVALID_CELL:
        return false
    var tile_data = logic_layer.get_cell_tile_data(position)
    return tile_data.get_custom_data("walkable")

func is_diggable(position: Vector2) -> bool:
    var cell_id = logic_layer.get_cell(position)
    if cell_id == TileMap.INVALID_CELL:
        return false
    var tile_data = logic_layer.get_cell_tile_data(position)
    return tile_data.get_custom_data("diggable")
```
2. *Replace Tile After Digging:* When a tile is dug, update the logic layer and visual layers:
```python
func dig_tile(position: Vector2):
    if not is_diggable(position):
        return

    # Replace with a walkable floor tile in the logic layer
    logic_layer.set_cell(position, FLOOR_TILE_ID)
    
    # Update visual layers (e.g., dirt layer becomes empty, ground layer shows floor)
    visual_dirt_layer.set_cell(position, TileMap.INVALID_CELL)
    visual_ground_layer.set_cell(position, FLOOR_TILE_ID)
```
*** 
TODO:
- Pathfinding (Update Navigation regions automatically):
```python
NavigationServer2D.map_set_cell(
    navigation_map_id, position, NavigationServer2D.CELL_TYPE_WALKABLE
)
```
- Particle Effects for digging
***
old:
```python
func dig_tile(position: Vector2):
    # Replace the tile at the given position
    logic_layer.set_cell(position, FLOOR_TILE_ID)  # Replace dirt with floor
    
    # Update the surrounding tiles to ensure transitions are correct
    for neighbor_offset in [
        Vector2(-1, 0), Vector2(1, 0), Vector2(0, -1), Vector2(0, 1)
    ]:
        var neighbor_pos = position + neighbor_offset
        logic_layer.update_bitmask_area(Rect2(neighbor_pos, Vector2(1, 1)))
```

# 2024-12-03
## TILEMAP & GRID
Working on [[TILEMAP]] and [[GRID]]. Think i need two. One for visual and one for logic.
![[tile-overlap-screen.png]]
- **Visual Layer:** Each tile can include overlaps that extend into neighboring tiles. For example, a wall top might only occupy 1/4 of the tile visually, and its side might visually spill into the tile below it
- **Logic Layer:** Create another, simpler tilemap (or grid-based system) for gameplay logic, where each "block" (e.g., dirt block, wall) occupies a single grid square
Tiles on *Wall Layer* seem to be offset on the slightly upwards.

### IDEA:
>*Layer1 (Background):* Floor and ground
>*Layer2 (Visual Walls):* Walls, including overlapping sides
>*Layer3 (Dirt):* Dirt, including overlapping sides
>*Layer4 (Collision):* Logic handling, ensure each object/block aligns to the logical grid, "diggable", "walkable"

1. Make tiles with overlap (e.g., 32x48 for 32x32 grid):
	- use *Autotile* to to dynamically combine tiles with overlap
	- configure the bitmask rules so the correct tiles (top, side, or empty) are automatically placed based on adjacency
	- when removing a tile, the TileMap will recalculate the surrounding tiles
2. Use consistent grid size:
	- set grid size to 32x32
	- ensure overlapping tiles are offset appropriately within their cell boundaries. Configure the `TileSet`'s **tile offsets**
3. Add Collision Logic:
	- collision shapes that strictly align with the logical grid. for a block that looks like it occupies 1.75 tiles visually, its collision should be confined to the central 1x1 tile
	- "diggable" state
***
#### AUTOTILE:
1. in `TileSet` Editor, select tile and enable Autotile
2. set up bitmask (3x3 grid) to define placement rules:
	- *Top Tile:* When no other dirt tiles are directly above.
	- *Side Tile:* When there’s a dirt tile directly above, and it extends downward.
	- *Corner Tile:* Dirt on one side only.
	- *Empty Tile:* When the tile is removed.
	- Configure each tile variant (top, side, corner) with its unique bitmask!
1. in `TileSet` Editor, adjust texture offset for wall side so it is visually overlaps the tile below. ***Top overlap is "walkable"!***
	- example: set vertical offset (e.g. +24 for a 32x32 grid) to make overlap the top
2. modify map at runtime (digging or destroying tiles):
	- use logic grid to decide what tile
	- update visual grid dynamically:
```python
func update_wall(position: Vector2):
    var above = TileMap_Logic.get_cellv(position + Vector2(0, -1))
    if above == WALL_TILE:
        TileMap_Visual.set_cellv(position, WALL_SIDE)
    else:
        TileMap_Visual.set_cellv(position, WALL_TOP)
```
*** 
#### When DIGGING a dirt block:
- use *logic tilemap/grid* to determine the current block
- remove tile form *Layer3 (Dirt)* TileMapLayer
- *Autotiling* recalculates the surrounding tiles, replacing them with the correct variants
```python
func dig_dirt(position: Vector2i):
    # Remove the dirt tile
    Dirt_Layer.set_cell(position, TileMap.INVALID_CELL)

    # Autotiling automatically adjusts surrounding tiles
```
- check for diggable tiles if *Layer4 (Collision)* TileMapLayer directly using:
```python
if Dirt_Layer.get_cell(position) == DIRT_TILE:
    dig_dirt(position)
```

All interactions (movement, digging, collision checks) should use the logic layer.
 ```python
 func dig_block(position: Vector2):
    var grid_pos = position / tile_size
    TileMap_Logic.set_cellv(grid_pos, EMPTY_TILE)
    TileMap_Visual.set_cellv(grid_pos, DUG_TILE)
```
```python
func dig_dirt(dirt_top_pos: Vector2i):
    # Logic update
    Logic_Layer.set_cell(dirt_top_pos, EMPTY_CELL)

    # Remove visual dirt
    Dirt_Layer.set_cell(dirt_top_pos, TileMap.INVALID_CELL)
    var dirt_side_pos = dirt_top_pos + Vector2i(0, 1)
    Dirt_Layer.set_cell(dirt_side_pos, TileMap.INVALID_CELL)

    # Update adjacent tiles
    update_dirt_autotiles(dirt_top_pos)
```

>[!info]+ best practices
>- **Avoid Redundant Layers:** If dirt sides and tops are tightly coupled, consider combining them into one layer using autotiling instead of separate top/side tiles.
>- **Use Logic Sparingly:** Keep logic calculations simple by working directly with tile positions and only updating surrounding tiles when necessary
>- **Leverage Godot's Autotile:** Autotile is powerful for handling adjacency-based tile changes dynamically, reducing manual effort.