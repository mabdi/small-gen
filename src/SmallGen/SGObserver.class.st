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
	sampleCode := aSampleCode.
	captureTargets := aListOfClassesCapture asSet.
	observationTargets := aListOfClasses asSet.
	observations := Dictionary new.
	self observe.
	^ observations asDictionary
]

{ #category : #'as yet unclassified' }
SGObserver >> inScope: aClass [
	^ (observationTargets includes: aClass)
]

{ #category : #'as yet unclassified' }
SGObserver >> installObservers [
	(captureTargets asOrderedCollection sort: [ :a :b  | b allSuperclasses includes: a ]) do: [ :aClass | self installObserversFor: aClass ]
]

{ #category : #'as yet unclassified' }
SGObserver >> installObserversFor: aClass [
	aClass methods do: [ :aMethod | self installProxyOn: aMethod ].
	(aClass allInstVarNames includes: 'smallgen_state')
		ifFalse: [ aClass addInstVarNamed: 'smallgen_state' ].
	aClass
		compile:
			'smallgen_state smallgen_state ifNil: [smallgen_state := SGHistory with: self]. ^ smallgen_state dictionaryRepresentation'.
	aClass
		compile:
			'smallgen_enterMethod: aSelector args: args smallgen_state ifNil: [smallgen_state := SGHistory with: self]. ^ smallgen_state enterMethod: aSelector on: self  args: args'.
	aClass
		compile:
			'smallgen_exitMethod: aSelector args: args result: aResult preCallData: preCallData smallgen_state ifNil: [smallgen_state := SGHistory for: self]. ^ smallgen_state exitMethod: aSelector on: self args: args result: aResult preCallData: preCallData'.
	aClass compile: 'smallgen_state_identity smallgen_state ifNil: [smallgen_state := SGHistory for: self]. ^ smallgen_state state_identity'
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
	| state |
	(self inScope: aReceiver class)
		ifFalse: [ ^ self ].
	state := aReceiver smallgen_state.
	(observations at: aReceiver class name ifAbsentPut: Dictionary new)
		at: (state at: #uuid)
		put: state
]

{ #category : #'as yet unclassified' }
SGObserver >> uninstallObservers [
	captureTargets  do: [ :aClass | self uninstallObserversFor: aClass ]
]

{ #category : #'as yet unclassified' }
SGObserver >> uninstallObserversFor: aClass [
	"aClass removeSelector: #smallGenCallRecords:."

	SGProxy cureClass: aClass.
	(aClass allInstVarNames includes: 'smallgen_state')
		ifFalse: [ aClass addInstVarNamed: 'smallgen_state' ].
	aClass removeSelector: #smallgen_state.
	aClass removeSelector: #smallgen_enterMethod:.
	aClass removeSelector: #smallgen_exitMethod:.
	aClass removeSelector: #smallgen_state_identity.
	(aClass hasInstVarNamed: 'smallgen_state')
		ifFalse: [ aClass removeInstVarNamed: 'smallgen_state' ]
]

{ #category : #'instance creation' }
SGObserver >> with: aConfig [
	self initialize.
	config := aConfig
]
