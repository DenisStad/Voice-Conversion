form Convert sound to pitch marks
	sentence Inputfile .
	sentence Outputfile .
endform
do("Read from file...",inputfile$)
selectObject(1)
do("To PointProcess (periodic, cc)...", 75, 600)
selectObject(2)
do("Save as text file...", outputfile$)