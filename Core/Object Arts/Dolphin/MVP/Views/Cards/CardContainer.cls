"Filed out from Dolphin Smalltalk 7"!

AbstractCardContainer subclass: #CardContainer
	instanceVariableNames: 'tabs'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
CardContainer guid: (GUID fromString: '{87b4c71c-026e-11d3-9fd7-00a0cc3e4a32}')!
CardContainer comment: 'A CardContainer is a <cardView> that allows each of its cards (sub-views) to appear with named tabs. The tab names are specified by the #arrangement aspects of the sub-views and appear in the z-order maintained by the container. The CardContainer uses a TabView to provide the name tabs.

Typically a CardContainer will be used for tab-style property pages within a dialog. For another example, the Categories/Protocols/Variables pane in the Class Hierarchy Browser is implemented using a CardContainer.

Instance Variables:
	tabs	<TabView> holding the name tabs.

'!
!CardContainer categoriesForClass!MVP-Views! !
!CardContainer methodsFor!

arrangementOf: aView put: anObject 
	"Set the arrangement parameter for aView in the receiver layout manager 
	to be anObject. Usually anObject will be a String to be used to identify
	the card. This is also added to the tab view associated with the receiver."

	| existingTab |
	existingTab := aView arrangement.
	super arrangementOf: aView put: anObject.
	(tabs model includes: existingTab) 
		ifTrue: 
			["If the view has already an arrangement, just do an update of the tab 
			instead of removing it and adding it. This will keep the tabs in order"
			| index |
			index := tabs model identityIndexOf: existingTab.
			tabs model at: index put: anObject]
		ifFalse: [tabs model add: anObject]!

backcolor: aColorOrNil 
	"Sets the background colour of the receiver to aColorOrNil.
	If aColorOrNil is nil then use the default color"

	backcolor := aColorOrNil.
	tabs backcolor: aColorOrNil!

createTabs
	"Private - Add a <TabView> as a non-managed sub view of the receiver"

	tabs notNil ifTrue: [^self].
	tabs := self newTabs.
	tabs isManaged: false.
	self basicAddSubView: tabs.
	tabs backcolor: nil!

defaultBackcolor
	^Color face3d!

defaultViewClass
	^TabViewXP!

ensureTabsAtBack
	"Private - Force the associated tab view to be behind all our managed subviews so that it
	does not obscure them. We must do this silently without causing an #onZOrderChanged."

	self hasOwnTabs 
		ifTrue: 
			[tabs 
				setWindowPosAfter: HWND_BOTTOM
				x: 0
				y: 0
				width: 0
				height: 0
				flags: ##(SWP_NOSIZE | SWP_NOMOVE)]!

getImageBlock
	"Answer the block to use to find out the image index of an object that will
	be placed displayed in the TabView associated with the receiver."

	^tabs getImageBlock!

getImageBlock: aOneArgBlock 
	"Set the block to use to find out the image index of an object that will
	be placed in the TabView associated with the receiver"

	tabs getImageBlock: aOneArgBlock!

getTextBlock
	"Answer the block to use to find out the text of an object that will
	be placed displayed in the TabView associated with the receiver."

	^tabs getTextBlock!

getTextBlock: aOneArgBlock 
	"Set the block to use to find out the text of an object that will
	be placed in the TabView associated with the receiver"

	tabs getTextBlock: aOneArgBlock!

hasButtons
	"Answer whether the receiver has the buttons instead of tabs."

	^tabs hasButtons!

hasButtons: aBoolean 
	"Set whether or not the receiver has buttons instead of tabs."

	^tabs hasButtons: aBoolean!

hasHotTracking
	"Answer whether the receiver has the hot-tracking style whereby tabs that are hovered over are automatically selected."

	^tabs hasHotTracking!

hasHotTracking: aBoolean 
	"Sets the receiver to hot-track the selection or not depending on the value of aBoolean."

	tabs hasHotTracking: aBoolean!

hasOwnTabs
	"Answer whether the tabs associated with the receiver are owned by the receiver. This will
	normally be the case, unless embedded in a SlidingCardContainer that supplies the tabs."

	^tabs parentView == self!

implicitInsets: aLayoutContext 
	"Private - Answer a <Rectangle> whose edges specify the implicit distance (in pixels) by
	which the sub views have to be inset from the border of the receiver."

	"Implementation Note: We must calculate this to allow space for the TabView's decoration
	(the tabs themselves, borders, etc)."

	| rect clientRect |
	self hasOwnTabs ifFalse: [^Rectangle new].
	rect := aLayoutContext rectangleOf: tabs.
	clientRect := tabs calcClientRectangleFromRectangle: rect.
	^rect insetBy: clientRect!

isDropTarget: aBoolean 
	tabs isDropTarget: aBoolean.
	^super isDropTarget: aBoolean!

isInverted
	#deprecated. "D6: Use #tabOrientation"
	^tabs isInverted!

isInverted: aBoolean 
	#deprecated. "D6: Use #tabOrientation:"
	^tabs isInverted: aBoolean!

isMultiline
	"Answers whether the receiver can display multiple lines of tabs."

	^tabs isMultiline!

isMultiline: aBoolean 
	"Set whether the receiver can display multiple lines of tabs."

	tabs isMultiline: aBoolean!

isTabStop
	"Answers whether the receiver is a tab stop."

	^tabs isTabStop!

isTabStop: aBoolean 
	"Set whether or not the receiver is a tab stop."

	^tabs isTabStop: aBoolean!

isVertical
	#deprecated. "D6: Use #tabOrientation"
	^tabs isVertical!

isVertical: aBoolean 
	#deprecated.	"D6: Use #tabOrientation:"
	^tabs isVertical: aBoolean!

layout: aLayoutContext 
	"Private - Recalculate the geometry of the receiver. Force the tab view to be the same size
	as the receiver, then ask for the standard layout to continue."

	self hasOwnTabs 
		ifTrue: [aLayoutContext setView: tabs rectangle: (0 @ 0 extent: (aLayoutContext extentOf: self))].
	super layout: aLayoutContext!

newTabs
	^self defaultViewClass new!

onCurrentCardChanged
	"Private - The current card has been changed in the layout manager. 
	Select the appropriate tab in the receiver to reflect this, and trigger
	our own card change event."

	tabs selection: self cardLayout currentCard arrangement.
	super onCurrentCardChanged!

onEraseRequired: aColorEvent 
	"Handler for erase background event- erase to the background colour,
	or answer nil if no colour is set to accept the default window processing."

	"CardContainers are completely covered by their unmanaged TabView child."

	^true!

onSubViewAdded: aView
	"Private - Received when aView has been added to the receiver. Ensure that the associated
	tab view is sent to the back"

	self ensureTabsAtBack.
	super onSubViewAdded: aView.
!

onTabChanged
	"Private - A tab has been selected by the user. 
	Ask our layout manager to show the appropriate view"

	| tabName |
	tabName := tabs selectionIfNone: [^self].
	self cardLayout showCardWithArrangement: tabName.

	"Note: Without the followng focus shift, Windows can loop endlessly if the receiver gains 
	focus and a key is typed."
	self hasFocusDeeply ifTrue: [self tabOntoCurrentCard]!

onTabChanging: booleanValue
	"Private - A tab has been selected by the user."

	self trigger: #currentCardChanging: with: booleanValue!

onViewCreated
	super onViewCreated.
	self createTabs.
	tabs
		when: #selectionChanging:
			send: #onTabChanging:
			to: self;
		when: #selectionChanged
			send: #onTabChanged
			to: self!

onZOrderChanged
	"Private - Received when the ZOrder of the receiver's subview has been changed.
	Rebuild the assocaited tab view to reflect the new ordering"

	super onZOrderChanged.
	self ensureTabsAtBack.
	self refreshTabs



	!

preTranslateKeyboardInput: aMSG 
	"Answer whether the receiver would like to consume the argument aMSG,
	which is a keyboard message."

	^tabs preTranslateKeyboardInput: aMSG!

queryCommand: aCommandQuery 
	"Update aCommandQuery to indicates how a command would be processed.
	if sent to the receiver. Answers whether the receiver recognised the command
	as one of its own (this may be ignored by the command router). This need not
	be supersent if the #isEnabled: is sent to the <CommandQuery> to explicitly
	enable or disable a particular command."

	| cmd |
	cmd := aCommandQuery commandSymbol.
	#viewMode: == cmd 
		ifTrue: [aCommandQuery isChecked: self viewMode == aCommandQuery command arguments first].
	#tabOrientation: == cmd 
		ifTrue: [aCommandQuery isChecked: self tabOrientation == aCommandQuery command arguments first].
	^super queryCommand: aCommandQuery!

refreshTabs
	"Rebuild the associated tab view to include all the managed subviews
	of the receiver in the correct z order sequence"

	| currentCard arrangements layout |
	layout := self cardLayout.
	currentCard := layout currentCard.
	arrangements := self cards collect: [:each | each arrangement].
	tabs model list: arrangements.
	currentCard ifNotNil: [layout showCard: currentCard]!

removeSubView: aView 
	"Removes aView as a subview of the receiver. First remove
	any associated tab. If aView is indeed a subview of the receiver then it is destroyed. If not,
	it continues to live."

	| arrangement |
	arrangement := self arrangementOf: aView.
	tabs model remove: arrangement ifAbsent: [].
	super removeSubView: aView!

tabOrientation
	"Answer a <Symbol> naming the orientation of the receiver. This primarily controls where the
	tab strip is displayed and is one of #left, #right, #top (the default) or #bottom."

	^tabs tabOrientation!

tabOrientation: aSymbol 
	"Set the orientation of the receiver. This primarily controls where the tab strip is
	displayed. The <Symbol> argument can be one of #left, #right, #top (the default) or
	#bottom."

	tabs tabOrientation: aSymbol!

tabs
	^tabs!

updateTabs
	"Update the tabs to reflect change in text/icon etc. We assume the arrangement object identity has not changed; if it
	has then #refreshTabs is more appropriate."

	tabs updateAll!

viewMode
	"Answer the view mode of the TabView associated with the receiver.
	This can be one of:
		#noIcons
		#smallIcons
		#largeIcons"

	^tabs viewMode!

viewMode: aSymbol 
	"Sets the view mode of the TabView associated with the reciver to aSymbol.
	This can be one of:
		#noIcons
		#smallIcons
		#largeIcons"

	tabs viewMode: aSymbol!

wmPrint: message wParam: wParam lParam: lParam 
	"Private - Handle WM_PRINT."

	"Implementation Note: For some reason the DefWindowProc implementation seems to paint the
	TabView over the top of the current card (even though at the back in the z-order), so we
	need to take control."

	| result canvas insetRect prev |
	self ensureLayoutValid.
	result := self 
				defaultWindowProcessing: message
				wParam: wParam
				lParam: lParam.
	self currentCard isNil ifTrue: [^result].
	(false or: [lParam noMask: PRF_CHILDREN]) ifTrue: [^result].
	insetRect := self actualInsets: (LayoutContext forContainer: self parentView).
	canvas := Canvas withNonOwnedDC: wParam.
	prev := canvas offsetWindowOrigin: (insetRect topLeft + (0 @ 0)) * -1.
	self currentCard 
		sendMessage: message
		wParam: wParam
		lParam: lParam.
	canvas windowOrigin: prev.
	^result! !
!CardContainer categoriesFor: #arrangementOf:put:!accessing!public! !
!CardContainer categoriesFor: #backcolor:!accessing!public! !
!CardContainer categoriesFor: #createTabs!helpers!private! !
!CardContainer categoriesFor: #defaultBackcolor!public! !
!CardContainer categoriesFor: #defaultViewClass!constants!public! !
!CardContainer categoriesFor: #ensureTabsAtBack!operations!private! !
!CardContainer categoriesFor: #getImageBlock!adapters!public! !
!CardContainer categoriesFor: #getImageBlock:!adapters!public! !
!CardContainer categoriesFor: #getTextBlock!adapters!public! !
!CardContainer categoriesFor: #getTextBlock:!adapters!public! !
!CardContainer categoriesFor: #hasButtons!accessing-styles!public! !
!CardContainer categoriesFor: #hasButtons:!accessing-styles!public! !
!CardContainer categoriesFor: #hasHotTracking!accessing-styles!public! !
!CardContainer categoriesFor: #hasHotTracking:!accessing-styles!public! !
!CardContainer categoriesFor: #hasOwnTabs!public!testing! !
!CardContainer categoriesFor: #implicitInsets:!accessing!private! !
!CardContainer categoriesFor: #isDropTarget:!accessing!public! !
!CardContainer categoriesFor: #isInverted!accessing-styles!public! !
!CardContainer categoriesFor: #isInverted:!accessing-styles!public! !
!CardContainer categoriesFor: #isMultiline!accessing!public! !
!CardContainer categoriesFor: #isMultiline:!accessing!public! !
!CardContainer categoriesFor: #isTabStop!accessing!public! !
!CardContainer categoriesFor: #isTabStop:!accessing-styles!public! !
!CardContainer categoriesFor: #isVertical!accessing-styles!public! !
!CardContainer categoriesFor: #isVertical:!accessing-styles!public! !
!CardContainer categoriesFor: #layout:!geometry!public! !
!CardContainer categoriesFor: #newTabs!helpers!private! !
!CardContainer categoriesFor: #onCurrentCardChanged!event handling!private! !
!CardContainer categoriesFor: #onEraseRequired:!event handling!public! !
!CardContainer categoriesFor: #onSubViewAdded:!event handling!private! !
!CardContainer categoriesFor: #onTabChanged!event handling!private! !
!CardContainer categoriesFor: #onTabChanging:!event handling!private! !
!CardContainer categoriesFor: #onViewCreated!event handling!private! !
!CardContainer categoriesFor: #onZOrderChanged!event handling!private! !
!CardContainer categoriesFor: #preTranslateKeyboardInput:!public! !
!CardContainer categoriesFor: #queryCommand:!commands!public! !
!CardContainer categoriesFor: #refreshTabs!public!updating! !
!CardContainer categoriesFor: #removeSubView:!public! !
!CardContainer categoriesFor: #tabOrientation!accessing-styles!public! !
!CardContainer categoriesFor: #tabOrientation:!accessing-styles!public! !
!CardContainer categoriesFor: #tabs!accessing!private! !
!CardContainer categoriesFor: #updateTabs!public!updating! !
!CardContainer categoriesFor: #viewMode!accessing!public! !
!CardContainer categoriesFor: #viewMode:!accessing!public! !
!CardContainer categoriesFor: #wmPrint:wParam:lParam:!private! !

!CardContainer class methodsFor!

resource_Default_view
	"Answer the literal data from which the 'Default view' resource can be reconstituted.
	DO NOT EDIT OR RECATEGORIZE THIS METHOD.

	If you wish to modify this resource evaluate:
	ViewComposer openOn: (ResourceIdentifier class: self selector: #resource_Default_view)
	"

	^#(#'!!STL' 3 788558 10 ##(Smalltalk.STBViewProxy)  8 ##(Smalltalk.CardContainer)  98 16 0 0 98 2 8 1409286144 131073 416 0 524550 ##(Smalltalk.ColorRef)  8 4278190080 0 5 0 0 0 416 655878 ##(Smalltalk.CardLayout)  202 208 98 0 0 234 256 592 0 410 8 ##(Smalltalk.TabViewXP)  98 28 0 416 98 2 8 1140916736 1 624 590662 2 ##(Smalltalk.ListModel)  202 208 592 0 1310726 ##(Smalltalk.IdentitySearchPolicy)  0 0 1 0 0 0 624 0 8 4294903589 787814 3 ##(Smalltalk.BlockClosure)  0 0 918822 ##(Smalltalk.CompiledMethod)  2 3 8 ##(Smalltalk.ListControlView)  8 #defaultGetTextBlock 575230339 8 #[30 105 226 0 106] 8 #displayString 816 7 257 0 802 0 0 834 2 3 8 ##(Smalltalk.IconicListAbstract)  8 #defaultGetImageBlock 579598755 8 #[30 105 226 0 106] 8 #iconImageIndex 928 7 257 0 1049670 1 ##(Smalltalk.IconImageManager)  0 0 0 0 0 8 #noIcons 0 0 0 0 0 983302 ##(Smalltalk.MessageSequence)  202 208 98 2 721670 ##(Smalltalk.MessageSend)  8 #createAt:extent: 98 2 328198 ##(Smalltalk.Point)  1 1 1202 701 501 624 1138 8 #tcmSetExtendedStyle:dwExStyle: 98 2 -1 1 624 983302 ##(Smalltalk.WINDOWPLACEMENT)  8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 0 0 0 0 0 0 0 0 94 1 0 0 250 0 0 0] 98 0 1202 193 193 0 27 1074 202 208 98 1 1138 1168 98 2 1202 2799 21 1202 701 501 416 1298 8 #[44 0 0 0 0 0 0 0 1 0 0 0 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 255 119 5 0 0 10 0 0 0 213 6 0 0 4 1 0 0] 98 1 624 1360 0 27 )! !
!CardContainer class categoriesFor: #resource_Default_view!public!resources-views! !

