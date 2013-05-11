xpra
=======

This package exists to overcome some of xpra's shortcomings.

xpra is a fine tool, but it has two serious flaws:

* There's no easy way to figure out what runs which session

* xpra requires a terminal (aka xterm) to be alive when attaching. Killing
  that terminal will also detach the corresponding x-session. Forcing the
  user to have an extra terminal up wastes display real-estate. Even if
  terminal is reused for other purposes, there is still always a risk of
  killing it inadvisedly. Especially if you (like me) have tons of terminals
  active and need to clean up every now and then.

Both of these flaws are overcome in the tool winselect, but this is in my
mind overkilling the problem. It also lacks one feature I really wanted to
have:

* xpra.teleport.sh

This is an old QNX inspired concept, where a (X-)session instead of first
being detached, then picked up by a recipiency host, is instead is sent to
it. There are use-cases where this is really useful.



Technical description
---------------------
The questions above were tackled as follows:

  1: Solved by maintain a "database" which maps names to X session ID:s.
     This is done by simple temp-files, but to work bi-directionally there is
     a restriction introduced: There must me exactly one xvfb per application
     running. xpra accepts several applications to use the same xvfb even
     thoug this is not a common use-case (winselect does not utilize the
     possibility either) I'm still mentioning it.


  2: Handled by letting screen run as a daemon and handling all requests.
	 Srceen has it's own internal terminal even when detached. I.e. even if
	 not visible, it will still handle the requests and still keep the
	 X-sessions alive. As an additional benefit one can get the
	 screen-session up and have a look what it's doing. The sessions will be
	 named following a convention where each user logged in gets it's own
	 daemonized screen called xpra-${USER}.

	 The only quirk using screen is that to run it as a daemon, one has to
	 have had it attached at least once.

	 The following discussion helped figured out how to work around the
	 limitation:
	 http://www.linuxquestions.org/questions/linux-software-2/how-to-send-a-command-to-a-screen-session-625015/

	 And the result us as in the following example:

	 screen -r xpra-me -p0 -X stuff "xpra attach :10 &"`echo -ne '\015'`

 -or-

     screen -r xpra-me -p0 -X exec "xpra attach :10 &"

	 The latter has the disadvantage of that CR is not echoed, hence if you
	 bring out the sessions you will not see the prompts in-between
	 commands.

  3: There's really nothing rocket-sciency about it. It's just having a
	 script logging in to a remote host using ssh, then pick up a session
	 from the "teleporter". Basically the same as you would do manually, but
	 with the difference in that you don't have to physically move which
	 saves you one run exra and which is especially useful if the remote
	 host isn't within arm-lengths distance.


SCRIPT3 note:
-------------
This project is a script sub-library and is part of a larger project managed
as a Google-repo called "SCRIPT3" (or "s3" for short). S3 can be found
here: https://github.com/mambrus/script3

To download and install any of s3's sub-projects, use the Google's "repo" tool
and the manifest file in the main project above. Much better documentation
there too.

Note that most of s3's sub-project files won't operate without s3 easily (or
at all).

