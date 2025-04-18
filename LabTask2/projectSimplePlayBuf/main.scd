//LAB TASK 2

MIDIIn.connectAll;
(

(Document.current.dir +/+ "synthDefs.scd").load;


~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(16).memSize_(2**21));
~server.waitForBoot({

	~buffers = PathName(Document.current.dir +/+ "Sounds/").files.collect{ |pathName, increment|
		CtkBuffer(pathName.fullPath).load
	};
	~rateSpec = ControlSpec(0.25, 4.0, 'exp'); //(changed from -100,100) (*lin or exp)
	~panSpec = ControlSpec(-45, 45, 'lin'); //lin not exp
	~audioBuss = CtkAudio.play(2, server: ~server);

	~buffer = ~buffers.choose;

	~start = 0.0.rrand(10.0);

	~note = ~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
		starttime: ~start

	)
	.dur_(~buffer.duration)
	.bufnum_(~buffer)
	.outBus_(~audioBuss)
	.loop_(1)
	.play;

	~reverbNote = ~myPlayBufPNotes['reverb'].note.(addAction: 'tail').in_(~audioBuss).play;

	~midiFreq = MIDIFunc.cc({ |val, num, chan, src|
		~note.rate_(~rateSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 0);
	~midiPan = MIDIFunc.cc({ |val, num, chan, src|
		~note.panAngle_(~panSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 1);
})


)
~reverbNote.free
MIDIFunc.trace;
MIDIFunc.trace;(false)
