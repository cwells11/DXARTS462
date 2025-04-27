/*
Project Title: projectPalindromePlayBuf
Date: Wed Jan 29 16:32:10 2025

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
	Enveloped stereo PlayBuf x 2 - forward & backward
	*/
	SynthDef.new(
		\dxarts46x_stereoPalindromePlayBuf,  // name - as Symbol

		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, rate = 1, panAngle = 0,
			bufnum = 0, outBus = 0|  // UGen graph function

			// vars for UGens
			var ampEnvSig;
			var playBufSig;
			var exchangeSig;
			var panSig;
			var outSig;

			// vars for control
			var numChannels = 2; // <-- stereo buffer - must be set in the UGen graph function!
			var amp = gain.dbamp;
			var pos = panAngle.neg / 45;
			var loop = 1;  // <-- looping must be on for forward and backward playback

			// ----
			// synthesis

			// amplitude envelope
			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
				levelScale: amp,
				doneAction: Done.freeSelf
			);  // EnvGen (control rate)

			// sample playback
			playBufSig = Array.with(
				PlayBuf.ar(numChannels, bufnum, BufRateScale.kr(bufnum) * rate, loop: loop),  // forward
				PlayBuf.ar(numChannels, bufnum, BufRateScale.kr(bufnum) * rate.neg, loop: loop);  // backward
			);  // Array of two PlayBuf (audio rate)
			/*
			a more concise version, using Multichannel Expansion:

			playBufSig = PlayBuf.ar(numChannels, bufnum, BufRateScale.kr(bufnum) * [ rate, rate.neg ], loop: loop);
			*/

			// mix / crossfade between forward and backward playBufs
			exchangeSig = SelectX.ar(
				Line.kr(dur: dur),
				playBufSig
			);  // SelectX (audio rate)

			// apply -linen envelope
			// ... reuse exchangeSig var
			// NOTE: we could have just passed ampEnvSig to the level arg of Balance2
			exchangeSig = exchangeSig * ampEnvSig;

			// stereo imager
			panSig = Balance2.ar(exchangeSig[0], exchangeSig[1], pos);  // Balance2 (audio rate)

			// assign to out
			outSig = panSig;

			Out.ar(
				outBus,  // out bus - set as an argument
				outSig
			)  // Out (audio rate)
		}
	)
);
