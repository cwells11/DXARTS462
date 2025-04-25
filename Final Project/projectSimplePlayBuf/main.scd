

(

MIDIIn.connectAll;

~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(2));

~server.waitForBoot({

	~soundPath = PathName("../../sounds/waveDrum1.wav".resolveRelative);

	~buffer = CtkBuffer(~soundPath.fullPath).load;

	(Document.current.dir +/+ "synthDefs.scd").load;

	~rateSpec = ControlSpec(0.25, 4.0, 'lin');

	~panSpec = ControlSpec(-45, 45, 'lin');

	~audioBuss = CtkAudio.play(2, server: ~server);

	// ~buffer = ~buffers[0];

	~rate = 1.0;
	~panAngle = 0;

	~task = Task({
		loop({
			~buffer = ~buffers.choose;
			~note = ~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note
			.dur_(~buffer.duration)
			.rate_(~rate)
			.bufnum_(~buffer)
			.outBus_(~audioBuss)
			.panAngle_(~panAngle)
			.play;
			0.5.wait
		})
	});

	~reverbNote = ~myPlayBufPNotes['reverb'].note(addAction: 'tail')
	.in_(~audioBuss).play;

	~midiRate = MIDIFunc.cc({ |val, num, chan, src|
		~rate = ~rateSpec.map(val.linlin(0, 127, 0, 1))
	}, ccNum: 0);

	~midiPan = MIDIFunc.cc({ |val, num, chan, src|
		~panAngle = ~panSpec.map(val.linlin(0, 127, 0, 1))
	}, ccNum: 1);

	~start = MIDIFunc.cc({ |val, num, chan, src|
		(val == 127).if({ ~task.play })

	}, 64);

	~stop = MIDIFunc.cc({ |val, num, chan, src|
		(val == 127).if({ ~task.stop })
	}, 65);

	~hdr = HDR(
		~server,
		[0, 1],
		1,
		0,
		"recordings/".resolveRelative,
		~soundPath.fileNameWithoutExtension,
		"WAV",
		"float"

	);

	~hdr.record;



})

)

~note.panAngle

~reverbNote.free

MIDIFunc.trace
MIDIFunc.trace(false)











