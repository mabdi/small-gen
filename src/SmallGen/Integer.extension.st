Extension { #name : #Integer }

{ #category : #'*SmallGen' }
Integer >> smallgen_state [
	^ (SGPrimitive with: self) dictionaryRepresentation 
]
