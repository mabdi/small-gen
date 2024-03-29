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

{ #category : #'as yet unclassified' }
SGObserver class >> logMe: txt [ 
	Stdio stdout
		nextPutAll: txt;
		lf;
		flush
]

{ #category : #'as yet unclassified' }
SGObserver >> addStateInstanceVariable: aClass [
	self logMe: 'state_var:  ' , aClass name.
	aClass allSubclasses
		do: [ :cls | 
			(cls hasInstVarNamed: 'smallgen_state')
				ifTrue: [ aClass removeInstVarNamed: 'smallgen_state' ] ].
	(aClass allInstVarNames includes: 'smallgen_state')
		ifFalse: [ aClass addInstVarNamed: 'smallgen_state' ].
	self observerMethods do: [ :mtd | aClass compile: mtd sourceCode ]
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
	"(captureTargets asOrderedCollection
		sort: [ :a :b | b allSuperclasses includes: a ])
		do: [ :aClass | self installObserversFor: aClass ]"

	| allsubs |
	allsubs := captureTargets flatCollect: [ :cls | cls allSubclasses ].
	(captureTargets difference: allsubs asSet)
		do: [ :aClass | self addStateInstanceVariable: aClass ].
	self logMe: 'state variable and methods installation done '.	
	captureTargets do: [ :cls | self installObserversFor: cls ].
	self logMe: 'observer installation done '
]

{ #category : #'as yet unclassified' }
SGObserver >> installObserversFor: aClass [
	
	aClass methods
		reject: [ :aMethod | aMethod selector beginsWith: 'smallgen' ]
		thenDo: [ :aMethod | self installProxyOn: aMethod ]
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

{ #category : #'as yet unclassified' }
SGObserver >> logMe: txt [
	self class logMe: txt
]

{ #category : #'instance creation' }
SGObserver >> observe [
	[ self installObservers.
	sampleCode value ]
		ensure: [ self uninstallObservers ].
	
	^ observations
]

{ #category : #'as yet unclassified' }
SGObserver >> observerMethods [
	^ {ObserverTrait >> #smallgen_state.
	ObserverTrait >> #smallgen_enterMethod:args:
			.ObserverTrait >> #smallgen_exitMethod:args:result:preCallData:.
			ObserverTrait >> #smallgen_state_identity:}
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
	self snapShotIfInScope: aReceiver.
	
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
	self observerMethods do: [ :mtd | aClass removeSelector: mtd selector ].
	(aClass hasInstVarNamed: 'smallgen_state')
		ifTrue: [ aClass removeInstVarNamed: 'smallgen_state' ]
]

{ #category : #'instance creation' }
SGObserver >> with: aConfig [
	self initialize.
	config := aConfig
]
