"Filed out from Dolphin Smalltalk 7"!

Link variableSubclass: #Process
	instanceVariableNames: 'suspendedFrame priority myList callbackDepth primitiveFailureCode primitiveFailureData fpeMask threadSync thread exceptionEnvironment _alreadyPrinted _reserved1 debugger name _reserved2'
	classVariableNames: 'DefaultFPEMask DefaultMaxStack DefaultStack'
	poolDictionaries: 'CRTConstants'
	classInstanceVariableNames: ''!
Process guid: (GUID fromString: '{87B4C64E-026E-11D3-9FD7-00A0CC3E4A32}')!
Process comment: 'A Process represents an individual thread of execution in the image.

Note that the name "Process" is historic - a Smalltalk Process is much more similar to a "thread" than a true process, since all Processes share the same execution context (the image). Dolphin''s processes do not map directly onto native threads, but are "green" threads. The multi-threading system is implemented internally by the VM and image, with all "green" threads running within a single Win32 thread. This means that a call to a long running (or blocking) external API call will block the entire system, so a facility is provided to "overlap" such calls. This is done by marking the external method with the "overlap" annotation, in which case the VM will perform the call on a separate native thread. For the duration of the overlapped operation the calling Process is blocked, but other Processes in the image will continue to run. 

A Process can in any of the following states:
	- active		The Process is actually running. Usually you will only be able to catch the main UI process in this state.
	- debug		The Process is currently being debugged.
	- ready		The Process is ready to run, but currently suspended on one of the Processors priority queues.
	- suspended	The Process has been suspended (see #suspend), and will not run again until sent #resume.
				Note that a suspended process with no active references will be garbage collected.
	- waiting	The Process is waiting on a <Semaphore>, i.e. it has sent #wait to a Semaphore with no excess signals.
				A Process remains waiting on a Semaphore until it reaches the front of that Semaphores queue of
				waiting Processes and the Semaphore is sent a #signal message.
	- dead		The Process has been terminated, or has run to completion.

A Process in any state other than #dead is considered alertable, and may be sent an interrupt by the VM at any time. See<ProcessorScheduler> for more details.

In general it is not a good idea to manipulate the contents of a live process directly (e.g. in an Inspector). For performance reasons the VM tends to assume that a Process'' state is consistent, and it does not perform much error checking. Hence it is quite easy to crash the system by modification of instance variables and the stack. It is quite safe to view the contents, but if a live Process is inspected you may find that the snapshot is invalidated by the stack growing and shrinking to meet requirements, which could cause errors in the inspector when trying to access non-existant stack slots.

Instance Variables:
	suspendedFrame 		<Integer> address of suspendedFrame when in states ready, waiting, or suspended, otherwise nil.
	priority 					<Integer> priority level (see ProcessorScheduler).
	myList 					<LinkedList> on which the process is currently queued if in states ready or waiting, otherwise nil.
	callbackDepth 			<Integer> number of callbacks which have not yet been returned from (i.e. nested depth).
	primitiveFailureCode		<Integer> code reported by last primitive failure.
	primitiveFailureData 		<Object> argument supplied by last primitive failure. Value depends on primitive and failure reason.
	fpeMask 				<Integer> floating point exception mask specifying which FP exceptions to mask. See Intel/CRT docs.
	tls 						Reserved for future use.
	thread 					Pointer to overlapped call control block. For VM use only.
	exceptionEnvironment	List of active exception frames <ExceptionHandler> in LIFO order.
	_alreadyPrinted			<IdentitySet> of objects which have already printed in a recursive #printOn:
	errno					<integer>. C runtime library error code recorded after last overlapped external call
	debugger 				<debugEventHandler> associated with the Process, if any. Used as a destination for debug events.
	name 					The <Object> ''name'' of the process. Usually a <String> or <CompiledMethod>.
	lastError 				<integer>. Win32 GetLastError() code recorded after last overlapped external call.

Class Variables:
	DefaultFPEMask			<Integer> default floating point exception mask used to initialize fpeMask instance variable.
	DefaultMaxStack 		<Integer> maximum stack depth (size up to which a Process may grow - virtual memory reserved).
	DefaultStack				<Integer> initial stack depth (initial virtual memory committed).'!
!Process categoriesForClass!Kernel-Processes! !
!Process methodsFor!

_alreadyPrinted
	^_alreadyPrinted!

at: anInteger 
	"Answer the receiver's indexed instance variable at the argument index.
	As basicAt:, but may be reimplemented.

	Primitive Failure Reasons:
		0	- index is not a SmallInteger
		1	- index out of bounds (not in the range 1..receiver's indexable size)."

	<primitive: 49>
	^self errorAt: anInteger!

at: anInteger ifAbsent: exceptionBlock 
	"Answer an <Object> which is the element of the receiver 
	at the specified <SmallInteger> index. If the index is out of bounds 
	answer the result of evaluating the <niladicValuable> exceptionBlock."

	^(anInteger > 0 and: [anInteger <= self size]) 
		ifTrue: [self at: anInteger]
		ifFalse: [exceptionBlock value]!

at: anInteger put: anObject 
	"Replace the receivers indexed instance variable at the argument,
	index, with the argument, value. Answer value.

	Primitive Failure Reasons:
		0	- index is not a <SmallInteger>
		1	- index is out of bounds (not in the range 1..receiver's indexable size)."

	<primitive: 176>
	^self errorAt: anInteger put: anObject!

basicAt: anInteger put: anObject 
	"Private - Replace the receivers indexed instance variable at the argument,
	index, with the argument, value. Answer value. 

	Primitive Failure Reasons:
		0	- index is not a SmallInteger
		1	- index out of bounds (not in the range 1..receiver's indexable size) 

	MUST not be reimplemented (except by classes whose instances have special representations
	such as SmallInteger)."

	<primitive: 176>
	^self errorAt: anInteger put: anObject!

basicSuspendedFrame
	"Private - Answer the SmallInteger pointer into the stack of the suspended frame. If nil then
	the process has terminated (or is not yet initialized)."

	^suspendedFrame!

callbackDepth
	"Private - Answer the depth of outstanding callbacks from the VM in the receivers stack.
	An example of a callback is an entry from the Smalltalk window procedure to
	View>>dispatchMessage:. Recursive callbacks (callbacks which occur during the
	processing of another callback, e.g. sending a Win32 message in the handler for
	another Win32 message) will increase the callback depth to a figure greater than one.
	The Main (user interface) process will always have a callback depth >= 1 when
	examined.

	Whether a Process' stack contains callbacks affects the way it must be unwound
	on termination, or when handling an exception, since the callbacks from the 
	VM must themselves be properly unwound, not just the Smalltalk stack."

	^callbackDepth!

canDebug
	"Answer whether the receiver can be debugged (this requires that a debugger
	be available)."

	^self respondsTo: #debuggerClass!

debugger
	"Private - Answer the object which is currently claiming to be the 'debugger' on this
	process. This object will receiver debug events as and when they occur in the receiver
	(it need not be an actual <Debugger>). The answer will be nil if there is no debugger."

	^debugger!

debugger: anObject
	"Private - anObject is claiming to be the debugger for the receiver, so save it so
	that it can later be sent debug events which occur in the receiver. Any 
	existing debugger is disconnected."

	debugger := anObject!

errno
	"Answer the value of the C runtime 'errno' global variable saved on completion of the last
	overlapped call made from the receiver."

	^CRTLibrary default thread_errno asExternalAddress sdwordAtOffset: 0!

exceptionEnvironment
	"Private - Answer the receiver's exception environment (a LIFO stack of ExceptionHandlers).
	A linked list of ExceptionHandlers is maintained to expedite the search for handlers 
	when an exception occurs."

	^exceptionEnvironment!

exceptionEnvironment: anExceptionHandler
	"Private - Set the receiver's exception environment to be the argument,
	anExceptionHandler. N.B. Use with care, the previous exception environment
	should be linked to the new exception environment."

	exceptionEnvironment := anExceptionHandler!

finalize
	"Private - Ensure the receiver is properly terminated.
	This method should only be invoked if the process dies because there
	are no outstanding references to it. If normally terminated, then
	it will not be finalized."

	self terminate!

fpeMask
	"Answer the current floating point exception mask for the receiver.
	This mask is set whenever the process is running (by the VM).
	Note that the mask determines which exceptions are masked out, rather
	than generated."

	^fpeMask!

fpeMask: anInteger
	"Set the current floating point exception mask for the receiver.
	Answer the old mask (not the receiver as is normal for a set method).
	If the receiver is the current active process, then the current
	FP exception mask is established. The mask is recorded for future
	switching by the VM on context switches.
	Note that the mask determines which exceptions are masked out, rather
	than generated."

	| oldMask |
	oldMask := fpeMask.
	fpeMask := anInteger.
	self isActive ifTrue: [Float reset].
	^oldMask!

frameAtAddress: spInteger
	"Private - Answer a frame representing the real stack frame at the specified SP (a
	SmallInteger address/2 in the receiver), or nil if the address is not within this process."

	^self frameAtIndex: (self indexOfSP: spInteger)!

frameAtIndex: anInteger
	"Private - Answer a StackFrame represent a real frame in the receiver at the specified index,
	or nil if the index is out of bounds."

	^self frameClass process: self index: anInteger!

frameClass
	"Private - Answer the class of object to use to represent the receiver's activation records"

	^StackFrame!

id
	"Answer an id which is unique for the lifetime of the process within
	this particular session. Should the process be terminated in the session
	then the id may be re-used, i.e. this is really only useful to help with debugging."

	^self yourAddress bitShift: -16!

indexOfSP: anInteger
	"Private - Answer the index into the receiver of the VM stack pointer value, anInteger
	(which is a pointer, bitshifted right one position, although this is an implementation
	detail which may be changed)."

	<primitive: 175>
	^((anInteger bitShift: -1) - (self yourAddress bitShift: -2)) - self class instSize + 1!

initialize
	"Private - Initialize the instance variables of the receiver to default values.
	Certain properties are inherited from the forking process (e.g. floating point
	exception mask). Also mark the receiver as finalizable so that the stack can be 
	correctly unwound if the receiver is not explicitly terminated.
	Answer the receiver."

	_alreadyPrinted := IdentitySet new.
	callbackDepth := priority := 0.
	(fpeMask := Processor activeProcess fpeMask) isNil ifTrue: [fpeMask := DefaultFPEMask].
	self beFinalizable!

interruptWith: aBlock
	"Private - Interrupt the receiver with the specified block. The block is evaluated regardless of
	the receiver's current state (unless dead). On completion of the block, the receiver resumes whatever
	it was doing before, including waiting on a Semaphore, etc."

	"Implementation Note: aBlock is evaluated with asynchronous process switching disabled!!"

	^self queueInterrupt: Processor genericInterrupt with: aBlock!

isActive
	"Answer whether the receiver is the current active process."

	^Processor activeProcess == self
	
	!

isAlive
	"Answer whether the receiver is either ready, waiting, or active."

	^self isActive or: [self suspendingList notNil]	!

isAlive: aSemaphore 
	"Private - Answer whether the receiver is either ready, waiting on the specified 
	Semaphore, or active."

	| state |
	state := self state.
	^state == #ready 
		or: [state == #running or: [state == #waiting and: [self suspendingList == aSemaphore]]]!

isDead
	^suspendedFrame isNil!

isDebuggee
	"Private - Answer whether the receiver is currently being debugged."

	^debugger notNil!

isInCallback
	"Private - Answer whether the receiver is processing a callback from the VM.

	Whether a Process' stack contains callbacks affects the way it must be unwound
	on termination, or when handling an exception, since the callbacks from the 
	VM must themselves be properly unwound (and in the same order in which they
	were made), not just the Smalltalk stack."

	^self callbackDepth > 0!

isMain
	"Answer whether the receiver is the main user I/F process (i.e. it
	manages the input queue)."

	^SessionManager inputState main == self	
	!

isReady
	"Answer whether the receiver is Ready to run but inactive"

	^self state == #ready	!

isSuspended
	"Answer whether the receiver is Suspended/Terminated."

	^self state == #suspended
	
	!

isTerminated
	"Answer whether the receiver has Terminated."

	^self state == #dead
	
	!

isWaiting
	"Answer whether the receiver is waiting on a Semaphore."

	^self state == #waiting	!

kill
	"Terminate the receiver with extreme prejudice. Any outstanding unwind blocks
	will not be run. It is necessary, however, to correctly maintain the VM's callback stack,
	so all outstanding callbacks are unwound. Finally, the receiver is put to sleep, permanently.
	N.B. This should not be sent to a process which is not the active process if it has callbacks."

	self isDead ifTrue: [^self].
	self isActive 
		ifTrue: [self shutdown]
		ifFalse: 
			["As the receiver is not active, we queue an interrupt which will
				cause the VM to activate the receiver (even if Waiting or Suspended)."

			self queueInterrupt: Processor killInterrupt]!

lastError
	"Answer the value of the Win32 error code (i.e. the result of GetLastError()) run in the
	context of the overlapped external call thread associated with the receiver."

	^KernelLibrary default threadGetLastError!

launchBlock: aBlockClosure 
	"Private - Install aBlockClosure as the launch frame of the receiver (which must be
	a new process). The VM needs a correctly established frame in order to start running
	a process."

	| baseFrame |
	self at: 1 put: aBlockClosure receiver.
	"Note that we must allow space for the block's stack temps"
	baseFrame := self frameClass new setProcess: self index: (2 + aBlockClosure localCount).
	baseFrame
		basicSender: 0;
		basicIP: aBlockClosure initialIP + MemoryManager current objectHeaderSize - 1;
		sp: baseFrame frameSize+1;
		method: aBlockClosure method;
		environment: aBlockClosure.
	baseFrame bp: 2.
	self suspendedFrame: baseFrame!

name
	"Answer the 'name' of the Process. This is usually defined by the creator of the process.
	The default name is the home method (which allows access to the source of the forking block, 
	even for immediate expressions). The name need not be a String (all Objects respond to #displayString)"

	^name!

name: anObject
	"Set the name of the Process to the argument, anObject (see #name)"

	name := anObject!

primitiveFailureCode
	"Private - Answer the SmallInteger failure code set by the last primitive which failed 
	when executed by the receiver. This should be retrieved as soon as possible following a 
	failure so that it is not overwritten by a subsequent failure - remember that not all
	primitive failures are errors, and they are a faily common occurrence in SmallInteger arithmetic.
	Some primitives may not set a failure code when they fail.
	Currently each primitive defines its own failure codes (documented in the primitive call method), 
	and additional information of any type may also be present in 'primitiveFailureData'.
	The failure code/data are not normally affected by primitives which succeed."

	^primitiveFailureCode!

primitiveFailureData
	"Private - Answer the extra failure data set by the last primitive which failed (and
	which had extra information to supply about the failure over and above the failure code).
	See #primitiveFailureCode for additional information."

	^primitiveFailureData!

primTerminate
	"Private - Transition the receiver from its current state to the Terminated state. Once
	Terminated, a Process cannot (easily) be resumed or restarted.

	Primitive Failure Reasons:

	0 - Not used
	1 - The receiver is the last running process, so it cannot be terminated until another
	process has been started (an Idle Panic interrupt will also be generated). Assuming correct
	recovery after the idle panic, a second attempt at termination should succeed."

	"Implementation Note: This primitive is approximately equivalent to:

		self suspendUnconditionally. 
		suspendedFrame := nil

	except that the primitive can correctly terminate any process, even the active process. The
	active process cannot terminate itself correctly in this way in Smalltalk without the
	assistance of another process, because as soon as it suspends itself, it will obviously stop
	running, and so will be unable to nil out its suspended context. It is considered that the
	use of a simple primitive to terminate processes is both less error prone, and consumes less
	resources, than the alternative of dedicating another process to this task."

	<primitive: 91>
	^Processor activeProcess primitiveFailureCode == 1 
		ifTrue: [false	"Please try again"]
		ifFalse: [self primitiveFailed]!

printOn: aStream
	"Append a short debug description of the receiver to aStream."

	aStream
		basicPrint: self;
		nextPut: $(;
		print: self name;
		nextPutAll: ', id: ';
		print: self id;
		nextPutAll: ', priority: ';
		print: self priority;
		nextPutAll: ', state: ';
		print: self state;
		nextPut: $)!

priority
	"Answer the receiver's priority (see ProcessorScheduler)"

	^priority
!

priority: anInteger 
	"Set the receiver's priority to anInteger and Answer the previous priority. Note that 
	if the receiver is the currently active process, the new priority is lower, and there 
	are higher-priority processes ready to run, the active process will be preempted.
	If the receiver is not the active process, and its priority is increased above that of
	the active process, then the active process will be preempted.

	Primitive failure reasons:
		0 -	anInteger is not a SmallInteger.
		1 -	anInteger is not in the range of permissible priorities (1..highest priority)."

	<primitive: 92>
	^((anInteger isMemberOf: SmallInteger) 
		and: [anInteger between: 1 and: Processor highestPriority]) 
			ifTrue: [self primitiveFailed]
			ifFalse: [self error: 'Invalid Process priority ' , priority printString]!

queueInterrupt: anInteger
	"Queue an interrupt with the specified number for the receiver (which can be in any resumable state)
	and a nil argument."

	^self queueInterrupt: anInteger with: nil!

queueInterrupt: anInteger with: anObject
	"Queue an interrupt with the specified number for the receiver (which can be in any resumable state).
	The argument is passed to the interrupted process and can be of any type as necessary.

	Primitive failure reasons:
		0 -	anInteger is not a SmallInteger.
		1 -	the receiver is dead (i.e. not runnable)."

	<primitive: 98>
	^self primitiveFailed!

resume
	"Change the state of the receiver from Suspended to Ready (by placing
	it at the end of the Processor's queue for the receiver's priority).
	Fail if the receiver is already waiting in a queue (in a Semaphore 
	or the Processor). See #resume: for further details (sending this message
	is equivalent to sending #resume: with nil as the argument)."

	<primitive: 87>
	^self primitiveFailed!

resume: suspendingListOrNil
	"Change the state of the receiver from Suspended to Ready/Waiting 
	by placing it at the end of the Processor's queue for the receiver's priority
	if suspendingListOrNil is nil, otherwise returning it to the queue associated
	with suspendingListOrNil. Fail if the receiver is already waiting in a queue 
	(in a Semaphore or the Processor) - i.e. it is only appropriate to send this message to
	previously #suspend'd Processes, it is not the means by which to start
	currently Waiting or Ready processes (which have to wait either for the Semaphore
	on which they are Waiting to be signalled, or their turn to run after
	higher priority processes, and in a round robin fashion with respect to
	Processes of the same priority if they are Ready to run).

	Primitive failure reasons:
		0 -	the receiver is not suspended on a scheduler or semaphore list.
		1 - 	the receiver has been terminated (or not properly initialized)."

	<primitive: 87>
	^self primitiveFailed!

resumeUnconditionally
	"Change the state of the receiver to Ready to run regardless of its current
	state (unless terminated)."

	<primitive: 87>
	myList isNil ifTrue: [^self primitiveFailed]!

setPriority: anInteger 
	priority := anInteger!

shutdown
	"Private - Terminate the receiver with extreme prejudice. Any outstanding unwind blocks
	will not be run. It is necessary, however, to correctly maintain the VM's callback stack,
	so all outstanding callbacks ARE unwound. Finally, the receiver is put to sleep, permanently.
	N.B. This should not be sent to a process which is not the active process if it has callbacks.
	Sending this method directly is not recommended (send either #kill or #terminate instead)."

	"Inform any debugger so that it can close.
	You will not be able to debug past this point."
	debugger notNil ifTrue: [debugger perform: #onTerminate].

	"Unwind any outstanding callbacks."
	Processor unwindCallbacks.
	self beUnfinalizable.
	[self primTerminate == true] whileFalse!

size
	"Answer the number of indexed variables in the receiver (0 for non-indexable objects,
	as the named instance variables are not included)."

	"Implementation Note: Access thisContext to get the process size saved down as the
	processes dynamically change size to accomodate their stack. Normally the process
	size is only recorded from the SP on process switches, when thisContext is accessed,
	on GC's, on invocations of the #allReferences primitive, and on image save."

	thisContext.
	^super size!

spOfIndex: anInteger
	"Private - Answer a VM stack pointer value (SmallInteger) for the specified index of the
	receiver."

	^(self yourAddress bitShift: -1) + ((anInteger + self class instSize - 1) * 2)!

stackFramesFrom: startFrame depth: anInteger 
	"Private - Answer a <sequencedReadableCollection> containing up to the first anInteger stack 
	frames below the <StackFrame>, startFrame, in the receiver's stack (inclusive)."

	| answer |
	answer := OrderedCollection new: (anInteger min: 50).
	self 
		stackFramesFrom: startFrame
		depth: anInteger
		do: [:frame | answer addLast: frame].
	^answer!

stackFramesFrom: aStackFrame depth: depth do: operation 
	"Private - Evaluate the <monadicValuable> operation for each of the receiver's stack frames
	up to a depth of <integer> depth (inclusive, maximum), below aStackFrame."

	| frame i |
	frame := aStackFrame.
	i := 0.
	[i < depth and: [frame notNil and: [frame method selector notNil]]] whileTrue: 
			[operation value: frame.
			frame := frame sender.
			i := i + 1]!

stackTrace: anInteger
	"Private - Answer a <readableString> containing a stack trace to the depth specified by the <integer>
	argument."

	^self stackTraceFrom: self topFrame depth: anInteger!

stackTraceFrom: aStackFrame depth: anInteger 
	"Private - Answer a <readableString> containing a stack trace up to the <integer> depth, anInteger,
	or 50 frames, whichever is the smaller."

	| stackStream |
	stackStream := String writeStream: 25 * (anInteger min: 50).
	
	[(self stackFramesFrom: aStackFrame depth: anInteger) 
		do: [:frame | frame displayOn: stackStream]
		separatedBy: [stackStream cr]] 
			on: Error
			do: [:e | e notify].
	^stackStream contents!

state
	"Private - Answer a symbol identifying the receiver's state."

	^self isActive 
		ifTrue: [#running]
		ifFalse: 
			["The state may change, so minimize chance of getting
			it wrong by storing suspendingList in a temporary"

			| list |
			list := self suspendingList.
			list isNil 
				ifTrue: 
					[self isDebuggee 
						ifTrue: [#debug]
						ifFalse: [self basicSuspendedFrame isNil ifTrue: [#dead] ifFalse: [#suspended]]]
				ifFalse: [(list isKindOf: Semaphore) ifTrue: [#waiting] ifFalse: [#ready]]]!

stbSaveOn: anSTBOutFiler
	"Save out a binary representation of the receiver to anSTBOutFiler. 
	Processes cannot be saved and restored correctly so output them as 
	nil by default"

	anSTBOutFiler saveObject: self as: nil.!

suspend
	"Transition the receiver from Running (if active), Waiting (if waiting on a Semaphore) 
	or Ready (if waiting to be scheduled by the Processor) states to the Suspended state 
	(i.e. not runnable). If the receiver is the activeProcess, suspend it and schedule another, 
	otherwise remove the receiver from the list of Ready processes in the Processor, or the 
	list of Waiting processes in a Semaphore, and nil out its suspending list backpointer. 
	The receiver may be transitioned back to the Ready state at any time by sending it #resume 
	(but remember that resuming a Process that was waiting on a Semaphore when it was suspended 
	may upset process synchronisation because it will not return to the Semaphores waiting list).
	Report an error if the receiver is already Suspended (which is recognised by a null backpointer, 
	as this indicates that the process is not waiting in a list).

	Suspended processes have a 'nil' suspending list, are not the active process, and have
	a non-zero suspendedFrame address (which distinguishes them from terminated processes).
	If the process is the last runnable process, then answer false, otherwise answer the receiver 
	(when resumed).

	Primitive failure results:
		0 -	the process is already suspended.
		1 -	the process is the active process and could not be suspended because
			it is the only runnable process remaining."

	| failureCode |
	<primitive: 88>
	failureCode := Processor activeProcess primitiveFailureCode.
	^failureCode == 1 ifTrue: [false] ifFalse: [self primitiveFailed]!

suspendedFrame
	"Private - Answer a stack frame for the receiver's suspended context, nil if the receiver is dead."

	| frameAddress |
	frameAddress := self basicSuspendedFrame.
	^frameAddress isNil ifFalse: [self frameAtAddress: frameAddress]!

suspendedFrame: aStackFrameOrIndex
	"Private - Set the suspended frame index of the receiver."

	suspendedFrame := self spOfIndex: aStackFrameOrIndex asInteger!

suspendingList
	"Private - Answer the list (semaphore or Processor queue) on which the receiver has been 
	suspended. A Process which has been suspended, or which is currently active,
	will answer nil."

	^myList!

suspendUnconditionally
	"As #suspend, but fails silently attempts at suspending processes which are already Suspended.
	Answers the receiver.

	Primitive failure results:
		0 -	the process is already suspended.
		1 -	the process is the active process and could not be suspended because
			it is the only runnable process remaining.
		2-	the process is pending termination

	The first two failure codes are ignored. Any other failure code is unexpected, and will result in 
	normal failure handling."

	| failureCode |
	<primitive: 88>
	failureCode := Processor activeProcess primitiveFailureCode.
	^failureCode == 1 
		ifTrue: [false]
		ifFalse: [failureCode == 0 ifTrue: [self] ifFalse: [self primitiveFailed]]!

terminate
	"Transition the receiver from its current state to the Terminated state. Once Terminated, 
	a Process cannot be resumed or restarted.

	Implementation note: In order to ensure that all unwind blocks (see BlockClosure>>andFinally:
	and BlockClosure>>ifCurtailed:) are run, termination is achieved by raising a ProcessTermination 
	exception which is caught and handled by the launch block of the receiver (see 
	BlockClosure>>newProcess). The launch block handler for ProcessTermination #return:'s, dropping
	all later stack frames, and thus causing any unwind blocks to be executed. As its last action the launch
	block sends #shutdown message to the Process for final cleanup."

	self isDead ifTrue: [^self].
	self isActive 
		ifTrue: 
			[ProcessTermination signalWith: self.
			"Won't get this far unless the process hasn't completed its initialization,
			 and established a based handler block for the ProcessTermination signal."
			self shutdown]
		ifFalse: 
			["Exceptions can only be raised in active processes (and a process must be active
			 to terminate itself), so as the receiver is not active, we must queue an interrupt 
			 which will cause the VM to activate the receiver (even if Waiting or Suspended)."

			self queueInterrupt: Processor terminateInterrupt]!

threadSync
	^threadSync!

topFrame
	"Private - Answer a frame representing the top activation record of the receiver's stack.
	We deliberately answer a frame for the sender if the receiver is the active
	process, as the current context will be invalidated immediately this method
	returns. Of course that frame will also be invalidated should the sender
	subsequently return too."

	^self isActive 
		ifTrue: [(self frameAtAddress: thisContext) sender]
		ifFalse: [self suspendedFrame]! !
!Process categoriesFor: #_alreadyPrinted!accessing!private! !
!Process categoriesFor: #at:!accessing!public! !
!Process categoriesFor: #at:ifAbsent:!accessing!public! !
!Process categoriesFor: #at:put:!accessing!public! !
!Process categoriesFor: #basicAt:put:!accessing!private! !
!Process categoriesFor: #basicSuspendedFrame!private!stack frames! !
!Process categoriesFor: #callbackDepth!accessing!private! !
!Process categoriesFor: #canDebug!development!public!testing! !
!Process categoriesFor: #debugger!accessing!development!private! !
!Process categoriesFor: #debugger:!accessing!development!private! !
!Process categoriesFor: #errno!accessing!public! !
!Process categoriesFor: #exceptionEnvironment!accessing!debugger-step over!public! !
!Process categoriesFor: #exceptionEnvironment:!accessing!debugger-step over!private! !
!Process categoriesFor: #finalize!finalizing!private! !
!Process categoriesFor: #fpeMask!accessing!public! !
!Process categoriesFor: #fpeMask:!accessing!public! !
!Process categoriesFor: #frameAtAddress:!private!stack frames! !
!Process categoriesFor: #frameAtIndex:!private!stack frames! !
!Process categoriesFor: #frameClass!private!stack frames! !
!Process categoriesFor: #id!accessing!public! !
!Process categoriesFor: #indexOfSP:!private!stack frames! !
!Process categoriesFor: #initialize!initializing!public! !
!Process categoriesFor: #interruptWith:!interrupts!private! !
!Process categoriesFor: #isActive!public!states-testing! !
!Process categoriesFor: #isAlive!public!states-testing! !
!Process categoriesFor: #isAlive:!private!states-testing! !
!Process categoriesFor: #isDead!public!states-testing! !
!Process categoriesFor: #isDebuggee!private!states-testing! !
!Process categoriesFor: #isInCallback!private!testing! !
!Process categoriesFor: #isMain!public!testing! !
!Process categoriesFor: #isReady!public!states-testing! !
!Process categoriesFor: #isSuspended!public!states-testing! !
!Process categoriesFor: #isTerminated!public!states-testing! !
!Process categoriesFor: #isWaiting!public!states-testing! !
!Process categoriesFor: #kill!public!states-changing! !
!Process categoriesFor: #lastError!accessing!public! !
!Process categoriesFor: #launchBlock:!accessing!public! !
!Process categoriesFor: #name!accessing!public! !
!Process categoriesFor: #name:!accessing!public! !
!Process categoriesFor: #primitiveFailureCode!accessing!private! !
!Process categoriesFor: #primitiveFailureData!accessing!private! !
!Process categoriesFor: #primTerminate!private!states-changing! !
!Process categoriesFor: #printOn:!development!printing!public! !
!Process categoriesFor: #priority!accessing!public! !
!Process categoriesFor: #priority:!accessing!public! !
!Process categoriesFor: #queueInterrupt:!interrupts!public! !
!Process categoriesFor: #queueInterrupt:with:!interrupts!public! !
!Process categoriesFor: #resume!public!states-changing! !
!Process categoriesFor: #resume:!public!states-changing! !
!Process categoriesFor: #resumeUnconditionally!public!states-changing! !
!Process categoriesFor: #setPriority:!accessing!private! !
!Process categoriesFor: #shutdown!private!states-changing! !
!Process categoriesFor: #size!accessing!public! !
!Process categoriesFor: #spOfIndex:!private!stack frames! !
!Process categoriesFor: #stackFramesFrom:depth:!helpers!private! !
!Process categoriesFor: #stackFramesFrom:depth:do:!helpers!private! !
!Process categoriesFor: #stackTrace:!helpers!private! !
!Process categoriesFor: #stackTraceFrom:depth:!helpers!private! !
!Process categoriesFor: #state!private!states-changing! !
!Process categoriesFor: #stbSaveOn:!binary filing!public! !
!Process categoriesFor: #suspend!public!states-changing! !
!Process categoriesFor: #suspendedFrame!private!stack frames! !
!Process categoriesFor: #suspendedFrame:!private!stack frames! !
!Process categoriesFor: #suspendingList!accessing!private! !
!Process categoriesFor: #suspendUnconditionally!public!states-changing! !
!Process categoriesFor: #terminate!public!states-changing! !
!Process categoriesFor: #threadSync!accessing!private! !
!Process categoriesFor: #topFrame!private!stack frames! !

!Process class methodsFor!

forContext: aBlockClosure priority: anInteger 
	"Private - Answer a suspended instance of the receiver that will execute the block,
	aBlockClosure, at the priority, anInteger.
	N.B. There are certain requirements which must be met by the launch block, aBlockClosure,
	if the new process is to die quietly without causing a GPF:
		1) It must be a zero argument BlockClosure (not just any old niladic valuable)
		2) It must have a null home stack frame (i.e. its home context is marked as having
		already returned).
		3) It must catch ProcessTermination notifications, and proceed through to its 
		shutdown code (e.g. [...] on: ProcessTermination do: [:pt | pt return]).
		4) It must send #shutdown to the active process so that it is properly terminated.
		5) It must perform a ^-return as its last action.
	Items (2) and (5) ensure that any attempt to drop off the bottom of the process stack
	is trapped by the VM and results in a 'Context Expiry' walkback rather than an
	unrecoverable GPF."

	^self new
		launchBlock: aBlockClosure;
		priority: anInteger;
		yourself.!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

initialize
	"Initialize the class variables of the receiver:
		DefaultStack		-	The initial stack size of new Processes. This should be relatively
							small so as not to waste space, and to reduce instantiation overhead,
							but not so small that it causes a stack fault and growth. A default
							value which corresponds to less than one OS page (normally 4k bytes, 
							or 1024 object pointers) will be rounded up to one OS page. The
							actual stack size will be slightly less than the number of pointers
							which fit on one OS page, because the VM adjusts it to account for 
							Process' fixed instance variables, and overhead.
		DefaultMaxStack	-	The maximum size to which the stack of new Processes can grow before
							the VM signals a stack overflow. Processes grow by a page each time 
							a stack overflow occurs, from the initial size, up to this maximum.
							This value should be large enough to allow useful work to be done by 
							recursive methods, but not so large that programming errors go 
							undetected, It is unlikely that a stack need be large than 32768, 
							and for those instances, specific instantiation is recommended.

	Evaluate me to initialize:
		Process initialize
	"

	DefaultStack := 1.			"Let the VM work out the minimum size (will be an OS page)"
	DefaultMaxStack := (128*4*1024)/4. 	"Grow to 128K slots (512Kb) before overflow."

	"Floating point Inexact and Underflow exceptions will be masked (i.e. not raised) by default"
	DefaultFPEMask := _EM_INEXACT | _EM_UNDERFLOW.!

new
	"Private - Answer a new instance of the receiver. In order to create a runnable process,
	the suspendedFrame and priority must be set. The normal way to create a process
	is to use one of the #forkXX methods of BlockClosure."

	^(self new: DefaultStack max: DefaultMaxStack) initialize! !
!Process class categoriesFor: #forContext:priority:!instance creation!private! !
!Process class categoriesFor: #icon!constants!public! !
!Process class categoriesFor: #initialize!development!initializing!public! !
!Process class categoriesFor: #new!instance creation!private! !

