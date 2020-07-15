Extension { #name : #Class }

{ #category : #'*SmallGen' }
Class >> smallgen_state [
	^ (SGClassPrimitive with: self) dictionaryRepresentation 
]
