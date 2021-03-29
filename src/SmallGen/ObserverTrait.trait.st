Trait {
	#name : #ObserverTrait,
	#instVars : [
		'smallgen_state'
	],
	#category : #'SmallGen-Observation'
}

{ #category : #'as yet unclassified' }
ObserverTrait >> smallgen_enterMethod: aSelector args: args [ smallgen_state ifNil: [smallgen_state := SGHistory with: self]. ^ smallgen_state enterMethod: aSelector on: self  args: args
]

{ #category : #'as yet unclassified' }
ObserverTrait >> smallgen_exitMethod: aSelector args: args result: aResult preCallData: preCallData [ smallgen_state ifNil: [smallgen_state := SGHistory with: self]. ^ smallgen_state exitMethod: aSelector on: self args: args result: aResult preCallData: preCallData
]

{ #category : #accessing }
ObserverTrait >> smallgen_state [ smallgen_state ifNil: [smallgen_state := SGHistory with: self]. ^ smallgen_state dictionaryRepresentation
]

{ #category : #'as yet unclassified' }
ObserverTrait >> smallgen_state_identity [ smallgen_state ifNil: [smallgen_state := SGHistory with: self]. ^ smallgen_state state_identity
]

{ #category : #'as yet unclassified' }
ObserverTrait >> smallgen_state_identity: depth [
	smallgen_state ifNil: [ smallgen_state := SGHistory with: self ].
	^ smallgen_state state_identity
]
