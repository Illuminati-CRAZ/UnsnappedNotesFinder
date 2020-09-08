# UnsnappedNotesFinder
random white arrow bad

1/n Snap settings determine which notes count as snapped and which ones don't. By default uses n1 = 12 and n2 = 16 to treat notes snapped to 1/1 (12/12), 1/2 (6/12), 1/3 (4/12), 1/4 (3/12), 1/6 (2/12), 1/12, 1/8 (2/16), and 1/16 as snapped.

Lenience determines how many milliseconds of error is allowed for a note to still be treated as snapped. Lenience is by default set to 1, and will find white colored notes, along with (some?) notes that have proper beat snap coloring, but are off by 1+ ms. Setting lenience high enough (around 5) will cause the plugin to only find white colored notes, but set it too high and all notes will be treated as snapped.
