//LAB TASK 2
(
MIDIIn.connectAll;


(Document.current.dir +/+ "synthDefs.scd").load;


~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(16).memSize_(2**21));
~server.waitForBoot({

	/*~buffers = PathName(Document.current.dir +/+ "../../Sounds/").files.collect{ |pathName, increment|
	CtkBuffer(pathName.fullPath).load
	};*/

	~buffer = CtkBuffer("../../sounds/FOAWavedrum.wav".resolveRelative).load;

	~rateSpec = ControlSpec(0.25, 4.0, 'exp'); //(changed from -100,100) (*lin or exp)
	~panSpec = ControlSpec(-45, 45, 'lin'); //lin not exp
	~audioBuss = CtkAudio.play(2, server: ~server);

	// ~buffer = ~buffers.choose;

	// |dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01, minWinDur = 1.0, maxWinDur = 1.0, minSkipTime = 0.0, maxSkipTime = 0.0,
	// minRate = 1, maxRate = 1,
	// minDensity = 1, maxDensity = 4,
	// winRand = 0.0,
	// interp = 4,
	// panAngle = 0,
	// bufnum = 0,
	// outBus = 0|
	~note = ~myPlayBufPNotes[\dxarts46x_stereoWarp1Shuffle].note
	.dur_(~buffer.duration)
	.minRate_(~rate)
	.bufnum_(~buffer)
	.outBus_(~audioBuss)
	.panAngle_(~panAngle)
	.play;

	~server.sync;

	~reverbNote = ~myPlayBufPNotes['reverb'].note(addAction: 'tail').in_(~audioBuss).play;

	~midiFreq = MIDIFunc.cc({ |val, num, chan, src|
		~note.minRate_(~rateSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 0);
	~midiPan = MIDIFunc.cc({ |val, num, chan, src|
		~note.panAngle_(~panSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 1);
	~midiminWin = MIDIFunc.cc({ |val, num, chan, src|
		~note.minWinDur_(~minSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 2);
	~midimaxWin = MIDIFunc.cc({ |val, num, chan, src|
		~note.maxWinDur_(~maxSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 3);

	~hdr = HDR.new(
		Server.default, //server
		[0, 1], //an array of all the channels to record
		sessionPath: "../recordings/".resolveRelative, //current folder
		filename: ~buffer.path.basename.splitext($.)[0],
		headerFormat: "wav",
		sampleFormat: "float", //also int16, int24
	);

	~hdr.record
})


)

~hdr.stop

~buffers.collect(_.path)
~reverbNote.free
MIDIFunc.trace;
MIDIFunc.trace;(false)
