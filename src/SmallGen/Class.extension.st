Extension { #name : #Class }

{ #category : #'*SmallGen' }
Class >> smallgen_state [
	^ (SGClassPrimitive with: self) dictionaryRepresentation 
]

{ #category : #'*SmallGen' }
Class >> smallgen_state_identity [
	^ self name asSymbol 
]
