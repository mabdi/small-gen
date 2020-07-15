Extension { #name : #UndefinedObject }

{ #category : #'*SmallGen' }
UndefinedObject >> smallgen_state [
	^ (SGPrimitive with: self) dictionaryRepresentation 
]
