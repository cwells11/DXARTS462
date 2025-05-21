/*
Project Title: projectPAGS
Date: Thu Feb 20 11:55:29 2025

DXARTS 46x: Sound Series Tutorial
Authors: Joseph Anderson, Wei Yang, et al.
Affiliation: DXARTS, University of Washington (https://dxarts.washington.edu/)
License: GPLv3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
*/

/*
For examples see:

HelpBrowser.openLink("link::Tutorials/Getting Practice/ProjectSHARCWTsWPs::")
*/


// -------------------------
// instantiate CtkProtoNotes
~myPlayBufPNotes = CtkProtoNotes.new;
~myGrainBufPNotes = CtkProtoNotes.new;


// -------------------------
// add synthDefs

~myPlayBufPNotes.add(

	/*
	Enveloped mono PlayBuf
	*/
	SynthDef.new(
		\dxarts46x_monoPlayBuf,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, rate = 1, panAngle = 0,
			loop = 0, bufnum = 0, outBus = 0|  // UGen graph function

			// vars for UGens
			var ampEnvSig;
			var playBufSig;
			var panSig;
			var outSig;

			// vars for control
			var numChannels = 1; // <-- mono buffer - must be set in the UGen graph function!
			var amp = gain.dbamp;
			var pos = panAngle.neg / 45;

			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
				doneAction: Done.freeSelf
			);  // EnvGen (control rate)

			// sample playback
			playBufSig = PlayBuf.ar(numChannels, bufnum,  BufRateScale.kr(bufnum) * rate, loop: loop);

			// apply -linen envelope
			// ... reuse playBufSig var
			// NOTE: we could have just passed ampEnvSig to the level arg of Pan2
			playBufSig = playBufSig * ampEnvSig;

			// stereo imager
			panSig = Pan2.ar(playBufSig, pos);  // Pan2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	)
);


~myPlayBufPNotes.add(

	/*
	Enveloped stereo PlayBuf
	*/
	SynthDef.new(
		\dxarts46x_stereoPlayBuf,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, rate = 1, panAngle = 0,
			loop = 0, bufnum = 0, outBus = 0|  // UGen graph function

			// vars for UGens
			var ampEnvSig;
			var playBufSig;
			var panSig;
			var outSig;

			// vars for control
			var numChannels = 2; // <-- stereo buffer - must be set in the UGen graph function!
			var amp = gain.dbamp;
			var pos = panAngle.neg / 45;

			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
				doneAction: Done.freeSelf
			);  // EnvGen (control rate)

			// sample playback
			playBufSig = PlayBuf.ar(numChannels, bufnum,  BufRateScale.kr(bufnum) * rate, loop: loop);

			// apply -linen envelope
			// ... reuse playBufSig var
			// NOTE: we could have just passed ampEnvSig to the level arg of Balance2
			playBufSig = playBufSig * ampEnvSig;

			// stereo imager
			panSig = Balance2.ar(playBufSig[0], playBufSig[1], pos);  // Balance2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	)
);


~myGrainBufPNotes.add(
	SynthDef.new(
		\dxarts46x_monoGrainBufPAGS,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01,
			freq = 440.0, wavRatio = 1.0, refFreq = 440.0, q = 1.0,
			panAngle = 0,
			bufnum = 0,
			outBus = 0|  // UGen graph function

			// vars for UGens
			var ampEnvSig;
			var bufPosSig;
			var triggerSig;
			var grainBufSig;
			var panSig;
			var outSig;

			// vars for control
			var numChannels = 1; // <-- mono buffer, mono stream
			var amp = gain.dbamp;
			var pos = panAngle.neg / 45;
			var envFreq, grainFreq, grainDur;
			var bufferPers; // total number of sampled waveform periods

			// map / calculate SGS parameters
			grainFreq = freq;
			envFreq = wavRatio * refFreq / (2 * q);
			grainDur = envFreq.reciprocal;
			bufferPers = refFreq * BufDur.kr(bufnum);


			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
				doneAction: Done.freeSelf
			);  // EnvGen (control rate)


			// buffer position (index)
			bufPosSig = Line.ar(0, 1, dur);
			bufPosSig = (bufPosSig * bufferPers).floor / bufferPers; // quantize index to sync to whole period offsets

			// granular (grain frequency) trigger
			triggerSig = Impulse.ar(grainFreq);

			// granular synthesis
			grainBufSig = GrainBuf.ar(numChannels: numChannels, trigger: triggerSig, dur: grainDur, sndbuf: bufnum, rate: wavRatio, pos: bufPosSig);

			// apply -linen envelope
			grainBufSig = grainBufSig * ampEnvSig;

			// stereo imager
			panSig = Pan2.ar(grainBufSig, pos);  // Pan2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	)
);

~myGrainBufPNotes.add(
	SynthDef.new(
		\dxarts46x_stereoGrainBufPAGS,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01,
			freq = 440.0, wavRatio = 1.0, refFreq = 440.0, q = 1.0,
			panAngle = 0,
			bufnum0 = 0, bufnum1 = 1,
			outBus = 0|  // UGen graph function

			// vars for UGens
			var ampEnvSig;
			var bufPosSig;
			var triggerSig;
			var grainBufSig;
			var panSig;
			var outSig;

			// vars for control
			var numChannels = 1; // <-- mono buffer, mono stream
			var amp = gain.dbamp;
			var pos = panAngle.neg / 45;
			var envFreq, grainFreq, grainDur;
			var bufferPers; // total number of sampled waveform periods

			// map / calculate SGS parameters
			grainFreq = freq;
			envFreq = wavRatio * refFreq / (2 * q);
			grainDur = envFreq.reciprocal;
			bufferPers = refFreq * BufDur.kr(bufnum0);


			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
				//doneAction: Done.freeSelf
			);  // EnvGen (control rate)


			// buffer position (index)
			bufPosSig = Line.ar(0, 1, dur);
			bufPosSig = (bufPosSig * bufferPers).floor / bufferPers; // quantize index to sync to whole period offsets

			// granular (grain frequency) trigger
			triggerSig = Impulse.ar(grainFreq);

			// granular synthesis
			grainBufSig = GrainBuf.ar(numChannels: numChannels, trigger: triggerSig, dur: grainDur, sndbuf: [ bufnum0, bufnum1 ], rate: wavRatio, pos: bufPosSig);

			// apply -linen envelope
			grainBufSig = grainBufSig * amp;

			// stereo imager
			panSig = Balance2.ar(grainBufSig[0], grainBufSig[1], pos);  // Balance2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	)
);