# counter

A very simple counter for the playdate.

It took a while to get to this point.
Since I'm running on windows, I had to install the sdk and set up the `PLAYDATE_SDK_PATH` and the bin folder in the path.
I tried setting this up on a remote vm, but the biggest point of contention was copying over the resulting pdx file to my local simulator.
In addition, it seems like I can't necessarily get the debugger working on the remote vm.

I set up the project on vs-code using the playdate extension by Orta.
This simple example seems to work in the simulator.