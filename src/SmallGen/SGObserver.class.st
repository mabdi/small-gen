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
		'coverage',
		'callStack'
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
SGObserver >> generateObservationFor: aListOfClasses byRunning: aSampleCode [
	sampleCode := aSampleCode.
	captureTargets := aListOfClasses copy.
	observationTargets:= aListOfClasses copy.
	observations := self getAnObservation.
	self observe.
	^ observations
]

{ #category : #'instance creation' }
SGObserver >> generateObservationFor: aListOfClasses targetsCapture: aListOfClassesCapture byRunning: aSampleCode [
	sampleCode := aSampleCode.
	captureTargets := aListOfClassesCapture copy.
	observationTargets := aListOfClasses copy.
	observations := self getAnObservation.
	allObjects := Dictionary new.
	callStack := Stack new.
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
		  ifTrue: [ SGCallHistory for: anObject ]
		  ifFalse: [ 
		  allObjects at: anObject ifAbsentPut: (SGCallHistory for: anObject) ]
]

{ #category : #'instance creation' }
SGObserver >> initialize [ 
	allObjects := Dictionary new
]

{ #category : #'as yet unclassified' }
SGObserver >> installMetaLinkOn: aMethod [
	| link link2 |
	(self isItSafeToAddMetaLinkTo: aMethod)
		ifFalse: [ ^ self ].
	link := MetaLink new
		metaObject: self;
		selector: #linkBeforeMethodCallArguments:receiver:selector:context:;
		control: #before;
		level: 0;
		condition: [ :alink | true ] arguments: #(link);
		arguments: #(arguments receiver selector context).
	link2 := MetaLink new
		metaObject: self;
		selector: #linkAfterMethodCallArguments:receiver:selector:context:;
		control: #after;
		level: 0;
		condition: [ :alink | true ] arguments: #(link);
		arguments: #(arguments receiver selector context).	
	aMethod ast link: link.
	aMethod ast link: link2
]

{ #category : #'as yet unclassified' }
SGObserver >> installObservers [
	captureTargets  do: [ :aClass | self installObserversFor: aClass ]
]

{ #category : #'as yet unclassified' }
SGObserver >> installObserversFor: aClass [
	aClass compile: 'smallGenCallRecords: observer
	^ observer getCallRecordsFor: self'.
	aClass methods do: [ :aMethod | self installMetaLinkOn: aMethod ]
]

{ #category : #'as yet unclassified' }
SGObserver >> isItSafeToAddMetaLinkTo: aMethod [
	({ #initialization } includes: aMethod protocol) ifTrue: [ ^ false ].
	^ ({ #smallGenCallRecords: } includes: aMethod selector) not
]

{ #category : #'as yet unclassified' }
SGObserver >> linkAfterMethodCallArguments: args receiver: aReceiver selector: selector context: context [
	| s |
	(observationTargets includes: aReceiver class)
		ifTrue: [ s := callStack pop.
	s = selector
		ifFalse: [ self halt ] ].
	
]

{ #category : #'as yet unclassified' }
SGObserver >> linkBeforeMethodCallArguments: args receiver: aReceiver selector: selector context: context [
	| thisRecord snapshot |
	thisRecord := self getCallRecordsFor: aReceiver.
	thisRecord
		append: (self buildCallRecordFor: aReceiver selector: selector withArgs: args).
	snapshot := true.
	(observationTargets includes: aReceiver class)
		ifFalse: [ snapshot := false ]
		ifTrue: [ callStack push: selector. ].
	callStack size > 1
		ifTrue: [ snapshot := false ].
	snapshot
		ifTrue: [ self snapShot: thisRecord ]
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
		self halt
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
	aClass removeSelector: #smallGenCallRecords:.
	aClass methods do: [ :aMethod | self uninstallMetaLinkOn: aMethod ]
]

{ #category : #'instance creation' }
SGObserver >> with: aConfig [
	self initialize.
	config := aConfig
]
