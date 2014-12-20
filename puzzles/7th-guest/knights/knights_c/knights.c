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
 *      A    B    C    D    E
 *
 *   BL = Black Knight
 *   WH = WHite Knight
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#define EMPTY_SPOT_INDEX(board)         board & 0x1F
#define IS_WHITE_KNIGHT(board, index)  (board & KNIGHT_BITMAP[index]) > 0
#define MOVE_KNIGHT(board, start, end)                          \
    ( IS_WHITE_KNIGHT(board, start)                             \
        ?   board & ~KNIGHT_BITMAP[start] | KNIGHT_BITMAP[end]  \
        :   board                                               \
    ) & ~0x1F | start

int START_BOARD = 0x3dcc620c;
int END_BOARD   = 0x02319dec;

int KNIGHT_BITMAP[] = {
  0x00000020, 0x00000040, 0x00000080, 0x00000100, 0x00000200,
  0x00000400, 0x00000800, 0x00001000, 0x00002000, 0x00004000,
  0x00008000, 0x00010000, 0x00020000, 0x00040000, 0x00080000,
  0x00100000, 0x00200000, 0x00400000, 0x00800000, 0x01000000,
  0x02000000, 0x04000000, 0x08000000, 0x10000000, 0x20000000
};

char *LABEL_INDEX[] = {
  "A5", "B5", "C5", "D5", "E5",
  "A4", "B4", "C4", "D4", "E4",
  "A3", "B3", "C3", "D3", "E3",
  "A2", "B2", "C2", "D2", "E2",
  "A1", "B1", "C1", "D1", "E1"
};

int LEGAL_MOVES_TO_INDEX[][9] = {
  {0x07, 0x0b,                                       -1},
  {0x08, 0x0a, 0x0c,                                 -1},
  {0x05, 0x09, 0x0b, 0x0d,                           -1},
  {0x06, 0x0c, 0x0e,                                 -1},
  {0x07, 0x0d,                                       -1},
  {0x02, 0x0c, 0x10,                                 -1},
  {0x03, 0x0d, 0x0f, 0x11,                           -1},
  {0x00, 0x04, 0x0a, 0x0e, 0x10, 0x12,               -1},
  {0x01, 0x0b, 0x11, 0x13,                           -1},
  {0x02, 0x0c, 0x12,                                 -1},
  {0x01, 0x07, 0x11, 0x15,                           -1},
  {0x00, 0x02, 0x08, 0x12, 0x14, 0x16,               -1},
  {0x01, 0x03, 0x05, 0x09, 0x0f, 0x13, 0x15, 0x17,   -1},
  {0x02, 0x04, 0x06, 0x10, 0x16, 0x18,               -1},
  {0x03, 0x07, 0x11, 0x17,                           -1},
  {0x06, 0x0c, 0x16,                                 -1},
  {0x05, 0x07, 0x0d, 0x17,                           -1},
  {0x06, 0x08, 0x0a, 0x0e, 0x14, 0x18,               -1},
  {0x07, 0x09, 0x0b, 0x15,                           -1},
  {0x08, 0x0c, 0x16,                                 -1},
  {0x0b, 0x11,                                       -1},
  {0x0a, 0x0c, 0x12,                                 -1},
  {0x0b, 0x0d, 0x0f, 0x13,                           -1},
  {0x0c, 0x0e, 0x10,                                 -1},
  {0x0d, 0x11,                                       -1}
};

typedef uint32_t Board;

typedef struct Move {
  Board board;
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

Move *new_move(Board board);
void print_moves(Move *moves);
char *move_to_str(Move *moves);
void free_moves(Move *moves);

State* new_state(Move *moves, Board board);
void free_state(State *state);

void enqueue_state(StateQueue* queue, State *state);
State *dequeue_state(StateQueue* queue);

int is_solved(Board board);

int main(int argc, char **argv) {
  StateQueue queue;
  State *state;
  int tries;
  char *already_queued;
  size_t buf_size = sizeof (char) * (1 << 30);

  if (!(already_queued = malloc(buf_size))) {
    fprintf(stderr, "malloc() failed, reason: %s\n", strerror(errno));
    exit(1);
  }

  memset(already_queued, '\0', buf_size);
  memset(&queue,         '\0', sizeof (queue));

  state = new_state(NULL, START_BOARD);
  tries = 0;
  enqueue_state(&queue, state);
  already_queued[START_BOARD] = 1;

  while (queue.size > 0) {
    int empty_spot, board;
    int *next;
    int new_board, hash;

    tries += 1;
    state = dequeue_state(&queue);

    if (is_solved(state->current->board)) {
      printf("Moves:\n");
      print_moves(state->moves);
      break;
    }

    if ((tries % 10000) == 0) {
      fprintf(stderr, "Checking %d tries. Queue size: %d\n", tries, queue.size);
    }

    board      = state->current->board;
    empty_spot = EMPTY_SPOT_INDEX(board);

    for (next = LEGAL_MOVES_TO_INDEX[empty_spot]; *next != -1; ++next) {
      new_board = MOVE_KNIGHT(board, *next, empty_spot);

      if (!already_queued[new_board]) {
        already_queued[new_board] = 1;
        enqueue_state(&queue, new_state(state->moves, new_board));
      }
    }

    free_state(state);
  }

  return 0;
}

int is_solved(Board board) {
  return board == END_BOARD;
}

Move *new_move(Board board) {
  Move* move = malloc(sizeof (Move));

  move->board = board;
  move->next  = NULL;

  return move;
}


void print_moves(Move *moves) {
  Move *move;
  int prev_empty_index = -1;
  int empty_spot;
  char *str;

  for (move = moves; move; move = move->next) {
    empty_spot = EMPTY_SPOT_INDEX(move->board);

    if (prev_empty_index >= 0) {
      printf(
        "Move %s to %s:\n",
        LABEL_INDEX[empty_spot],
        LABEL_INDEX[prev_empty_index]
      );
    }

    str = move_to_str(move);
    printf("%s\n", str);
    free(str);

    prev_empty_index = empty_spot;
  }
}

char *move_to_str(Move *move) {
  Board board    = move->board;
  int empty_spot = EMPTY_SPOT_INDEX(board);
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
    if (i == empty_spot) {
      strcpy(labels[i], "  ");
    }
    else {
      strcpy(labels[i], IS_WHITE_KNIGHT(board, i) ? "WH" : "BL");
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

State* new_state(Move *moves, Board board) {
  State *state = malloc(sizeof (State));

  state->next = NULL;

  if (moves) {
    Move *last;
    last = state->moves = new_move(moves->board);

    for (moves = moves->next; moves; moves = moves->next) {
      last = last->next = new_move(moves->board);
    }

    state->current = last->next   = new_move(board);
  }
  else {
    state->current = state->moves = new_move(board);
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
