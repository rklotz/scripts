''' Python script to extract out all of the numbers from a file, add them into a list and
then provide the total sum'''

import re

try:
    file_handle = open('<add your file path here>', 'r')
except:
    print "Sorry dude, cannot open this file"
    exit()
total_list =[]

for line in file_handle:
   numbers = re.findall('([0-9]+)',line)
   if len(numbers) < 1: continue

   else:
       for number in numbers:
           total_list.append(int(number))
print sum(total_list)