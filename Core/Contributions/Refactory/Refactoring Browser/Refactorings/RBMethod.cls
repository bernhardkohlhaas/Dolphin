"Filed out from Dolphin Smalltalk 7"!

Object subclass: #RBMethod
	instanceVariableNames: 'class compiledMethod source selector'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
RBMethod guid: (GUID fromString: '{4f76178d-295e-4b31-9cda-d786b96c5ed7}')!
RBMethod comment: 'RBMethod represents a method in an RBAbstractClass.

Instance Variables:
	class	<RBAbstractClass>	where the method is defined
	compiledMethod	<CompiledCode | nil>	the CompiledMethod object (if we have been compiled)
	selector	<Symbol>	our name
	source	<String>	our source'!
!RBMethod categoriesForClass!Refactory-Model! !
!RBMethod methodsFor!

literal: anObject containsReferenceTo: aSymbol 
	anObject = aSymbol ifTrue: [^true].
	anObject class = Array ifFalse: [^false].
	anObject 
		do: [:each | (self literal: each containsReferenceTo: aSymbol) ifTrue: [^true]].
	^false!

method
	^compiledMethod!

method: aCompiledMethod 
	compiledMethod := aCompiledMethod!

modelClass
	^class!

modelClass: aRBClass
	class := aRBClass!

parseTree
	^RBParser parseMethod: self source in: self modelClass realClass onError: [:str :pos | ^nil]!

printOn: aStream 
	class printOn: aStream.
	aStream
		nextPutAll: '>>';
		nextPutAll: self selector!

refersToClassNamed: aSymbol 
	| searcher |
	searcher := ParseTreeSearcher new.
	searcher matches: aSymbol asString do: [:node :answer | true].
	^(searcher executeTree: self parseTree initialAnswer: false) 
		or: [self refersToSymbol: aSymbol]!

refersToSymbol: aSymbol 
	| searcher |
	searcher := ParseTreeSearcher new.
	searcher
		matches: aSymbol printString do: [:node :answer | true];
		matches: '`#literal'
			do: [:node :answer | answer or: [self literal: node value containsReferenceTo: aSymbol]].
	(RBScanner isSelector: aSymbol) 
		ifTrue: 
			[searcher 
				matches: '`@object ' , (ParseTreeSearcher buildSelectorString: aSymbol)
				do: [:node :answer | true]].
	^searcher executeTree: self parseTree initialAnswer: false!

refersToVariable: aString 
	| searcher tree |
	tree := self parseTree.
	((tree defines: aString) or: [tree body defines: aString]) 
		ifTrue: [^false].
	searcher := ParseTreeSearcher new.
	searcher
		matches: aString do: [:node :answer | true];
		matches: '[:`@vars | | `@temps | `@.Stmts]'
			do: 
				[:node :answer | 
				answer or: 
						[((node defines: aString) or: [node body defines: aString]) not 
							and: [searcher executeTree: node body initialAnswer: false]]].
	^searcher executeTree: self parseTree initialAnswer: false!

selector
	^selector!

selector: aSymbol 
	selector := aSymbol!

source
	^source isNil 
		ifTrue: [source := compiledMethod getSource]
		ifFalse: [source]!

source: aString 
	source := aString! !
!RBMethod categoriesFor: #literal:containsReferenceTo:!private! !
!RBMethod categoriesFor: #method!accessing!public! !
!RBMethod categoriesFor: #method:!accessing!public! !
!RBMethod categoriesFor: #modelClass!accessing!public! !
!RBMethod categoriesFor: #modelClass:!accessing!public! !
!RBMethod categoriesFor: #parseTree!accessing!public! !
!RBMethod categoriesFor: #printOn:!printing!public! !
!RBMethod categoriesFor: #refersToClassNamed:!public!testing! !
!RBMethod categoriesFor: #refersToSymbol:!public!testing! !
!RBMethod categoriesFor: #refersToVariable:!public!testing! !
!RBMethod categoriesFor: #selector!accessing!public! !
!RBMethod categoriesFor: #selector:!accessing!public! !
!RBMethod categoriesFor: #source!accessing!public! !
!RBMethod categoriesFor: #source:!accessing!public! !

!RBMethod class methodsFor!

for: aRBClass fromMethod: aCompiledMethod andSelector: aSymbol 
	^(self new)
		modelClass: aRBClass;
		method: aCompiledMethod;
		selector: aSymbol;
		yourself!

for: aRBClass source: aString selector: aSelector 
	^(self new)
		modelClass: aRBClass;
		selector: aSelector;
		source: aString;
		yourself! !
!RBMethod class categoriesFor: #for:fromMethod:andSelector:!instance creation!public! !
!RBMethod class categoriesFor: #for:source:selector:!instance creation!public! !

