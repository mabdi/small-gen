Class {
	#name : #SmallGen,
	#superclass : #Object,
	#instVars : [
		'config',
		'targets'
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
		          generate
]

{ #category : #example }
SmallGen class >> initializeWith: aConfig [
	^ self new initializeWith: aConfig
]

{ #category : #initialization }
SmallGen >> generate [
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

{ #category : #accessing }
SmallGen >> target:aTargetClass [
	self targets add: aTargetClass 
]
