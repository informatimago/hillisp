#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>
#include "lisp.h"

__managed__ x_any x_nil;
__managed__ x_any x_true;
__managed__ x_any x_dot;
__managed__ x_any x_left;
__managed__ x_any x_right;
__managed__ x_any x_eof;


char* new_name(const char* name) {
  char *n;
  cudaMallocManaged(&n, strlen(name) + 1);
  assert(n != NULL);
  strcpy(n, name);
  return n;
}

x_any new_cell(const char* name) {
  x_any cell;
  cudaMallocManaged(&cell, sizeof(x_cell));
  assert(cell != NULL);
  name(cell) = new_name(name);
  return cell;
}

x_any def_token(const char* new_name) {
  x_any cell;
  cell = new_cell(new_name);
  flags(cell) = TOKEN;
  return cell;
}

hash_table_type hash_table;

int hash(const char *name)
{
  int value = 0;
  while (*name != '\0')
    value = (value * HASH_MULTIPLIER + *name++) % HASH_TABLE_SIZE;
  return value;
}

x_any lookup(const char *name, x_any cell)
{
  if (cell == x_nil)
    return NULL;
  else if (strcmp(name(car(cell)), name) == 0)
    return car(cell);
  else
    return lookup(name, cdr(cell));
}

x_any create_symbol(const char *new_name)
{
  x_any cell;
  cell = new_cell(new_name);
  flags(cell) = SYMBOL;
  return cell;
}

void print_list(x_any, FILE*);

void print_cell(x_any cell, FILE *outfile)
{
  if (is_atom(cell))
    fprintf(outfile, "%s", name(cell));
  else {
    putc('(', outfile);
    print_list(cell, outfile);
  }
}

void print_list(x_any cell, FILE *outfile)
{
  print_cell(car(cell), outfile);
  if (cdr(cell) == x_nil)
    putc(')', outfile);
  else if (!is_pair(cdr(cell)) ) {
    fprintf(outfile, " . ");
    print_cell(cdr(cell), outfile);
    putc(')', outfile);
  }
  else {
    putc(' ', outfile);
    print_list(cdr(cell), outfile);
  }
}


__device__ __host__ x_any x_car(x_any cell)
{
  return car(cell);
}

__device__ __host__ x_any x_cdr(x_any cell)
{
  return cdr(cell);
}

x_any x_cons(x_any cell1, x_any cell2)
{
  x_any cell;
  cudaMallocManaged(&cell, sizeof(x_cell));
  assert(cell != NULL);
  flags(cell) = PAIR;
  car(cell) = cell1;
  cdr(cell) = cell2;
  return cell;
}

void enter(x_any cell)
{
  int hash_val;

  hash_val = hash(name(cell));
  hash_table[hash_val] = x_cons(cell, hash_table[hash_val]);
}

x_any intern(const char *name)
{
  x_any cell;

  cell = lookup(name, hash_table[hash(name)]);
  if (cell != NULL)
    return cell;
  else {
    cell = create_symbol(name);
    enter(cell);
    return cell;
  }
}

x_any x_print(x_any cell)
{
  print_cell(car(cell), stdout);
  putchar('\n');
  return car(cell);
}

int length(x_any cell)
{
  if (cell == x_nil)
    return 0;
  else
    return 1 + length(cdr(cell));
}

x_any x_eval(x_any);

x_any list_eval(x_any cell)
{
  if (cell == x_nil)
    return x_nil;
  else
    return x_cons(x_eval(car(cell)), list_eval(cdr(cell)));
}

x_any x_apply(x_any cell, x_any args)
{
  if (is_symbol(cell))
    return x_cons(cell, args);
  if (is_pair(cell))
    return x_cons(x_eval(cell), args);
  if (is_builtin(cell))
    switch (size(cell)) {
    case 0:
      return ((x_fn0)data(cell))();
    case 1:
      return ((x_fn1)data(cell))(args);
    case 2:
      return ((x_fn2)data(cell))(args, cdr(args));
    case 3:
      return ((x_fn3)data(cell))(args, cdr(args), car(cdr(args)));
    }
  else if (is_user(cell))
    return x_apply((x_any)data(cell), args);
  else
    assert(0);
  return x_nil;
}

x_any x_quote(x_any cell)
{
  return car(cell);
}

x_any x_eval(x_any cell)
{
  if (is_atom(cell))
    return cell;
  else if (is_pair(cell) && (is_symbol(car(cell))))
    return x_cons(car(cell), list_eval(cdr(cell)));
  else
    return x_apply(car(cell), list_eval(cdr(cell)));
}

x_any intern(const char*);

x_any def_builtin(char const *name, void *fn, size_t num_args)
{
  x_any cell;

  cell = intern(name);
  flags(cell) = BUILTIN;
  data(cell) = fn;
  size(cell) = num_args;
  return cell;
}

x_any read_token(FILE *infile)
{
  int c;
  static char buf[MAX_NAME_LEN];
  char *ptr = buf;

  do {
    c = getc(infile);
    if (c == ';')
      do c = getc(infile); while (c != '\n' && c != EOF);
  } while (isspace(c));
  switch (c) {
  case EOF:
    return x_eof;
  case '(':
    return x_left;
  case ')':
    return x_right;
  case '.':
    return x_dot;
  default:
    *ptr++ = c;
    while ((c = getc(infile)) != EOF && !isspace(c) && c != '(' && c != ')')
      *ptr++ = c;
    if (c != EOF)
      ungetc(c, infile);
    *ptr = '\0';
    return intern(buf);
  }
}

x_any read_sexpr(FILE*);
x_any read_token(FILE*);

x_any read_cdr(FILE *infile)
{
  x_any cdr;
  x_any token;

  cdr = read_sexpr(infile);
  token = read_token(infile);

  if (token == x_right)
    return cdr;
  else
    assert(0);
  return x_nil;
}

x_any read_head(FILE*);

x_any read_tail(FILE *infile)
{
  x_any token;
  x_any temp;

  token = read_token(infile);

  if (is_symbol(token) || is_builtin(token))
    return x_cons(token, read_tail(infile));

  if (token == x_left) {
    temp = read_head(infile);
    return x_cons(temp, read_tail(infile));
  }

  if (token == x_dot)
    return read_cdr(infile);

  if (token == x_right)
    return x_nil;

  if (token == x_eof)
    assert(0);
  return x_nil;
}

x_any read_head(FILE *infile)
{
  x_any token;
  x_any temp;

  token = read_token(infile);
  if (is_symbol(token) || is_builtin(token))
    return x_cons(token, read_tail(infile));
  if (token == x_left) {
    temp = read_head(infile);
    return x_cons(temp, read_tail(infile));
  }
  if (token == x_right)
    return x_nil;
  if (token == x_dot)
    assert(0);
  if (token == x_eof)
    assert(0);
  return x_nil;
}

x_any read_sexpr(FILE *infile)
{
  x_any token;

  token = read_token(infile);
  if (is_symbol(token) || is_builtin(token))
    return token;
  if (token == x_left)
    return read_head(infile);
  if (token == x_right)
    assert(0);
  if (token == x_dot)
    assert(0);
  if (token == x_eof)
    return token;
  return x_nil;
}

void init(void)
{
  x_dot = def_token(".");
  x_left = def_token("(");
  x_right = def_token(")");
  x_eof = def_token("EOF");

  x_nil = create_symbol("nil");
  for (int i = 0; i < HASH_TABLE_SIZE; i++)
    hash_table[i] = x_nil;
  enter(x_nil);
  x_true = intern("true");

  def_builtin("car", (void*)x_car, 1);
  def_builtin("cdr", (void*)x_cdr, 1);
  def_builtin("cons", (void*)x_cons, 2);
  def_builtin("quote", (void*)x_quote, 1);
  def_builtin("eval", (void*)x_eval, 1);
  def_builtin("apply", (void*)x_apply, 2);
  def_builtin("print", (void*)x_print, 1);
}

int main(int argc, const char* argv[])
{
  x_any expr;
  x_any value;

  init();
  for (;;) {
    printf("? ");
    expr = read_sexpr(stdin);
    if (expr == x_eof)
      break;
    value = x_eval(expr);
    printf(": ");
    print_cell(value, stdout);
    putchar('\n');
  }
}
