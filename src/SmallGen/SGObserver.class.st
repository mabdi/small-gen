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
SGObserver >> installMetaLinkOn: aMethodAst [
	| link |
	link := MetaLink new metaObject: self; selector: #linkBeforMethodCall; control: #before; argument: #(object).
	aMethodAst link: link
]

{ #category : #'as yet unclassified' }
SGObserver >> installObservers [
	targets do: [ :aClass | self installObserversFor: aClass ]
]

{ #category : #'as yet unclassified' }
SGObserver >> installObserversFor: aClass [
	aClass addInstVarNamed: 'smallGenState'.
	aClass methods do: [ :aMethod | self installMetaLinkOn: aMethod ast ]
]

{ #category : #'as yet unclassified' }
SGObserver >> linkBeforMethodCall: anObject [
	self halt.
]

{ #category : #'instance creation' }
SGObserver >> observe [
	self installObservers.
	sampleCode
		ensure: [ self uninstallObservers ]
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
