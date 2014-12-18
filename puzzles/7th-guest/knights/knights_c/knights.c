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
