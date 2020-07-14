Class {
	#name : #SGObserver,
	#superclass : #Object,
	#instVars : [
		'config',
		'sampleCode',
		'captureTargets',
		'observationTargets',
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
	self observe.
	result := Dictionary new.
	(observations
		do:
			[ :val | (result at: val theClass ifAbsentPut: OrderedCollection new) add: val ])
		asDictionary.
	^ result
]

{ #category : #'as yet unclassified' }
SGObserver >> inScope: aClass [
	^ (observationTargets includes: aClass)
]

{ #category : #'as yet unclassified' }
SGObserver >> installObservers [
	captureTargets  do: [ :aClass | self installObserversFor: aClass ]
]

{ #category : #'as yet unclassified' }
SGObserver >> installObserversFor: aClass [
	aClass methods do: [ :aMethod | self installProxyOn: aMethod ].
	aClass addInstVarNamed: 'smallgen_state'.
	aClass
		compile:
			'smallgen_state smallgen_state ifNil: [smallgen_state := SGHistory for: self]. ^ smallgen_state asString'.
	aClass
		compile:
			'smallgen_enterMethod: aSelector args: args smallgen_state ifNil: [smallgen_state := SGHistory for: self]. smallgen_state enterMethod: aSelector args: args'.
	aClass
		compile:
			'smallgen_exitMethod: aSelector args: args result: aResult preCallData: preCallData smallgen_state ifNil: [smallgen_state := SGHistory for: self]. smallgen_state exitMethod: aSelector on: self args: args result: aResult preCallData: preCallData'.
	
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
	^ observations
]

{ #category : #'as yet unclassified' }
SGObserver >> postCall: selector with: args in: aReceiver result: result preCallData: preCallData [
	| canLog |
	canLog := aReceiver
		smallgen_exitMethod: selector
		args: args
		result: result
		preCallData: preCallData.
	canLog
		ifFalse: [ ^ self ].
	self snapShotIfInScope: aReceiver
]

{ #category : #'as yet unclassified' }
SGObserver >> preCall: selector with: args in: aReceiver [
	^ aReceiver smallgen_enterMethod: selector args: args
]

{ #category : #'as yet unclassified' }
SGObserver >> snapShotIfInScope: aReceiver [ 
	(self inScope: aReceiver) ifTrue: [ observations at: aReceiver class name put: aReceiver smallgen_state ]
	
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
