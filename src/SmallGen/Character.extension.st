Extension { #name : #Character }

{ #category : #'*SmallGen' }
Character >> smallgen_state [
	^ (SGPrimitive with: self) dictionaryRepresentation
]

{ #category : #'*SmallGen' }
Character >> smallgen_state_identity [
	^ self
]
