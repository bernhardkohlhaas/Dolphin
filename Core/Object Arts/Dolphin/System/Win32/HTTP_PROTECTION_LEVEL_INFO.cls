"Filed out from Dolphin Smalltalk 7"!

HTTP_PROPERTY_FLAGS subclass: #HTTP_PROTECTION_LEVEL_INFO
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
HTTP_PROTECTION_LEVEL_INFO guid: (GUID fromString: '{e1881388-d03e-4ea0-8e39-8f1439753299}')!
HTTP_PROTECTION_LEVEL_INFO comment: '<HTTP_PROTECTION_LEVEL_INFO> is an <ExternalStructure> class to wrap the struct ''Win32.HTTP_PROTECTION_LEVEL_INFO'' from type information in the ''Win32 API'' library.

The type library contains the following helpstring for this struct
	"Controls whether the associated UrlGroup Namespace should receive edge traversed traffic. By default this parameter is unspecified."

** This comment was automatically generated from a type library. Delete this line to prevent any manual edits from being overwritten if the wrapper class is regenerated. **

IDL definition follows:

typedef [uuid(e1881388-d03e-4ea0-8e39-8f1439753299), helpstring("Controls whether the associated UrlGroup Namespace should receive edge traversed traffic. By default this parameter is unspecified.")]
struct tagHTTP_PROTECTION_LEVEL_INFO {
	HTTP_PROPERTY_FLAGS;
	HTTP_PROTECTION_LEVEL_TYPE level;
} HTTP_PROTECTION_LEVEL_INFO;
'!
!HTTP_PROTECTION_LEVEL_INFO categoriesForClass!Win32-Structs! !
!HTTP_PROTECTION_LEVEL_INFO methodsFor!

level
	"Answer the <Integer> value of the receiver's 'level' field."

	^bytes sdwordAtOffset: ##(self offsetOf: #level)!

level: anInteger
	"Set the receiver's 'level' field to the value of the argument, anInteger"

	bytes sdwordAtOffset: ##(self offsetOf: #level) put: anInteger! !
!HTTP_PROTECTION_LEVEL_INFO categoriesFor: #level!**compiled accessors**!public! !
!HTTP_PROTECTION_LEVEL_INFO categoriesFor: #level:!**compiled accessors**!public! !

!HTTP_PROTECTION_LEVEL_INFO class methodsFor!

defineFields
	"Define the fields of the HTTP_PROTECTION_LEVEL_INFO structure.

	HTTP_PROTECTION_LEVEL_INFO compileDefinition

		typedef [uuid(e1881388-d03e-4ea0-8e39-8f1439753299), helpstring('Controls whether the associated UrlGroup Namespace should receive edge traversed traffic. By default this parameter is unspecified.')]
		struct tagHTTP_PROTECTION_LEVEL_INFO {
			HTTP_PROPERTY_FLAGS;
			HTTP_PROTECTION_LEVEL_TYPE level;
		} HTTP_PROTECTION_LEVEL_INFO;
"

	super defineFields.
	self
		defineField: #level type: SDWORDField new offset: 4.
	self byteSize: 8! !
!HTTP_PROTECTION_LEVEL_INFO class categoriesFor: #defineFields!**auto generated**!initializing!public! !

