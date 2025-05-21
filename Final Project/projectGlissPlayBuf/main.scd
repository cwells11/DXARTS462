/*
Project Title: projectGlissPlayBuf
Date: Thu Jan 30 11:55:55 2025

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


// 2) add buffers to score
~mySFBufferDict.do({ |item|
	~mainScore.add(item)
});


// list the keys... these are the buffers (soundfiles)!
~mySFBufferDict.keys;


//////////////////////// add note events /////////////////////////

/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

(default) Gliss: span 1/4 octave, start low
*/
~start = 0.0;
~glissSpan = -1.0 / 4.0;
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum)
);


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

Gliss: span 1/4 octave, start high
*/
~start = 4.0;  // reuse start
~glissSpan = 1.0 / 4.0;  // reuse glissSpan
~mainScore.add(
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum)
);


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

Gliss: the above two, together
*/
~start = 8.0;  // reuse start
~glissSpan = -1.0 / 4.0;  // reuse glissSpan
~gain = -6.0;  // reduce gain to avoid clipping!!
~mainScore.add(

	// Gliss low to high
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// Gliss high to low
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(~glissSpan.neg)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),
);


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

Gliss: similar to the above, but Gliss a span of an octave
*/
~start = 12.0;  // reuse start
~glissSpan = -1.0;  // reuse glissSpan
~gain = -6.0;  // reuse gain
~mainScore.add(

	// Gliss low to high
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// Gliss high to low
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(~glissSpan.neg)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),
);

/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

Gliss: similar to the above, but Gliss a span of two octaves
*/
~start = 16.0;  // reuse start
~glissSpan = -2.0;  // reuse glissSpan
~gain = -6.0;  // reuse gain
~mainScore.add(

	// Gliss low to high
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// Gliss high to low
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(~glissSpan.neg)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),
);


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

Gliss: similar to the above, add playback with no Glissing
NOTE: we could have used non-Glissing \dxarts46x_stereoPlayBuf from projectSimplePlayBuf
*/

~start = 20.0;  // reuse start
~glissSpan = -2.0;  // reuse glissSpan
~gain = -6.0;  // reuse gain
~mainScore.add(

	// Gliss low to high
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// Gliss high to low
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(~glissSpan.neg)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// no Glissing here!
	// NOTE: glissSpan set to 0.0
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(0.0)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),
);


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

Gliss from below, into tune w/ non-Glissed

NOTE: we could have used non-Glissing \dxarts46x_stereoPlayBuf from projectSimplePlayBuf
*/

~start = 24.0;  // reuse start
~glissSpan = -0.5;  // reuse glissSpan
~glissRate = 2.pow(~glissSpan / 2);  // lower playback rate for Gliss...
~gain = -6.0;  // reuse gain
~mainScore.add(

	// Gliss low to high
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.rate_(~glissRate)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// no Glissing here!
	// NOTE: glissSpan set to 0.0
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(0.0)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),
);


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

Gliss from above, into tune w/ non-Glissed

NOTE: we could have used non-Glissing \dxarts46x_stereoPlayBuf from projectSimplePlayBuf
*/

~start = 28.0;  // reuse start
~glissSpan = 0.5;  // reuse glissSpan
~glissRate = 2.pow(~glissSpan / 2);  // lower playback rate for Gliss...
~gain = -6.0;  // reuse gain
~mainScore.add(

	// Gliss high to low
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.rate_(~glissRate)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// no Glissing here!
	// NOTE: glissSpan set to 0.0
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(0.0)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),
);


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

Gliss from below AND above, into tune w/ non-Glissed

NOTE: we could have used non-Glissing \dxarts46x_stereoPlayBuf from projectSimplePlayBuf

NOTE: we could write a function to do this!!!
*/

~start = 32.0;  // reuse start
~glissSpan = -0.5;  // reuse glissSpan
~glissRate = 2.pow(~glissSpan / 2);  // lower playback rate for Gliss...
~gain = -6.0;  // reuse gain
~mainScore.add(

	// Gliss low to high
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.rate_(~glissRate)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// Gliss high to low
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.rate_(~glissRate.reciprocal)  // <--- this is how we flip the Gliss
	.glissSpan_(~glissSpan.neg)  // <--- this is how we flip the Gliss
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// no Glissing here!
	// NOTE: glissSpan set to 0.0
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(0.0)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),
);


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

Gliss in tune to above

NOTE: we could have used non-Glissing \dxarts46x_stereoPlayBuf from projectSimplePlayBuf
*/

~start = 36.0;  // reuse start
~glissSpan = -0.5;  // reuse glissSpan
~glissRate = 2.pow(~glissSpan.neg / 2);  // higher playback rate for Gliss... from in tune
~gain = -6.0;  // reuse gain
~mainScore.add(

	// Gliss high to low
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.rate_(~glissRate)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// no Glissing here!
	// NOTE: glissSpan set to 0.0
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(0.0)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),
);


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

Gliss into tune to below

NOTE: we could have used non-Glissing \dxarts46x_stereoPlayBuf from projectSimplePlayBuf
*/

~start = 40.0;  // reuse start
~glissSpan = 0.5;  // reuse glissSpan
~glissRate = 2.pow(~glissSpan.neg / 2);  // higher playback rate for Gliss... from in tune
~gain = -6.0;  // reuse gain
~mainScore.add(

	// Gliss low to high
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.rate_(~glissRate)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// no Glissing here!
	// NOTE: glissSpan set to 0.0
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(0.0)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),
);


/*
soundfile: \Vibraphone_shortsustain_ff_Ab3_stereo

play complete soundfile, forward...

Gliss from in tune to out of tune, above and below

NOTE: we could have used non-Glissing \dxarts46x_stereoPlayBuf from projectSimplePlayBuf

NOTE: we could write a function to do this!!!
*/

~start = 44.0;  // reuse start
~glissSpan = 0.5;  // reuse glissSpan
~glissRate = 2.pow(~glissSpan.neg / 2);  // higher playback rate for Gliss... from in tune
~gain = -6.0;  // reuse gain
~mainScore.add(

	// Gliss high to low
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.rate_(~glissRate)
	.glissSpan_(~glissSpan)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// Gliss low to high
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.rate_(~glissRate.reciprocal)  // <--- this is how we flip the Gliss
	.glissSpan_(~glissSpan.neg)  // <--- this is how we flip the Gliss
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),

	// no Glissing here!
	// NOTE: glissSpan set to 0.0
	~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note(
		starttime: ~start,
		duration: ~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration
	)
	.dur_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].duration)
	.gain_(~gain)
	.glissSpan_(0.0)
	.bufnum_(~mySFBufferDict[\Vibraphone_shortsustain_ff_Ab3_stereo].bufnum),
);

/*
NOTE:

for further inspection, use Sonic Visualiser to view resulting spectra
*/


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