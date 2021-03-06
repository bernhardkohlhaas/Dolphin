"Filed out from Dolphin Smalltalk 7"!

Object subclass: #StParseNodeVisitor
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
StParseNodeVisitor guid: (GUID fromString: '{8cf81be6-059c-46da-86e3-b21a6781066b}')!
StParseNodeVisitor comment: 'BRProgramNodeVisitor is an abstract visitor for the BRProgramNodes.

'!
!StParseNodeVisitor categoriesForClass!Refactory-ParseTree Matching! !
!StParseNodeVisitor methodsFor!

processBlock: aBlockNode
	self visitArgumentNodes: aBlockNode arguments.
	self visitNode: aBlockNode body!

tagBeforeTemporaries
	^false!

visitArgumentNode: anStVariableNode
	"Here to allow subclasses to detect arguments or temporaries."

	^self visitVariableNode: anStVariableNode!

visitArgumentNodes: aNodeCollection
	^aNodeCollection do: [:each | self visitArgumentNode: each]!

visitAssignmentNode: anAssignmentNode
	self visitNode: anAssignmentNode variable.
	self visitNode: anAssignmentNode value!

visitBlockNode: aBlockNode
	self processBlock: aBlockNode!

visitCascadeNode: aCascadeNode
	aCascadeNode messages do: [:each | self visitNode: each]!

visitExternalArgTypeNode: anAssignmentNode
	"Dolphin specific extension"

	!

visitExternalCallNode: anStExternalCallNode
	"Dolphin specific extension"

	!

visitLiteralArrayNode: aLiteralArrayNode
	aLiteralArrayNode contents do: [:each | self visitNode: each]!

visitLiteralNode: aLiteralNode
	!

visitMessageNode: aMessageNode
	(aMessageNode isCascaded not or: [aMessageNode isFirstCascaded])
		ifTrue: [self visitNode: aMessageNode receiver].
	aMessageNode arguments do: [:each | self visitNode: each]!

visitMethodNode: aMethodNode
	self visitArgumentNodes: aMethodNode arguments.
	self visitNode: aMethodNode body!

visitNode: aNode 
	^aNode acceptVisitor: self!

visitOptimizedNode: anOptimizedNode
	self visitNode: anOptimizedNode body!

visitPrimitiveNode: anStPrimitiveNode
	!

visitReturnNode: aReturnNode
	self visitNode: aReturnNode value!

visitSequenceNode: aSequenceNode
	self visitTemporaryNodes: aSequenceNode temporaries.
	self tagBeforeTemporaries
		ifFalse: 
			[aSequenceNode parent
				ifNotNil: [:parent | parent isMethod ifTrue: [parent tag ifNotNil: [:tag | self visitNode: tag]]]].
	self visitStatements: aSequenceNode statements!

visitStatements: aNodeCollection
	aNodeCollection do: [:each | self visitNode: each]!

visitTemporaryNodes: aNodeCollection
	"Visit temporary declarations in a method or block body"

	^self visitArgumentNodes: aNodeCollection!

visitVariableNode: aVariableNode
	^aVariableNode! !
!StParseNodeVisitor categoriesFor: #processBlock:!helpers!private! !
!StParseNodeVisitor categoriesFor: #tagBeforeTemporaries!public!testing! !
!StParseNodeVisitor categoriesFor: #visitArgumentNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitArgumentNodes:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitAssignmentNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitBlockNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitCascadeNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitExternalArgTypeNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitExternalCallNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitLiteralArrayNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitLiteralNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitMessageNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitMethodNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitOptimizedNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitPrimitiveNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitReturnNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitSequenceNode:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitStatements:!helpers!private! !
!StParseNodeVisitor categoriesFor: #visitTemporaryNodes:!public!visiting! !
!StParseNodeVisitor categoriesFor: #visitVariableNode:!public!visiting! !

!StParseNodeVisitor class methodsFor!

new
	^super new initialize! !
!StParseNodeVisitor class categoriesFor: #new!instance creation!public! !

