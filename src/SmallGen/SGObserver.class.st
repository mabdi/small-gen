Class {
	#name : #SGObserver,
	#superclass : #Object,
	#instVars : [
		'config',
		'targets',
		'sampleCode',
		'observations'
	],
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGObserver class >> initWith: config [
	^ self new with: config
]

{ #category : #'as yet unclassified' }
SGObserver >> buildRecordFor: selector withArgs: args [
	^ SGCallRecord new
		selector: selector;
		args: (args collect: [ :arg | arg smallGenCallRecords class = OrderedCollection ifTrue:[ arg smallGenCallRecords collect: [ :rec | rec copy ]] ifFalse: [ arg smallGenCallRecords ] ])
]

{ #category : #'instance creation' }
SGObserver >> generateObservationFor: aListOfClasses byRunning: aSampleCode [
	sampleCode := aSampleCode.
	targets := aListOfClasses copy.
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
	targets do: [ :aClass | self installObserversFor: aClass ]
]

{ #category : #'as yet unclassified' }
SGObserver >> installObserversFor: aClass [
	aClass addInstVarNamed: 'smallGenState'.
	aClass
		compile:
			'smallGenCallRecords
	^ smallGenState ifNil: [ smallGenState := OrderedCollection new ]'.
	aClass methods do: [ :aMethod | self installMetaLinkOn: aMethod ]
]

{ #category : #'as yet unclassified' }
SGObserver >> isItSafeToAddMetaLinkTo: aMethod [
	({ #initialization} includes: aMethod protocol) ifTrue: [ ^ false ] .
	^ ({ #smallGenCallRecords } includes: aMethod selector ) not
]

{ #category : #'as yet unclassified' }
SGObserver >> linkBeforMethodCallArguments: args receiver: aReceiver selector: selector node: node [
	| result thisRecord |
	thisRecord := aReceiver smallGenCallRecords.
	thisRecord class = OrderedCollection ifTrue:[
	 thisRecord add: (self buildRecordFor: selector withArgs: args)].
	"node statements last isReturn  ifTrue: [ "
		self snapShot: thisRecord for: aReceiver 
		 "]."
	
]

{ #category : #'instance creation' }
SGObserver >> observe [
	[self installObservers.
	sampleCode value]
		ensure: [ self uninstallObservers ].
		self halt
]

{ #category : #'as yet unclassified' }
SGObserver >> snapShot: thisRecord [
	observations add: thisRecord copy
]

{ #category : #'as yet unclassified' }
SGObserver >> snapShot: thisRecord for: anObject [
	observations add: thisRecord copy; theClass: anObject class
]

{ #category : #'as yet unclassified' }
SGObserver >> uninstallObservers [
	targets do: [ :aClass | self uninstallObserversFor: aClass ]
]

{ #category : #'as yet unclassified' }
SGObserver >> uninstallObserversFor: aClass [
	aClass removeInstVarNamed: 'smallGenState'
]

{ #category : #'instance creation' }
SGObserver >> with: aConfig [
	self initialize.
	config := aConfig
]
