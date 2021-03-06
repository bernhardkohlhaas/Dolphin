"Filed out from Dolphin Smalltalk 7"!

ControlView subclass: #Tooltip
	instanceVariableNames: ''
	classVariableNames: 'TtnMap'
	poolDictionaries: 'TooltipConstants'
	classInstanceVariableNames: ''!
Tooltip guid: (GUID fromString: '{ba32bd21-5167-4bd1-949c-ab76875cdeb7}')!
Tooltip comment: 'Tooltip is a <ControlView> class which wraps the Windows Tool Tip control.'!
!Tooltip categoriesForClass!MVP-Views! !
!Tooltip methodsFor!

add: aTOOLINFOA tool: aView 
	"Adds a tool tip for aWinWindow to the receiever."

	self ttmAddTool: aTOOLINFOA.
	aView toolTipWindow: self!

alwaysTip
	^self baseStyleAllMask: TTS_ALWAYSTIP!

alwaysTip: aBoolean 
	self 
		baseStyleMask: TTS_ALWAYSTIP
		set: aBoolean
		recreateIfChanged: false!

defaultBackcolor
	^Color tooltip!

endTracking
	self sendMessage: TTM_TRACKACTIVATE wParam: false asParameter!

forecolor: aColorOrNil 
	"Sets the foreground colour of the receiver to aColorOrNil.
	If aColorOrNil is nil then use the default color"

	| clrref |
	super forecolor: aColorOrNil.
	clrref := (aColorOrNil isNil ifTrue: [Color tooltipText] ifFalse: [aColorOrNil]) 
				asColorRef asParameter.
	self sendMessage: TTM_SETTIPTEXTCOLOR wParam: clrref!

hasCloseButton
	"Answer whether the balloon tooltip has a close button."

	^self baseStyleAllMask: TTS_CLOSE!

hasCloseButton: aBoolean
	"Set whether the bubble message will have a close button,
	off by default. Changing this style has no effect once opened."

	self 
		baseStyleMask: TTS_CLOSE
		set: aBoolean
		recreateIfChanged: false!

isActive: aBoolean 
	"Activate or deactivate the tips, depending on the <Boolean> argument."

	self sendMessage: TTM_ACTIVATE wParam: aBoolean asParameter!

isBalloon
	"Answer whether the receiver has the balloon (speech bubble) style."

	^self baseStyleAllMask: TTS_BALLOON!

isBalloon: aBoolean 
	"Sets the rectangle style of this static control."

	self 
		baseStyleMask: TTS_BALLOON
		set: aBoolean
		recreateIfChanged: false!

margins
	"Answer a <Rectangle> specifying the left, right, top and bottom margins.
	Each margin is the distance in pixels between the relevant edge and the tip text."

	| rect |
	rect := RECT new.
	self 
		sendMessage: TTM_GETMARGIN
		wParam: 0
		lpParam: rect.
	^rect asRectangle!

margins: aRectangle 
	self 
		sendMessage: TTM_SETMARGIN
		wParam: 0
		lpParam: aRectangle asParameter!

maxWidth
	"Answer the maximum width of the tip, or -1 if none is specified.
	If a maximum width is set and the tip text needs more space, then 
	the tip window will expand to multiple lines."

	^self sendMessage: TTM_GETMAXTIPWIDTH!

maxWidth: anInteger 
	self 
		sendMessage: TTM_SETMAXTIPWIDTH
		wParam: 0
		lParam: anInteger!

nmNotify: anNMHDR 
	"Handler for a redirected WinListView WM_NOTIFY message."

	^(TtnMap at: (anNMHDR sdwordAtOffset: 8) ifAbsent: []) 
		ifNil: [super nmNotify: anNMHDR]
		ifNotNil: [:action | self perform: action with: anNMHDR]!

onLeftButtonReleased: aMouseEvent 
	"Default handler for a Left button up mouse event.
	Accept the default window processing."

	self hasCloseButton ifFalse: [
			[self
				pop;
				close] postToMessageQueue].
	^super onLeftButtonPressed: aMouseEvent!

onLinkClicked
	"A hyperlink embedded in the text of the tooltip has been clicked."

	self presenter trigger: #linkClicked.
	^nil!

onPop
	"The ToolTip is about to be hidden."

	self presenter trigger: #tipPopped!

onShow
	"The ToolTip is about to be shown. Answer false to display the tooltip in its default position. 
	Or reposition the tooltip (with SetWindowPos) and return true to suppress the default 
	positioning."

	| suppress |
	suppress := false asValue.
	self presenter trigger: #showTip: with: suppress.
	^suppress value!

pop
	self sendMessage: TTM_POP!

registerView: aView 
	self ttmAddTool: ((TOOLINFOA new)
				uFlags: ##(TTF_IDISHWND | TTF_CENTERTIP);
				textCallback;
				hwnd: aView asParameter;
				uId: aView asParameter;
				yourself)!

reshowDelay
	"Answer the <integer> number of milliseconds of delay between appearances of the tip window
	after it has popped up the first time - e.g. when sliding between buttons in a toolbar."

	^self ttmGetDelayTime: TTDT_RESHOW!

reshowDelay: anInteger 
	"Set the number of milliseconds of delay between appearances of the tip window after 
	it has popped up the first time - e.g. when sliding between buttons in a toolbar, to the
	<integer> argument."

	self ttmSetDelayTime: TTDT_RESHOW milliseconds: anInteger!

setControlBackcolor: aColor 
	self sendMessage: TTM_SETTIPBKCOLOR wParam: aColor asColorRef asParameter!

showDelay
	"Answer the <integer> number of milliseconds that the mouse must remain stationary
	over a tool before the tip window appears for the first time."

	^self ttmGetDelayTime: TTDT_INITIAL!

showDelay: anInteger 
	"Set the number of milliseconds that the mouse must remain stationary
	over a tool before the tip window appears for the first time to the 
	<integer> argument."

	self ttmSetDelayTime: TTDT_INITIAL milliseconds: anInteger!

showDuration
	"Answer the <integer> number of milliseconds that is the maximum period for which
	the tip window will be shown, even if the mouse remains stationary."

	^self ttmGetDelayTime: TTDT_AUTOPOP!

showDuration: anInteger 
	"Set the number of milliseconds that is the maximum period for which
	the tip window will be shown, even if the mouse remains stationary,
	to the <integer> argument."

	self ttmSetDelayTime: TTDT_AUTOPOP milliseconds: anInteger!

startTracking: aTOOLINFO 
	self 
		sendMessage: TTM_TRACKACTIVATE
		wParam: true asParameter
		lpParam: aTOOLINFO!

tools
	^(0 to: self ttmGetToolCount - 1) collect: 
			[:each | 
			| tool |
			tool := TOOLINFOA new.
			self ttmEnumTools: each info: tool.
			tool]!

trackPosition: aPoint 
	self 
		sendMessage: TTM_TRACKPOSITION
		wParam: 0
		lParam: aPoint asUIntPtr!

ttmAddTool: aTOOLINFOA 
	"Register a new tool with the receiver."

	(self 
		sendMessage: TTM_ADDTOOLA
		wParam: 0
		lpParam: aTOOLINFOA asParameter) == 0 
		ifTrue: [^self errorInCommonControlCall]!

ttmDelTool: aTOOLINFOA 
	"Unregister a tool from the receiver."

	self 
		sendMessage: TTM_DELTOOLA
		wParam: 0
		lpParam: aTOOLINFOA asParameter!

ttmEnumTools: anInteger info: aTOOLINFOA 
	"Enumerate the tools set up for the receiver."

	^(self 
		sendMessage: TTM_ENUMTOOLSA
		wParam: anInteger
		lpParam: aTOOLINFOA) asBoolean!

ttmGetCurrentTool
	"Retrieve the text for the current tool."

	| struct |
	struct := TOOLINFOA new.
	^(self 
		sendMessage: TTM_GETCURRENTTOOLA
		wParam: 0
		lpParam: struct) == 0 
		ifTrue: [self errorInCommonControlCall]
		ifFalse: [struct]!

ttmGetDelayTime: anInteger 
	^self sendMessage: TTM_GETDELAYTIME wParam: anInteger!

ttmGetMargin
	| answer |
	answer := RECT new.
	(self 
		sendMessage: TTM_GETMARGIN
		wParam: 0
		lpParam: answer) == 0 
		ifTrue: [self errorInCommonControlCall]
		ifFalse: [answer]!

ttmGetToolCount
	"Answer the number of tools with which the receiver is associated."

	^self sendMessage: TTM_GETTOOLCOUNT!

ttmGetToolInfo: aTOOLINFOA 
	"Retrieve tool details identified in aTOOLINFOA, filling out the structure."

	(self 
		sendMessage: TTM_GETTOOLINFOA
		wParam: 0
		lpParam: aTOOLINFOA asParameter) == 0 
		ifTrue: [^self errorInCommonControlCall]!

ttmRelayEvent: aMSG 
	"Private - Forward the windows mouse message, aMSG, to the tool tip control."

	self 
		sendMessage: TTM_RELAYEVENT
		wParam: 0
		lpParam: aMSG asParameter.
	"Return false as we don't want to consume the MSG"
	^false!

ttmSetDelayTime: dwInteger milliseconds: msInteger 
	self 
		sendMessage: TTM_SETDELAYTIME
		wParam: dwInteger
		lParam: msInteger!

ttmSetTitle: aString icon: anInteger 
	self 
		sendMessage: TTM_SETTITLEA
		wParam: anInteger
		lpParam: aString!

ttnLinkClick: pNMHDR 
	"Default handler for the TTN_LINKCLICK message, which is a notification that the 
	user has clicked an underlined link in the tooltip. Answer nil to accept the default processing."

	^self presenter onLinkClicked!

ttnPop: anNMHDR 
	"Default handler for the TTN_POP message, which is a notification that the tooltip
	window is about to be hidden. Answer nil to accept the default processing."

	self presenter onPop.
	^nil!

ttnShow: anNMHDR 
	"Private - Handler for the TTN_SHOW message, which is forwarded to the presenter."

	^self presenter onShow! !
!Tooltip categoriesFor: #add:tool:!operations!private! !
!Tooltip categoriesFor: #alwaysTip!public!testing! !
!Tooltip categoriesFor: #alwaysTip:!accessing!public! !
!Tooltip categoriesFor: #defaultBackcolor!colors!constants!public! !
!Tooltip categoriesFor: #endTracking!operations!public! !
!Tooltip categoriesFor: #forecolor:!accessing!public! !
!Tooltip categoriesFor: #hasCloseButton!public!testing! !
!Tooltip categoriesFor: #hasCloseButton:!accessing!public! !
!Tooltip categoriesFor: #isActive:!accessing!public! !
!Tooltip categoriesFor: #isBalloon!public!testing! !
!Tooltip categoriesFor: #isBalloon:!accessing!public! !
!Tooltip categoriesFor: #margins!accessing!public! !
!Tooltip categoriesFor: #margins:!accessing!public! !
!Tooltip categoriesFor: #maxWidth!accessing!public! !
!Tooltip categoriesFor: #maxWidth:!accessing!public! !
!Tooltip categoriesFor: #nmNotify:!events-win32!private! !
!Tooltip categoriesFor: #onLeftButtonReleased:!event handling!public! !
!Tooltip categoriesFor: #onLinkClicked!event handling!public! !
!Tooltip categoriesFor: #onPop!events-win32!public! !
!Tooltip categoriesFor: #onShow!events-win32!public! !
!Tooltip categoriesFor: #pop!operations!public! !
!Tooltip categoriesFor: #registerView:!operations!private! !
!Tooltip categoriesFor: #reshowDelay!accessing!public! !
!Tooltip categoriesFor: #reshowDelay:!accessing!public! !
!Tooltip categoriesFor: #setControlBackcolor:!helpers!private! !
!Tooltip categoriesFor: #showDelay!accessing!public! !
!Tooltip categoriesFor: #showDelay:!accessing!public! !
!Tooltip categoriesFor: #showDuration!accessing!public! !
!Tooltip categoriesFor: #showDuration:!accessing!public! !
!Tooltip categoriesFor: #startTracking:!operations!public! !
!Tooltip categoriesFor: #tools!operations!private! !
!Tooltip categoriesFor: #trackPosition:!geometry!public! !
!Tooltip categoriesFor: #ttmAddTool:!operations!private! !
!Tooltip categoriesFor: #ttmDelTool:!operations!private! !
!Tooltip categoriesFor: #ttmEnumTools:info:!operations!private! !
!Tooltip categoriesFor: #ttmGetCurrentTool!accessing!private! !
!Tooltip categoriesFor: #ttmGetDelayTime:!accessing!private! !
!Tooltip categoriesFor: #ttmGetMargin!accessing!private! !
!Tooltip categoriesFor: #ttmGetToolCount!accessing!private! !
!Tooltip categoriesFor: #ttmGetToolInfo:!accessing!private! !
!Tooltip categoriesFor: #ttmRelayEvent:!operations!private! !
!Tooltip categoriesFor: #ttmSetDelayTime:milliseconds:!accessing!private! !
!Tooltip categoriesFor: #ttmSetTitle:icon:!operations!private! !
!Tooltip categoriesFor: #ttnLinkClick:!events-win32!private! !
!Tooltip categoriesFor: #ttnPop:!events-win32!private! !
!Tooltip categoriesFor: #ttnShow:!events-win32!private! !

!Tooltip class methodsFor!

icon
	"Answers an Icon that can be used to represent this class"

	^##(self) defaultIcon!

initialize
	"Private - Initialise the map of Tooltip notification codes to selector/parameter-class pairs."

	TtnMap := (IdentityDictionary new)
				at: TTN_SHOW put: #ttnShow:;
				at: TTN_POP put: #ttnPop:;
				at: TTN_LINKCLICK put: #ttnLinkClick:;
				shrink;
				yourself!

winClassName
	"Private - Answer the name of the Windows window class to use when realizing the receiver."

	^'tooltips_class32'
! !
!Tooltip class categoriesFor: #icon!constants!public! !
!Tooltip class categoriesFor: #initialize!public! !
!Tooltip class categoriesFor: #winClassName!constants!private! !

