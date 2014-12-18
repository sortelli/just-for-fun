/*
 * Objective: Swap black and white knights
 *
 * Inital Board layout:
 *
 *    +----+----+----+----+----+
 *  5 | BL | BL | BL | BL | WH |
 *    +----+----+----+----+----+
 *  4 | BL | BL | BL | WH | WH |
 *    +----+----+----+----+----+
 *  3 | BL | BL |    | WH | WH |
 *    +----+----+----+----+----+
 *  2 | BL | BL | WH | WH | WH |
 *    +----+----+----+----+----+
 *  1 | BL | WH | WH | WH | WH |
 *    +----+----+----+----+----+
 *      a    b    c    d    e
 *
 *   BL = Black Knight
 *   WH = WHite Knight
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define START_KNIGHTS 0x1ee6310
#define END_KNIGHTS   0x0118cef

typedef struct MoveNode {
  char *move;
  struct MoveNode *next;
  struct MoveNode *end;
} MoveNode;

typedef struct State {
  MoveNode *moves;
  int value;
  struct State *next;
} State;

typedef struct {
  State  *start;
  State  *end;
  int size;
} StateQueue;

MoveNode *new_move_node(char *move);
MoveNode *copy_move_node(MoveNode *moves);
void push_move_node(MoveNode* moves, char *move);
void free_move_node(MoveNode *move_node);

State* new_state(MoveNode *prev_moves, char *move, int value);
void free_state(State *state);

void enqueue_state(StateQueue* queue, State *state);
State *dequeue_state(StateQueue* queue);

int main(int argc, char **argv) {
  int bitmap_index[] = {
    0x0000001, 0x0000002, 0x0000004, 0x0000008, 0x0000010,
    0x0000020, 0x0000040, 0x0000080, 0x0000100, 0x0000200,
    0x0000400, 0x0000800, 0x0001000, 0x0002000, 0x0004000,
    0x0008000, 0x0010000, 0x0020000, 0x0040000, 0x0080000,
    0x0100000, 0x0200000, 0x0400000, 0x0800000, 0x1000000
  };

  char *label_index[] = {
    "a5", "b5", "c5", "d5", "e5",
    "a4", "b4", "c4", "d4", "e4",
    "a3", "b3", "c3", "d3", "e3",
    "a2", "b2", "c2", "d2", "e2",
    "a1", "b1", "c1", "d1", "e1"
  };

  int legal_moves_to_square[][9] = {
    {7, 11, -1},
    {8, 10, 12, -1},
    {5, 9, 11, 13, -1},
    {6, 12, 14, -1},
    {7, 13, -1},
    {2, 12, 16, -1},
    {3, 13, 15, 17, -1},
    {0, 4, 10, 14, 16, 18, -1},
    {1, 11, 17, 19, -1},
    {2, 12, 18, -1},
    {1, 7, 17, 21, -1},
    {0, 2, 8, 18, 20, 22, -1},
    {1, 3, 5, 9, 15, 19, 21, 23, -1},
    {2, 4, 6, 16, 22, 24, -1},
    {3, 7, 17, 23, -1},
    {6, 12, 22, -1},
    {5, 7, 13, 23, -1},
    {6, 8, 10, 14, 20, 24, -1},
    {7, 9, 11, 21, -1},
    {8, 12, 22, -1},
    {11, 17, -1},
    {10, 12, 18, -1},
    {11, 13, 15, 19, -1},
    {12, 14, 16, -1},
    {13, 17, -1}
  };

  return 0;
}

MoveNode *new_move_node(char *move) {
  MoveNode* node = malloc(sizeof (MoveNode));

  node->move = strdup(move);
  node->next = NULL;
  node->end  = NULL;

  return node;
}

void push_move_node(MoveNode* moves, char *move) {
  if (moves->end) {
    moves->end->next = new_move_node(move);
    moves->end       = moves->end->next;
  }
  else {
    moves->next = new_move_node(move);
    moves->end  = moves->next;
  }
}

MoveNode *copy_move_node(MoveNode *moves) {
  MoveNode *node, *start = new_move_node(moves->move);

  for (node = moves->next; node; node = node->next) {
    push_move_node(start, node->move);
  }

  return start;
}

void free_move_node(MoveNode* move_node) {
  while (move_node) {
    MoveNode* node = move_node;
    move_node = node->next;
    free(node->move);
    free(node);
  }
}

State* new_state(MoveNode *prev_moves, char *move, int value) {
  State *state = malloc(sizeof (State));

  state->value = value;
  state->next  = NULL;

  if (prev_moves) {
    state->moves = copy_move_node(prev_moves);
    push_move_node(state->moves, move);
  }
  else {
    state->moves = new_move_node(move);
  }

  return state;
}

void free_state(State *state) {
  free_move_node(state->moves);
  free(state);
}

void enqueue_state(StateQueue* queue, State *state) {
  queue->size += 1;

  if (queue->start) {
    queue->end->next = state;
  }
  else {
    queue->start = state;
  }

  queue->end = state;
}

State *dequeue_state(StateQueue* queue) {
  State *state = queue->start;

  if (queue->size <= 0) {
    return NULL;
  }

  queue->size -= 1;
  queue->start = state->next;

  return state;
}
