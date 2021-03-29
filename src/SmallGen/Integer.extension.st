Extension { #name : #Integer }

{ #category : #'*SmallGen' }
Integer >> smallgen_state [
	^ (SGPrimitive with: self) dictionaryRepresentation 
]

{ #category : #'*SmallGen' }
Integer >> smallgen_state_identity: depth [
	^ self
]
