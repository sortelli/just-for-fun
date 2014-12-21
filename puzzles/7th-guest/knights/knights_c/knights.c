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

typedef struct State {
  Board *boards;
  Board *last;
  struct State *next;
} State;

typedef struct {
  State  *start;
  State  *end;
  int size;
} StateQueue;

char *board_to_str(Board board);

State* new_state(State *prev_state, Board board);
void free_state(State *state);
void print_state(State *state);
int is_solved(State *state);

void enqueue_state(StateQueue *queue, State *state);
State *dequeue_state(StateQueue *queue);


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

    if (is_solved(state)) {
      printf("Moves:\n");
      print_state(state);
      break;
    }

    if ((tries % 100000) == 0) {
      fprintf(stderr, "Checking %d tries. Queue size: %d\n", tries, queue.size);
    }

    board      = *(state->last);
    empty_spot = EMPTY_SPOT_INDEX(board);

    for (next = LEGAL_MOVES_TO_INDEX[empty_spot]; *next != -1; ++next) {
      new_board = MOVE_KNIGHT(board, *next, empty_spot);

      if (!already_queued[new_board]) {
        already_queued[new_board] = 1;
        enqueue_state(&queue, new_state(state, new_board));
      }
    }

    free_state(state);
  }

  return 0;
}

char *board_to_str(Board board) {
  int empty_spot = EMPTY_SPOT_INDEX(board);
  int spot;
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

  for (spot = 0; spot < 25; ++spot) {
    if (spot == empty_spot) {
      strcpy(labels[spot], "  ");
    }
    else {
      strcpy(labels[spot], IS_WHITE_KNIGHT(board, spot) ? "WH" : "BL");
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

void print_state(State *state) {
  Board *board;
  int prev_empty = -1;
  int empty;
  char *str;

  for (board = state->boards; board <= state->last; ++board) {
    empty = EMPTY_SPOT_INDEX(*board);

    if (prev_empty >= 0) {
      printf("Move %s to %s:\n", LABEL_INDEX[empty], LABEL_INDEX[prev_empty]);
    }

    str = board_to_str(*board);
    printf("%s\n", str);
    free(str);

    prev_empty = empty;
  }
}

State* new_state(State *prev_state, Board board) {
  State *state = malloc(sizeof (State));

  state->next = NULL;

  if (prev_state) {
    size_t size = (prev_state->last - prev_state->boards) + 1;

    if (!(state->boards = calloc(size + 1, sizeof (Board)))) {
      fprintf(stderr, "calloc() failed, reason: %s\n", strerror(errno));
      exit(2);
    }

    memcpy(state->boards, prev_state->boards, size * sizeof (Board));
    state->last = state->boards + size;
    state->boards[size] = board;
  }
  else {
    if (!(state->boards = malloc(sizeof (Board)))) {
      fprintf(stderr, "malloc() failed, reason: %s\n", strerror(errno));
      exit(3);
    }
    state->last = state->boards;
    state->boards[0] = board;
  }

  return state;
}

void free_state(State *state) {
  free(state->boards);
  free(state);
}

int is_solved(State *state) {
  return *(state->last) == END_BOARD;
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
