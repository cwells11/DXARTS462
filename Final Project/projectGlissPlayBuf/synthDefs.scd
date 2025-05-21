/*
Project Title: projectGlissPlayBuf
Date: Thu Jan 30 11:55:55 2025

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
~myPlayBufPNotes = CtkProtoNotes.new;  // protoNote dict for playing soundfiles


// -------------------------
// add synthDefs

~myPlayBufPNotes.add(

	/*
	Enveloped stereo _Glissed_ PlayBuf
	*/
	SynthDef.new(
		\dxarts46x_stereoGlissPlayBuf,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, rate = 1, glissSpan = 0.0, panAngle = 0,
			loop = 0, bufnum = 0, outBus = 0|  // UGen graph function

			// vars for UGens
			var ampEnvSig;
			var glissEnvSig;
			var playBufSig;
			var panSig;
			var outSig;

			// vars for control
			var numChannels = 2;  // stereo buffer - must be set in the UGen graph function!
			var amp = gain.dbamp;
			var pos = panAngle.neg / 45;

			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(
					riseTime,
					(dur - (riseTime + decayTime)).clip(0.001, dur),
					decayTime
				),
				//doneAction: Done.freeSelf
			) * amp;

			// glissando envelope (pitch sweep)
			glissEnvSig = XLine.kr(
				2.pow(glissSpan / 2),
				2.pow(glissSpan.neg / 2),
				dur
			);

			// sample playback
			playBufSig = PlayBuf.ar(
				numChannels,
				bufnum,
				BufRateScale.kr(bufnum) * rate * glissEnvSig,
				startPos: 0,
				loop: loop,
				//doneAction: 0
			);

			// apply amplitude envelope
			playBufSig = playBufSig * amp;

			// stereo imaging
			panSig = Balance2.ar(playBufSig[0], playBufSig[1], pos);

			// output
			outSig = panSig;

			Out.ar(outBus, outSig);
		}
	)
);
