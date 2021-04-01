Trait {
	#name : #ObserverTrait,
	#instVars : [
		'smallgen_state'
	],
	#category : #'SmallGen-Observation'
}

{ #category : #'as yet unclassified' }
ObserverTrait >> smallgen_enterMethod: aSelector args: args [
	self smallgen_state_init.
	SGObserver
		logMe:
			(' -> '
				join:
					{'enter'.
					self class name.
					aSelector}).
	^ smallgen_state enterMethod: aSelector on: self args: args
]

{ #category : #'as yet unclassified' }
ObserverTrait >> smallgen_exitMethod: aSelector args: args result: aResult preCallData: preCallData [
	self smallgen_state_init.
	SGObserver
		logMe:
			(' -> '
				join:
					{'exit'.
					self class name.
					aSelector}).
	^ smallgen_state
		exitMethod: aSelector
		on: self
		args: args
		result: aResult
		preCallData: preCallData
]

{ #category : #accessing }
ObserverTrait >> smallgen_state [
	self smallgen_state_init.
	^ smallgen_state dictionaryRepresentation
]

{ #category : #'as yet unclassified' }
ObserverTrait >> smallgen_state_identity [
	self smallgen_state_init.
	^ smallgen_state state_identity
]

{ #category : #'as yet unclassified' }
ObserverTrait >> smallgen_state_identity: depth [
	self smallgen_state_init.
	^ smallgen_state state_identity: depth
]

{ #category : #accessing }
ObserverTrait >> smallgen_state_init [
	smallgen_state ifNil: [ smallgen_state := SGHistory with: self ]
]
