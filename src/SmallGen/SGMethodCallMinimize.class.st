"
I am a copy of class SGSimilarMinimize. This comment is copied from there, and might not be entirely accurate

Please comment me using the following template inspired by Class Responsibility Collaborator (CRC) design:

For the Class part:  State a one line summary. For example, ""I represent a paragraph of text"".

For the Responsibility part: Three sentences about my main responsibilities - what I do, what I know.

For the Collaborators Part: State my main collaborators and one line about how I interact with them. 

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	config:		<Object>
	minimizedList:		<Object>
	observations:		<Object>


    Implementation Points
"
Class {
	#name : #SGMethodCallMinimize,
	#superclass : #Object,
	#instVars : [
		'config',
		'observations',
		'observationTargets'
	],
	#category : #SmallGen
}

{ #category : #'as yet unclassified' }
SGMethodCallMinimize class >> initWith: config [
	^ self new with: config
]

{ #category : #testing }
SGMethodCallMinimize >> isOkToDeleteCallRecord: callRecord inScope: inScope [
	| okToDelete stateUpdated deepCoverage isVoid |
	stateUpdated := callRecord receiverLastState
		~= callRecord receiverCurrentState.
	deepCoverage := callRecord coverage 
		ifNil: [ false ]
		ifNotNil: [ callRecord coverage size > 1 ].
	isVoid := callRecord isVoidReturn.
	okToDelete := stateUpdated
		ifTrue: [ false ]
		ifFalse: [ inScope
				ifTrue: [ deepCoverage
						ifTrue: [ isVoid ]
						ifFalse: [ true ] ]
				ifFalse: [ true ] ].
	okToDelete
		ifFalse: [ callRecord args do: [ :item | self minimizeHistory: item ] ].
	^ okToDelete
]

{ #category : #'window management' }
SGMethodCallMinimize >> minimize [
	observations
		keysDo: [ :target | 
			| histories |
			
			histories := observations at: target.
			histories do: [ :history | self minimizeHistory: history ] ]
]

{ #category : #'window management' }
SGMethodCallMinimize >> minimizeHistory: history [
	^ history
		records:
			(history records reject: [ :item | self isOkToDeleteCallRecord: item inScope: history inScope ]);
		yourself
]

{ #category : #'as yet unclassified' }
SGMethodCallMinimize >> minimizerFor: observationData [
	observations := Dictionary new.
	observationData
		keysDo: [ :key | 
			observations
				at: key
				put: ((observationData at: key)
				collect: [ :h | h copy ]) ].
	self minimize.
	^ observations
]

{ #category : #'instance creation' }
SGMethodCallMinimize >> with: aConfig [
	self initialize.
	config := aConfig
]
