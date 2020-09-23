# UnsnappedNotesFinder

random white arrow bad

Distance to closest snap will be measured for each snap given and the smallest distance is the one shown.

Lenience determines how many milliseconds of error is allowed for a note to still be treated as snapped. Lenience is by default set to 1, and will find white colored notes, along with notes that have proper beat snap coloring, but are off by 1+ ms. Setting lenience high enough (around 5) will cause the plugin to only find white colored notes, but set it too high and all notes will be treated as snapped. Set it to 0 to check the distances for every note, regardless of snap.

If the checkbox is ticked, then only selected notes will be checked for unsnaps.
