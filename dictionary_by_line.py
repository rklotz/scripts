'''
The program looks for 'From ' lines in a mailbox file and takes the second word of those lines as the person who sent the mail.
The program creates a Python dictionary that maps the sender's mail address to a count of the number of times
they appear in the file. After the dictionary is produced, the program reads through the dictionary using a maximum
loop to find the most prolific committer.
'''

name = raw_input("Enter path to a mailbox file:") # Prompt user for a valid mailbox filename and path

try:
    handle = open(name)
except:
    print "Sorry, cannot open the file"
    exit()

my_dict={}
for line in handle:
    if line.startswith('From '):
        line = line.split()
        sender=line[1]
        my_dict[sender] = my_dict.get(sender,0)+1

maxcount=None
maxname=None
for name,number in my_dict.items():
    if number == None or number > maxcount:
        maxcount=number
        maxname=name

print maxname,maxcount
