####xpmGlitcher####

The ruby-answer to cliché glitches

examples: [xpmGlitcher][1]

#### requirements ####

 - ruby > 1.8.7 (tested on 1.9.2)
 - imagemagick ([imagemagick)][2]

#### usage ####
`ruby xpmglitch.rb [mode] <inputfile> [output count]"`

 - modes available so far: `-m a`,`-m d`,`-m c`,`-m d`,`-m e`
 - calling without a specified mode yields a random mode
 - optionally takes a number to produce `n` outputs from the same source in one execution

#### next steps? #####
Might be fruitful (as much as making glitches could be) to load all the *pixels* into one row and only after processing divide them back into original (or scaled) rows.


  [1]: http://www.kaniowski.info/XpmGlitcher/
  [2]: http://www.imagemagick.org/
