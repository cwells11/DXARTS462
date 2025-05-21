//LAB TASK 2//but make it PAGS!!
(
MIDIIn.connectAll;


(Document.current.dir +/+ "synthDefs.scd").load;


~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(16).memSize_(2**21));
~server.waitForBoot({

	~buffers = PathName(Document.current.dir +/+ "../../Sounds/").files.collect{ |pathName, increment|
	CtkBuffer(pathName.fullPath).load
	};

	~buffer0 = CtkBuffer("../../sounds/dxarts461a_Wi25_group_3longring.wav".resolveRelative, channels: 0).load;
	~buffer1 = CtkBuffer("../../sounds/dxarts461a_Wi25_group_3longring.wav".resolveRelative, channels: 1).load;

	~freqSpec = ControlSpec(440, 400, 'exp'); //(changed from -100,100) (*lin or exp)
	~panSpec = ControlSpec(-45, 45, 'lin'); //lin not exp
	~audioBuss = CtkAudio.play(2, server: ~server);
	~wavRatio = ControlSpec(0.25, 8.0);
	~q = ControlSpec(0.1, 10.0);

	/*{|dur = 1.0, gain = 0.0, riseTime = 0.01, decayTime = 0.01,
			freq = 440.0, wavRatio = 1.0, refFreq = 440.0, q = 1.0,
			panAngle = 0,
			bufnum0 = 0, bufnum1 = 1,
			outBus = 0| */


	~note = ~myGrainBufPNotes[\dxarts46x_stereoGrainBufPAGS].note
	.dur_(100)
	.outBus_(0)
	.bufnum0_(~buffer0)
	.bufnum1_(~buffer1)
	.play;

	~server.sync;

	// ~reverbNote = ~myPlayBufPNotes['reverb'].note(addAction: 'tail').in_(~audioBuss).play;

	~midiFreq = MIDIFunc.cc({ |val, num, chan, src|
		~note.freq_(~freqSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 0);
	~midiPan = MIDIFunc.cc({ |val, num, chan, src|
		~note.panAngle_(~panSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 1);
	~midiq = MIDIFunc.cc({ |val, num, chan, src|
		~note.q_(~q.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 2);
	~midiwavRatio = MIDIFunc.cc({ |val, num, chan, src|
		~note.wavRatio_(~wavRatio.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 3);

	~hdr = HDR.new(
		Server.default, //server
		[0, 1], //an array of all the channels to record
		sessionPath: "../../../recordings/".resolveRelative, //current folder
		filename: "pags_" ++ ~buffer0.path.basename.splitext($.)[0],
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
