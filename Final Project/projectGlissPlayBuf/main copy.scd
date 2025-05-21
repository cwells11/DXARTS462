//462 Final Midi gliss playbuf


s.boot;

s.options.memSize = 65536;

(
// MIDI-controlled Glissando Synth — adapted from other working synthDef

MIDIIn.connectAll;

MIDIFunc.trace(false); // true and false

(Document.current.dir +/+ "synthDefs.scd").load;
~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(16).memSize_(2**21));
~server.waitForBoot({

	~buffer = CtkBuffer("../../sounds/Marimba.roll.ff.Ab3.stereo.aif".resolveRelative).load;

	// Control specs
	~rateSpec = ControlSpec(0.25, 4.0, 'exp');
	~panSpec = ControlSpec(-45, 45, 'lin');
	~glissSpec = ControlSpec(-2.0, 2.0, 'lin'); // new
	~gainSpec = ControlSpec(-48, 0, 'lin');    // optional

	~audioBuss = CtkAudio.play(2, server: ~server);

	// Synth note
	~note = ~myPlayBufPNotes[\dxarts46x_stereoGlissPlayBuf].note
		.dur_(~buffer.duration)
		.rate_(1.0)
		.glissSpan_(0)
		.gain_(-12.0)
		.riseTime_(0.01)
		.decayTime_(0.1)
		.panAngle_(0.0)
	    .bufnum_(~buffer)
		.outBus_(0)
		.play;

	~server.sync;
~myPlayBufPNotes.dict.keys.postln;


	// MIDI mappings
	~midiRate = MIDIFunc.cc({ |val, num, chan, src|
		~note.rate_(~rateSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 0);

	~midiGliss = MIDIFunc.cc({ |val, num, chan, src|
		~note.glissSpan_(~glissSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 1);

	~midiPan = MIDIFunc.cc({ |val, num, chan, src|
		~note.panAngle_(~panSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 2);

	~midiGain = MIDIFunc.cc({ |val, num, chan, src|
		~note.gain_(~gainSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 3);

	// HDR recording setup
	~hdr = HDR.new(
		Server.default,
		[0, 1],
		sessionPath: "../../../recordings/".resolveRelative,
		filename: ~buffer.path.basename.splitext($.)[0],
		headerFormat: "wav",
		sampleFormat: "float"
	);

	~hdr.record;
});
)
~note.gate_(0);
~hdr.stop;
~buffers.collect(_.path)
~reverbNote.free
MIDIFunc.trace;
MIDIFunc.trace;(false)

(

