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
	targets := aListOfClasses.
	observations := self getAnObservation.
	self observe.
	^ observations
]

{ #category : #'instance creation' }
SGObserver >> getAnObservation [
	^ OrderedCollection new
]

{ #category : #'as yet unclassified' }
SGObserver >> installObservers [
]

{ #category : #'instance creation' }
SGObserver >> observe [
	self installObservers.
	sampleCode
		ensure: [ self uninstallObsevers ].
]

{ #category : #'as yet unclassified' }
SGObserver >> uninstallObsevers [
]

{ #category : #'instance creation' }
SGObserver >> with: aConfig [
	self initialize.
	config := aConfig
]
