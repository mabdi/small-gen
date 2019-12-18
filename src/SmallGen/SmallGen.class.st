Class {
	#name : #SmallGen,
	#superclass : #Object,
	#instVars : [
		'config',
		'targets',
		'sampleCode',
		'observations',
		'targetsCapture'
	],
	#category : #SmallGen
}

{ #category : #example }
SmallGen class >> example [
	| config result |
	config := SGConfig new.
	result := (SmallGen initializeWith: config)
		          target: SmallBank;
		          target: SmallBank2;
					 sampleCode: [ SmallBank example. SmallBank2 example ];
		          generate
]

{ #category : #example }
SmallGen class >> example2 [
	
	(self initializeWith: SGConfig new)
		          target: SAAssertGenerator;
		targetsCapture: { SAAssertGenerator. SAAssertGenerator class. SAObservationFalse class . SAObservationTrue class. SAObservationNil class. SAObservationFraction class. SAObservationPrimitive  class. SAObservationCollection class. SAObservationObject class. SAObservationValue class. SAObservationAbstract class };
					 sampleCode: [ SmallAmp example ];
		          generate
]

{ #category : #example }
SmallGen class >> initializeWith: aConfig [
	^ self new initializeWith: aConfig
]

{ #category : #initialization }
SmallGen >> generate [
	self observe.
	self generateUsingObservations.
"	self initState.
	self installObservers.
	sampleCode
		ensure: [ self uninstallObsevers ].
	self generate"
]

{ #category : #'as yet unclassified' }
SmallGen >> generateUsingObservations [
]

{ #category : #'as yet unclassified' }
SmallGen >> getObserver [
	^ self observerClass initWith: config
]

{ #category : #initialization }
SmallGen >> initialize [ 
	targets := OrderedCollection new
]

{ #category : #initialization }
SmallGen >> initializeWith: aConfig [
	self initialize. 
	config := aConfig.
	
]

{ #category : #initialization }
SmallGen >> observe [
	observations := self getObserver
		                generateObservationFor: targets
			targetsCapture: targetsCapture                 
		byRunning: sampleCode
]

{ #category : #'as yet unclassified' }
SmallGen >> observerClass [
	^ SGObserver 
]

{ #category : #accessing }
SmallGen >> sampleCode: aCode [
	sampleCode:= aCode
]

{ #category : #accessing }
SmallGen >> target: aTargetClass [
	 targets add: aTargetClass
]

{ #category : #accessing }
SmallGen >> targetsCapture: aClassList [
	targetsCapture:= aClassList
]
