/*
Project Title: projectSimplePlayBuf/project warp shuffle LAB 4
Date: Tues April 29, 2025

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
~myWarp1ShufflePNotes = CtkProtoNotes.new;

// -------------------------
// add synthDefs

~myPlayBufPNotes.add(
	SynthDef.new(
		\dxarts46x_stereoPlayBuf,
		{ |dur = 3.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, rate = 1, panAngle = 0,
			loop = 0, bufnum = 0, outBus = 0, combFreq = 100, rq = 0.01|  // <-- Added lpFreq

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

			// decode to stereo
			//playBufSig = FoaDecode.ar(playBufSig, FoaDecoderMatrix.newStereo);

			// Apply Low-Pass Filter
			filteredSig = CombPZC.ar(playBufSig, freq: combFreq, rq: rq);  //

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

//Project Warp Shuffle

~myPlayBufPNotes.add(

	/*
	Enveloped mono PlayBuf
	*/


		/*
		Enveloped mono Warp1 - with offset start position, optimised for Brassage / Shuffling
		*/
		SynthDef.new(
			\dxarts46x_stereoWarp1Shuffle,  // name - as Symbol

			{ |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01,
				minWinDur = 1.0, maxWinDur = 1.0,
				minSkipTime = 0.0, maxSkipTime = 0.0,
				minRate = 1, maxRate = 1,
				minDensity = 1, maxDensity = 4,
				winRand = 0.0,
				interp = 4,
				panAngle = 0,
				bufnum = 0,
				outBus = 0|  // UGen graph function

				// vars for UGens
				var ampEnvSig;
				var shuffleSig;
				var panSig;
				var outSig;

				// vars for control
				var numChannels = 2; // <-- stereo buffer - must be set in the UGen graph function!
				var amp = gain.dbamp;
				var pos = panAngle.neg / 45;
				var bufferDurReciprocal = BufDur.kr(bufnum).reciprocal;
				var minPoint = minSkipTime * bufferDurReciprocal;
				var maxPoint = maxSkipTime * bufferDurReciprocal;
				var pointerSig, winDurSig, densitySig, rateSig;

				// ----
				// synthesis

				// shuffler control
				pointerSig = WhiteNoise.kr.range(minPoint, maxPoint);
				winDurSig = WhiteNoise.kr.range(minWinDur, maxWinDur);
				densitySig = WhiteNoise.kr.range(minDensity, maxDensity);
				rateSig = WhiteNoise.kr.range(minRate, maxRate);


				// amplitude envelope
				ampEnvSig = EnvGen.kr(
					Env.linen(riseTime, dur - (riseTime + decayTime), decayTime),  // Env: *linen
					levelScale: amp,
				// doneAction: Done.freeSelf
				);  // EnvGen (control rate)


				// sample shuffle playback
				shuffleSig = Warp1.ar(
					numChannels: numChannels,
					bufnum: bufnum,
					pointer: pointerSig,
					freqScale: rateSig,
					windowSize: winDurSig,
					overlaps: densitySig,
					windowRandRatio: winRand,
					interp: interp,
				);

				// apply -linen envelope
				// ... reuse playBufSig var
				// NOTE: we could have just passed ampEnvSig to the level arg of Balance2
				shuffleSig = shuffleSig * amp;

				// stereo imager
				panSig = Balance2.ar(shuffleSig[0], shuffleSig[1], pos);  // Balance2 (audio rate)

				// assign to out
				outSig = panSig;

				Out.ar(
					outBus,  // out bus - set as an argument
					outSig
				)  // Out (audio rate)
			}
		)
	);
	