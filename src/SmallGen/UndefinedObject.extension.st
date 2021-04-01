Extension { #name : #UndefinedObject }

{ #category : #'*SmallGen' }
UndefinedObject >> smallgen_state [
	^ (SGPrimitive with: self) dictionaryRepresentation 
]

{ #category : #'*SmallGen' }
UndefinedObject >> smallgen_state_identity:depth [
	^ nil
]
