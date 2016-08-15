// engine.c
//
// Load a game file and run it in the order below.
//
// This introduces the use of Lua tables via Lua's C API.
//
//   -- Lua-ish pseudocode representing the order of events.
//   game.init()
//   while true do
//     game.loop(state)  -- state has keys 'clock' and 'key'.
//     sleep(0.016)
//   end
//
//

#include <fcntl.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>

#include "lauxlib.h"
#include "lua.h"
#include "lualib.h"


// Internal functions.

double gettime() {
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return tv.tv_sec + 1e-6 * tv.tv_usec;
}

int getkey(int *is_end_of_seq) {

  // We care about two cases:
  // Case 1: A sequence of the form 27, 91, X; return X.
  // Case 2: For any other sequence, return each int separately.

  *is_end_of_seq = 0;
  int ch = getchar();
  if (ch == 27) {
    int next = getchar();
    if (next == 91) {
      *is_end_of_seq = 1;
      return getchar();
    }
    // If we get here, then we're not in a 27, 91, X sequence.
    ungetc(next, stdin);
  }
  return ch;
}

void sleephires(double sec) {
  long s = (long)floor(sec);
  long n = (long)floor((sec - s) * 1e9);
  struct timespec delay = { .tv_sec = s, .tv_nsec = n };
  nanosleep(&delay, NULL);
}

void start() {

  // Terminal setup.
  system("tput clear");  // Clear the screen.
  system("tput civis");  // Hide the cursor.
  system("stty raw");    // Improve access to keypresses from stdin.

  // Make reading from stdin non-blocking.
  fcntl(STDIN_FILENO, F_SETFL, fcntl(STDIN_FILENO, F_GETFL) | O_NONBLOCK);
}

void done() {

  // Ensure no pending output is emitted after we send out the cleanup strings
  // via stty and tput below.
  fflush(stdout);

  // Put the terminal back into a decent state.
  system("stty cooked");  // Undo earlier call to "stty raw".
  system("tput reset");   // Reset terminal colors and clear the screen.

  exit(0);
}

void push_keypress(lua_State *L, int key, int is_end_of_seq) {
  if (is_end_of_seq && 65 <= key && key <= 68) {
    // up, down, right, left = 65, 66, 67, 68
    static const char *arrow_names[] = {"up", "down", "right", "left"};
    lua_pushstring(L, arrow_names[key - 65]);
  } else {
    lua_pushnumber(L, key);
  }
}

void push_state_table(lua_State *L, int key, int is_end_of_seq) {

  lua_newtable(L);

    // stack = [.., {}]

  push_keypress(L, key, is_end_of_seq);

    // stack = [.., {}, key]

  lua_setfield(L, -2, "key");

    // stack = [.., {key = key}]

  lua_pushnumber(L, gettime());

    // stack = [.., {key = key}, clock]

  lua_setfield(L, -2, "clock");

    // stack = [.., {key = key, clock = clock}]
}

char *get_game_file(int argc, char **argv) {
  if (argc != 2) {
    printf("Usage: engine <mygame.lua>\n");
    exit(1);
  }
  return argv[1];
}


// Lua-visible functions.

// Lua: timestamp().
// Return a high-resolution timestamp in seconds.
int timestamp(lua_State *L) {
  lua_pushnumber(L, gettime());
  return 1;
}


// Main.

int main(int argc, char **argv) {

  char *game_file = get_game_file(argc, argv);

  start();

  // Create a Lua state and load the module.
  lua_State *L = luaL_newstate();
  luaL_openlibs(L);

  // Set up API functions written in C.
  lua_register(L, "timestamp", timestamp);

  // Set up API functions written in Lua.
  luaL_dofile(L, "engine_util.lua");

  // Load the game file and run the init() function.
  luaL_dofile(L, game_file);
  lua_setglobal(L, "game");
  lua_settop(L, 0);

  lua_getglobal(L, "game");
  lua_getfield(L, -1, "init");  // -1 means stack top.
  lua_call(L, 0, 0);            // 0, 0 = #args, #retvals

  lua_getglobal(L, "game");
  while (1) {
    int is_end_of_seq;
    int key = getkey(&is_end_of_seq);
    if (key == 27 || key == 'q' || key == 'Q') done();

    // Call game.loop(state).
    lua_getfield(L, -1, "loop");
    push_state_table(L, key, is_end_of_seq);
    lua_call(L, 1, 1);
    const char *game_state = lua_tostring(L, -1);
    if (game_state && strcmp(game_state, "game over") == 0) done();
    lua_pop(L, 1);

    sleephires(0.016);  // Sleep for 16ms.
  }

  return 0;
}
