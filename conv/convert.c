#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "csv.h"
/* Basic CSV Parsing - WIP */

enum { NOMEM = -2 };            /* out of memory signal */

static int  max_line    = 0;     /* size of line[] and sep_line[] */
static int  max_field   = 0;     /* size of field[] */
static int  nfields     = 0;     /* number of fields in field[] */
static int  h_count     = 0;     /* counter to check if header */
static char *line       = NULL;  /* input chars */
static char **field     = NULL;  /* field pointers */
static char *sep_line   = NULL;  /* line copy used by split */
static char **headers   = NULL;  /* the header */
static char field_sep[] = ",";   /* field separator chars */

static char *advquoted(char *);
static int split(void);
static int endofline(FILE *fin, int c) /* endofline: check for and consume \r, \n, \r\n, or EOF */
{
  int eol;

  eol = (c == '\r' || c == '\n');
  if (c == '\r') {
    c = getc(fin);
    if (c != '\n' && c != EOF) ungetc(c, fin);  /* read too far; put c back */
  }

  return eol;
}

static void reset(void) /* reset: set variables back to starting values */
{
  free(line);            /* free(NULL) permitted by ANSI C */
  free(sep_line);
  free(field);
  line     = NULL;
  sep_line = NULL;
  field    = NULL;
  max_line = max_field = nfields = 0;
}

/* csvgetline:  get one line, grow as needed */
char *csvgetline(FILE *fin)
{
  int i, c;
  char *new_line, *new_sep;

  if (line == NULL) {      /* allocate on first call */
    max_line = max_field = 1;
    line     = (char *)  malloc(max_line);
    sep_line = (char *)  malloc(max_line);
    field    = (char **) malloc(max_field * sizeof(field[0]));

    if (line == NULL || sep_line == NULL || field == NULL) {
      reset();
      return NULL; /* out of memory */
    }
  }

  for (i = 0; (c = getc(fin)) != EOF && !endofline(fin,c); i++) {
    if (i >= max_line - 1) {  /* grow line */
      max_line *= 2;          /* double current size */
      new_line = (char *) realloc(line, max_line);

      if (new_line == NULL) {
        reset();
        return NULL;
      }

      line = new_line;
      new_sep = (char *) realloc(sep_line, max_line);

      if (new_sep == NULL) {
        reset();
        return NULL;
      }

      sep_line = new_sep;
    }

    line[i] = c;
  }

  line[i] = '\0';
  if (split() == NOMEM) {
    reset();
    return NULL;      /* out of memory */
  }

  /* If first line of csv, */
  if (h_count == 0) {
    headers = (char **) malloc(csvnfield());
  }

  return (c == EOF && i == 0) ? NULL : line;
}

/* split: split line into fields */
static int split(void)
{
  char *p, **newf;
  char *sepp; /* pointer to temporary separator character */
  int sepc;   /* temporary separator character */

  nfields = 0;
  if (line[0] == '\0') return 0;
  strcpy(sep_line, line);
  p = sep_line;

  do {
    if (nfields >= max_field) {
      max_field *= 2;      /* double current size */
      newf = (char **) realloc(field,
            max_field * sizeof(field[0]));

      if (newf == NULL) return NOMEM;
      field = newf;
    }

    if (*p == '"') {
      sepp = advquoted(++p);  /* skip initial quote */
    } else {
      sepp = p + strcspn(p, field_sep);
    }

    sepc = sepp[0];
    sepp[0] = '\0';        /* terminate field */
    field[nfields++] = p;
    p = sepp + 1;
  } while (sepc == ',');

  return nfields;
}

/* advquoted: quoted field; return pointer to next separator */
static char *advquoted(char *p)
{
  int i, j, k;

  for (i = j = 0; p[j] != '\0'; i++, j++) {
    if (p[j] == '"' && p[++j] != '"') {
      /* copy up to next separator or \0 */
      k = strcspn(p+j, field_sep);
      memmove(p+i, p+j, k);
      i += k;
      j += k;
      break;
    }

    p[i] = p[j];
  }

  p[i] = '\0';
  return p + j;
}

/* csvfield:  return pointer to n-th field */
char *csvfield(int n)
{
  if (n < 0 || n >= nfields) return NULL;

  /* Assigning headers, the header array, if this is the first iteration */
  if (h_count == 0) headers[n] = strdup(field[n]);

  return field[n];
}

/* csvnfield:  return number of fields */
int csvnfield(void)
{
  return nfields;
}

/* Printing in JSON format to console */
void json_print(int x)
{
  int y;

  if (x != 1) printf("\n  },  \n");
  printf("  Row %d: {", x);

  for (y = 0; y < nfields-2; y++) {
    printf("\n    %s: %s,", headers[y], csvfield(y));
  }

  printf("\n    %s: %s", headers[nfields-1], csvfield(nfields-1));
}

/* csvtest main: test CSV library */
int main(void)
{
  int i;
  int x = 0;
  char *line;

  while ((line = csvgetline(stdin)) != NULL) {
    if (x == 0) {
      for (i = 0; i < csvnfield(); i++)
        csvfield(i);

      printf("{\n");
    } else {
      json_print(x);
    }

    if (x == 0) h_count = 1;
    x++;
  }

  printf("\n  }  \n}\n");
  return 0;
}
