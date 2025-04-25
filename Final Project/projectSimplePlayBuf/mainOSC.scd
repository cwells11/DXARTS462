(

(Document.current.dir +/+ "synthDefs.scd").load;


~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(2));

~server.waitForBoot({

	~sounds = "../sounds/*".resolveRelative.pathMatch;

	~buffers = ~sounds.collect{ |pathName, increment|
		CtkBuffer(pathName).load
	};

	~rateSpec = ControlSpec(0.25, 4.0, 'lin');

	~panSpec = ControlSpec(-45, 45, 'lin');

	~audioBuss = CtkAudio.play(2, server: ~server);

	~buffer = ~buffers[0];

	~start = 0.0;

	~task = Task({
		loop({
			~note = ~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(
				starttime: ~start
			)
			.dur_(~buffer.duration)
			.bufnum_(~buffer)
			.outBus_(~audioBuss)
			.loop1_(1)
			.play;
		})
	});



	~reverbNote = ~myPlayBufPNotes['reverb'].note(addAction: 'tail')
	.in_(~audioBuss).play;

	~phone = NetAddr("192.168.0.53", 9000);

	// respond to the first fader on page 1
	~rate = OSCFunc({ |msg, time, addr, recPort|
		~note.rate_(~rateSpec.map(msg[1]))
	}, '/1/fader1', ~phone);

	// respond to the first fader on page 1
	~pan = OSCFunc({ |msg, time, addr, recPort|
		~note.panAngle_(~panSpec.map(msg[1]))
	}, '/1/fader2', ~phone);

})

)

~note.panAngle

~reverbNote.free

MIDIFunc.trace
MIDIFunc.trace(false)











