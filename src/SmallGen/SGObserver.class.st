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
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGObserver class >> initWith: config [
	^ self new with: config
]

{ #category : #'as yet unclassified' }
SGObserver >> buildCallRecordFor: aReciever selector: selector withArgs: args result: aResult inScope: inScope stateBefore: state1 stateAfter: state2 [
	| res |
	res := SGCallRecord new
		selector: selector;
		isVoidReturn: aResult == aReciever;
		inScope: inScope;
		returnValue: nil;
		args: (args collect: [ :arg | (self getCallRecordsFor: arg) copy ]).
	inScope
		ifTrue: [ aResult == aReciever
				ifFalse: [ res returnValue: (SGHistory for: aResult) ].
			res
				receiverLastState: state1;
				receiverCurrentState: state2 ].
	^ res
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
		ifTrue: [ ^ SGLiteralHistory  for: anObject ].
	anObject isClass
		ifTrue: [ ^ SGClassHistory for: anObject ].
	^ allObjects at: anObject ifAbsentPut: (SGHistory for: anObject)
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
	| thisHistory popedSelector inScope |
	thisHistory := self getCallRecordsFor: aReceiver.
	popedSelector := thisHistory callStack pop.
	popedSelector = selector
		ifFalse: [ self halt.
			self error: 'You shouldnt be here. something is wrong.' ].
	thisHistory callStack ifNotEmpty: [ ^ self ].
	inScope := self inScope: aReceiver class.
	thisHistory
		append:
			(self
				buildCallRecordFor: aReceiver
				selector: selector
				withArgs: args
				result: result
				inScope: inScope
				stateBefore: thisHistory lastState
				stateAfter: (STON toString: aReceiver)).
	inScope
		ifTrue: [ self snapShot: thisHistory ]
]

{ #category : #'as yet unclassified' }
SGObserver >> preCall: selector with: args in: aReceiver [
	| thisHistory |
	thisHistory := self getCallRecordsFor: aReceiver.
	thisHistory coveredMethods add: selector.
	thisHistory callStack push: selector.
	thisHistory lastState: (STON toString: aReceiver)
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
