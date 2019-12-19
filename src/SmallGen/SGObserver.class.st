Class {
	#name : #SGObserver,
	#superclass : #Object,
	#instVars : [
		'config',
		'sampleCode',
		'observations',
		'captureTargets',
		'observationTargets',
		'allObjects',
		'coverage'
	],
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGObserver class >> initWith: config [
	^ self new with: config
]

{ #category : #'as yet unclassified' }
SGObserver >> buildCallRecordFor: aReciever selector: selector withArgs: args [
	
	^ SGCallRecord new
		selector: selector;
		args: (args collect: [ :arg | (self getCallRecordsFor: arg) copy ])
]

{ #category : #'as yet unclassified' }
SGObserver >> callerFromContext: context [
	| c |
	c := context.
	"[ c sender receiver class = ReflectiveMethod ]"
	[ c method = (MetaLink >> #valueInContext:) ]
		whileFalse: [ c := c sender ].
	c := c sender sender sender.
	
	^ c
]

{ #category : #'instance creation' }
SGObserver >> generateObservationFor: aListOfClasses targetsCapture: aListOfClassesCapture byRunning: aSampleCode [
	sampleCode := aSampleCode.
	captureTargets := aListOfClassesCapture asSet.
	observationTargets := aListOfClasses asSet.
	observations := self getAnObservation.
	allObjects := Dictionary new.
	self observe.
	^ observations
]

{ #category : #'instance creation' }
SGObserver >> getAnObservation [
	^ OrderedCollection new
]

{ #category : #'as yet unclassified' }
SGObserver >> getCallRecordsFor: anObject [
	^ anObject isLiteral
		ifTrue: [ SGCallHistory forPrimitive: anObject ]
		ifFalse:
			[ allObjects at: anObject ifAbsentPut: (SGCallHistory for: anObject) ]
]

{ #category : #'instance creation' }
SGObserver >> initialize [ 
	allObjects := Dictionary new
]

{ #category : #'as yet unclassified' }
SGObserver >> installObservers [
	captureTargets  do: [ :aClass | self installObserversFor: aClass ]
]

{ #category : #'as yet unclassified' }
SGObserver >> installObserversFor: aClass [
	"aClass methods do: [ :aMethod | self installMetaLinkOn: aMethod ]"
	aClass methods do: [ :aMethod | self installProxyOn: aMethod ]
]

{ #category : #'as yet unclassified' }
SGObserver >> installProxyOn: aMethod [
	| link |
	(self isItSafeToAddMetaLinkTo: aMethod)
		ifFalse: [ ^ self ].
	link := SGProxy on: aMethod action: self.
	link install
]

{ #category : #'as yet unclassified' }
SGObserver >> isItSafeToAddMetaLinkTo: aMethod [
	({ #initialization } includes: aMethod protocol) ifTrue: [ ^ false ].
	^ ({ #smallGenCallRecords: } includes: aMethod selector) not
]

{ #category : #'as yet unclassified' }
SGObserver >> linkInsteadMethodCallArguments: args receiver: aReceiver selector: selector context: link [
	| thisRecord result |
	thisRecord := self getCallRecordsFor: aReceiver.
	thisRecord
		append: (self buildCallRecordFor: aReceiver selector: selector withArgs: args).
	(observationTargets includes: aReceiver class)
		ifTrue: [ self snapShot: thisRecord ].
	"self halt.
	link disable.
	result := aReceiver perform: selector withArguments: args.
	link enable.
	self halt.
	^ result"
]

{ #category : #'instance creation' }
SGObserver >> observe [
	[ self installObservers.
	sampleCode value ]
		ensure: [ self uninstallObservers ].
	allObjects removeAll.
	^ observations
]

{ #category : #'as yet unclassified' }
SGObserver >> postCall: selector with: anArray in: aReceiver result: result [
	| thisHistory popedSelector |
	thisHistory := self getCallRecordsFor: aReceiver.
	popedSelector := thisHistory callStack pop. 
	popedSelector = selector ifFalse: [ self halt. self error: 'You shouldnt be here. something is wrong.' ]
]

{ #category : #'as yet unclassified' }
SGObserver >> preCall: selector with: args in: aReceiver [
	| thisHistory |
	thisHistory := self getCallRecordsFor: aReceiver.
	thisHistory callStack push: selector.
	thisHistory callStack size > 1 ifTrue: [ ^ self ].
	thisHistory
		append: (self buildCallRecordFor: aReceiver selector: selector withArgs: args).
	(observationTargets includes: aReceiver class)
		ifTrue: [ self snapShot: thisHistory ]
]

{ #category : #'as yet unclassified' }
SGObserver >> snapShot: thisRecord [
	observations add: (thisRecord copy)
]

{ #category : #'as yet unclassified' }
SGObserver >> uninstallMetaLinkOn: aMethod [
	aMethod ast links asSet
		select: [ :metalink | metalink metaObject == self ]
		thenDo: [ :metalink | "aMethod removeLink: metalink" metalink uninstall ]
]

{ #category : #'as yet unclassified' }
SGObserver >> uninstallObservers [
	captureTargets  do: [ :aClass | self uninstallObserversFor: aClass ]
]

{ #category : #'as yet unclassified' }
SGObserver >> uninstallObserversFor: aClass [
	"aClass removeSelector: #smallGenCallRecords:."
SGProxy cureClass: aClass
]

{ #category : #'instance creation' }
SGObserver >> with: aConfig [
	self initialize.
	config := aConfig
]
