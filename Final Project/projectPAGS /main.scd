/*
Project Title: projectPAGS
Date: Thu Feb 20 11:55:29 2025

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
_main_ is where we'll organize the "main" tasks of our project.

*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::");
HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectRissetsBells::");
*/


///////////////// load functions, data & synthDefs ///////////////

/*
If we haven't already, we'll want to load functions, data and synthDefs.

*/
(Document.current.dir +/+ "functions.scd").load;
(Document.current.dir +/+ "synthDefs.scd").load;




///////////////// set RT/NRT environment variables ///////////////

~sampleRate = s.sampleRate.isNil.if({   // set sampleRate
    "% sampleRate is %. Try booting rt server.".format(s, s.sampleRate).warn;
}, {
    s.sampleRate.asInteger
});
~serverOptions = ServerOptions.new;
~serverOptions.numOutputBusChannels = 2;  // stereo --> 2 channels
~headerFormat = "WAV";                    // soundfile header format
~sampleFormat = "int24";                  // soundfile sample format

~outputFilePath = PathName.new(
    "%/%/_%.%".format(
        Document.current.dir,
        "sounds",
        PathName.new(Document.current.dir).fileName,
        ~headerFormat.toLower
    )
);


///////////////// set scoring parameter values //////////////////

/*
create score(s)...

e.g.:

~mainScore = ...;
*/

~mainScore = CtkScore.new;  // the main score to be rendered


//////////////////////// add buffers /////////////////////////
/*
NOTE: we could write functions to do this!
*/

// 1) collect soundFiles - and instance ctkBuffers
~mySoundFiles = SoundFile.collect(Document.current.dir +/+ "sounds/*");

/*
buffers are collected into a dictionary, where the key is the soundfile name
*/
~mySFBufferDict = Dictionary.newFrom(
	~mySoundFiles.collect({ |item|
		var itemPath = item.path;
		[
			PathName.new(itemPath).fileNameWithoutExtension.replace(".", "_").asSymbol,
			CtkBuffer.playbuf(itemPath)
		]
	}).flatten
);

// GrainBuf uses only mono buffers, so also we need a dictionary with split left & right buffers!
~mySplitSFBufferDict = Dictionary.newFrom(
	~mySoundFiles.collect({ |item|
		var itemPath = item.path;
		[
			PathName.new(itemPath).fileNameWithoutExtension.replace(".", "_").asSymbol,
			[
				CtkBuffer.playbuf(itemPath, channels: 0),  // left channel
				CtkBuffer.playbuf(itemPath, channels: 1)  // right channel
			]
		]
	}).flatten
);


// 2) add buffers to score
~mySFBufferDict.do({ |item|
	~mainScore.add(item)
});

~mySplitSFBufferDict.do({ |item|
	item.do({ |jtem|
		~mainScore.add(jtem)
	})
});


// list the keys... these are the buffers (soundfiles)!
~mySFBufferDict.keys;
~mySplitSFBufferDict.keys;  // should be the same...


//////////////////////// add note events /////////////////////////

/*
soundfile: \dxarts461a_Wi25_group_3longring

for reference, play complete soundfile forward... via a Ctk note instance
*/
~start = 0.0;
~gain = 6.0;
~dur = ~mySFBufferDict[\dxarts461a_Wi25_group_3longring].duration;
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start,
		duration: ~dur
	)
	.dur_(~dur)
	.gain_(~gain)
	.bufnum_(~mySFBufferDict[\dxarts461a_Wi25_group_3longring].bufnum)
);


// now try Phase Aligned Granular Synthesis (PAGS)!!
/*
try time stretching
*/
~start = ~start + ~dur + 1;
~dur = 5 * ~mySFBufferDict[\dxarts461a_Wi25_group_3longring].duration;
~refFreq = 209.669;  // measured - PAGS needs to know so as to align the grains
~freq = ~refFreq;
~mainScore.add(
	~myGrainBufPNotes[\dxarts46x_stereoGrainBufPAGS].note(
		starttime: ~start,
		duration: ~dur
	)
	.dur_(~dur)
	.gain_(~gain)
	.freq_(~freq)
	.refFreq_(~refFreq)
	.bufnum0_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][0].bufnum)
	.bufnum1_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][1].bufnum)
);
//

/*
try pitch shifting - up!
*/
~start = ~start + ~dur + 1;
~dur = ~mySFBufferDict[\dxarts461a_Wi25_group_3longring].duration;
~refFreq = 209.669;  // measured - PAGS needs to know so as to align the grains
~freq = 2.pow(0.5) * ~refFreq;
~mainScore.add(
	~myGrainBufPNotes[\dxarts46x_stereoGrainBufPAGS].note(
		starttime: ~start,
		duration: ~dur
	)
	.dur_(~dur)
	.gain_(~gain)
	.freq_(~freq)
	.refFreq_(~refFreq)
	.bufnum0_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][0].bufnum)
	.bufnum1_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][1].bufnum)
);


/*
try pitch shifting - down!
*/
~start = ~start + ~dur + 1;
~dur = ~mySFBufferDict[\dxarts461a_Wi25_group_3longring].duration;
~refFreq = 209.669;  // measured - PAGS needs to know so as to align the grains
~freq = 2.pow(-0.5) * ~refFreq;
~mainScore.add(
	~myGrainBufPNotes[\dxarts46x_stereoGrainBufPAGS].note(
		starttime: ~start,
		duration: ~dur
	)
	.dur_(~dur)
	.gain_(~gain)
	.freq_(~freq)
	.refFreq_(~refFreq)
	.bufnum0_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][0].bufnum)
	.bufnum1_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][1].bufnum)
);
//

/*
try spectral shifting - up!!
*/
~start = ~start + ~dur + 1;
~dur = ~mySFBufferDict[\dxarts461a_Wi25_group_3longring].duration;
~refFreq = 209.669;  // measured - PAGS needs to know so as to align the grains
~freq = ~refFreq;
~wavRatio = 2.pow(0.5);
~mainScore.add(
	~myGrainBufPNotes[\dxarts46x_stereoGrainBufPAGS].note(
		starttime: ~start,
		duration: ~dur
	)
	.dur_(~dur)
	.gain_(~gain)
	.freq_(~freq)
	.refFreq_(~refFreq)
	.wavRatio_(~wavRatio)
	.bufnum0_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][0].bufnum)
	.bufnum1_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][1].bufnum)
);

/*
try spectral shifting - down!!
*/
~start = ~start + ~dur + 1;
~dur = ~mySFBufferDict[\dxarts461a_Wi25_group_3longring].duration;
~refFreq = 209.669;  // measured - PAGS needs to know so as to align the grains
~freq = ~refFreq;
~wavRatio = 2.pow(-0.5);
~mainScore.add(
	~myGrainBufPNotes[\dxarts46x_stereoGrainBufPAGS].note(
		starttime: ~start,
		duration: ~dur
	)
	.dur_(~dur)
	.gain_(~gain)
	.freq_(~freq)
	.refFreq_(~refFreq)
	.wavRatio_(~wavRatio)
	.bufnum0_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][0].bufnum)
	.bufnum1_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][1].bufnum)
);

/*
try spectral shifting - using an envelope - up!!!!!
*/
~start = ~start + ~dur + 1;
~dur = ~mySFBufferDict[\dxarts461a_Wi25_group_3longring].duration;
~refFreq = 209.669;  // measured - PAGS needs to know so as to align the grains
~freq = ~refFreq;
~wavRatio = CtkControl.env(
	Env.pairs(
		[
			[ 0.0, 1.0 ],  // starting time, value
			[ ~dur, 2.pow(3) ]  // ending time, value
		],
		\exp
	)
);
~mainScore.add(
	~myGrainBufPNotes[\dxarts46x_stereoGrainBufPAGS].note(
		starttime: ~start,
		duration: ~dur
	)
	.dur_(~dur)
	.gain_(~gain)
	.freq_(~freq)
	.refFreq_(~refFreq)
	.wavRatio_(~wavRatio)
	.bufnum0_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][0].bufnum)
	.bufnum1_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][1].bufnum)
);


/*
try pitch shifting - using an envelope - up!!!!!
*/
~start = ~start + ~dur + 1;
~dur = ~mySFBufferDict[\dxarts461a_Wi25_group_3longring].duration;
~refFreq = 209.669;  // measured - PAGS needs to know so as to align the grains
~freq = CtkControl.env(
	Env.pairs(
		[
			[ 0.0, 2.pow(-1) * ~refFreq ],  // starting time, value
			[ ~dur, 2.pow(1) * ~refFreq ]  // ending time, value
		],
		\exp
	)
);
~mainScore.add(
	~myGrainBufPNotes[\dxarts46x_stereoGrainBufPAGS].note(
		starttime: ~start,
		duration: ~dur
	)
	.dur_(~dur)
	.gain_(~gain)
	.freq_(~freq)
	.refFreq_(~refFreq)
	.bufnum0_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][0].bufnum)
	.bufnum1_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][1].bufnum)
);


/*
try pitch shifting - using an envelope - down!!!!!
*/
~start = ~start + ~dur + 1;
~dur = ~mySFBufferDict[\dxarts461a_Wi25_group_3longring].duration;
~refFreq = 209.669;  // measured - PAGS needs to know so as to align the grains
~freq = CtkControl.env(
	Env.pairs(
		[
			[ 0.0, 2.pow(1) * ~refFreq ],  // starting time, value
			[ ~dur, 2.pow(-1) * ~refFreq ]  // ending time, value
		],
		\exp
	)
);
~mainScore.add(
	~myGrainBufPNotes[\dxarts46x_stereoGrainBufPAGS].note(
		starttime: ~start,
		duration: ~dur
	)
	.dur_(~dur)
	.gain_(~gain)
	.freq_(~freq)
	.refFreq_(~refFreq)
	.bufnum0_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][0].bufnum)
	.bufnum1_(~mySplitSFBufferDict[\dxarts461a_Wi25_group_3longring][1].bufnum)
);



///////////////// render the main score //////////////////


// write score to sound file with the -write message, and then open with helper score function, \scoreWriteOpenSFPlayer
(
    ~mainScore.write(
        path: ~outputFilePath.fullPath,
        sampleRate: ~sampleRate,
        headerFormat: ~headerFormat,
        sampleFormat: ~sampleFormat,
        options: ~serverOptions,
        action: ~myScoreFuncs[\scoreWriteOpenSFPlayer].value(~mainScore, ~outputFilePath)
    )
);

/*
NOTE:

we could synthesize and then open "by hand"...
*/
/*
(
~mainScore.write(
path: ~outputFilePath.fullPath,
sampleRate: ~sampleRate,
headerFormat: ~headerFormat,
sampleFormat: ~sampleFormat,
options: ~serverOptions,
)
);

// wait until final nextOSCPacket is posted...
"Wait until nextOSCPacket % is posted before opening SFPlayer.".format(Score.new(~mainScore.score).endTime).postln;

// ... open in SFPlayer...
SFPlayer.new(~outputFilePath.fullPath).gui;
*/


// ... when finished, free buffers...
/*
it is always good practice to free up buffers when finished!!
- if we want to continue modifying the scores, it is fine to leave the buffers loaded
*/

/*
NOTE:

If we've only used the non-realtime server, this step is not necessary.

For instance, if we've only used -write rather than -play, we don't need to free buffers.

*/
  