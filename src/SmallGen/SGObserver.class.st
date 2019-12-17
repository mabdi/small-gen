Class {
	#name : #SGObserver,
	#superclass : #Object,
	#instVars : [
		'config',
		'sampleCode',
		'observations',
		'captureTargets',
		'observationTargets'
	],
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGObserver class >> initWith: config [
	^ self new with: config
]

{ #category : #'as yet unclassified' }
SGObserver >> buildRecordFor: aReciever selector: selector withArgs: args [
	^ SGCallRecord new
		selector: selector;
		args: (args collect: [ :arg | arg smallGenCallRecords copy ])
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
SGObserver >> getAnObservation [
	^ OrderedCollection new
]

{ #category : #'as yet unclassified' }
SGObserver >> installMetaLinkOn: aMethod [
	| link |
	(self isItSafeToAddMetaLinkTo: aMethod) ifFalse: [^ self ].
	link := MetaLink new
		metaObject: self;
		selector: #linkBeforMethodCallArguments:receiver:selector:node:;
		control: #before;
		level: 0;
		arguments: #(arguments receiver selector node)";
		condition: [ :selector | selector  ] arguments: #(selector)".
	aMethod ast link: link
]

{ #category : #'as yet unclassified' }
SGObserver >> installObservers [
	captureTargets  do: [ :aClass | self installObserversFor: aClass ]
]

{ #category : #'as yet unclassified' }
SGObserver >> installObserversFor: aClass [
	aClass addInstVarNamed: 'smallGenState'.
	aClass
		compile:
			'smallGenCallRecords
	^ smallGenState ifNil: [ smallGenState := SGCallHistory for: self ]'.
	aClass methods do: [ :aMethod | self installMetaLinkOn: aMethod ]
]

{ #category : #'as yet unclassified' }
SGObserver >> isItSafeToAddMetaLinkTo: aMethod [
	({ #initialization} includes: aMethod protocol) ifTrue: [ ^ false ] .
	^ ({ #smallGenCallRecords } includes: aMethod selector ) not
]

{ #category : #'as yet unclassified' }
SGObserver >> linkBeforMethodCallArguments: args receiver: aReceiver selector: selector node: node [
	| thisRecord |
	thisRecord := aReceiver smallGenCallRecords.
	thisRecord append: (self buildRecordFor: aReceiver selector: selector withArgs: args). 
	(observationTargets includes: aReceiver class)
		ifTrue: [ self snapShot: thisRecord ]
]

{ #category : #'instance creation' }
SGObserver >> observe [
	[ self installObservers.
	sampleCode value ]
		ensure: [ self uninstallObservers ].
	self halt. "node statements last isReturn  ifTrue: [ "
]

{ #category : #'as yet unclassified' }
SGObserver >> snapShot: thisRecord [
	observations add: (thisRecord copy)
]

{ #category : #'as yet unclassified' }
SGObserver >> uninstallMetaLinkOn: aMethod [
	aMethod links
				select: [ :metalink | metalink metaObject == self ]
				thenDo: [ :metalink | aMethod removeLink: metalink ]
]

{ #category : #'as yet unclassified' }
SGObserver >> uninstallObservers [
	captureTargets  do: [ :aClass | self uninstallObserversFor: aClass ]
]

{ #category : #'as yet unclassified' }
SGObserver >> uninstallObserversFor: aClass [
	aClass removeInstVarNamed: 'smallGenState'.
	aClass removeSelector: #smallGenCallRecords.
	aClass methods do: [ :aMethod | self uninstallMetaLinkOn: aMethod ]
]

{ #category : #'instance creation' }
SGObserver >> with: aConfig [
	self initialize.
	config := aConfig
]
