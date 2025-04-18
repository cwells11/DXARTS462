/*
Project Title: projectSimplePlayBuf Lab 2-2
Date: Wed Jan 29 13:48:27 2025

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
			Enveloped stereo PlayBuf with Low-Pass Filter
			*/
			/*SynthDef.new(
				\dxarts46x_stereoPlayBuf,  // name - as Symbol

				{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, rate = 1, panAngle = 0,
					loop = 0, bufnum = 0, outBus = 0, lpFreq = 1000|  // Added low-pass filter frequency argument

					// vars for UGens
					var ampEnvSig;
					var playBufSig;
					var panSig;
					var outSig;
					var filteredSig; // Added for LPF

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
					playBufSig = playBufSig * ampEnvSig;

					// Apply low-pass filter
					filteredSig = LPF.ar(playBufSig, lpFreq); // Low-pass filter applied

					// stereo imager
					panSig = Balance2.ar(filteredSig[0], filteredSig[1], pos);  // Balance2 (audio rate)

					// assign to out
					outSig = panSig;

					Out.ar(
						outBus,  // out bus - set as an argument
						outSig
					)  // Out (audio rate)
				}
			)*/
		);
			~myPlayBufPNotes.add(
	SynthDef.new(
		\dxarts46x_stereoPlayBuf,
		{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, rate = 1, panAngle = 0,
			loop = 0, bufnum = 0, outBus = 0, lpFreq = 1000|  // <-- Added lpFreq

            var ampEnvSig, playBufSig, panSig, outSig, filteredSig;
            var numChannels = 2;
            var amp = gain.dbamp;
            var pos = panAngle.neg / 45;

			ampEnvSig = EnvGen.kr(
				Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),
				levelScale: amp,
				//doneAction: Done.freeSelf //*remove to play live
			);

			playBufSig = PlayBuf.ar(numChannels, bufnum, BufRateScale.kr(bufnum) * rate, loop: loop);
			//playBufSig = playBufSig * ampEnvSig;

			// Apply Low-Pass Filter
			filteredSig = LPF.ar(playBufSig, lpFreq);  // <---- Low-pass filter added

			panSig = Balance2.ar(filteredSig[0], filteredSig[1], pos);
			outSig = panSig;

			Out.ar(outBus, outSig);
		}
	),
	SynthDef('reverb', { |in, out = 0|
    var src;
    src = In.ar(in, 2); // stereo buss
		Out.ar(out, FreeVerb2.ar(src[0], src[1],0.7, 0.7, 0.2))
})
);


