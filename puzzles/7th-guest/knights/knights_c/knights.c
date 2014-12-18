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
#include <errno.h>

int START_KNIGHTS             = 0x1ee6310;
int START_KNIGHTS_EMPTY_INDEX = 12;
int END_KNIGHTS               = 0x0118cef;
int END_KNIGHTS_EMPTY_INDEX   = 12;

int BITMAP_INDEX[] = {
  0x0000001, 0x0000002, 0x0000004, 0x0000008, 0x0000010,
  0x0000020, 0x0000040, 0x0000080, 0x0000100, 0x0000200,
  0x0000400, 0x0000800, 0x0001000, 0x0002000, 0x0004000,
  0x0008000, 0x0010000, 0x0020000, 0x0040000, 0x0080000,
  0x0100000, 0x0200000, 0x0400000, 0x0800000, 0x1000000
};

char *LABEL_INDEX[] = {
  "a5", "b5", "c5", "d5", "e5",
  "a4", "b4", "c4", "d4", "e4",
  "a3", "b3", "c3", "d3", "e3",
  "a2", "b2", "c2", "d2", "e2",
  "a1", "b1", "c1", "d1", "e1"
};

int LEGAL_MOVES_TO_SQUARE[][9] = {
  { 7, 11, -1},
  { 8, 10, 12, -1},
  { 5,  9, 11, 13, -1},
  { 6, 12, 14, -1},
  { 7, 13, -1},
  { 2, 12, 16, -1},
  { 3, 13, 15, 17, -1},
  { 0,  4, 10, 14, 16, 18, -1},
  { 1, 11, 17, 19, -1},
  { 2, 12, 18, -1},
  { 1,  7, 17, 21, -1},
  { 0,  2,  8, 18, 20, 22, -1},
  { 1,  3,  5,  9, 15, 19, 21, 23, -1},
  { 2,  4,  6, 16, 22, 24, -1},
  { 3,  7, 17, 23, -1},
  { 6, 12, 22, -1},
  { 5,  7, 13, 23, -1},
  { 6,  8, 10, 14, 20, 24, -1},
  { 7,  9, 11, 21, -1},
  { 8, 12, 22, -1},
  {11, 17, -1},
  {10, 12, 18, -1},
  {11, 13, 15, 19, -1},
  {12, 14, 16, -1},
  {13, 17, -1}
};

typedef struct Move {
  int empty_index;
  int knights;
  struct Move *next;
} Move;

typedef struct State {
  Move *moves;
  Move *current;
  struct State *next;
} State;

typedef struct {
  State  *start;
  State  *end;
  int size;
} StateQueue;

Move *new_move(int empty_index, int knights);
void print_moves(Move *moves);
char *move_to_str(Move *moves);
void free_moves(Move *moves);

State* new_state(Move *moves, int empty_index, int knights);
void free_state(State *state);

void enqueue_state(StateQueue* queue, State *state);
State *dequeue_state(StateQueue* queue);

unsigned int state_hash(int empty_index, int knights);
int is_solved(int empty_index, int knights);

int main(int argc, char **argv) {
  StateQueue queue;
  State *state;
  int tries;
  char *already_queued;
  size_t buf_size = sizeof (char) * 0x3ffffff0;

  if (!(already_queued = malloc(buf_size))) {
    fprintf(stderr, "malloc() failed, reason: %s\n", strerror(errno));
    exit(1);
  }

  memset(already_queued, '\0', buf_size);
  memset(&queue,         '\0', sizeof (queue));

  state = new_state(NULL, START_KNIGHTS_EMPTY_INDEX, START_KNIGHTS);
  tries = 0;
  enqueue_state(&queue, state);
  already_queued[state_hash(START_KNIGHTS_EMPTY_INDEX, START_KNIGHTS)] = 1;

  while (queue.size > 0) {
    int empty_index, knights;
    int *legal_move;

    tries += 1;
    state = dequeue_state(&queue);

    empty_index = state->current->empty_index;
    knights     = state->current->knights;

    if ((tries % 10000) == 0) {
      fprintf(stderr, "Checking %d tries. Queue size: %d\n", tries, queue.size);
    }

    if (is_solved(state->current->empty_index, state->current->knights)) {
      printf("Moves:\n");
      print_moves(state->moves);
      break;
    }

    for (legal_move = LEGAL_MOVES_TO_SQUARE[empty_index];
        *legal_move != -1;
       ++legal_move) {
      int start_index, is_white, new_knights, hash;

      start_index = *legal_move;
      is_white    = (knights & BITMAP_INDEX[start_index]) > 0;

      if (is_white) {
        new_knights = (knights | BITMAP_INDEX[empty_index]) & ~BITMAP_INDEX[start_index];
      }
      else {
        new_knights = knights;
      }

      hash = state_hash(start_index, new_knights);

      if (!already_queued[hash]) {
        already_queued[hash] = 1;
        enqueue_state(&queue, new_state(state->moves, start_index, new_knights));
      }
    }

    free_state(state);
  }

  return 0;
}

unsigned int state_hash(int empty_index, int knights) {
  return (unsigned int) (knights << 5) + empty_index;
}

int is_solved(int empty_index, int knights) {
  return empty_index == END_KNIGHTS_EMPTY_INDEX && \
         knights     == END_KNIGHTS;
}

Move *new_move(int empty_index, int knights) {
  Move* move = malloc(sizeof (Move));

  move->empty_index = empty_index;
  move->knights     = knights;
  move->next        = NULL;

  return move;
}


void print_moves(Move *moves) {
  Move *move;
  int prev_empty_index = -1;

  for (move = moves; move; move = move->next) {
    char *str;

    if (prev_empty_index >= 0) {
      printf(
        "Move %s to %s:\n",
        LABEL_INDEX[move->empty_index],
        LABEL_INDEX[prev_empty_index]
      );
    }

    str = move_to_str(move);
    printf("%s\n", str);
    free(str);

    prev_empty_index = move->empty_index;
  }
}

char *move_to_str(Move *move) {
  int i;
  char labels[25][3];
  char *str;
  char *fmt = "      +----+----+----+----+----+\n"
              "    5 | %2s | %2s | %2s | %2s | %2s |\n"
              "      +----+----+----+----+----+\n"
              "    4 | %2s | %2s | %2s | %2s | %2s |\n"
              "      +----+----+----+----+----+\n"
              "    3 | %2s | %2s | %2s | %2s | %2s |\n"
              "      +----+----+----+----+----+\n"
              "    2 | %2s | %2s | %2s | %2s | %2s |\n"
              "      +----+----+----+----+----+\n"
              "    1 | %2s | %2s | %2s | %2s | %2s |\n"
              "      +----+----+----+----+----+\n"
              "        a    b    c    d    e\n";

  str = strdup(fmt);

  for (i = 0; i < 25; ++i) {
    if (i == move->empty_index) {
      strcpy(labels[i], "  ");
    }
    else {
      strcpy(labels[i], (move->knights & BITMAP_INDEX[i]) > 0 ? "WH" : "BL");
    }
  }

  snprintf(str, strlen(fmt), fmt,
    labels[ 0], labels[ 1], labels[ 2], labels[ 3], labels[ 4],
    labels[ 5], labels[ 6], labels[ 7], labels[ 8], labels[ 9],
    labels[10], labels[11], labels[12], labels[13], labels[14],
    labels[15], labels[16], labels[17], labels[18], labels[19],
    labels[20], labels[21], labels[22], labels[23], labels[24]
  );

  return str;
}

void free_moves(Move* moves) {
  while (moves) {
    Move* move = moves;
    moves = moves->next;
    free(move);
  }
}

State* new_state(Move *moves, int empty_index, int knights) {
  State *state = malloc(sizeof (State));

  state->next = NULL;

  if (moves) {
    Move *last;
    last = state->moves = new_move(moves->empty_index, moves->knights);

    for (moves = moves->next; moves; moves = moves->next) {
      last = last->next = new_move(moves->empty_index, moves->knights);
    }

    state->current = last->next   = new_move(empty_index, knights);
  }
  else {
    state->current = state->moves = new_move(empty_index, knights);
  }

  return state;
}

void free_state(State *state) {
  free_moves(state->moves);
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
