Extension { #name : #Boolean }

{ #category : #'*SmallGen' }
Boolean >> smallgen_state [
	^ (SGPrimitive with: self) dictionaryRepresentation 
]

{ #category : #'*SmallGen' }
Boolean >> smallgen_state_identity [
	^ self
]
