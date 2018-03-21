/*
This is an example startup file. You can load it from your startup file
(to be found in Platform.userAppSupportDir +/+ "startup.scd")
*/

(
n = NanoKontrol2();
// configure the sound server: here you could add hardware specific options
// see http://doc.sccode.org/Classes/ServerOptions.html
s.options.numBuffers = 1024 * 16; // increase this if you need to load more samples
s.options.memSize = 8192 * 16; // increase this if you get "alloc failed" messages
s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
// boot the server and start SuperDirt
s.waitForBoot {
	~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
	~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
	// for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
	s.sync; // wait for samples to be read
	~dirt.start(57120, [0, 0, 0, 0, 0 ,0 ,0 ,0]);   // start listening on port 57120, create two busses each sending audio to channel 0

	"Loading synths.".underlined.postln;
	(thisProcess.nowExecutingPath.dirname +/+ "/synths/*.scd").loadPaths(warn:false);

	~spec = \db.asSpec;
	~win = Window("orbital volume", Rect(240, 240, 400, 200)).front;
	~win.view.layout = HLayout(*~dirt.orbits.collect { |x, i|
		var val = ~spec.unmap(x.get(\amp).ampdb);

		var sli = Slider();
		~sli_list.add(sli);
		sli.value_(val).action_({ |v| x.set(\amp, ~spec.map(v.value).dbamp) })
	});

	~dirt.orbits.collect { |x, i|
		n.faders[i].onChange = {|faderval|
			x.set(\amp, ~spec.map(faderval/127).dbamp);
			// ~sli_list[i].value = 20;
			};
		}

};

s.latency = 0.3; // increase this if you get "late" messages

);

// (
// n.faders.do {|fader, i|
// 	fader.onChange = {|val|
// 		~win.view.children[i].value = val;
// 	}
// };
// )