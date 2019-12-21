Class {
	#name : #SGObserver,
	#superclass : #Object,
	#instVars : [
		'config',
		'sampleCode',
		'captureTargets',
		'observationTargets',
		'allObjects',
		'coverage',
		'observations'
	],
	#category : #'SmallGen-Observation'
}

{ #category : #'as yet unclassified' }
SGObserver class >> initWith: config [
	^ self new with: config
]

{ #category : #'instance creation' }
SGObserver >> generateObservationFor: aListOfClasses targetsCapture: aListOfClassesCapture byRunning: aSampleCode [
	| result |
	sampleCode := aSampleCode.
	captureTargets := aListOfClassesCapture asSet.
	observationTargets := aListOfClasses asSet.
	observations := Dictionary new.
	allObjects := Dictionary new.
	self observe.
	result := Dictionary new.
	(observations
		do: [ :val | (result at: val theClass ifAbsentPut: OrderedCollection new) add: val ])
		asDictionary.
	^ result
]

{ #category : #'as yet unclassified' }
SGObserver >> getCallRecordsFor: anObject [
	anObject isLiteral
		ifTrue: [ ^ SGLiteralHistory for: anObject ].
	anObject isClass
		ifTrue: [ ^ SGClassHistory for: anObject ].
	^ allObjects
		at: anObject
		ifAbsentPut:
			((SGHistory for: anObject)
				inScope: (self inScope: anObject class);
				yourself)
]

{ #category : #'as yet unclassified' }
SGObserver >> inScope: aClass [
	^ (observationTargets includes: aClass)
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
	(self isItSafeToProxyTo: aMethod)
		ifFalse: [ ^ self ].
	link := SGProxy on: aMethod action: self.
	link install
]

{ #category : #'as yet unclassified' }
SGObserver >> isItSafeToProxyTo: aMethod [
	({#initialization} includes: aMethod protocol)
		ifTrue: [ ^ false ].
	^ true
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
SGObserver >> postCall: selector with: args in: aReceiver result: result [
	| thisHistory popedSelector res |
	thisHistory := self getCallRecordsFor: aReceiver.
	popedSelector := thisHistory callStack pop.
	popedSelector = selector
		ifFalse: [ self error: 'You shouldnt be here. something is wrong.' ].
	thisHistory callStack ifNotEmpty: [ ^ self ].
	res := SGRecord new
		selector: selector;
		isVoidReturn: result == aReceiver;
		returnValue: nil;
		receiverLastState: thisHistory lastState;
		receiverCurrentState: (SGHelpers new serialize: aReceiver);
		args: (args collect: [ :arg | (self getCallRecordsFor: arg) copy ]).
	thisHistory inScope
		ifTrue: [ res coverage: thisHistory coveredMethods copy.
			result == aReceiver
				ifFalse: [ res returnValue: (SGHistory for: result) ] ].
	thisHistory append: res.
	thisHistory coveredMethods removeAll.
	thisHistory inScope
		ifTrue: [ self snapShot: thisHistory ]
]

{ #category : #'as yet unclassified' }
SGObserver >> preCall: selector with: args in: aReceiver [
	| thisHistory |
	thisHistory := self getCallRecordsFor: aReceiver.
	thisHistory coveredMethods add: selector.
	thisHistory callStack push: selector.
	thisHistory lastState: (SGHelpers new serialize: aReceiver)
]

{ #category : #'as yet unclassified' }
SGObserver >> snapShot: thisRecord [
	observations at: thisRecord theUniqueId put: thisRecord copy
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
