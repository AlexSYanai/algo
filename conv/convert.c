#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include "csv.h"
/* Basic CSV Parsing - WIP */

enum { NOMEM = -2 };          /* out of memory signal */

static char *line    = NULL;  /* input chars */
static char *sline   = NULL;  /* line copy used by split */
static int  maxline  = 0;     /* size of line[] and sline[] */
static char **field  = NULL;  /* field pointers */
static int  maxfield = 0;     /* size of field[] */
static int  nfield   = 0;     /* number of fields in field[] */
static int  h_count  = 0;     /* counter to check if header */
static char **h_ary  = NULL;	/* the header */
static char fieldsep[] = ","; /* field separator chars */
static char *advquoted(char *);
static int split(void);

static int endofline(FILE *fin, int c) /* endofline: check for and consume \r, \n, \r\n, or EOF */
{
	int eol;

	eol = (c=='\r' || c=='\n');
	if (c == '\r') {
		c = getc(fin);
		if (c != '\n' && c != EOF)
			ungetc(c, fin);	/* read too far; put c back */
	}
	return eol;
}

static void reset(void) /* reset: set variables back to starting values */
{
	free(line);	/* free(NULL) permitted by ANSI C */
	free(sline);
	free(field);
	line = NULL;
	sline = NULL;
	field = NULL;
	maxline = maxfield = nfield = 0;
}

/* csvgetline:  get one line, grow as needed */
char *csvgetline(FILE *fin)
{	
	int i, c, a;
	char *newl, *news;

	if (line == NULL) {			/* allocate on first call */
		maxline = maxfield = 1;
		line = (char *) malloc(maxline);
		sline = (char *) malloc(maxline);
		field = (char **) malloc(maxfield*sizeof(field[0]));
		if (line == NULL || sline == NULL || field == NULL) {
			reset();
			return NULL;		/* out of memory */
		}
	}

	for (i = 0; (c = getc(fin)) != EOF && !endofline(fin,c); i++) {
		if (i >= maxline - 1) {	/* grow line */
			maxline *= 2;		      /* double current size */
			newl = (char *) realloc(line, maxline);
			if (newl == NULL) {
				reset();
				return NULL;
			}

			line = newl;
			news = (char *) realloc(sline, maxline);

			if (news == NULL) {
				reset();
				return NULL;
			}

			sline = news;
		}

		line[i] = c;
	}

	line[i] = '\0';
	if (split() == NOMEM) {
		reset();
		return NULL;			/* out of memory */
	}

	// If first line of csv, 
	if (h_count == 0) {
		h_ary = (char **) malloc(csvnfield());
	}

	return (c == EOF && i == 0) ? NULL : line;
}

/* split: split line into fields */
static int split(void)
{
	char *p, **newf;
	char *sepp; /* pointer to temporary separator character */
	int sepc;   /* temporary separator character */

	nfield = 0;
	if (line[0] == '\0') return 0;
	strcpy(sline, line);
	p = sline;

	do {
		if (nfield >= maxfield) {
			maxfield *= 2;			/* double current size */
			newf = (char **) realloc(field, 
						maxfield * sizeof(field[0]));

			if (newf == NULL) return NOMEM;
			field = newf;
		}

		if (*p == '"') {
			sepp = advquoted(++p);	/* skip initial quote */
		} else {
			sepp = p + strcspn(p, fieldsep);
		}

		sepc = sepp[0];
		sepp[0] = '\0';				/* terminate field */
		field[nfield++] = p;
		p = sepp + 1;
	} while (sepc == ',');

	return nfield;
}

/* advquoted: quoted field; return pointer to next separator */
static char *advquoted(char *p)
{
	int i, j, k;

	for (i = j = 0; p[j] != '\0'; i++, j++) {
		if (p[j] == '"' && p[++j] != '"') {
			/* copy up to next separator or \0 */
			k = strcspn(p+j, fieldsep);
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

// Printing in JSON format to console
void Json_print(int x)
{
	int y;

	if (x != 1) printf("\n  },  \n");
	printf("  Row %d: {", x);

	for (y = 0; y < nfield-2; y++) {
		printf("\n    %s: %s,", h_ary[y], csvfield(y));
	}

	printf("\n    %s: %s", h_ary[nfield-1], csvfield(nfield-1));
}

/* csvfield:  return pointer to n-th field */
char *csvfield(int n)
{
	if (n < 0 || n >= nfield) return NULL;
	
	// Assigning h_ary, the header array, if this is the first iteration
	if (h_count == 0) h_ary[n] = strdup(field[n]);

	return field[n];
}

/* csvnfield:  return number of fields */ 
int csvnfield(void)
{
	return nfield;
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
			Json_print(x);
		}

		if (x == 0) h_count = 1;
		x++;
	}
	
	printf("\n  }  \n}\n");
	return 0;
}
