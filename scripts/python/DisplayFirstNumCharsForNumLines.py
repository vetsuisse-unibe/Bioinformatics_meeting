''' Author: Victor C Mason '''
''' Date: April 13, 2015 '''
'''
Script will print the specified number of lines, and number of characters from those lines to an output file
Note: Do not specify more lines than are in the file.
Contact: victor.mason@vetsuisse.unibe.ch
'''

'''
#Example input file:
108 108 0 0 0 -9 T T G G T T A A A A G G A A C C A A G G C C A A G G G G T T A A A A A A G G T T C C
1115 1115 0 0 0 -9 T T A G T T A A A A A G A A C C A A G G C T G A G A A G T T A A G A A A G A T T T
1145 1145 0 0 0 -9 T T A G T T A A A A G G A A T C A A G G C T A A G A G G T T A A A A A A G A T T C
115 115 0 0 0 -9 T T G G T T A A A A G G A A C C A A G G C C A A G G G G T T A A A A A A G G T T C C
1155 1155 0 0 0 -9 T T A G T T A A A A G G A A T C A A G G C T A A G A G G T T A A A A A A G A T T C
121 121 0 0 0 -9 T T G G T T A A A A G G A A T C A A G G C T A A G A G G T T A A A A A A G A T T C C
124 124 0 0 0 -9 T T A G T T A A A A G G A A T C A A G G T T G A A A A G T T A A G A A A A A T T T C
126 126 0 0 0 -9 T T G G T T A A A A G G A A C C A A A G C T G A G G A G T T A A G A A A G A T T T C
130 130 0 0 0 -9 T T A G T T G A A A A G A A C C A A G G C T G A G A A G T T A A G A A A G A T T T C
139 139 0 0 0 -9 T T G G C T A A A A G G A A C C A A 0 0 T T G G G A A G T T A A G G A A A A T T T T
#
#Example output file:
108 108 0 
1115 1115 
1145 1145 
115 115 0 
1155 1155 

#Command:
python DisplayFirstNumCharsForNumLines.py
'''

f = 'test.ped' # input filename
outfile = 'ViewNumChars.out' # output file name
numchars = 10
numlines = 5

def main():
	output = ''
	FILE = open(f, 'r')
	for i, line in enumerate(FILE):
		if i == numlines:
			break
		print line.strip()[:numchars]
		output += line.strip()[:numchars] + '\n'
	FILE.close()
	OUT = open(outfile, 'w')
	OUT.write(output)
	OUT.close()
main()
