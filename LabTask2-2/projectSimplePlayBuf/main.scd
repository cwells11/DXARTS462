//LAB TASK 2-2
NetAddr.langPort

 OSCFunc.trace(true, true)
// OSCFunc.trace(false)
(

(Document.current.dir +/+ "synthDefs.scd").load;


~server = Server.default;
~server.options_(ServerOptions.new.numOutputBusChannels_(16).memSize_(2**21));
~server.waitForBoot({

	~buffers = PathName(Document.current.dir +/+ "Sounds/").files.collect{ |pathName, increment|
		CtkBuffer(pathName.fullPath).load
	};
	~rateSpec = ControlSpec(0.25, 4.0, 'exp'); //(changed from -100,100) (*lin or exp)
	~lpFreqSpec = ControlSpec(100, 20000, 'exp');
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
	  ~iPhone = NetAddr("192.168.0.69", 9000);

    // respond to the first fader on page 1
    ~rate = OSCFunc({ |msg, time, addr, recPort|
		~note.rate_(~rateSpec.map(msg[1]))
    }, '/1/fader1', ~iPhone);

    // respond to the first fader on page 1
    ~pan = OSCFunc({ |msg, time, addr, recPort|
       	~note.panAngle_(~panSpec.map(msg[1]))
    }, '/1/fader2', ~iPhone);
	 ~decay = OSCFunc({ |msg, time, addr, recPort|
		~note.decayTime_(~decaySpec.map(msg[1]))
    }, '/1/rotary1', ~iPhone);
	~lpFreq = OSCFunc({ |msg, time, addr, recPort|
		msg.postln;
		~note.lpFreq_(~lpFreqSpec.map(msg[1]).postln)
		 }, '/1/rotary2');


	/*~midiRate = OSCFunc.new({ |val, num, chan, src|
		~note.rate_(~rateSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 0);
	~midiPan = OSCFunc.cc({ |val, num, chan, src|
		~note.panAngle_(~panSpec.map(val.linlin(0, 127, 0, 1)))
	}, ccNum: 1);*/
})


)
 //~reverbNote.free
// MIDIFunc.trace;
// MIDIFunc.trace;(false)



/*Lab 2ExtensionExtension
MIDI and OSC
Part 1 - MIDI
Take your submission from Lab 1 and add two MIDIFuncs to control TWO of the parameters of your playbuf synth with your NanoKONTROL. Options include:

Control the gain.
Control the playback rate.
Control the panning (balance).


Part 2 - OSC
Copy the code from part 1 to a new project called Lab2-2. Modify the MIDIFuncs to be OSCFuncs to be controlled via TouchOSC. If you don't have TouchOSC and don't plan on using it, just send yourself messages to control the synth parameters from SCLang:
~localAddr = NetAddr.localAddr;
​
// for instance if you are controlling the playback rate
~localAddr.sendMsg('/rate', 0.5)
Extra Credit (1 point)
Modify the FluCoMa example from MIDI Controllers: FluCoMa to use OSCFuncs and TouchOSC instead of MIDI.

Submission
*/
