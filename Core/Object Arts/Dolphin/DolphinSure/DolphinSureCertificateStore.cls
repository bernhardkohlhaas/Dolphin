"Filed out from Dolphin Smalltalk 7"!

Object subclass: #DolphinSureCertificateStore
	instanceVariableNames: 'regKey'
	classVariableNames: ''
	poolDictionaries: ''
	classInstanceVariableNames: ''!
DolphinSureCertificateStore guid: (GUID fromString: '{39c8afb3-b270-4b5a-bd4f-c370eeb7c57b}')!
DolphinSureCertificateStore comment: 'A DolphinSureCertificateStore is used to store DolphinSureCertificates for later retrieval.  The implementation uses the Windows Registry under HKEY_CURRENT_USER and certificates are stored as binary bytes (streamed out using STB). They can be looked up by serial number.

Currently, three such stores are defined and can be accessed by the following class methods:

#myCertificates --  is used to store your own personal certificates that have been issued to.  When you receive a certificate it will be in the form of an ST text file with a series of Smalltalk expressions that can be used to regenerate the certificate instance.  Once this is done there is also an expression to store the certificate into your "my certificates" store.

#temporaryTrust -- is used to store certificates for publishers that should be trusted in future, but only within the current Dolphin session.  If a certificate is added to this store then any content from the publisher will be automatically trusted until Dolphin (or the current DolphinSure application) shuts down. For example, if a user chooses to trust the publisher of a particular web applet, the publisher''s certificate will be added to the temporary trust store so that further prompts for each class that is loaded are unnecessary.  This store is cleared down whenever the image starts. This store is used by the Dolphin web applet plug-in but can also be used by other applications.

#permanentTrust -- is used to store certificates for publishers that are to be permanently trusted in future. Certificates are typically added to this store if the user ticks the box marked, "Always trust content from this publisher?", when faced with a SignedClassWarning dialog. This store is used by the Dolphin web applet plug-in but can also be used by other applications.

Instance Variables:
	regKey		<RegKey> identifying the registry location of certificates held by this store.

'!
!DolphinSureCertificateStore categoriesForClass!Cryptography-Certificates! !
!DolphinSureCertificateStore methodsFor!

<= aDolphinSureCertificateStore
	"Answer whether the receiver is 'less than' aDolphinSureCertificateStore.
	By implementing this method, we enable DolphinSureCertificateStore objects to be stored
	in a SortedCollection with the default sort block."

	^self name <= aDolphinSureCertificateStore name!

addCertificate: aDolphinSureCertificate
	"Adds aDolphinSureCertificate to the receiver"

	self regKey valueAt: aDolphinSureCertificate serial put: aDolphinSureCertificate binaryStoreBytes!

atSerial: aStringSerialNo ifAbsent: exceptionHandler
	"Answers the certificate stored in the receiver at aStringSerialNo. Evaluates
	the exceptionHandler if no such certificate is found"

	| bytes |
	bytes := self regKey subValues at: aStringSerialNo ifAbsent: [ ^exceptionHandler value ].
	^Object fromBinaryStoreBytes: bytes!

certificates
	"Answer anOrderedCollection of the certificates in the receiver"

	^self regKey subValues associations collect: [:each | Object fromBinaryStoreBytes: each value]!

default
	"Answer the default (first) certificate in the receiver"

	^Object fromBinaryStoreBytes: (self regKey subValues associations first value)!

displayOn: aStream
	"Append a textual representation of the receiver to the <puttableStream> argument
	as a user might want to see it."

	aStream display: self name.
!

includesCertificate: aDolphinSureCertificate
	"Answers true if the receiver includes aDolphinSureCertificate"

	^self includesSerial: aDolphinSureCertificate serial!

includesSerial: aStringSerialNo
	"Answers ttrue if the certificate with aStringSerialNo is stored in the receiver. Evaluates
	the exceptionHandler if no such certificate is found"

	^(self regKey subValues at: aStringSerialNo ifAbsent: []) notNil.
!

name
	"Answers the <readableString> name of the receiver"

	^File splitStemFrom: regKey name

	!

name: aStringName
	"Private - Initializes the receiver with aStringName"

	regKey := RegKey userRoot createKey: (self class certificateStoreRoot , '\', aStringName)

	!

printOn: aStream
	"Append a textual representation of the receiver to the <puttableStream> argument
	as a developer might want to see it."

	aStream 
		basicPrint: self;
		nextPut: $(;
		display: self;
		nextPut: $)!

regKey
	"Private - Answers the registry key for the receiver"

	^regKey!

removeAllCertificates
	"Removes all certificates from the receiver"

	| name |
	name := File splitStemFrom: self regKey name.
	self regKey parentKey removeKey: self regKey name.
	self name: name

	

!

removeCertificate: aDolphinSureCertificate ifAbsent: exceptionHandler
	"Removes aDolphinSureCertificate to the receiver. Evaluates the exceptionHandler
	if the certificate was not in the store"

	self regKey removeSubValue: aDolphinSureCertificate serial ifAbsent: exceptionHandler!

serials
	"Answer anOrderedCollection of the certificate serial numbers in the receiver"

	^self regKey subValues associations collect: [:each | each key]! !
!DolphinSureCertificateStore categoriesFor: #<=!comparing!public! !
!DolphinSureCertificateStore categoriesFor: #addCertificate:!adding!public! !
!DolphinSureCertificateStore categoriesFor: #atSerial:ifAbsent:!accessing!public! !
!DolphinSureCertificateStore categoriesFor: #certificates!accessing!public! !
!DolphinSureCertificateStore categoriesFor: #default!accessing!public! !
!DolphinSureCertificateStore categoriesFor: #displayOn:!printing!public! !
!DolphinSureCertificateStore categoriesFor: #includesCertificate:!public!testing! !
!DolphinSureCertificateStore categoriesFor: #includesSerial:!public!testing! !
!DolphinSureCertificateStore categoriesFor: #name!initializing!private! !
!DolphinSureCertificateStore categoriesFor: #name:!initializing!private! !
!DolphinSureCertificateStore categoriesFor: #printOn:!printing!public! !
!DolphinSureCertificateStore categoriesFor: #regKey!accessing!private! !
!DolphinSureCertificateStore categoriesFor: #removeAllCertificates!public!removing! !
!DolphinSureCertificateStore categoriesFor: #removeCertificate:ifAbsent:!public!removing! !
!DolphinSureCertificateStore categoriesFor: #serials!accessing!public! !

!DolphinSureCertificateStore class methodsFor!

allStores
	"Answers a Set of all the available certificate stores"

	^(RegKey userRoot at: self certificateStoreRoot) keys collect: [:each | self name: each]!

certificateStoreRoot
	"Private - Answer the root key of the DolphinSure stores"

	^'Software\Object Arts\DolphinSure\Certificates'!

clearTemporaryTrustStore
	"Private - Clear the temporary trust store"

	self temporaryTrust removeAllCertificates!

initialize
	"Private - Initialize the receiver

	self initialize.
"

	"When the image restarts the local trust store is emptied"
	SessionManager current when: #sessionStarted send: #clearTemporaryTrustStore to: self.
!

myCertificates
	"Answer an instance of the receiver for the my certificates store."

	^self name: 'My Certificates'!

name: aStringName
	"Answer an instance of the receiver with aStringName"

	^super new name: aStringName!

new
	"Private - Use #name:"

	self shouldNotImplement!

permanentTrust
	"Answer an instance of the receiver for the permanently trusted certificate store."

	^self name: 'PermanentTrust'!

temporaryTrust
	"Answer an instance of the receiver for the temporarilyt rusted certificate store."

	^self name: 'TemporaryTrust'!

uninitialize
	SessionManager current removeEventsTriggeredFor: self! !
!DolphinSureCertificateStore class categoriesFor: #allStores!enquiries!public! !
!DolphinSureCertificateStore class categoriesFor: #certificateStoreRoot!accessing!private! !
!DolphinSureCertificateStore class categoriesFor: #clearTemporaryTrustStore!operations!private! !
!DolphinSureCertificateStore class categoriesFor: #initialize!initializing!private! !
!DolphinSureCertificateStore class categoriesFor: #myCertificates!instance creation!public! !
!DolphinSureCertificateStore class categoriesFor: #name:!instance creation!public! !
!DolphinSureCertificateStore class categoriesFor: #new!instance creation!private! !
!DolphinSureCertificateStore class categoriesFor: #permanentTrust!instance creation!public! !
!DolphinSureCertificateStore class categoriesFor: #temporaryTrust!instance creation!public! !
!DolphinSureCertificateStore class categoriesFor: #uninitialize!class hierarchy-removing!private! !

