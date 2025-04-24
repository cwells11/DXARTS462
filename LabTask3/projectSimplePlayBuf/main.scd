//LAB TASK 3 Take your submission from Lab 2 and add a Task to control note creation.

/*Create a looping task to make notes with random times and parameters.
Add a button to your MIDIFuncs to start the task.
Add a button to pause (stop) the task.
Optional (Extra Credit): Route the synths in the task into another synth to control their overall gain that is controlled via a MIDI slider*/
// Part 2- Part 2 - ProcMod
// Start with Lab3 Part 1. Wrap your Task inside a ProcMod and use ProcEvents to start (and free) the ProcMod.
//
// Create a MIDI button to cycle through ProcEvents.
// Use MIDI to control your synth parameters.


(

(Document.current.dir +/+ "synthDefs.scd").load;

MIDIIn.connectAll;

~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(16).memSize_(2**21));
~server.waitForBoot({
	~sounds = "../../sounds/*".resolveRelative.pathMatch;

	~buffers = ~sounds.collect{ |pathName, increment|
		CtkBuffer(pathName).load
	};
	~rateSpec = ControlSpec(0.25, 4.0, 'exp'); //(changed from -100,100) (*lin or exp)
	~panSpec = ControlSpec(-45, 45, 'lin'); //lin not exp
	~audioBuss = CtkAudio.play(2, server: ~server);

	//~buffer = ~buffers.choose; [0]

	//~start = 0.0.rrand(10.0);
	~rate = 1.0;
	~panAngle = 0;

	~proc = ProcModR.new(
		env: Env([0, 1, 0], [10, 10], 'sin', 1),
		amp: 2,
		numChannels: 2,
		procout: ~audioBuss,
		id: 'test',
		server: ~server,
		function: { |group, routebus, server, pmod|
			[pmod, group, routebus, server].postln;
			// collect a new CtkNote and make sure the note is added to the group
			~task = Task({
				loop({
					~buffer = ~buffers.choose;
					~note = ~myPlayBufPNotes[\dxarts46x_stereoPlayBuf].note(target: group)
					.dur_(~buffer.duration)
					.rate_(~rate)
					.bufnum_(~buffer)
					.outBus_(routebus)
					.panAngle_(~panAngle)
					.play;
					0.2.rrand(1.0).wait; //0.5.wait
				})

			});

		}
	);
	~events = ProcEvents.new([
		[~proc, nil], // play the first procmod and release nothing
		[nil, ~proc] // play nothing and release a procmod
	], 1, nil, nil, 'test'
	);



	~reverbNote = ~myPlayBufPNotes['reverb'].note.(addAction: 'tail').in_(~audioBuss).play;

	~midiRate = MIDIFunc.cc({ |val, num, chan, src|
		~rate = ~rateSpec.map(val.linlin(0, 127, 0, 1))
	}, ccNum: 0);
	~midiPan = MIDIFunc.cc({ |val, num, chan, src|
		~panAngle = ~panSpec.map(val.linlin(0, 127, 0, 1))
	}, ccNum: 1);
	~start = MIDIFunc.cc({ |val, num, chan, src|
		(val == 127).if({~events.next})
	}, 64);
	/*~stop = MIDIFunc.cc({ |val, num, chan, src|
		(val == 127).if({~task.stop})
	}, 65);*/ //proc does this for us!
})


)
~reverbNote.free
MIDIFunc.trace;
MIDIFunc.trace;(false)


//Task code here
/*(
~synth = CtkSynthDef(\default, { |out = 0, freq = 440, amp = 0.5, pan = 0|
var snd, env;
snd = SinOsc.ar(freq, 0, amp);
env = EnvGen.kr(Env.perc, doneAction: 2);
Out.ar(out, Pan2.ar(snd * env, pan));
});
)
// Using Task so you can pause the sequence
(
~task = Task({
loop({     // loop the whole thing
3.do({     // do this 3 times
~synth.note.freq_(76.midicps).play;
0.5.wait;
~synth.note.freq_(73.midicps).play;
0.5.wait;
});
"I'm waiting for you to resume".postln;
nil.yield;// fermata
~synth.note.freq_(69.midicps).play;
1.wait;
});
});
)
~task.play;
~task.resume;
~task.stop;
~task.reset;