package isaac

import "core:fmt"
import "core:mem"
import "core:math"
import rl "vendor:raylib"

/////////////////////////////////////////////////////////////////////
// Data
/////////////////////////////////////////////////////////////////////
game_data :: struct {
  window : rl.Vector2,
}

GameData : game_data = {
  rl.Vector2{640, 480},
}

obj_type :: enum {
  PLAYER,
  ENEMY,
  PROJECTILE,
  GROUND,
  BG_GROUND,
}

obj :: struct {
  type       : obj_type,
  src        : rl.Rectangle,
  dest       : rl.Rectangle,
  color      : rl.Color,
  move_speed : f32,
  health     : i32,
  dmg        : i32,
  alive      : bool,
}

/////////////////////////////////////////////////////////////////////
// Data arrays 
/////////////////////////////////////////////////////////////////////
Objects : [10]obj

/////////////////////////////////////////////////////////////////////
// Global varialbes for execution status and game loop
/////////////////////////////////////////////////////////////////////
is_running          : = false

/////////////////////////////////////////////////////////////////////
// Debugging related
/////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////
window_setup :: proc() {
  using rl

  InitWindow(i32(GameData.window.x), i32(GameData.window.y), "Isaac meets Odin")
  

  SetExitKey(KeyboardKey.ESCAPE)
}

game_setup :: proc() {
  using rl

  //Game related setup

  //Player setup
  Objects[0].type = .PLAYER
  Objects[0].color = ORANGE
  Objects[0].dest = Rectangle{
    GameData.window.x / 2,
    GameData.window.y / 2,
    64, 64}
  Objects[0].move_speed = 250
  Objects[0].health = 3
  Objects[0].dmg = 1
  Objects[0].alive = true

  //Ground Setup
  Objects[1].type = .GROUND
  Objects[1].color = LIME
  Objects[1].dest = Rectangle{
    0,
    GameData.window.y / 2 + 64,
    GameData.window.x, GameData.window.y / 2}

  Objects[2].type = .BG_GROUND
  Objects[2].color = DARKGREEN
  Objects[2].dest = Rectangle{
    0,
    GameData.window.y / 2 + 48,
    GameData.window.x, GameData.window.y / 2}

  // Enemies
  for i := 3; i < 5; i+=1  {
    Objects[i].type = .ENEMY
    Objects[i].color = DARKPURPLE
    Objects[i].dest = Rectangle{
      f32(i * 128) - 300,
      GameData.window.y / 2,
      64, 64}
    Objects[i].move_speed = 150

    Objects[i].health = 1
    Objects[i].dmg = 1
    Objects[i].alive = true
  }
  
  //bullets
  for i:=5; i <len(Objects); i+=1  {

  }
}

/////////////////////////////////////////////////////////////////////
process_input :: proc() {
  //NOTE: can use iskeypressed for escape to handle quitting with 
  // is_rnning more gracefully
  // for sdl.PollEvent(&event) {
  //   #partial switch event.type
  //   {
  //   case sdl.EventType.QUIT:
  //     {
  //       is_running = false
  //     }
  //   case sdl.EventType.KEYDOWN:
  //     {
  //       if event.key.keysym.sym == sdl.Keycode.ESCAPE {
  //         rl.CloseWindow()
  //       }
  //     }
  //   }
  // }

  if rl.IsKeyDown(.A) {
    Objects[0].dest.x -= Objects[0].move_speed * rl.GetFrameTime()
  }
  if rl.IsKeyDown(.D) {
    Objects[0].dest.x += Objects[0].move_speed * rl.GetFrameTime()
  }
  // if rl.IsKeyDown(.W) {
  //   Objects[0].dest.y -= Objects[0].move_speed * rl.GetFrameTime()
  // }
  // if rl.IsKeyDown(.S) {
  //   Objects[0].dest.y += Objects[0].move_speed * rl.GetFrameTime()
  // }

}

/////////////////////////////////////////////////////////////////////
update :: proc() {
  for &obj in Objects{
    if obj.type == .ENEMY{
      if Objects[0].dest.x < obj.dest.x{
        obj.dest.x -= obj.move_speed * rl.GetFrameTime()
      }
      if Objects[0].dest.x > obj.dest.x{
        obj.dest.x += obj.move_speed * rl.GetFrameTime()
      }
    }

  }
}

/////////////////////////////////////////////////////////////////////
render :: proc() {
  rl.BeginDrawing()
    rl.ClearBackground(rl.BLACK)
    rl.DrawText("Isaac Meets Odin", 
      i32(GameData.window.x / 2) - 75, 
      i32(GameData.window.y / 2) - 20, 
      20, rl.LIGHTGRAY)

      rl.DrawRectangleRec(Objects[2].dest, Objects[2].color) 

      rl.DrawRectangleRec(Objects[1].dest, Objects[1].color) 

      rl.DrawRectangleRec(Objects[0].dest, Objects[0].color) 

      for &obj in Objects{
        if obj.type == .ENEMY {
          rl.DrawRectangleRec(obj.dest, obj.color) 
        }
      }
  rl.EndDrawing()
}

/////////////////////////////////////////////////////////////////////
// Free the memory that has been dynamically allocated by the program
/////////////////////////////////////////////////////////////////////
free_resources :: proc() {
}

/////////////////////////////////////////////////////////////////////
main :: proc() {
  track: mem.Tracking_Allocator
  mem.tracking_allocator_init(&track, context.allocator)
  defer mem.tracking_allocator_destroy(&track)

  context.allocator = mem.tracking_allocator(&track)

  defer {
    for _, leak in track.allocation_map {
      fmt.printf("%v leaked %m\n", leak.location, leak.size)
    }
    for bad_free in track.bad_free_array {
      fmt.printf(
        "%v allocation %p was freed badly\n",
        bad_free.location,
        bad_free.memory,
      )
    }
  }

  /////////////////////////////////////////////////////////

  window_setup()

  game_setup()

  for !rl.WindowShouldClose() {
    process_input()
    update()
    render()
  }

  free_resources()

  rl.CloseWindow()
}
