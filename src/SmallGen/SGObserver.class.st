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
SGObserver >> buildCallRecordFor: aReciever selector: selector withArgs: args result: aResult [
	| res isVoid |
	res := nil.
	aResult == aReciever
		ifTrue: [ isVoid := true ]
		ifFalse: [ res := (SGHistory for: aResult)].
	^ SGCallRecord new
		selector: selector;
		isVoidReturn: isVoid;
		returnValue: res;
		args: (args collect: [ :arg | (self getCallRecordsFor: arg) copy ])
]

{ #category : #'instance creation' }
SGObserver >> generateObservationFor: aListOfClasses targetsCapture: aListOfClassesCapture byRunning: aSampleCode [
	sampleCode := aSampleCode.
	captureTargets := aListOfClassesCapture asSet.
	observationTargets := aListOfClasses asSet.
	observations := Dictionary new. 
	allObjects := Dictionary new.
	self observe.
	^ observations
]

{ #category : #'as yet unclassified' }
SGObserver >> getCallRecordsFor: anObject [
	anObject isLiteral
		ifTrue: [ ^ SGLiteralHistory  for: anObject ].
	anObject isClass
		ifTrue: [ ^ SGClassHistory for: anObject ].
	^ allObjects at: anObject ifAbsentPut: (SGHistory for: anObject)
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
	| thisHistory popedSelector skip |
	thisHistory := self getCallRecordsFor: aReceiver.
	popedSelector := thisHistory callStack pop.
	popedSelector = selector
		ifFalse: [ self halt.
			self error: 'You shouldnt be here. something is wrong.' ].
	thisHistory callStack ifNotEmpty: [ ^ self ].
	skip := true.
	thisHistory lastState = (STON toString: aReceiver)
		ifFalse: [ skip := false ].	"It's state updating call"
	(observationTargets includes: aReceiver class)
		ifTrue: [ result == aReceiver
				ifFalse: [ skip := false ]	"It returns something on target" ].
	skip
		ifTrue: [ ^ self ].
	thisHistory
		append:
			(self
				buildCallRecordFor: aReceiver
				selector: selector
				withArgs: args
				result: result).
	(observationTargets includes: aReceiver class)
		ifTrue: [ self snapShot: thisHistory ]
]

{ #category : #'as yet unclassified' }
SGObserver >> preCall: selector with: args in: aReceiver [
	| thisHistory |
	thisHistory := self getCallRecordsFor: aReceiver.
	
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
