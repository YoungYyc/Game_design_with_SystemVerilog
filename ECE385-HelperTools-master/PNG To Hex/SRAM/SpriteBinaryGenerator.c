/* SpriteParser.c - Parses the t files from matlab into an MIF file format
 */

#include <stdio.h>
#include <stdlib.h>

#define INPUT_FILE "./ECE385-HelperTools-master/PNG To Hex/On-Chip Memory/sprite_bytes/stand2.txt"			// Input filename
#define OUTPUT_FILE "man.ram"		// Name of file to output to
#define NUM_COLORS 	12								// Total number of different colors
#define WIDTH		8								
#define DEPTH		3072

// Use this to define value of each color in the palette
const long Palette_Colors []= {255255255, 19510251, 1971640, 1012815, 1652520, 227212212, 205130126, 15111090, 967447, 1236524, 1795743, 25277102};
int addr = 0;

int main()
{
	char line[21];
	FILE *in = fopen(INPUT_FILE, "r");
	FILE *out = fopen(OUTPUT_FILE, "w");
	size_t num_chars = 20;
	long value = 0;
	int i;
	int *p;

	if(!in)
	{
		printf("Unable to open input file!");
		return -1;
	}
                    
	// Get a line, convert it to an integer, and compare it to the palette values.
	while(fgets(line, num_chars, in) != NULL)
	{
		value = (char)strtol(line, NULL, 10);
		p = (int *)&value;
		fwrite(p, 2, 1, out);
	}

	fclose(out);
	fclose(in);
	return 0;
}
