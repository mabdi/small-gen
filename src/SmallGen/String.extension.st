Extension { #name : #String }

{ #category : #'*SmallGen' }
String >> smallgen_state [
	^ (SGPrimitive with: self) dictionaryRepresentation 
]

{ #category : #'*SmallGen' }
String >> smallgen_state_identity:depth [
	^ self asString
]
