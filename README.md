# playdate minis

This is a collection of small prototype projects to get familiar with the Playdate SDK and its features.
The console has been a great deal of fun, and it's been inspiring to see all of the creative projects that have been made with it.

The goal is to make many small, self-contained projects.
I am using LLMs to help the development process, and I will document to some degree the process of making some of these projects.

## 2025-06-22 - counter

This is the first project that uses either the A button or the crank to increment a counter and display it to the screen.

It took a while to get to a functional state where I could write some code and see it on the playdate simulator.
Since I'm running on windows, I had to install the sdk and set up the `PLAYDATE_SDK_PATH` and the bin folder in the path.
I tried setting this up on a remote vm, but the biggest point of contention was copying over the resulting pdx file to my local simulator.
In addition, it seems like I can't necessarily get the debugger working on the remote vm.

I set up the project on vs-code using the playdate extension by Orta.
This simple example seems to work in the simulator.
From the simulator, I am able to upload the project up to the actual playdate console.